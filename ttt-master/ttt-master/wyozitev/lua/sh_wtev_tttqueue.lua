
wyozitev.EventQueue = {}

function wyozitev.QueueEvent(id, queued_by)
	table.insert(wyozitev.EventQueue, {Id = id, By = queued_by})
end
function wyozitev.CancelEvent()
	table.remove(wyozitev.EventQueue, 1)
end
function wyozitev.ClearEvents()
	table.Empty(wyozitev.EventQueue)
end
function wyozitev.FormattedEventQueue()
	local ret = {}
	for k,v in pairs(wyozitev.EventQueue) do
		if k > 9 then
			table.insert(ret, "etc..")
			break
		end
		table.insert(ret, v.Id)
	end
	return "[" .. table.concat(ret, ", ") .. "]"
end

if CLIENT then
	net.Receive("wtev_clevent", function()
		local id = net.ReadString()
		
		local event = wyozitev.NewEvent(id)
		if not event then return end

		if wyozitev.ActiveEvent then
			wyozitev.ActiveEvent:End()
		end

		event:Prepare()
		wyozitev.ActiveEvent = event
	end)
end

hook.Add("TTTBeginRound", "WyoziTEVBeginEvent", function()
	if wyozitev.ActiveEvent then
		wyozitev.ActiveEvent:Begin()
	end
end)
hook.Add("TTTEndRound", "WyoziTEVEndEvent", function()
	if wyozitev.ActiveEvent then
		wyozitev.ActiveEvent:End()
		wyozitev.ActiveEvent = nil
	end
end)