local EVENT = {}

if SERVER then

	function EVENT:Prepare()
		self:AddHook("WyoziTEVSelectRoles", self.ShuffleRolePicker)
		self:EventNotification()

		self:SmallNotification(_, {
			"1. 50% Traitors, 50% Detectives",
			"2. Kill members of the other role",
			"3. Killing someone converts them to your role",
			"4. Everyone has three lives!"
		}, 15)
	end

	function EVENT:Begin()
		self:AddHook("PlayerDeath")
		self:AddHook("WKCShow")
		for _,ply in pairs(self:GetPlayers()) do
			ply.ShuffleLives = 3
		end
	end

	function EVENT:WKCShow(ply)
		return false
	end

	function EVENT:ShuffleRolePicker()
		for i, ply in pairs(self:GetPlayers()) do
			if (i % 2) == 0 then
				ply:SetRole( ROLE_DETECTIVE )
			else
				ply:SetRole( ROLE_TRAITOR )
			end
			--ply:SetDefaultCredits()
		end
		return true
	end

	local function OppositeRole(role)
		return role == ROLE_TRAITOR and ROLE_DETECTIVE or ROLE_TRAITOR
	end

	local wepoptions = {
		"weapon_zm_shotgun",
		"weapon_zm_mac10",
		"weapon_ttt_m16",
		"weapon_zm_sledge"
	}

	function EVENT:PlayerDeath(victim, weapon, killer)
		if IsValid(killer) and killer:IsPlayer() then
			killer:AddCredits(1)
		end

		local myrole = victim:GetRole()

		victim.ShuffleLives = (victim.ShuffleLives or 1) - 1
		if victim.ShuffleLives > 0 then
			timer.Simple(0, function()
				if IsValid(victim.server_ragdoll) then
					victim.server_ragdoll:Remove()
				end

				victim:UnSpectate()
				victim:SetTeam(TEAM_TERROR)

				victim:StripAll()

				victim:Spawn()

				victim:SetMoveType(MOVETYPE_WALK)

				local newrole
				if IsValid(killer) and killer:IsPlayer() then
					newrole = (myrole == killer:GetRole()) and OppositeRole(myrole) or killer:GetRole()
				else
					newrole = OppositeRole(myrole)
				end
				victim:SetRole(newrole)

				victim:Give(table.Random(wepoptions))

				local livlev = "You have " .. tostring(victim.ShuffleLives) .. " lives left."

				self:SmallNotification(victim, livlev)
				victim:ChatPrint(livlev)

				SendFullStateUpdate()
			end)
		end
	end
else

	function EVENT:Begin()
		self:AddHook("HUDPaint", self.DrawShuffleMarkers)
	end

	local indicator_mat = Material("icon32/zoom_extend.png")
	local indicator_col = Color(255, 255, 255, 255)
	
	function EVENT:DrawShuffleMarkers()
		local client = LocalPlayer()
		local plys = player.GetAll()
		
		if client:GetDetective() then
			local dir = client:GetForward() * -1
			render.SetMaterial(indicator_mat)
			for _,ply in pairs(plys) do
				if ply:Alive() and ply:IsActiveDetective() and ply ~= client then
					local pos = ply:GetPos()
					pos.z = pos.z + 74
					
						render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)	
				end
			end	
		end
	end

end

EVENT.RequireClientside = true

wyozitev.RegisterEvent("shuffle", EVENT)