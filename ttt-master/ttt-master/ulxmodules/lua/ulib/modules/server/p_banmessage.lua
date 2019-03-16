MsgC( Color( 0, 0, 200 ), '\n===============================================\n= ' );
MsgC( Color( 0, 200, 255 ), 'Loaded PBanMessage System by thelastpenguin™ ' );
MsgC( Color( 0, 0, 200 ), '=\n===============================================\n\n' );
include( 'pbanmsg_config.lua' );


hook.Add('PostGamemodeLoaded','PBanMessage.inject', function()
	function GAMEMODE:CheckPassword( steamid64, ip, sv_password, cl_password, cl_name )
		if( string.len( sv_password ) > 0 and sv_password ~= cl_password )then
			if( PBanMsg.notifyAdmins_BadPW )then
				for k,v in pairs( player.GetAll() )do
					if( v:IsAdmin() )then
						v:ChatPrint('Player '..cl_name..' tried to join with a bad password.');
					end
				end
			end
			return false, PBanMsg.badpw_message
		end

		local steamid = util.SteamIDFrom64( steamid64 )
		
		-- Get the time for everything.
		local curTime = os.time();
		
		// WE CHECK IF THEY ARE BANNED.
		local c_ban = ULib.bans[ steamid ]
		
		if( c_ban ~= nil )then
			local totalLength = c_ban.unban - c_ban.time
			local timeLeft = c_ban.unban - os.time( );
			local isPerm = c_ban.unban == 0;

			local TimeStr = nil
			if( isPerm )then
				TimeStr = "NEVER"
			else
				local minutes = math.floor( timeLeft / 60 )
				local seconds = timeLeft - minutes * 60
				local hours = math.floor( minutes / 60 )
				minutes = minutes - hours * 60
				local days = math.floor( hours / 24 )
				hours = hours - days * 24
				
				TimeStr = ''
				if( days ~= 0 )then
					TimeStr = TimeStr..days..'d '
				end
				if( hours ~= 0 )then
					TimeStr = TimeStr..hours..'h '
				end
				if( minutes ~= 0 )then
					TimeStr = TimeStr..minutes..'m '
				end
				if( seconds ~= 0 )then
					TimeStr = TimeStr..seconds..'s '
				end
			end

			if( PBanMsg.notifyAdmins_BannedUser )then
				for k,v in pairs( player.GetAll() )do
					if( v:IsAdmin() )then
						v:ChatPrint('Banned player '..cl_name..' ('..steamid..') tried to join and was blocked.');
					end
				end
			end

			return false, PBanMsg.ban_message:gsub( '<time>', TimeStr or '' ):gsub( '<admin>', c_ban.admin or '' ):gsub( '<reason>', c_ban.reason or '' );
		end
	end -- returns bool. Disconnect return false, <msg>:string
end)