if SERVER then
	AddCSLuaFile("scoreboard/cl_init.lua")
	AddCSLuaFile("scoreboard/sb_override.lua")
	AddCSLuaFile("scoreboard/sb_config.lua")
	AddCSLuaFile("scoreboard/override/sb_info.lua")
	AddCSLuaFile("scoreboard/override/sb_main.lua")
	AddCSLuaFile("scoreboard/override/sb_row.lua")
	AddCSLuaFile("scoreboard/override/sb_team.lua")
else
	include( "scoreboard/cl_init.lua" )
end