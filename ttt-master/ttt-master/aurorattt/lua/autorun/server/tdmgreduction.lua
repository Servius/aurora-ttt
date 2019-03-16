hook.Add("EntityTakeDamage", "TraitorDamageReduction", function(ent, dmginfo)
	if GetRoundState() == ROUND_ACTIVE and ent:IsPlayer() and ent:IsActive() and ent:IsTraitor() and dmginfo:GetAttacker() != ent and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():IsTraitor() and dmginfo:GetAttacker():IsActive() then
		dmginfo:ScaleDamage(0.5)
	end
end)