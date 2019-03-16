
local function DoUlxCommandsExist()
	return ulx and ulx.queuewtevent
end

concommand.Add("wyozitev_queuewtevent", function(ply, cmd, args)
	if not SERVER then return end
	if ply:IsValid() and not ply:IsAdmin() then return ply:ChatPrint("not allowed") end
	if DoUlxCommandsExist() then return ply:ChatPrint("use 'ulx queuewtevent'") end

	local event = args[1]
	if not wyozitev.Events[event] then return ply:ChatPrint("event doesnt exist!") end

	local rounds = 1
	for i=1, rounds do wyozitev.QueueEvent(event, ply) end

	CustomMsg(_, "Queued TTT Event " .. event, Color(255, 127, 0))
end, function(cmd, args)
	local t = {}
	for _,v in pairs(wyozitev.EventsAC) do
		table.insert(t, "wyozitev_queuewtevent " .. v)
	end
	return t
end)

concommand.Add("wyozitev_cancelwtevent", function(ply, cmd, args)
	if not SERVER then return end
	if ply:IsValid() and not ply:IsAdmin() then return ply:ChatPrint("not allowed") end
	if DoUlxCommandsExist() then return ply:ChatPrint("use 'ulx cancelwtevent'") end

	wyozitev.CancelEvent()
end)
