/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap_config.lua
	
	If you need help configuring below, please submit a ticket or add me on Steam:
		http://steamcommunity.com/profiles/76561197964365747
	
***/



/*******************************************************************
	TTT INFO
		Name is used in the menu for Traitor purchases. 
		Description is shown in the Traitor shop.
		PrintName is used for the post round score logs:
			"(player) was blown up by (BOOBYTRAP.PrintName)"
*******************************************************************/
BOOBYTRAP.Name 				= "Health Station Booby Trap"
BOOBYTRAP.PrintName 		= "a Booby Trapped health station"
BOOBYTRAP.Desc 				= [[Use this kit and some ninja-like 
	moves to convert a detective's 
	health station into a death machine...
	or just conveniently drop one your own!]]
BOOBYTRAP.Type = "item_explosive"

	
/*******************************************************************
  ICON
	  Set the icon image below. 
	  Setting a missing image will result in a purple texture in the Traitor shop. 

		See autorun/sh_ttt_boobytrap.lua for more.
		>> Other Options:
			BOOBYTRAP.Icon 		= "gmodfriends/ttt_boobytrap/red.png"
			BOOBYTRAP.Icon 		= "gmodfriends/ttt_boobytrap/yellow.png"
			BOOBYTRAP.Icon 		= "gmodfriends/ttt_boobytrap/green.png"
			BOOBYTRAP.Icon 		= "gmodfriends/ttt_boobytrap/blue.png"
		>> With Clock:
			BOOBYTRAP.Icon 		= "gmodfriends/ttt_boobytrap/red_clock.png"
			BOOBYTRAP.Icon 		= "gmodfriends/ttt_boobytrap/yellow_clock.png"
			BOOBYTRAP.Icon 		= "gmodfriends/ttt_boobytrap/green_clock.png"
			BOOBYTRAP.Icon 		= "gmodfriends/ttt_boobytrap/blue_clock.png"
*******************************************************************/
BOOBYTRAP.Icon 				= "gmodfriends/ttt_boobytrap/blue_clock.png"



/*******************************************************************
	EVENTS 
		Score event recognition. 
		If you have other custom events make sure the event ID's dont conflict! 
*******************************************************************/
BOOBYTRAP.EventExplode 		= { ID = 420, 	Text = "%s's Booby Trap has exploded!", 						Short = "Booby Trap exploded", 	Icon = "icon16/bug_error.png" }
BOOBYTRAP.EventDefuse 		= { ID = 421, 	Text = "%s defused a Booby Trap belonging to %s", 			Short = "Booby Trap disarmed", 	Icon = "icon16/bug_delete.png" }
BOOBYTRAP.EventPlant 		= { ID = 422, 	Text = "%s set up a Booby Trapped on %s's health station", 	Short = "Booby Trap planted", 	Icon = "icon16/bug_add.png" }
BOOBYTRAP.EventDrop 		= { ID = nil, 	Text = "%s dropped a Booby Trapped.", 						Short = "Booby Trap dropped", 	Icon = "icon16/bug_link.png" }



/*** OnPlanted - PopUp message (MsgStack) to display to the planter ***/
BOOBYTRAP.OnPlanted 		= "You have sucessfully rigged this health station."
BOOBYTRAP.OnPlantedColor 	= Color(255,183,175)


/*** OnDefused - PopUp message (MsgStack) to display to the defuser ***/
BOOBYTRAP.OnDefused 		= "You have sucessfully disarmed this %s."
BOOBYTRAP.OnDefusedColor 	= Color(153,216,255)



/*** LimitedStock - Can this swep be purchased multiple times ***/
BOOBYTRAP.LimitedStock 		= true

/*** AllowDrop - Can this swep be dropped ***/
BOOBYTRAP.AllowDrop 		= false

/*** DefuseDuringExplode - Can we defuse the TNT while its in the process of exploding ***/
BOOBYTRAP.DefuseDuringExplode = false

/*** DNAOnlyOnTNT - Should the DNA of the planter be available on the TNT only, or both the machine and tnt... ***/
BOOBYTRAP.DNAOnlyOnTNT 		= true

/*** DNAAfterDefuse - If DNAOnlyOnTNT is enabled, should DNA somehow make its way to the health station after defusal for detectives ***/
BOOBYTRAP.DNAAfterDefuse 	= false

/*** PlayerEmotes - Should the activator say a sound. See list in sounds below ***/
BOOBYTRAP.PlayerEmotes 		= true

/*** MaxDistance - Welding Max distance the player can attach an explosive from. ***/
BOOBYTRAP.MaxDistance 		= 40

/*** BlastDamage - BlastDamage during explosion. Recommended range: 120-250 ***/
BOOBYTRAP.BlastDamage 		= 250

/*** ExplosionDelay - Delay of explosion after user activation (in seconds). Recommended range: 0.1-0.3 ***/
BOOBYTRAP.ExplosionDelay 	= 2.2

/*** AnimDuration - Duration of animations ( in seconds ). Recommended range: 0.1-0.3 ***/
BOOBYTRAP.AnimDuration 		= 0.2



/*******************************************************************
	BreakToDefuse.
		Allow the explosive to be disabled through brute force.
		Comment, set to false or 0 to disable and the damage will be dealt to the station. 
		Crowbar doesnt seem to register damage to the entity properly from all angles so its default to off.
*******************************************************************/
-- BOOBYTRAP.BreakToDefuse 	= 80




/*******************************************************************
	MODELS - I.E.D. of choice: timed dynamite
		Calculations have been made for these models so changing these requires additional scripting. 
		PM me for assistance if you use a dif health staion model.
*******************************************************************/
BOOBYTRAP.StationModel 		= Model("models/props/cs_office/microwave.mdl")
BOOBYTRAP.TNTModel 			= Model("models/dav0r/tnt/tnttimed.mdl")
-- BOOBYTRAP.TNTModel 		= Model("models/dav0r/tnt/tnt.mdl")



/*******************************************************************
	SCALE - Of the TNT model. Recommended Range: 0.2-0.3  
		Changing this will skew some renderings.
*******************************************************************/
BOOBYTRAP.TNTScale 			= 0.3



/*******************************************************************
	SIMILAR WEAPON PRIORITY 
		Used to stop duplicate, or conflicting, weapons in the Traitor menu without having to uninstall the other files. 
		If enabled this script will look for and prevent the following weapons from being available for purchase:
*******************************************************************/
-- BOOBYTRAP.Conflicts 		= { 
	-- "weapon_ttt_death_station";
	-- "weapon_ttt_deathstation";
	-- "weapon_ttt_healthbomb";
	-- "weapon_ttt_bomb_station"; 
	-- "weapon_ttt_bombstation"; 
	-- "weapon_ttt_splodestation";
-- }



/*******************************************************************
	DEFUSER - Hints for the adjusted defuser swep. 
*******************************************************************/
BOOBYTRAP.DefuserHint 		= "Click to defuse traitorous stuff..."
BOOBYTRAP.DefuserDesc 		= "Defuses traitorous stuff."
BOOBYTRAP.DefuseSound 		= Sound("c4.disarmfinish") -- defined in TTT



/*******************************************************************
	SOUNDS 
*******************************************************************/
BOOBYTRAP.DropSound 		= Sound("weapons/slam/throw.wav")
BOOBYTRAP.StickSound 		= Sound("physics/cardboard/cardboard_box_impact_soft7.wav")
BOOBYTRAP.AlarmSound 		= Sound("ambient/alarms/city_firebell_loop1.wav")
-- BOOBYTRAP.SparkSound 		= Sound("npc/assassin/ball_zap1.wav")
BOOBYTRAP.SparkSound 		= Sound("physics/plastic/plastic_box_break1.wav")

-- BOOBYTRAP.ExplodeSound 		= Sound("siege/big_explosion.wav")
-- BOOBYTRAP.ExplodeSound 		= Sound("weapons/explode5.wav")
-- BOOBYTRAP.ExplodeSound 		= Sound("weapons/explode4.wav")
BOOBYTRAP.ExplodeSound 		= Sound("weapons/explode3.wav")

-- BOOBYTRAP.ExplodeUnderH2O 	= Sound("weapons/underwater_explode3.wav")
BOOBYTRAP.ExplodeUnderH2O 	= Sound("weapons/underwater_explode3.wav")



/*******************************************************************
	EMOTES! 
		The translations ( or ["keys"] ) are for ease of configuration and are not used in the code.
		You can add any sounds you like but if its a custom sound make sure to add your own resources!
*******************************************************************/
BOOBYTRAP.PlayerSounds 		= {
	-- ["oh shit"] = "vo/npc/Barney/ba_ohshit03.wav";
	-- ["oh shit too late"] = "vo/canals/matt_toolate.wav";
	["oh fiddlesticks what now"] = "vo/k_lab/kl_fiddlesticks.wav";
	["you must get out of here"] = "vo/k_lab/kl_getoutrun02.wav";
	["ahhhh"] = "vo/k_lab/kl_ahhhh.wav";
	["run!"] = "vo/k_lab/kl_getoutrun03.wav";
	["what is it?"] = "vo/k_lab/kl_whatisit.wav";
	["i wish i knew!"] = "vo/k_lab/kl_wishiknew.wav";
	["fascinating!"] = "vo/k_lab2/kl_slowteleport01.wav";
	["look out"] = "vo/ravenholm/monk_blocked02.wav";
	["well i'll be damned"] = "vo/Streetwar/rubble/ba_illbedamned.wav";
	["now what?"] = "vo/npc/male01/gordead_ans01.wav";
	["oh god"] = "vo/npc/male01/gordead_ans04.wav";
	["we're done for"] = "vo/npc/male01/gordead_ans14.wav";
	["this is bad"] = "vo/npc/male01/gordead_ques10.wav";
	["and things were going so well"] = "vo/npc/male01/gordead_ans02.wav";
	["don't tell me"] = "vo/npc/male01/gordead_ans03.wav";
	["please no"] = "vo/npc/male01/gordead_ans06.wav";
	["this doesn't look good"] = "vo/trainyard/male01/cit_window_use01.wav";
	["i can't look"] = "vo/k_lab/ba_cantlook.wav";
	["no! help!"] = "vo/coast/bugbait/sandy_help.wav";
	["this is where i get off"] = "vo/Citadel/gman_exit10.wav";
	["you got here at a bad time"] = "vo/canals/shanty_badtime.wav";
	["look out!"] = "vo/npc/Barney/ba_lookout.wav";
	["damnit"] = "vo/npc/Barney/ba_damnit.wav";
	["woops"] = "vo/npc/male01/whoops01.wav";
	["what did i do to deserve this?"] = "vo/npc/male01/vanswer14.wav";
	["no no"] = "vo/npc/male01/no01.wav";
	["how about that"] = "vo/npc/male01/answer25.wav";
	["you never know"] = "vo/npc/male01/answer22.wav";
	["you never can tell"] = "vo/npc/male01/answer23.wav";
	["whoops"] = "vo/k_lab/ba_whoops.wav";
	["oops"] = "vo/npc/male01/whoops01.wav";
	["get down"] = "vo/npc/Barney/ba_getdown.wav";
	["gtho"] = "vo/npc/male01/gethellout.wav";
	["noes"] = "vo/npc/Alyx/ohno_startle01.wav";
	["run"] = "vo/npc/male01/strider_run.wav";
	["run for your life"] = "vo/npc/male01/runforyourlife01.wav";
	["fantastic"] = "vo/npc/male01/fantastic01.wav";
	["moan"] = "vo/npc/male01/moan01.wav";
	["noo"] = "vo/npc/Barney/ba_no01.wav";
	["nooo"] = "vo/npc/male01/no02.wav";
	["oh no"] = "vo/npc/male01/ohno.wav";
	["i don't like the looks of this"] = "vo/npc/Barney/ba_danger02.wav";
}