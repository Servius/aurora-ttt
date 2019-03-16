wyozitev.Events = {}

local wtev_meta = {}

function wtev_meta:AddHook(hooktype, callbackfunc)
	callbackfunc = callbackfunc or self[hooktype]
	hook.Add(hooktype, "WTEVEvent" .. self.Id .. ":" .. hooktype, function(...)
		return callbackfunc(self, ...)
	end)
	self.Hooks = self.Hooks or {}
	table.insert(self.Hooks, {hooktype, "WTEVEvent" .. self.Id .. ":" .. hooktype})
end

function wtev_meta:CleanUpHooks()
	if not self.Hooks then return end
	for _,ahook in pairs(self.Hooks) do
		hook.Remove(ahook[1], ahook[2])
	end
	table.Empty(self.Hooks)
end

function wtev_meta:Prepare()

end
function wtev_meta:Begin()

end
function wtev_meta:End()
	self:CleanUpHooks()
end

-- Valid players not in spec
function wtev_meta:GetPlayers()
	local plys = {}
	for _,ply in pairs(player.GetAll()) do
		if IsValid(ply) and (not ply:IsSpec()) then
			table.insert(plys, ply)
		end
	end
	return plys
end

if SERVER then
	util.AddNetworkString("wyozitev_message")
	function wtev_meta:EventNotification()
		net.Start("wyozitev_message")
		net.WriteUInt(1, 8)
		net.WriteTable({self.Id})
		net.WriteUInt(0, 8)
		net.Broadcast()
	end
	function wtev_meta:SmallNotification(targ, msg, length)
		net.Start("wyozitev_message")
		net.WriteUInt(2, 8)
		net.WriteTable(type(msg) == "table" and msg or {msg})
		net.WriteUInt(length or 0, 8)
		if not targ then net.Broadcast() else net.Send(targ) end
	end
	function wtev_meta:HidePSItems(ply)
		if ply.PS_PlayerDeath then
			timer.Simple(2, function() -- There's a timer in PS_PlayerSpawn of 1 second, 2 seconds should be enough
				if ply:IsValid() then ply:PS_PlayerDeath() end
			end)
		end
	end
end

wtev_meta.__index = wtev_meta

wyozitev.EventsAC = {}

function wyozitev.RegisterEvent(id, tbl)
	tbl.Id = id
	tbl.__index = tbl
	setmetatable(tbl, wtev_meta)
	wyozitev.Events[id] = tbl

	table.insert(wyozitev.EventsAC, id)

	wyozitev.Debug("Registered event " .. id)
end

function wyozitev.NewEvent(id)
	if not wyozitev.Events[id] then return ErrorNoHalt("Trying to create new inexistent event " .. id) end
	local tbl = {}
	setmetatable(tbl, wyozitev.Events[id])
	return tbl
end