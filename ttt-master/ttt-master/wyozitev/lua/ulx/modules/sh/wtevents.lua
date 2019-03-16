local CATEGORY_NAME = "TTT Events"

-- Ugly but required because of addon load order

local function CreateULXCommands()
	function ulx.queuewtevent( calling_ply, id, rounds )
		for i=1, rounds do wyozitev.QueueEvent(id, calling_ply) end
		ulx.fancyLogAdmin( calling_ply, "#A queued a TTT Event #s for #d rounds. Queue: #s", id, rounds, wyozitev.FormattedEventQueue() )
	end

	local queuewtevent = ulx.command( CATEGORY_NAME, "ulx queuewtevent", ulx.queuewtevent, "!queuewtevent" )
	queuewtevent:addParam{ type=ULib.cmds.StringArg, completes=wyozitev.EventsAC, hint="event id", error="invalid event \"%s\" specified", ULib.cmds.restrictToCompletes }
	queuewtevent:addParam{ type=ULib.cmds.NumArg, hint="rounds", min=1, default=1, max=10, ULib.cmds.optional, ULib.cmds.round }
	queuewtevent:defaultAccess( ULib.ACCESS_ADMIN )
	queuewtevent:help( "Queues a TTT Event to happen next round." )

	function ulx.cancelwtevent( calling_ply, id )
		wyozitev.CancelEvent()
		ulx.fancyLogAdmin( calling_ply, "#A cancelled TTT event. Remaining queue: #s", wyozitev.FormattedEventQueue() )
	end

	local cancelwtevent = ulx.command( CATEGORY_NAME, "ulx cancelwtevent", ulx.cancelwtevent, "!cancelwtevent" )
	cancelwtevent:defaultAccess( ULib.ACCESS_ADMIN )
	cancelwtevent:help( "Cancels the last added TTT Event." )

	function ulx.printwteventqueue( calling_ply )
		calling_ply:ChatPrint("Event Queue: " .. wyozitev.FormattedEventQueue())
	end

	local printwteventqueue = ulx.command( CATEGORY_NAME, "ulx printwteventqueue", ulx.printwteventqueue, "!printwteventqueue" )
	printwteventqueue:defaultAccess( ULib.ACCESS_ADMIN )
	printwteventqueue:help( "Clears the whole TTT Event queue." )

	function ulx.clearwteventqueue( calling_ply )
		wyozitev.ClearEvents()
		ulx.fancyLogAdmin( calling_ply, "#A cleared TTT event queue.")
	end

	local clearwteventqueue = ulx.command( CATEGORY_NAME, "ulx clearwteventqueue", ulx.clearwteventqueue, "!clearwteventqueue" )
	clearwteventqueue:defaultAccess( ULib.ACCESS_ADMIN )
	clearwteventqueue:help( "Clears the whole TTT Event queue." )
end

hook.Add("WyotiTEVEventsLoaded", "WyoziTEVAddULX", CreateULXCommands)

-- Already loaded, weird but let's roll with it
if wyozitev and wyozitev.EventsAC then
	CreateULXCommands()
end