hook.Add( "PostGamemodeLoaded", "AuroraHUD", function()
	include("hud/override/cl_hud.lua")
	include("hud/override/cl_wepswitch.lua")
	include("hud/override/cl_hudpickup.lua")
end )