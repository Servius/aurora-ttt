hook.Add( "PostGamemodeLoaded", "EquipmentOverride", function()
	include("eqmenu/override/cl_equip.lua")
end )