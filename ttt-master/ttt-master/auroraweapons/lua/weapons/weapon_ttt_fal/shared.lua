if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType        = "ar2"




   SWEP.PrintName       = "FN FAL"
   SWEP.Slot            = 2
if CLIENT then
   SWEP.ViewModelFlip   = false
   SWEP.ViewModelFOV    = 55
end


SWEP.Base            = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY

SWEP.Primary.Delay         = 0.12
SWEP.Primary.Recoil        = 0.8
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.Damage        = 20
SWEP.Primary.Cone          = 0.018
SWEP.Primary.ClipSize      = 30
SWEP.Primary.ClipMax         = 60
SWEP.Primary.DefaultClip   = 30
SWEP.AutoSpawnable         = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.UseHands        = true
SWEP.ViewModel       = "models/weapons/fn_fal/v_fnfalnato.mdl"
SWEP.WorldModel         = "models/weapons/fn_fal/w_fn_fal.mdl"

SWEP.Primary.Sound = Sound( "fnfal.Single" )

SWEP.IronSightsPos = Vector(-3.161, -1.068, 1.24)
SWEP.IronSightsAng = Vector(0.425, 0.05, 0)


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

if CLIENT then
   function SWEP:DrawHUD()
      if not self:GetIronsights() or GetConVar("ttt_ironsights_lowered"):GetBool() then
        return self.BaseClass.DrawHUD(self)
      end
   end
end