if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType        = "ar2"




   SWEP.PrintName       = "HK G3A3"
   SWEP.Slot            = 2
if CLIENT then
   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV    = 70
end


SWEP.Base            = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY

SWEP.Primary.Delay         = 0.13
SWEP.Primary.Recoil        = 0.5
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "smg1"
SWEP.Primary.Damage        = 22
SWEP.Primary.Cone          = 0.02
SWEP.Primary.ClipSize      = 20
SWEP.Primary.ClipMax         = 40
SWEP.Primary.DefaultClip   = 20
SWEP.AutoSpawnable         = true
SWEP.AmmoEnt               = "item_ammo_smg1_ttt"

SWEP.UseHands        = true
SWEP.ViewModel       = "models/weapons/hkg3a3/v_hk_g3_rif.mdl"
SWEP.WorldModel         = "models/weapons/hkg3a3/w_hk_g3.mdl"

SWEP.Primary.Sound = Sound( "hk_g3_weapon.Single" )

SWEP.IronSightsPos = Vector(-2.419, -2.069, 1.498)
SWEP.IronSightsAng = Vector(-0.109, -0.281, 0)


function SWEP:SetZoom(state)
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then
      self.Owner:SetFOV(55, 0.3)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self.Weapon:GetNextSecondaryFire() > CurTime() then return end

   bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom(bIronsights)
   end

   self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
   self.Weapon:DefaultReload( ACT_VM_RELOAD );
   self:SetIronsights( false )
   self:SetZoom(false)
end


function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end
