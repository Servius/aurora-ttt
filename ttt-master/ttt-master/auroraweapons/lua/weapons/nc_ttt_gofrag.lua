
AddCSLuaFile()

SWEP.HoldType			= "grenade"

if SERVER then
   resource.AddFile( "materials/vgui/ttt/icon_aurora_he.png" )
   resource.AddFile( "models/weapons/v_nc_fraggrenade.mdl")
   resource.AddFile( "models/weapons/w_nc_fraggrenade.mdl")
   resource.AddFile( "models/weapons/w_nc_fraggrenade_thrown.mdl")
   resource.AddFile( "materials/models/weapons/v_models/eq_fraggrenade/m67_grenade_01.vmt")
   resource.AddFile( "materials/models/weapons/w_models/w_eq_fraggrenade/m67_grenade_01.vmt")
end

if CLIENT then
   SWEP.PrintName = "HE Grenade"
   SWEP.Slot = 3
   SWEP.EquipMenuData = {
      type = "item_explosive",
      desc = "A high explosive fragmentation grenade\nadministers high damage through\na wide area,making it ideal for\nclearing out rooms full of innocents."
   };
   
   SWEP.Icon = "vgui/ttt/icon_aurora_he.png"
end

SWEP.Base				= "weapon_tttbasegrenade"
SWEP.Kind				= WEAPON_NADE
SWEP.Spawnable = true

SWEP.UseHands			= true
SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 64
SWEP.ViewModel			= "models/weapons/v_nc_fraggrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_nc_fraggrenade.mdl"
SWEP.Weight			= 5
SWEP.AutoSpawnable      = false
SWEP.AllowDrop = false
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = false
-- really the only difference between grenade weapons: the model and the thrown
-- ent.

function SWEP:GetGrenadeName()
   return "ttt_fraggrenade_proj"
end

