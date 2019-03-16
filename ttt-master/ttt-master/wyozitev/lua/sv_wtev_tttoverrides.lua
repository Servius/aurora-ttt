
util.AddNetworkString("wtev_clevent")

local function ActivateEvent(event, is_automatic)
	if wyozitev.ActiveEvent then
		wyozitev.ActiveEvent:End()
	end

	event:Prepare()
	wyozitev.ActiveEvent = event

	CustomMsg(_, "Preparing " .. (is_automatic and "automatic" or "") .. " event " .. event.Id, Color(200, 255, 200))

	if event.RequireClientside then
		net.Start("wtev_clevent")
			net.WriteString(event.Id)
		net.Broadcast()
	end
end

hook.Add("TTTPrepareRound", "WyoziTEVInitializeEvent", function()
	local ev = table.remove(wyozitev.EventQueue, 1)
	if ev then
		local event = wyozitev.NewEvent(ev.Id)
		if not event then return end
		ActivateEvent(event)
		return
	end

	local rounds_elapsed = GetConVar("ttt_round_limit"):GetInt() - GetGlobalInt("ttt_rounds_left", 6) + 1
	wyozitev.Debug("Checking automatic events (rounds elapsed: " .. rounds_elapsed .. ")")

	-- No queued event, let's see if automatic events should happen
	for _,ae in pairs(wyozitev.AutomaticEvents) do
		local should_play = true

		if ae.RoundStride and (rounds_elapsed % ae.RoundStride) ~= 0 then
			should_play = false
		end
		if ae.RoundFilter and not ae.RoundFilter() then
			should_play = false
		end

		if should_play then
			local eventid = ae.Event
			if type(eventid) == "table" then
				eventid = table.Random(eventid)
			end
			local event = wyozitev.NewEvent(eventid)
			if event then ActivateEvent(event) break end
		end
	end
end)

local traitor_queue = {}
concommand.Add("wyozitev_dbgtraitor", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	table.insert(traitor_queue, ply)
end)

hook.Add("TTTCheckForWin", "WyoziTEVCheckWin", function()
	return hook.Call("WyoziTEVOverrideWin", GAMEMODE)
end)

-- Dirty hooks aka the hooks that require hacky tricks to get access to
hook.Add("InitPostEntity", "WyoziTEVDirtyHooks", function()
	local oldselect = SelectRoles
	if oldselect then
		function SelectRoles()
			local isel = hook.Call("WyoziTEVSelectRoles", GAMEMODE)
			if not isel then
				oldselect()
				table.foreach(traitor_queue, function(k,v) v:SetRole(ROLE_TRAITOR) end)
			end
		end
	end
	
	local oldcfw = CheckForWin
	if oldcfw then
		function CheckForWin()
			return hook.Call("WyoziTEVOverrideWin", GAMEMODE) or oldcfw()
		end
	else -- Assume we're using newer version which has an actual hook for this
		hook.Add("TTTCheckForWin", "WyoziTEVCheckForWin", function()
			return hook.Call("WyoziTEVOverrideWin", GAMEMODE)
		end)
	end

	local oldkie = KARMA and KARMA.IsEnabled
	if oldkie then
		function KARMA.IsEnabled()
			if wyozitev.ActiveEvent and wyozitev.ActiveEvent.KarmaLock then return false end
			return oldkie()
		end
	end
	
	local pmeta = FindMetaTable("Player")
	
	function pmeta:SetSpeed(slowed)
		local mul = hook.Call("WyoziTEVPlayerSpeed", GAMEMODE, self) or 1

		local gmul = (hook.Call("WyoziGenericSpeedMul", GAMEMODE, self) or 1)
		if gmul ~= 1 then
			--MsgN("Generic mul for ", self, ": ", gmul)
		end
		mul = mul * gmul
		
		if slowed then
			self:SetWalkSpeed(120 * mul)
			self:SetRunSpeed(120 * mul)
			self:SetMaxSpeed(120 * mul)
		else
			self:SetWalkSpeed(220 * mul)
			self:SetRunSpeed(220 * mul)
			self:SetMaxSpeed(220 * mul)
		end
	end
	
end)