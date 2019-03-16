hook.Add( "PostGamemodeLoaded", "ULX Ban Override", function()
	function ULib.addBan( steamid, time, reason, name, admin )
		local strTime = time ~= 0 and string.format( "for %s minute(s)", time ) or "permanently"
		local showReason = string.format( "Banned %s: %s", strTime, reason )
		if ( sourcebans ) then
            sourcebans.BanPlayerBySteamID( steamid, time*60, reason, admin, name )
        else
			local players = player.GetAll()
			for i=1, #players do
				if players[ i ]:SteamID() == steamid then
					ULib.kick( players[ i ], showReason, admin )
				end
			end

			-- Remove all semicolons from the reason to prevent command injection
			showReason = string.gsub(showReason, ";", "")

			-- This redundant kick code is to ensure they're kicked -- even if they're joining
			game.ConsoleCommand( string.format( "kickid %s %s\n", steamid, showReason or "" ) )
			game.ConsoleCommand( string.format( "banid %f %s kick\n", time, steamid ) )
			game.ConsoleCommand( "writeid\n" )
		end
		
		local admin_name
		if admin then
			admin_name = "(Console)"
			if admin:IsValid() then
				admin_name = string.format( "%s(%s)", admin:Name(), admin:SteamID() )
			end
		end

		local t = {}
		if ULib.bans[ steamid ] then
			t = ULib.bans[ steamid ]
			t.modified_admin = admin_name
			t.modified_time = os.time()
		else
			t.admin = admin_name
		end
		t.time = t.time or os.time()
		if time > 0 then
			t.unban = ( ( time * 60 ) + os.time() )
		else
			t.unban = 0
		end
		if reason then
			t.reason = reason
		end
		if name then
			t.name = name
		end
		ULib.bans[ steamid ] = t
		ULib.fileWrite( ULib.BANS_FILE, ULib.makeKeyValues( ULib.bans ) )
	end

	function ULib.unban( steamid, admin )

		--Default banlist
		if ULib.fileExists( "cfg/banned_user.cfg" ) then
			ULib.execFile( "cfg/banned_user.cfg" )
		end
		if ( sourcebans ) then
		    sourcebans.UnbanPlayerBySteamID( steamid, "In game unban", nil)
		else
			ULib.queueFunctionCall( game.ConsoleCommand, "removeid " .. steamid .. ";writeid\n" ) -- Execute after done loading bans
		end
		--ULib banlist
		ULib.bans[ steamid ] = nil
		ULib.fileWrite( ULib.BANS_FILE, ULib.makeKeyValues( ULib.bans ) )
	end
end)