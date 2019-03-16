
local wyozitev_debug = CreateConVar("wyozitev_debug", "0", FCVAR_ARCHIVE)

wyozitev = wyozitev or {}
function wyozitev.Debug(...)
	if not wyozitev_debug:GetBool() or not game.IsDedicated() then return end
	print("[WYOZITEV-DEBUG] ", ...)
end

local function AddClient(fil)
	if SERVER then AddCSLuaFile(fil) end
	if CLIENT then include(fil) end
end

local function AddServer(fil)
	if SERVER then include(fil) end
end

local function AddShared(fil)
	include(fil)
	AddCSLuaFile(fil)
end

AddShared("sh_wtev_config.lua")
AddShared("sh_wtev_base.lua")
AddShared("sh_wtev_tttqueue.lua")
AddServer("sv_wtev_tttoverrides.lua")
AddServer("sh_wtev_commands.lua")
AddClient("cl_wtev_hud.lua")

local files, folders = file.Find("wtevents/*", "LUA")

for _,file in pairs(files) do
	if string.EndsWith(file, ".lua") then
		AddShared("wtevents/" .. file)
		wyozitev.Debug("Loading single file event " .. file)
	end
end

hook.Call("WyotiTEVEventsLoaded", GAMEMODE)