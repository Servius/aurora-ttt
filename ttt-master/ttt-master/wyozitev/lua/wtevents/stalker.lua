local EVENT = {}

if SERVER then

	EVENT.KarmaLock = true

	function EVENT:Prepare()
		self:EventNotification()

		self:SmallNotification(_, {
			"Traitors are invisible stalkers!",
			"Traitors have knives and can longjump.",
			"Innocents need to cooperate and kill the traitors.",
		}, 15)
	end

	function EVENT:ModWepToPushVisOnAtck(wep)
		local oldpa = wep.PrimaryAttack
		wep.PrimaryAttack = function(mself)
			oldpa(mself)
			
			local owner = mself.Owner
			if not IsValid(owner) or owner:GetRole() ~= ROLE_TRAITOR then return end
			
			self:PushPlyVis(owner, 1.5)
		end
	end

	function EVENT:GiveKnife(ply)
		local wep = ply:Give("weapon_ttt_knife")
		wep.AllowDrop = false
		wep.Primary.Damage = 50
		wep.OnDrop = function(self) -- Remove knife on drop
			self:Remove()
		end
		wep.SecondaryAttack = function() end
		self:ModWepToPushVisOnAtck(wep)

		timer.Simple(0.1, function()
			if not IsValid(ply) then return end
			ply:SelectWeapon("weapon_ttt_knife") -- meh
		end)
	end

	local allowed_weapons = {
		"weapon_ttt_knife",
		"weapon_zm_carry",
		"weapon_zm_improvised"
	}

	function EVENT:Begin()
		for _,ply in pairs(player.GetAll()) do
			ply:Flashlight( false )
			if ply:GetRole() == ROLE_TRAITOR then
			
				ply:SetHealth(150)
				ply:SetColor(Color(0, 0, 255))

				ply:StripWeapons()
				
				self:GiveKnife(ply)
				for _,aw in pairs(allowed_weapons) do
					if aw ~= "weapon_ttt_knife" then -- Handled in self.GiveKnife
						local wep = ply:Give(aw)
						if IsValid(wep) then self:ModWepToPushVisOnAtck(wep) end
					end
				end
				
				-- Give player disguise so their name is not visible
				timer.Simple(0.5, function()
					 if not IsValid(ply) then return end
					
					ply:AddEquipmentItem( EQUIP_DISGUISE )
					ply:SetNWBool("disguised", true)
					self:SetPlayerInvisibility(ply, true)
				end)

				self:HidePSItems(ply)
				
			end
		end
		self:AddHook("WyoziTEVPlayerSpeed", self.ModifyStalkersSpeed)
		self:AddHook("PlayerSwitchWeapon", self.PreventStalkerWepSwitch)
		self:AddHook("Think")
		self:AddHook("EntityTakeDamage")
		self:AddHook("KeyPress")
		self:AddHook("SetupPlayerVisibility")
	end

	function EVENT:End()
		self:CleanUpHooks()
		for _,ply in pairs(player.GetAll()) do
			ply.PushPlayerVis = nil
			self:SetPlayerInvisibility(ply, false)
			ply:SetColor(Color(255, 255, 255))
		end
	end
	
	function EVENT:SetupPlayerVisibility(ply)
		if ply:GetRole() == ROLE_TRAITOR then
			for _,aply in pairs(player.GetAll()) do
				AddOriginToPVS( aply:GetPos() )
			end
		end
	end

	function EVENT:ModifyStalkersSpeed(ply)
		return ply:GetRole() == ROLE_TRAITOR and 1.45 or 1
	end

	function EVENT:PreventStalkerWepSwitch(ply, oldwep, newwep)
		if ply:GetRole() == ROLE_TRAITOR and not table.HasValue(allowed_weapons, newwep:GetClass()) then
			timer.Simple(0, function()
				if not IsValid(ply) then return end
				ply:SelectWeapon("weapon_ttt_knife")
				ply.PushPlayerVis = ply.PushPlayerVis or 0 -- If no ply.PushPlayerVis, forces resetting invisibility in think hook.
														    --  Doing it this way prevents us from having to check for pushplyvis manually.
			end)
		end
	end

	-- Longjump stuff
	function EVENT:KeyPress(ply, key)
		if (ply:Alive() && key == IN_JUMP && ply:WaterLevel() <= 1 && ply:IsOnGround()) then
			if (ply:GetRole() == ROLE_TRAITOR and ply:KeyDown(IN_DUCK) && ply:KeyDown(IN_FORWARD) && ply:GetVelocity():Length() >= 200) then
				ply:SetVelocity((ply:GetUp() * 300) + (ply:GetForward() * 425))
			end
		end
	end

	function EVENT:PushPlyVis(ply, vis)
		if not ply.PushPlayerVis then
			self:SetPlayerInvisibility(ply, false)
		end
		ply.PushPlayerVis = math.max((ply.PushPlayerVis or 0), CurTime() + vis)
	end

	function EVENT:Think()
		for _,ply in pairs(player.GetAll()) do
			if ply:GetRole() == ROLE_TRAITOR and not ply:HasWeapon("weapon_ttt_knife") then
				self:GiveKnife(ply)
			end
			if ply.PushPlayerVis and ply.PushPlayerVis < CurTime() then
				self:SetPlayerInvisibility(ply, true)
				ply.PushPlayerVis = nil
			end
		end
	end

	function EVENT:SetPlayerInvisibility(ply, invis)
		local wep = ply:GetActiveWeapon()

		if invis then
			ply:DrawShadow(false)
			ply:SetMaterial("models/effects/vol_light001")
			ply:SetRenderMode(RENDERMODE_TRANSALPHA)
			ply:Fire("alpha", 0, 0)
			if IsValid(wep) then
				wep:SetRenderMode(RENDERMODE_TRANSALPHA)
				wep:Fire("alpha", 0, 0)
				wep:SetMaterial("models/effects/vol_light001")
			end
		else
			ply:DrawShadow(true)
			ply:SetMaterial("")
			ply:SetRenderMode(RENDERMODE_NORMAL)
			ply:Fire("alpha", 255, 0)
			if IsValid(wep) then
				wep:SetRenderMode(RENDERMODE_NORMAL)
				wep:Fire("alpha", 255, 0)
				wep:SetMaterial("")
			end
		end
	end

	function EVENT:EntityTakeDamage(targ, dmginfo)
		if (targ:IsPlayer() and targ:GetRole() == ROLE_TRAITOR ) then
			if (dmginfo:IsDamageType(DMG_FALL)) then
				dmginfo:ScaleDamage(0.3)
			else
				self:PushPlyVis(targ, 0.15)
			end
		end
	end

end
if CLIENT then

	local wtev_halos = CreateConVar("wyozitev_stalker_halos", "0", FCVAR_ARCHIVE)

	function EVENT:Begin()
		self:AddHook("PreDrawHalos", self.DrawStalkerWH)
	end

	function EVENT:DrawStalkerWH()
		if not wtev_halos:GetBool() then return end
		
		local me = LocalPlayer()
		if me:IsActiveTraitor() then
		
			local reds = {}
			local greens = {}
			for _,ply in pairs( player.GetAll() ) do
				if not ply:IsTerror() or not ply:Alive() then continue end
				
				if ply:IsActiveTraitor() then
					table.insert(reds, ply)
				else
					table.insert(greens, ply)
				end
			end
			
			effects.halo.Add( reds, COLOR_RED, _, _, _, true, true )
			effects.halo.Add( greens, COLOR_GREEN, _, _, _, true, true )
			
		end
	end

end

EVENT.RequireClientside = true

wyozitev.RegisterEvent("stalker", EVENT)