if SERVER then
	AddCSLuaFile("eqmenu/cl_init.lua")
	AddCSLuaFile("eqmenu/override/cl_equip.lua")
else
	include( "eqmenu/cl_init.lua" )
end