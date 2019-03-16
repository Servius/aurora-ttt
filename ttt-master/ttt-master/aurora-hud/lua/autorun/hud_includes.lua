if SERVER then
	AddCSLuaFile("hud/cl_init.lua")
	AddCSLuaFile("hud/override/cl_hud.lua")
	AddCSLuaFile("hud/override/cl_wepswitch.lua")
	AddCSLuaFile("hud/override/cl_hudpickup.lua")
else
	include( "hud/cl_init.lua" )
end