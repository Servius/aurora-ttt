/*
	Addon by Voikanaa	
*/

local Category = "Voikanaa NPC"

local NPC = {	Name = "Snoop Dogg",
				Class = "npc_citizen",
				Model = "models/player/voikanaa/snoop_dogg_npc.mdl",
				Health = "100",
				KeyValues = { citizentype = 4 },
				Weapons = { "weapon_smg1" },
				Category = Category }

list.Set( "NPC", "npc_snoopdogg_hq", NPC )


// ----------------------- ENEMY --------------------------


local Category = "Voikanaa NPC"

local NPC = {	Name = "Snoop Dogg Enemy",
				Class = "npc_combine_s",
				Model = "models/player/voikanaa/snoop_dogg_npc.mdl",
				Health = "100",
				Weapons = { "weapon_smg1" },
				Category = Category }

list.Set( "NPC", "npc_snoopdogg_hq_enemy", NPC )