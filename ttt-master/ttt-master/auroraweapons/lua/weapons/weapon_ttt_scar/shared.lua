if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType        = "ar2"



   SWEP.PrintName       = "SCAR"           
   SWEP.Slot               = 2
if CLIENT then
   SWEP.ViewModelFlip   = false
   SWEP.ViewModelFOV    = 70
end

SWEP.Base            = "weapon_tttbase"
SWEP.Kind            = WEAPON_HEAVY

SWEP.Primary.Delay         = 0.092
SWEP.Primary.Recoil        = 0.32
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.Damage        = 20
SWEP.Primary.Cone          = 0.03
SWEP.Primary.ClipSize      = 30
SWEP.Primary.ClipMax         = 60
SWEP.Primary.DefaultClip   = 30
SWEP.AutoSpawnable         = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.HeadshotMultiplier = 3

SWEP.ViewModel       = "models/weapons/scar/v_fnscarh.mdl"
SWEP.WorldModel         = "models/weapons/scar/w_fn_scar_h.mdl"

SWEP.Primary.Sound = Sound( "Masada.Single" )

SWEP.IronSightsPos = Vector(-2.652, 0.187, -0.003)
SWEP.IronSightsAng = Vector(2.565, 0.034, 0)

SWEP.VElements = {
   ["rect"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "gun_root", rel = "", pos = Vector(0, -0.461, 3.479), angle = Angle(0, 0, 90), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/wystan/attachments/eotech/rect", skin = 0, bodygroup = {} }
}

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

-- We were bought as special equipment, and we have an extra to give
function SWEP:WasBought(buyer)
   if IsValid(buyer) then -- probably already self.Owner
      buyer:GiveAmmo( 30, "smg1" )
   end
end

if CLIENT then
   function SWEP:DrawHUD()
      if not self:GetIronsights() or GetConVar("ttt_ironsights_lowered"):GetBool() then
        return self.BaseClass.DrawHUD(self)
      end
   end
end