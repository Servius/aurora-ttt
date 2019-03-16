require("tmysql4")

--[[ Configuration ]]--
local HOST = "vulcan.auroraen.com"
local USER = "ttt"
local PASS = "9jg1Ww8AYepnCS88bvz1hZntW3qUYfE6flMWsblaUZWwzShZ8ZoycOYG2ujNHeJf"
local NAME = "ttt_ulx"
local PORT = 3306

local REFRESH_TIME = 300 // The amount of time you want the server to refresh groups.

local ENABLE_USERS = true // Whether you want users to be synced to all servers.
local ENABLE_GROUPS = true // Whether you want groups to be synced to all servers.

gameevent.Listen("player_connect")

function ULib.ucl.getGroups()
	if !ENABLE_GROUPS then return end
	
	ULib.ucl.groups = {}
	
	ULib.MySQL:Query("SELECT * FROM `groups`", function( data )
		if !ULib.MySQLData then ULib.MySQLData = true end
		
		for k, v in pairs(data[1].data) do
			if v['can_target'] == "" or v['can_target'] == " "  or v['can_target'] == "NULL" then
				v['can_target'] = nil
			end
			
			if v['inherit_from'] == "" or v['inherit_from'] == " " or v['inherit_from'] == "NULL" then
				v['inherit_from'] = nil
			end
			
			if v['inherit_from'] == "user" and v['name'] == "user" or v['inherit_from'] == v['name'] then
				v['inherit_from'] = nil
				
				ULib.MySQL:Query("UPDATE `groups` SET `inherit_from`='" .. ULib.MySQL:Escape("") .. "' WHERE `name`='" .. v['name'] .. "'")
			end
			
			ULib.ucl.groups[v['name']] = { allow = util.JSONToTable(v['allow']) or {}, can_target = v['can_target'] or nil, inherit_from = v['inherit_from'] or nil }
		end
	end)
end

function ULib.ucl.getUsers()
	if !ENABLE_USERS then return end
	
	ULib.ucl.users = {}
	
	ULib.MySQL:Query("SELECT * FROM `users`", function( data )
		if !ULib.MySQLData then ULib.MySQLData = true end
		
		for k, v in pairs(data[1].data) do
			ULib.ucl.users[v['steamid']] = { allow = util.JSONToTable(v['allow']) or {}, name = v['name'] or nil, deny = util.JSONToTable(v['deny']) or {}, group = v['group'] or "user" }
		end
	end)
end

function ULib.refreshGroups()
	if !ENABLE_GROUPS then return end
	ULib.MySQL:Query("SELECT * FROM `groups`", function( data )
		for k, v in pairs(data[1].data) do
			if v['can_target'] == "" or v['can_target'] == " " or v['can_target'] == "NULL" then
				v['can_target'] = nil
			end
			
			if v['inherit_from'] == "" or v['inherit_from'] == " " or v['inherit_from'] == "NULL" then
				v['inherit_from'] = nil
			end
			
			if !ULib.ucl.groups[v['name']] then
				ULib.ucl.groups[v['name']] = { allow = util.JSONToTable(v['allow']) or {}, can_target = v['can_target'] or nil, inherit_from = v['inherit_from'] or nil }
			else
				ULib.ucl.groups[v['name']].allow = util.JSONToTable(v['allow']) or {}
				ULib.ucl.groups[v['name']].inherit_from = v['inherit_from'] or nil
				ULib.ucl.groups[v['name']].can_target = v['can_target'] or nil
			end
			
			if k and k == #data then
				hook.Call( ULib.HOOK_UCLCHANGED )
			end
		end
	end)
end


local _addGroup = ULib.ucl.addGroup
function ULib.ucl.addGroup( name, allows, inherit_from )
	if !ENABLE_GROUPS then return _addGroup( name, allows, inherit_from ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.addGroup", "string", name )
	ULib.checkArg( 2, "ULib.ULib.ucl.addGroup", {"nil","table"}, allows )
	ULib.checkArg( 3, "ULib.ULib.ucl.addGroup", {"nil","string"}, inherit_from )
	allows = allows or {}
	inherit_from = inherit_from or "user"
	
	if ULib.ucl.groups[ name ] then return error( "Group already exists, cannot add again (" .. name .. ")", 2 ) end
	if inherit_from then
		if inherit_from == name then return error( "Group cannot inherit from itself", 2 ) end
		if not ULib.ucl.groups[ inherit_from ] then return error( "Invalid group for inheritance (" .. tostring( inherit_from ) .. ")", 2 ) end
	end
	
	for k, v in ipairs( allows ) do allows[ k ] = v:lower() end
	
	ULib.ucl.groups[ name ] = { allow=allows, inherit_from=inherit_from }
	
	local query = "`name`"
	local query2 = "'" .. ULib.MySQL:Escape(name) .. "'"
	
	query = query .. ", `allow`"
	query2 = query2 .. ", '" .. ULib.MySQL:Escape(util.TableToJSON(allows)) .. "'"
	
	query = query .. ", `inherit_from`"
	query2 = query2 .. ", '" .. ULib.MySQL:Escape(inherit_from) .. "'"
	
	ULib.MySQL:Query("INSERT INTO `groups` (" .. query .. ") VALUES(" .. query2 .. ")")
	
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _groupAllow = ULib.ucl.groupAllow
function ULib.ucl.groupAllow( name, access, revoke )
	if !ENABLE_GROUPS then return _groupAllow( name, access, revoke ) end
	
	ULib.checkArg( 1, "ULib.ucl.groupAllow", "string", name )
	ULib.checkArg( 2, "ULib.ucl.groupAllow", {"string","table"}, access )
	ULib.checkArg( 3, "ULib.ucl.groupAllow", {"nil","boolean"}, revoke )
	
	if type( access ) == "string" then access = { access } end
	if not ULib.ucl.groups[ name ] then return error( "Group does not exist for changing access (" .. name .. ")", 2 ) end
	
	local allow = ULib.ucl.groups[ name ].allow
	
	local changed = false
	for k, v in pairs( access ) do
		local access = v:lower()
		local accesstag
		if type( k ) == "string" then
			accesstag = v:lower()
			access = k:lower()
		end
		
		if not revoke and (allow[ access ] ~= accesstag or (not accesstag and not ULib.findInTable( allow, access ))) then
			changed = true
			if not accesstag then
				table.insert( allow, access )
				allow[ access ] = nil
			else
				allow[ access ] = accesstag
				if ULib.findInTable( allow, access ) then
					table.remove( allow, ULib.findInTable( allow, access ) )
				end
			end
		elseif revoke and (allow[ access ] or ULib.findInTable( allow, access )) then
			changed = true
			
			allow[ access ] = nil
			if ULib.findInTable( allow, access ) then
				table.remove( allow, ULib.findInTable( allow, access ) )
			end
		end
	end
	
	local group = ULib.ucl.groups[name]
	ULib.MySQL:Query("UPDATE `groups` SET `allow`='"  .. ULib.MySQL:Escape(util.TableToJSON(group.allow)) ..  "', `inherit_from`='" .. ULib.MySQL:Escape(group.inherit_from or "user") .. "', `can_target`='" .. ULib.MySQL:Escape(group.can_target or " ") .. "' WHERE `name`='" .. name .. "'")
	
	if changed then
		for id, userInfo in pairs( ULib.ucl.authed ) do
			local ply = ULib.getPlyByID( id )
			if ply and ply:CheckGroup( name ) then
				ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
			end
		end
		
		ULib.ucl.saveGroups()
		
		hook.Call( ULib.HOOK_UCLCHANGED )
	end
	
	return changed
end

local _renameGroup = ULib.ucl.renameGroup
function ULib.ucl.renameGroup( orig, new )
	if !ENABLE_GROUPS then return _renameGroup( orig, new ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.renameGroup", "string", orig )
	ULib.checkArg( 2, "ULib.ULib.ucl.renameGroup", "string", new )
	
	if orig == ULib.ACCESS_ALL then return error( "This group (" .. orig .. ") cannot be renamed!", 2 ) end
	if not ULib.ucl.groups[ orig ] then return error( "Group does not exist for renaming (" .. orig .. ")", 2 ) end
	if ULib.ucl.groups[ new ] then return error( "Group already exists, cannot rename (" .. new .. ")", 2 ) end
	
	for id, userInfo in pairs( ULib.ucl.users ) do
		if userInfo.group == orig then
			userInfo.group = new
		end
	end
	
	for id, userInfo in pairs( ULib.ucl.authed ) do
		local ply = ULib.getPlyByID( id )
		if ply and ply:CheckGroup( orig ) then
			if ply:GetUserGroup() == orig then
				ULib.queueFunctionCall( ply.SetUserGroup, ply, new )
			else
				ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
			end
		end
	end
	
	ULib.ucl.groups[ new ] = ULib.ucl.groups[ orig ]
	ULib.ucl.groups[ orig ] = nil
	
	ULib.MySQL:Query("DELETE FROM `groups` WHERE `name`='" .. orig .. "'")
	
	local query = "`name`"
	local query2 = "'" .. ULib.MySQL:Escape(new) .. "'"
	
	if ULib.ucl.groups[ new ].allow then
		query = query .. ", `allow`"
		query2 = query2 .. ", '" .. ULib.MySQL:Escape(util.TableToJSON(ULib.ucl.groups[ new ].allow)) .. "'"
	end
	
	if ULib.ucl.groups[ new ].can_target then
		query = query .. ", `can_target`"
		query2 = query2 .. ", '" .. ULib.MySQL:Escape(ULib.ucl.groups[ new ].can_target) .. "'"
	end
	
	if ULib.ucl.groups[ new ].inherit_from then
		query = query .. ", `inherit_from`"
		query2 = query2 .. ", '" .. ULib.MySQL:Escape(ULib.ucl.groups[ new ].inherit_from) .. "'"
	end
	
	ULib.MySQL:Query("INSERT INTO `groups` (" .. query .. ") VALUES(" .. query2 .. ")")
	
	for _, groupInfo in pairs( ULib.ucl.groups ) do
		if groupInfo.inherit_from == orig then
			groupInfo.inherit_from = new
		end
	end
	
	ULib.ucl.saveUsers()
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _removeGroup = ULib.ucl.removeGroup
function ULib.ucl.removeGroup( name )
	if !ENABLE_GROUPS then return _removeGroup( name ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.removeGroup", "string", name )
	
	if name == ULib.ACCESS_ALL then return error( "This group (" .. name .. ") cannot be removed!", 2 ) end
	if not ULib.ucl.groups[ name ] then return error( "Group does not exist for removing (" .. name .. ")", 2 ) end
	
	local inherits_from = ULib.ucl.groupInheritsFrom( name )
	if inherits_from == ULib.ACCESS_ALL then inherits_from = nil end
	
	for id, userInfo in pairs( ULib.ucl.users ) do
		if userInfo.group == name then
			userInfo.group = inherits_from
			
			ULib.MySQL:Query("DELETE FROM `users` WHERE `steamid`='" .. id .. "'")
			
			syncUsers()
		end
	end
	
	for id, userInfo in pairs( ULib.ucl.authed ) do
		local ply = ULib.getPlyByID( id )
		if ply and ply:CheckGroup( name ) then
			if ply:GetUserGroup() == name then
				ULib.queueFunctionCall( ply.SetUserGroup, ply, inherits_from or ULib.ACCESS_ALL )
			else
				ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
			end
		end
	end
	
	ULib.MySQL:Query("DELETE FROM `groups` WHERE `name`='" .. name .. "'")
	
	ULib.ucl.groups[ name ] = nil
	for _, groupInfo in pairs( ULib.ucl.groups ) do
		if groupInfo.inherit_from == name then
			groupInfo.inherit_from = inherits_from
		end
	end
	
	ULib.ucl.saveUsers()
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _setGroupInheritance = ULib.ucl.setGroupInheritance
function ULib.ucl.setGroupInheritance( group, inherit_from )
	if !ENABLE_GROUPS then return _setGroupInheritance( group, inherit_from ) end
	
	ULib.checkArg( 1, "ULib.ucl.renameGroup", "string", group )
	ULib.checkArg( 2, "ULib.ucl.renameGroup", {"nil","string"}, inherit_from )
	if inherit_from then
		if inherit_from == ULib.ACCESS_ALL then inherit_from = nil end
	end
	
	if group == ULib.ACCESS_ALL then return error( "This group (" .. group .. ") cannot have it's inheritance changed!", 2 ) end
	if not ULib.ucl.groups[ group ] then return error( "Group does not exist (" .. group .. ")", 2 ) end
	if inherit_from and not ULib.ucl.groups[ inherit_from ] then return error( "Group for inheritance does not exist (" .. inherit_from .. ")", 2 ) end
	
	local old_inherit = ULib.ucl.groups[ group ].inherit_from
	ULib.ucl.groups[ group ].inherit_from = inherit_from
	local groupCheck = ULib.ucl.groupInheritsFrom( group )
	while groupCheck do
		if groupCheck == group then
			ULib.ucl.groups[ group ].inherit_from = old_inherit
			error( "Changing group \"" .. group .. "\" inheritance to \"" .. inherit_from .. "\" would cause cyclical inheritance. Aborting.", 2 )
		end
		groupCheck = ULib.ucl.groupInheritsFrom( groupCheck )
	end
	ULib.ucl.groups[ group ].inherit_from = old_inherit
	
	if old_inherit == inherit_from then return end
	
	for id, userInfo in pairs( ULib.ucl.authed ) do
		local ply = ULib.getPlyByID( id )
		if ply and ply:CheckGroup( group ) then
			ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
		end
	end
	
	ULib.ucl.groups[ group ].inherit_from = inherit_from
	
	ULib.MySQL:Query("UPDATE `groups` SET `inherit_from`='" .. ULib.MySQL:Escape(inherit_from or "user") .. "' WHERE `name`='" .. group .. "'")
	
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _setGroupCanTarget = ULib.ucl.setGroupCanTarget
function ULib.ucl.setGroupCanTarget( group, can_target )
	if !ENABLE_GROUPS then return _setGroupCanTarget( group, can_target ) end
	print(can_target)
	ULib.checkArg( 1, "ULib.ucl.setGroupCanTarget", "string", group )
	ULib.checkArg( 2, "ULib.ucl.setGroupCanTarget", {"nil","string"}, can_target )
	can_target = can_target or ""
	if not ULib.ucl.groups[ group ] then return error( "Group does not exist (" .. group .. ")", 2 ) end
	
	if ULib.ucl.groups[ group ].can_target == can_target then return end
	
	ULib.ucl.groups[ group ].can_target = can_target
	ULib.MySQL:Query("UPDATE `groups` SET `can_target`='" .. ULib.MySQL:Escape(can_target) .. "' WHERE `name`='" .. group .. "'")
	
	ULib.ucl.saveGroups()
	
	hook.Call( ULib.HOOK_UCLCHANGED )
end

local _addUser = ULib.ucl.addUser
function ULib.ucl.addUser( id, allows, denies, group )
	if !ENABLE_USERS then return _addUser( id, allows, denies, group ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.addUser", "string", id )
	ULib.checkArg( 2, "ULib.ULib.ucl.addUser", {"nil","table"}, allows )
	ULib.checkArg( 3, "ULib.ULib.ucl.addUser", {"nil","table"}, denies )
	ULib.checkArg( 4, "ULib.ULib.ucl.addUser", {"nil","string"}, group )
	
	id = id:upper()
	allows = allows or {}
	denies = denies or {}
	if allows == ULib.DEFAULT_GRANT_ACCESS.allow then allows = table.Copy( allows ) end
	if denies == ULib.DEFAULT_GRANT_ACCESS.deny then denies = table.Copy( denies ) end
	if group and not ULib.ucl.groups[ group ] then return error( "Group does not exist for adding user to (" .. group .. ")", 2 ) end
	
	for k, v in ipairs( allows ) do allows[ k ] = v:lower() end
	for k, v in ipairs( denies ) do denies[ k ] = v:lower() end
	
	local ply = ULib.getPlyByID( id )
	local found = false
	local name
	
	if ULib.ucl.users[ id ] then
		found = true
	end
	
	if ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name then name = ULib.ucl.users[ id ].name end
	ULib.ucl.users[ id ] = { allow=allows, deny=denies, group=group, name=name }
	
	if ply then
		name = ply:Nick()
	end
	
	ULib.MySQL:Query("SELECT * FROM `users` WHERE `steamid`='" .. id .. "'", function( data )
		data = data[1].data[1]
		
		if data and data['steamid'] then
			ULib.MySQL:Query("UPDATE `users` SET `name`='" .. ULib.MySQL:Escape(name) .. "', `group`='" .. ULib.MySQL:Escape(group) .. "' WHERE `steamid`='" .. id .. "'")
			
			found = true
		else
			ULib.MySQL:Query("INSERT INTO `users` (`steamid`, `deny`, `allow`, `name`, `group`) VALUES('" .. ULib.MySQL:Escape(id) .. "', '" .. ULib.MySQL:Escape(util.TableToJSON(denies)) .. "', '" .. ULib.MySQL:Escape(util.TableToJSON(allows)) .. "', '" .. ULib.MySQL:Escape(name or "No name given.") .. "', '" .. ULib.MySQL:Escape(group) .. "')")
			
			found = false
		end
	end)
	
	ULib.ucl.saveUsers()
	
	syncUsers()
	
	if ply then
		ULib.ucl.probe( ply )
	else
		hook.Call( ULib.HOOK_UCLCHANGED )
	end
end

local _removeUser = ULib.ucl.removeUser
function ULib.ucl.removeUser( id )
	if !ENABLE_USERS then return _removeUser( id ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.addUser", "string", id )
	id = id:upper()
	
	local userInfo = ULib.ucl.users[ id ] or ULib.ucl.authed[ id ]
	if not userInfo then return error( "User id does not exist for removing (" .. id .. ")", 2 ) end
	
	local changed = false
	
	if ULib.ucl.authed[ id ] and not ULib.ucl.users[ id ] then
		local ply = ULib.getPlyByID( id )
		if not ply then return error( "SANITY CHECK FAILED!" ) end
		
		local ip = ULib.splitPort( ply:IPAddress() )
		local checkIndexes = { ply:UniqueID(), ip, ply:SteamID() }
		
		for _, index in ipairs( checkIndexes ) do
			if ULib.ucl.users[ index ] then
				changed = true
				ULib.ucl.users[ index ] = nil
				break
			end
		end
		
		ULib.MySQL:Query("DELETE FROM `users` WHERE `steamid`='" .. ply:SteamID() .. "'")
	else
		changed = true
		ULib.ucl.users[ id ] = nil
		
		ULib.MySQL:Query("DELETE FROM `users` WHERE `steamid`='" .. id .. "'")
	end
	
	syncUsers()
	
	ULib.ucl.saveUsers()
	
	local ply = ULib.getPlyByID( id )
	if ply then
		ply:SetUserGroup( ULib.ACCESS_ALL, true )
		ULib.ucl.probe( ply )
	else
		hook.Call( ULib.HOOK_UCLCHANGED )
	end
end

local _userAllow = ULib.ucl.userAllow
function ULib.ucl.userAllow( id, access, revoke, deny )
	if !ENABLE_USERS then return _userAllow( id, access, revoke, deny ) end
	
	ULib.checkArg( 1, "ULib.ULib.ucl.userAllow", "string", id )
	ULib.checkArg( 2, "ULib.ULib.ucl.userAllow", {"string","table"}, access )
	ULib.checkArg( 3, "ULib.ULib.ucl.userAllow", {"nil","boolean"}, revoke )
	ULib.checkArg( 4, "ULib.ULib.ucl.userAllow", {"nil","boolean"}, deny )
	
	id = id:upper()
	if type( access ) == "string" then access = { access } end
	
	local uid = id
	if not ULib.ucl.authed[ uid ] then
		local ply = ULib.getPlyByID( id )
		if ply and ply:IsValid() then
			uid = ply:UniqueID()
		end
	end
	
	local userInfo = ULib.ucl.users[ id ] or ULib.ucl.authed[ uid ]
	if not userInfo then return error( "User id does not exist for changing access (" .. id .. ")", 2 ) end
	
	if userInfo.guest then
		local allows = {}
		local denies = {}
		if not revoke and not deny then allows = access
		elseif not revoke and deny then denies = access end
		
		ULib.ucl.addUser( id, allows, denies )
		return true
	end
	
	local accessTable = userInfo.allow
	local otherTable = userInfo.deny
	if deny then
		accessTable = userInfo.deny
		otherTable = userInfo.allow
	end
	
	local changed = false
	for k, v in pairs( access ) do
		local access = v:lower()
		local accesstag
		if type( k ) == "string" then
			access = k:lower()
			if not revoke and not deny then
				accesstag = v:lower()
			end
		end
		
		if not revoke and (accessTable[ access ] ~= accesstag or (not accesstag and not ULib.findInTable( accessTable, access ))) then
			changed = true
			if not accesstag then
				table.insert( accessTable, access )
				accessTable[ access ] = nil
			else
				accessTable[ access ] = accesstag
				if ULib.findInTable( accessTable, access ) then
					table.remove( accessTable, ULib.findInTable( accessTable, access ) )
				end
			end
			
			if deny then
				otherTable[ access ] = nil
			end
			if ULib.findInTable( otherTable, access ) then
				table.remove( otherTable, ULib.findInTable( otherTable, access ) )
			end
		elseif revoke and (accessTable[ access ] or ULib.findInTable( accessTable, access )) then
			changed = true
			
			if not deny then
				accessTable[ access ] = nil
			end
			if ULib.findInTable( accessTable, access ) then
				table.remove( accessTable, ULib.findInTable( accessTable, access ) )
			end
		end
	end
	
	local ply = ULib.getPlyByID( id )
	
	if ply then
		local v = ULib.ucl.users[ply:SteamID()]
		
		ULib.MySQL:Query("UPDATE `users` SET `deny`='" .. ULib.MySQL:Escape(util.TableToJSON(v.deny)) .. "', `allow`='"  .. ULib.MySQL:Escape(util.TableToJSON(v.allow)) ..  "', `name`='" .. ULib.MySQL:Escape(v.name) .. "', `group`='" .. ULib.MySQL:Escape(v.group) .. "' WHERE `steamid`='" .. ply:SteamID() .. "'")
	end
	
	if changed then
		if ply then
			ULib.queueFunctionCall( hook.Call, ULib.HOOK_UCLAUTH, _, ply )
		end
		
		hook.Call( ULib.HOOK_UCLCHANGED )
	end
	
	ULib.ucl.saveUsers()
	
	syncUsers()
	
	return changed
end

function ULib.Connect()
	if !tmysql then MsgN("[ULX MySQL] -> Failed to load tmysql4 module.\n\tPlease recheck your version to make sure it's installed correctly.\n\tAlso check to see if you have the right version.") return end

	local connection, error = tmysql.initialize( HOST, USER, PASS, NAME, PORT, nil, CLIENT_MULTI_STATEMENTS )

	ULib.MySQL = connection

	if ULib.MySQL then 
		ULib.MySQLConnected = true
		
		if ENABLE_GROUPS then
			ULib.ucl.getGroups()
		end
		
		if ENABLE_USERS then
			ULib.ucl.getUsers()
		end
		
		MsgN("[ULX MySQL] Successfully to connect to database.")
	else 
		ULib.MySQLConnected = false
		MsgN("[ULX MySQL] Failed to connect to database -> " .. error)
	end



	
	//ULib.MySQL, error = tmysql.Create(HOST, USER, PASS, NAME, PORT, nil, CLIENT_MULTI_STATEMENTS)
	//local status, error = ULib.MySQL:Connect()

	
	//print(status)
	--[[
	ULib.MySQL.onConnected = function()
		ULib.MySQLConnected = true
		
		ULib.ucl.getGroups()
		ULib.ucl.getUsers()
		
		MsgN("[ULX MySQL] Successfully to connect to database.")
	end
	ULib.MySQL.onConnectionFailed = function(db, err)
		ULib.MySQLConnected = false
		MsgN("[ULX MySQL] Failed to connect to database -> " .. err)
	end
	ULib.MySQL:connect()
	]]
end
ULib.Connect()


hook.Add("PlayerInitialSpawn", "PlayerBanned", function( ply )
	if !ULib.MySQLConnected then
		ply:ChatPrint("[ULXMySQL] Your sever was unable to connect to the database. Errors will occur until it's connected.")
	end
	
	if ULib.MySQLConnected and !ULib.MySQLData then
		ply:ChatPrint("[ULXMySQL] Your sever was unable to fetch data from mysql database. Errors will occur until data is retrieved.")
	end
	
	if ENABLE_BANS then
		for k, v in pairs(ULib.bans) do
			if k == ply:SteamID() then
				if tonumber(v.unban) < os.time() and tonumber(v.unban) != 0 then
					ULib.unban(ply:SteamID())
				end
			end
		end
		
		ULib.MySQL:Query("SELECT * FROM `bans` WHERE `steamid`='" .. ply:SteamID() .. "'", function( data )
			data = data[1].data[1]
			
			if data then
				if tonumber(data['unban']) > os.time() or tonumber(data['unban']) == 0 then
					if !ULib.bans[data['steamid']] then
						ULib.bans[data['steamid']] = { reason = data['reason'], admin = data['admin'], unban = tonumber(data['unban']), time = tonumber(data['time']), name = data['name'] }
					else
						ULib.bans[data['steamid']] = { reason = data['reason'], admin = data['admin'], unban = tonumber(data['unban']), time = tonumber(data['time']), name = data['name'] }
						
						
						if data['modified_time'] then
							ULib.bans[data['steamid']].modified_time = tonumber(data['modified_time'])
						end
						
						if data['modified_admin'] then
							ULib.bans[data['steamid']].modified_admin = tonumber(data['modified_admin'])
						end
					end
					
					local time = "for " .. string.NiceTime(os.difftime(data['unban'], os.time()))
					
					if data['unban'] == 0 or data['modified_time'] == 0 then
						time = "Permanent"
					end
					
					game.ConsoleCommand(string.format("kickid %s %s %s\n", ply:UserID(), "Banned for " .. data['reason'] .. " by " .. data['admin'], time ) )
				else
					ULib.unban(data['steamid'])
				end
			end
		end)
	end
	
	if ENABLE_USERS then
		ULib.MySQL:Query("SELECT * FROM `users` WHERE `steamid`='" .. ply:SteamID() .. "'", function( data )
			data = data[1].data[1]
			
			if data then
				if !ULib.ucl.users[data['steamid']] then
					ULib.ucl.users[data['steamid']] = { allow = util.JSONToTable(data['allow']) or {}, name = data['name'] or "", deny = util.JSONToTable(data['deny']) or {}, group = data['group'] or "user" }
				else
					if data['allow'] then
						ULib.ucl.users[data['steamid']].allow = util.JSONToTable(data['allow'])
					end
					
					if data['deny'] then
						ULib.ucl.users[data['steamid']].deny = util.JSONToTable(data['deny'])
					end
					
					if data['group'] then
						ULib.ucl.users[data['steamid']].group = data['group']
					end
					
					ply:SetUserGroup(data['group'])
				end
				
				if data['name'] and data['name'] != ply:Nick() then
					ULib.MySQL:Query("UPDATE `users` SET `name`='" .. ULib.MySQL:Escape(ply:Nick()) .. "' WHERE `steamid`='" .. ply:SteamID() .. "'")
				end
			end
		end)
	end
	
	timer.Simple(3, function()
		if !IsValid(ply) then return end
		
		if ENABLE_BANS then
			xgui.sendDataTable(ply, "bans")
		end
		
		if ENABLE_USERS then
			xgui.sendDataTable(ply, "users")
		end
		
		if ENABLE_GROUPS then
			xgui.sendDataTable(ply, "groups")
		end
	end)
end)

hook.Add("player_connect", "DenyAccessPlayerBanned", function( data )
	if ENABLE_BANS then
		for k, v in pairs(ULib.bans) do
			if k == data['networkid'] then
				if tonumber(v.unban) > os.time() or tonumber(v.unban) == 0 then
					if !v.reason then
						v.reason = "No reason given"
					end
					
					if !v.admin then
						v.admin = "Console"
					end
					
					local time = "for " .. string.NiceTime(os.difftime(v.unban, os.time()))
					
					if v.unban == 0 then
						time = "Permanent"
					end
					
					game.ConsoleCommand(string.format("kickid %s %s %s\n", data['userid'], "Banned for " .. v.reason .. " by " .. v.admin, time ) )
				end
			end
		end
	end
end)

timer.Create("refreshGroups", REFRESH_TIME, 0, function()
	if !ULib.MySQLConnected then MsgN("[ULX MySQL] -> Refresh Groups -> Not connected to the database.") return end
	if !ENABLE_GROUPS then return end
	
	ULib.refreshGroups()
end)


function syncBans( ply )
	if !ply then ply = {} end
	
	xgui.sendDataTable(ply, "bans")
end

function syncUsers( ply )
	if !ply then ply = {} end
	
	xgui.sendDataTable(ply, "users")
end

function syncGroups( ply )
	if !ply then ply = {} end
	
	xgui.sendDataTable(ply, "groups")
end