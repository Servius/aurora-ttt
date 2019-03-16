local EVENT = {}

function EVENT:Prepare()
	self:AddHook("WyoziTEVSelectRoles", self.SelectRoles)
	self:AddHook("PlayerCanPickupWeapon", self.PreventWepPickup)

	self:SmallNotification(_, {
		"Detectives vs traitors dodgeball!"
	}, 5)

	self:EventNotification()
end

function EVENT:PreventWepPickup(ply, wep)
	return wep:GetClass() == "wtev_dodgeballwep"
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
		ply:StripWeapons()
		local dbwep = ply:Give("wtev_dodgeballwep")
		if ply:GetRole() == ROLE_DETECTIVE then
			dbwep:SetBallColor(Vector(0, 0, 1))
		elseif ply:GetRole() == ROLE_TRAITOR then
			dbwep:SetBallColor(Vector(1, 0, 0))
		end
	end
end

wyozitev.RegisterEvent("dodgeball", EVENT)