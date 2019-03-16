

--[[
User rights. The default level is 2 if your rank isn't here
	1 : Can't open the menu
	2 : Can only use the damagelog when the round isn't active
	3 : Can use the damagelog when spectating and when the round isn't active
	4 : Can always use the damagelog
]]--

--[[
NOTE: Inheritance does not apply! You must add an entry for every user group you
wish to have access to the Damagelogs!
]]--

Damagelog:AddUser("superadmin", 4)
Damagelog:AddUser("admin", 4)
Damagelog:AddUser("primeadmin", 4)
Damagelog:AddUser("primemoderator", 4)
Damagelog:AddUser("operator", 3)
Damagelog:AddUser("trusted", 3)
Damagelog:AddUser("user", 3)
Damagelog:AddUser("prime", 3)
Damagelog:AddUser("moderator", 4)
Damagelog:AddUser("enforcer", 4)
Damagelog:AddUser("primeenforcer", 4)
Damagelog:AddUser("seniormoderator", 4)

--[[
A message is shown when an alive player opens the menu
	1 : if you want to only show it to superadmins
	2 : to let others see that you have abusive admins
]]--

Damagelog.AbuseMessageMode = 1

-- true to enable the RDM Manager, false to disable it

Damagelog.RDM_Manager_Enabled = true

-- Commands to open the report and response menu. Never forget the quotation marks or the whole menu will break!

Damagelog.RDM_Manager_Command = "!report"

-- If you don't answer to your RDMs after the round, you can use this command to re-open the menu

Damagelog.RDM_Manager_Respond = "!respond"