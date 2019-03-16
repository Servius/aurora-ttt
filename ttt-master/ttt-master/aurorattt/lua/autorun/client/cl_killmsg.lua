local teams = {
	[0] = {"an", Color(0, 200, 0, 255), " innocent."},
	[1] = {"a", Color(180, 50, 40, 255), " traitor."},
	[2] = {"a", Color(50, 60, 180, 255), " detective."}
}

function PrintKillMsg(um)
	local p = um:ReadEntity()
	local team = um:ReadChar()
	team = team - 1
	if team ~= -1 then
		chat.AddText(color_white, "You were killed by ", teams[team][2], p:Nick(), color_white, " who was ", unpack( teams[team] ))
	else
		chat.AddText(color_white, "You were killed by the world.")
	end
end

usermessage.Hook("KillMsg", PrintKillMsg)