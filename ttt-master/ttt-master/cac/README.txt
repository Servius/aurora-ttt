=====================================================
 Installation
=====================================================
There is no need to configure or whitelist anything, the anticheat generates a whitelist automatically.

- Copy the folder inside the .zip file into addons/ on your server.
	If you are using FileZilla, set the transfer mode to Binary (not Auto) first.
- Do not install, reinstall or modify the anticheat while your server is up and running with players
- Do not install, reinstall or modify other addons or gamemodes while your server is up and running with players
- Ensure that you do a mapchange or server restart after installing the AC, to make it generate its whitelist.

=====================================================
 Configuration
=====================================================
Menu access
	Edit settings/permissions.lua
	More information can be found in that file.
	
=====================================================
 Menu
=====================================================
Say !cac_menu in chat or use the +cac_menu console command to open the menu

=====================================================
 Logs
=====================================================
Logs are saved in data/cac/playerdata/[PLAYER STEAM ID]/session_########_[DATE]-[TIME]_log.txt
	Eg. data/cac/playerdata/steam_0_1_19269760/session_54546b39_20141101-051017_log.txt
	
	Logs are only saved when the anticheat detects something!


=====================================================
 Bug reports / issues
=====================================================
1. Before asking for support, check the changelog for any fixes that might address your issue
   and update the anticheat.

2. If you're getting banned for "Clientside Lua Execution" and you have installed or modified an addon
   without restarting the server (a reload DOES NOT count), delete data/cac/serverluainformation.txt and
   restart the server.

3. If you've got more than one anticheat installed and you've getting false kicks and bans,
   uninstall all but one of them. Multiple anticheats do not get along.

If you're still having problems, email me at cakenotfound@gmail.com or leave a comment on scriptfodder.

If you contact me and it turns out that your issue is one of the three above, I reserve the right to
withhold further support to avoid having my time wasted.