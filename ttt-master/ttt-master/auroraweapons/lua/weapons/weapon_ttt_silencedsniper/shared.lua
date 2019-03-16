
if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("materials/vgui/ttt/icon_aurora_silencedsniper.vmt")
   resource.AddFile("models/weapons/v_snip_g3sg1.mdl")
   resource.AddFile("models/weapons/w_snip_g3sg1.mdl")
end

SWEP.HoldType           = "ar2"


   SWEP.PrintName          = "Silenced Sniper"

   SWEP.Slot               = 6
if CLIENT then
   SWEP.Icon = "vgui/ttt/icon_aurora_silencedsniper"
end


SWEP.Base               = "weapon_tttbase"
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_EQUIP1

SWEP.Primary.Delay          = 0.9
SWEP.Primary.Recoil         = 4
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 50
SWEP.Primary.Cone = 0.006
SWEP.Primary.ClipSize = 10
SWEP.Primary.ClipMax = 20
SWEP.Primary.DefaultClip = 10
SWEP.AutoSpawnable      = false
SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.ViewModel = "models/weapons/v_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"

SWEP.Primary.Sound = Sound ("Weapon_M4A1.Silenced")
--SWEP.Primary.Sound            = Sound( "Weapon_M4A1.Single" )

--SWEP.IronSightsPos        = Vector( 5, 0, 1 )
SWEP.IronSightsPos = Vector(0, 0, -15)
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

SWEP.EquipMenuData = {
   type = "item_weapon",
   desc = "A long-ranged sniper with the ability to\nkill targets silently."
};
SWEP.AllowDrop = true
SWEP.IsSilent = true

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos      = Vector( 5, -15, -2 )
SWEP.IronSightsAng      = Vector( 2.6, 1.37, 3.5 )

function SWEP:SetZoom(state)
    if CLIENT then 
       return
    else
       if state then
          self.Owner:SetFOV(20, 0.3)
       else
          self.Owner:SetFOV(0, 0.2)
       end
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
     else
        self:EmitSound(self.Secondary.Sound)
    end
    
    self.Weapon:SetNextSecondaryFire( CurTime() + 0.3)
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
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )
         
         local x = ScrW() / 2.0
         local y = ScrH() / 2.0
         local scope_size = ScrH()

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)

         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)

      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end
