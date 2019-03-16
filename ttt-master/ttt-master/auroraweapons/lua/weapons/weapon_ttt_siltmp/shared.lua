
if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("materials/vgui/ttt/icon_aurora_tmp.vmt")
   resource.AddFile("models/weapons/v_smg_tmp.mdl")
   resource.AddFile("models/weapons/v_smg_tmp.mdl")
end

SWEP.HoldType			= "ar2"


   SWEP.PrintName			= "Silenced TMP"
   SWEP.Slot				= 6
if CLIENT then
   SWEP.EquipMenuData = {
      type="item_weapon",
      model="models/weapons/w_smg_tmp.mdl",
      desc="Silenced submachinegun, uses normal smg\nammo.\n\nVictims will not scream when killed."
   };

   SWEP.Icon = "vgui/ttt/icon_aurora_tmp"
end

SWEP.Base = "weapon_tttbase"
SWEP.Primary.Recoil	= 1.2
SWEP.Primary.Damage = 32
SWEP.Primary.Delay = 0.095
SWEP.Primary.Cone = 0.06
SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.DefaultClip = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.Ammo = "smg1"
SWEP.AutoSpawnable      = false

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock = true -- only buyable once

SWEP.AmmoEnt = "item_ammo_smg1_ttt"

SWEP.IsSilent = true

SWEP.ViewModel			= "models/weapons/v_smg_tmp.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_tmp.mdl"

SWEP.Primary.Sound = Sound( "Weapon_tmp.Single" )
SWEP.IronSightsPos = Vector( 5, -5, 2.2091 )
SWEP.IronSightsAng = Vector( 5, -1.5, 0 )

function SWEP:Deploy()
   self.Weapon:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
   return true
end

function SWEP:WasBought(buyer)
   if IsValid(buyer) then -- probably already self.Owner
      buyer:GiveAmmo( 10, "smg1" )
   end
end
