local CATEGORY_NAME = "Links"

local function showDonate( ply )
	ULib.clientRPC( ply, "ulx.showDonate", ply:Nick(), ply:SteamID())
end

function ulx.donate( calling_ply )
	if not calling_ply:IsValid() then return end
	showDonate( calling_ply )
end
local donate = ulx.command( CATEGORY_NAME, "ulx donate", ulx.donate, "!donate")
donate:defaultAccess( ULib.ACCESS_ALL )
donate:help( "Show donation information." )

local function showForums( ply )
	ULib.clientRPC( ply, "ulx.showForums")
end

function ulx.forums( calling_ply )
	if not calling_ply:IsValid() then return end
	showForums( calling_ply )
end
local forums = ulx.command( CATEGORY_NAME, "ulx forums", ulx.forums, "!forums")
forums:defaultAccess( ULib.ACCESS_ALL )
forums:help( "Visit the community forums." )

local function showRules( ply )
	ULib.clientRPC( ply, "ulx.showRules")
end

function ulx.rules( calling_ply )
	if not calling_ply:IsValid() then return end
	showRules( calling_ply )
end
local rules = ulx.command( CATEGORY_NAME, "ulx rules", ulx.rules, "!rules")
rules:defaultAccess( ULib.ACCESS_ALL )
rules:help( "Display the server rules." )