if SERVER then
   AddCSLuaFile( "shared.lua" )
end


   SWEP.PrintName = "AK47"
   SWEP.Slot      = 2
if CLIENT then
   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = true
end

SWEP.Base            = "weapon_tttbase"

SWEP.HoldType        = "ar2"

SWEP.Primary.Delay       = 0.08
SWEP.Primary.Recoil      = 2.2
SWEP.Primary.Automatic   = true
SWEP.Primary.Damage      = 25
SWEP.Primary.Cone        = 0.025
SWEP.Primary.Ammo        = "Pistol"
SWEP.Primary.ClipSize    = 30
SWEP.Primary.ClipMax     = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound       = Sound( "Weapon_AK47.Single" )

SWEP.IronSightsPos = Vector( 6.05, -5, 2.4 )
SWEP.IronSightsAng = Vector( 2.2, -0.1, 0 )

SWEP.ViewModel  = "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"