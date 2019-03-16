-- Although this may seem messy, it is better than asking the user to manually replace core gamemode files.
-- When replacing core gamemode files, it is harder to revert and the user will have to reinstall every Garry's Mod update.

hook.Add( "PostGamemodeLoaded", "Modern Scoreboard Override", function()
	include("scoreboard/override/sb_main.lua")
	include("scoreboard/override/sb_team.lua")
	include("scoreboard/override/sb_row.lua")
	include("scoreboard/override/sb_info.lua")
end)