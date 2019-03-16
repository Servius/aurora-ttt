AddCSLuaFile()

E_Boots = 128

if SERVER then
   resource.AddFile("materials/VGUI/ttt/boots.vmt")
end

local function Init()
       local equipitem = {
              id = E_Boots,
              loadout = false,
              type = "item_passive",
              material = "vgui/ttt/boots.vtf",
              name = "Ironboots",
              desc = "These boots are made of iron.\nThis somehow negates fall damage."
      }
      table.insert( EquipmentItems[ROLE_TRAITOR], equipitem )
	  table.insert( EquipmentItems[ROLE_DETECTIVE], equipitem )
end
hook.Add( "InitPostEntity", "LoadEquipItem", Init )



hook.Add("EntityTakeDamage", "E_Boots", function(ent, dmginfo)
	if (IsValid(ent) and ent:IsPlayer() and dmginfo:IsFallDamage() and ent:HasEquipmentItem(E_Boots)) then
		dmginfo:ScaleDamage(0) 
		ent:EmitSound( "physics/metal/metal_box_impact_hard3.wav", 450, 75 )
		ent:EmitSound( "physics/metal/metal_solid_impact_hard4.wav", 450, 75 )
			end
end)
	