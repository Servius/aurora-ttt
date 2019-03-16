--[[

Modern UI Scoreboard for TTT
Lovingly crafted by Divine

For support, please send me a message on ScriptFodder :)
  
]]--

ScoreboardConfig = {}

-- [[ Scoreboard Configuration ]] --

-- [[ General Scoreboard Configuration ]] --

-- Text on the top of the scoreboard --
ScoreboardConfig.SB_Name = "Aurora Entertainment Network"
-- Colour of the bar of the scoreboard --
ScoreboardConfig.BAR_Color = Color(41, 128, 185)
-- Background Colour --
ScoreboardConfig.BG_Color = Color(29,29,29, 235)
ScoreboardConfig.BG2_Color = Color(20,20,20, 150)
-- Icons for the ranks of the server --
-- The list can be found here: http://www.famfamfam.com/lab/icons/silk/previews/index_abc.png
-- If you are using these, make sure you insert icon16/{NAME}.png
ScoreboardConfig.SB_Ranks = { 
	{"prime", "icon16/star.png"},
	{"admin", "icon16/shield.png"},
	{"primeadmin", "icon16/shield.png"},
	{"superadmin", "icon16/shield.png"},
	{"primeenforcer", "icon16/shield.png"},
	{"enforcer", "icon16/shield.png"},
	{"primemoderator", "icon16/shield.png"},
	{"seniormoderator", "icon16/shield.png"},
	{"moderator", "icon16/shield.png"}
}
-- Rank Name Colours --
ScoreboardConfig.SB_RankNameColors = {
	{"primemoderator", Color(220, 180, 0, 255)},
	{"primeadmin", Color(220, 180, 0, 255)},
	{"enforcer", Color(220, 180, 0, 255)},
	{"primeenforcer", Color(220, 180, 0, 255)},
	{"moderator", Color(220, 180, 0, 255)},
	{"seniormoderator", Color(220, 180, 0, 255)},
	{"dev", Color(100, 240, 105, 255)}
}

-- If the rank is not specified above, use these colors:
ScoreboardConfig.DefaultPlayerColor = Color(255, 255, 255, 255)
ScoreboardConfig.DefaultAdminColor = Color(220, 180, 0, 255)

-- [[ Pointshop Configuration ]] --

-- Use Pointshop?
ScoreboardConfig.PS = true
-- Points Name?
ScoreboardConfig.PS_Name = "Coins"

-- [[ Miscellaneous ]] --

-- Show SlayNR on Right-Click menu? Make sure you have http://forums.ulyssesmod.net/index.php?topic=6279.0 
ScoreboardConfig.SlayNR = false
-- Default ban-time in Right-Click menu. This is for quicker bans if you have a consistent ban time.
ScoreboardConfig.BanTime = 1440
-- If you do not like the whitestrike underneath the team name, disable it here.
ScoreboardConfig.WhiteStrike = true 

-- [[ Team Colours ]] --
ScoreboardConfig.SpectatorColour = Color(29,29,29, 100) -- Default: Color(29,29,29, 100)
ScoreboardConfig.TerroristColour = Color(0,163,0,100) -- Default: Color(0,163,0,100)
ScoreboardConfig.MissingInActionColour = Color(26, 188, 156, 100) -- Default: Color(26, 188, 156, 100)
ScoreboardConfig.ConfirmedColour = Color(192, 57, 43, 100) -- Default: Color(192, 57, 43, 100)

-- [[ SpecDM ]]--
-- If you are using Spectator Deathmatch by Tommy (https://github.com/Tommy228/TTT_Spectator_Deathmatch), enable this option
-- and also change SpecDM.IsScoreboardCustom = false to SpecDM.IsScoreboardCustom = true in the file specdm_config.lua which
-- is located in the spectator deathmatch addon

ScoreboardConfig.UsingSpecDM = false

-- [[ Tags ]] --

-- These tags are entirely optional. You need to have Wyozi's Tag Editor installed. This scoreboard is compatible
-- with it but you must enable it. Make sure you have wyozite.DontUseContextMenu set to false in the addon's
-- config else it will override our scoreboard's context functions.

-- Wyozi's Tag Editor
ScoreboardConfig.UseWyozi = false -- If you are using this, please disable wyozite.DontUseContextMenu in that addon's config and set column index to 6!

-- [[ End of Scoreboard Configuration ]] --