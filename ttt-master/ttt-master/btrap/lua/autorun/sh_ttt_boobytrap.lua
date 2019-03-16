/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends	
	76561198101347368
	
	autorun/sh_ttt_boobytrap.lua
	
	>> The following has parts comprised from the following publicly available works:
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_health_station.lua
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/entities/ttt_health_station.lua
		>> [ttt] defuser: 		/garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_defuser.lua
		>> [ttt] dna scanner: 	/garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_wtester.lua
		>> [clavus] swep construction kit: https://github.com/Clavus/SWEP_Construction_Kit/
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
		
	Please do not edit below unless you are a proficient coder!
***/

BOOBYTRAP = { Version = 20141102 }

if SERVER then
	AddCSLuaFile("ttt_boobytrap_config.lua")
end
include("ttt_boobytrap_config.lua")

/*** 76561198101347368 ***/
hook.Add("InitPostEntity", "BOOBYTRAP::HOOKTTT", function()
	local function checkFolder(str) 
		return GAMEMODE and ( ( GAMEMODE.Folder and string.find(string.lower(GAMEMODE.Folder), str ) ) or ( GAMEMODE.FolderName and string.find(string.lower(GAMEMODE.FolderName), str ) ) )
	end
	if not( checkFolder("terrortown") or checkFolder("ttt") ) then
		print("[BOOBYTRAP] Gamemode is not TTT.")
	else
		if SERVER then
			include("ttt_boobytrap/sv_boobytrap.lua")
			include("ttt_boobytrap/sv_healthbomb.lua")
			include("ttt_boobytrap/sv_dynamite.lua")
			include("ttt_boobytrap/sv_healthstation_upgrade.lua")
			AddCSLuaFile("ttt_boobytrap/cl_boobytrap.lua")
			AddCSLuaFile("ttt_boobytrap/cl_dynamite.lua")
			AddCSLuaFile("ttt_boobytrap/cl_healthbomb.lua")
			AddCSLuaFile("ttt_boobytrap/cl_healthstation_upgrade.lua")
			if BOOBYTRAP.Icon then
				if file.Exists( "materials/" .. BOOBYTRAP.Icon, "GAME" ) then
					resource.AddFile( "materials/" .. BOOBYTRAP.Icon )
				else
					print("[BOOBYTRAP] Icon Error - incorrect model set for BOOBYTRAP.Icon:", BOOBYTRAP.Icon )
				end
			end
		else
			include("ttt_boobytrap/cl_boobytrap.lua")
			include("ttt_boobytrap/cl_healthbomb.lua")
			include("ttt_boobytrap/cl_dynamite.lua")
			include("ttt_boobytrap/cl_healthstation_upgrade.lua")
		end		
	end	
end )

/*** TTT Realistic Booby Trap 76561198101347368 ***/