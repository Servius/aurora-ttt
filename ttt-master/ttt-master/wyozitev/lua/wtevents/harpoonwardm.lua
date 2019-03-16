local EVENT = {}

EVENT.KarmaLock = true

function EVENT:Prepare()
	self:AddHook("WyoziTEVSelectRoles", self.SelectRoles)
	self:AddHook("PlayerCanPickupWeapon", self.PreventWepPickup)
	self:AddHook("WyoziTEVOverrideWin", self.OverrideWin)

	self:SmallNotification(_, {
		"All players get harpoons!",
		"Kill anyone you see!",
		"Karma won't be affected during this round."
	}, 5)

	self:EventNotification()
end

function EVENT:PreventWepPickup(ply, wep)
	return wep:GetClass() == "weapon_ev_harpoon"
end

function EVENT:OverrideWin()
	local plycount = 0
	for _,ply in pairs(player.GetAll()) do
		if ply:IsTerror() and ply:Alive() then plycount = plycount+1 end
	end
	return plycount > 1 and WIN_NONE or WIN_TRAITOR
end

function EVENT:SelectRoles()
	for i, ply in pairs(self:GetPlayers()) do
		ply:SetRole( ROLE_TRAITOR )
		ply:SetDefaultCredits()
	end
	return true
end


function EVENT:Begin()
	for _,ply in pairs(player.GetAll()) do
		if not ply:IsSpec() then
			ply:StripWeapons()
			local dbwep = ply:Give("weapon_ev_harpoon")
		end
	end
end

wyozitev.RegisterEvent("HarpoonWar Free-for-All", EVENT)