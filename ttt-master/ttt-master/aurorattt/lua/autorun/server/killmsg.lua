AddCSLuaFile("autorun/client/cl_killmsg.lua")
print("Aurora Kill-Message Script Loaded")

function PrintKillMsgOnDeath(victim, wep, attacker)
	if GetRoundState() == ROUND_ACTIVE then
		print(attacker)
		if !attacker:IsPlayer() then
			umsg.Start("KillMsg", victim)
				umsg.Char(-1)
			umsg.End()
		else
			umsg.Start("KillMsg", victim)
				umsg.Entity(attacker)
				umsg.Char(attacker:GetRole() + 1)
			umsg.End()
		end
	end
end

hook.Add("PlayerDeath", "ChatKillMsg", PrintKillMsgOnDeath)
