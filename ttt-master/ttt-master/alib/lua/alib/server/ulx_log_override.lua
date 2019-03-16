hook.Add( "PostGamemodeLoaded", "ULX Log Override", function()
	local logEvents = ulx.convar( "logEvents", "1", "Log events (player connect, disconnect, death)", ULib.ACCESS_SUPERADMIN )
	local logJoinLeaveEcho = ulx.convar( "logJoinLeaveEcho", "1", "Echo players leaves and joins to admins in the server (useful for banning minges)", ULib.ACCESS_SUPERADMIN )

	local joinTimer = {}
	local mapStartTime = os.time()

	local function echoToAdmins( txt )
		local players = player.GetAll()
		for _, ply in ipairs( players ) do
			if ULib.ucl.authed[ ply:UniqueID() ] and ULib.ucl.query( ply, spawnechoAccess ) then
				ULib.console( ply, txt )
			end
		end
	end

	local function playerConnect( name, address )
		joinTimer[address] = os.time()
		if logEvents:GetBool() then
			ulx.logString( string.format( "Client \"%s\" connected. %s", name, address ) )
		end
	end
	hook.Add( "PlayerConnect", "ULXLogConnect", playerConnect, -20 )

	local function playerInitialSpawn( ply )
		local ip = ply:IPAddress()
		local seconds = os.time() - (joinTimer[ip] or mapStartTime)
		joinTimer[ip] = nil
		
		local txt = string.format( "Client \"%s\" spawned in server <%s> (took %i seconds).", ply:Nick(), ply:SteamID(), seconds )
		if logEvents:GetBool() then
			ulx.logString( txt )
		end

		if logJoinLeaveEcho:GetBool() then
			echoToAdmins( txt )
		end
	end
	hook.Add( "PlayerInitialSpawn", "ULXLogInitialSpawn", playerInitialSpawn, -19 )
end)