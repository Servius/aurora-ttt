local EVENT = {}

EVENT.KarmaLock = true

function EVENT:Prepare()
	self:AddHook("WyoziTEVSelectRoles", self.SelectRoles)
	self:EventNotification()
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

wyozitev.RegisterEvent("teamdm", EVENT)