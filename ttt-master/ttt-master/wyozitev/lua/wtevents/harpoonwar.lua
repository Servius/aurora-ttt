local EVENT = {}

function EVENT:Prepare()
	self:AddHook("WyoziTEVSelectRoles", self.SelectRoles)
	self:AddHook("PlayerCanPickupWeapon", self.PreventWepPickup)

	self:SmallNotification(_, {
		"All players get harpoons!",
		"Detectives vs Traitors!",
		"Be careful not to kill your teammates."
	}, 5)

	self:EventNotification()
end

function EVENT:PreventWepPickup(ply, wep)
	return wep:GetClass() == "weapon_ev_harpoon"
end

function EVENT:SelectRoles()
	for i, ply in pairs(self:GetPlayers()) do
		if (i % 2) == 0 then
			ply:SetRole( ROLE_DETECTIVE )
		else
			ply:SetRole( ROLE_TRAITOR )
		end
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

wyozitev.RegisterEvent("Team HarpoonWar", EVENT)