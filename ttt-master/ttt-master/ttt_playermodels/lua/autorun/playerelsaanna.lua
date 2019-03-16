player_manager.AddValidModel( "Queen Elsa","models/player_elsa.mdl" )
player_manager.AddValidModel( "Princess Anna","models/player_anna.mdl" )
player_manager.AddValidHands( "Queen Elsa", "models/elsa_arms.mdl", 0, "00000000" )
player_manager.AddValidHands( "Princess Anna", "models/anna_arms.mdl", 0, "00000000" )

--Add NPC
local Category = "Frozen NPCs"

local NPCA = {
	Name = "Queen Elsa",
	Class = "npc_citizen",
	Model = "Models/frozennpc/npc_elsa.mdl",
	Health = "100",
	KeyValues = { citizentype = 4 },
	Category = Category
}
local NPCB = {
	Name = "Princess Anna",
	Class = "npc_citizen",
	Model = "Models/frozennpc/npc_anna.mdl",
	Health = "100",
	KeyValues = { citizentype = 4 },
	Category = Category
}

list.Set( "NPC", "npc_elsa", NPCA )
list.Set( "NPC", "npc_anna", NPCB )

