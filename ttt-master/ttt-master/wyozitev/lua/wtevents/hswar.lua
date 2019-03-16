local EVENT = {}

function EVENT:Prepare()
	self:EventNotification()

	self:SmallNotification(_, {
		"Normal TTT, but only headshots count!",
	}, 5)

	self:AddHook("ScalePlayerDamage", self.ScaleDamages)
	self:AddHook("PlayerCanPickupWeapon", self.PreventWepPickup)
end

function EVENT:PreventWepPickup(ply, wep)
	return wep:GetClass() == "weapon_zm_revolver"
end

function EVENT:ScaleDamages(ply, hitgroup, dmg)
	if hitgroup ~= HITGROUP_HEAD then dmg:ScaleDamage(0) end
end

function EVENT:Begin()
	for _,ply in pairs(player.GetAll()) do
		if not ply:IsSpec() then
			ply:StripWeapons()
			local deagle = ply:Give("weapon_zm_revolver")
			ply:SetAmmo(1000, deagle:GetPrimaryAmmoType())
		end
	end
end

wyozitev.RegisterEvent("headshotwar", EVENT)