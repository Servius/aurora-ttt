---- Example TTT custom weapon

-- First some standard GMod stuff
if SERVER then
   AddCSLuaFile( "shared.lua" )
end


   SWEP.PrintName = "GALIL"
   SWEP.Slot      = 2 -- add 1 to get the slot number key
if CLIENT then
   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = false
end

SWEP.Base				= "weapon_tttbase"


SWEP.HoldType			= "ar2"

SWEP.Primary.Delay       = 0.1
SWEP.Primary.Recoil      = 0.804
SWEP.Primary.Automatic   = true
SWEP.Primary.Damage      = 21
SWEP.Primary.Cone        = 0.025
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.ClipSize    = 30
SWEP.Primary.ClipMax     = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound       = Sound( "Weapon_GALIL.Single" )

SWEP.IronSightsPos = Vector(-5.1337, -3.9115, 2.1624)
SWEP.IronSightsAng = Vector(0.0873, 0.0006, 0)
SWEP.IronsightsFOV = 60

SWEP.ViewModel  = "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"



SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.IsSilent = false
SWEP.NoSights = false
