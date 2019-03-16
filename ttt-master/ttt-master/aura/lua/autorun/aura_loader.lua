--[[

╔══╗───────╔══╗──╔╗────╔═╗
║╔╗╠╦╦╦╦═╗─╚║║╬═╦╣╚╦═╦╦╣═╬═╗╔═╦═╗
║╠╣║║║╔╣╬╚╗╔║║╣║║║╔╣╩╣╔╣╔╣╬╚╣═╣╩╣
╚╝╚╩═╩╝╚══╝╚══╩╩═╩═╩═╩╝╚╝╚══╩═╩═╝
────────────────────────────────
  Designed and Coded by Divine
        www.AuroraEN.com
────────────────────────────────

]]

local path = "aura/vgui"
local files = file.Find("aura/vgui/*.lua", "LUA")

if SERVER then
	for k,v in pairs(files) do
		AddCSLuaFile(path.."/"..v)
	end
elseif CLIENT then
	for k,v in pairs(files) do
		include(path.."/"..v)
	end
end