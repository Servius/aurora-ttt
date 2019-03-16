if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType        = "ar2"




   SWEP.PrintName       = "SR-3M Vikhr"
   SWEP.Slot            = 2
if CLIENT then
   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV    = 70
end


SWEP.Base            = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY

SWEP.Primary.Delay         = 0.085
SWEP.Primary.Recoil        = 0.6
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.Damage        = 18
SWEP.Primary.Cone          = 0.033
SWEP.Primary.ClipSize      = 30
SWEP.Primary.ClipMax         = 60
SWEP.Primary.DefaultClip   = 30
SWEP.AutoSpawnable         = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.UseHands        = true
SWEP.ViewModel       = "models/weapons/vikhr_fix/v_dmg_vikhr.mdl"
SWEP.WorldModel         = "models/weapons/vikhr_fix/w_dmg_vikhr.mdl"

SWEP.Primary.Sound = Sound( "Dmgfok_vikhr.Single" )

SWEP.IronSightsPos = Vector (-2.2363, -1.0859, 0.5292)
SWEP.IronSightsAng = Vector (1.4076, 0.0907, 0)


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
