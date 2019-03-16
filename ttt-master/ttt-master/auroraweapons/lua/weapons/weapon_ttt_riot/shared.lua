if SERVER then
  AddCSLuaFile( "shared.lua" )
	
	resource.AddFile("models/arleitiss/riotshield/shield.mdl")
	resource.AddFile("models/arleitiss/riotshield/shield.dx80.vtx")
	resource.AddFile("models/arleitiss/riotshield/shield.dx90.vtx")
	resource.AddFile("models/arleitiss/riotshield/shield.phy")
	resource.AddFile("models/arleitiss/riotshield/shield.sw.vtx")
	resource.AddFile("models/arleitiss/riotshield/shield.vvd")
	resource.AddFile("materials/vgui/ttt/icon_aurora_riotshield.vmt")
	resource.AddFile("materials/arleitiss/riotshield/riot_metal.vmt")
	resource.AddFile("materials/arleitiss/riotshield/riot_metal_bump.vtf")
	resource.AddFile("materials/arleitiss/riotshield/shield_cloth.vmt")
	resource.AddFile("materials/arleitiss/riotshield/shield_edges.vmt")
	resource.AddFile("materials/arleitiss/riotshield/shield_glass.vmt")
	resource.AddFile("materials/arleitiss/riotshield/shield_grip.vmt")
	resource.AddFile("materials/arleitiss/riotshield/shield_gripbump.vtf")
end

SWEP.HoldType			= "slam"


   SWEP.PrintName = "Riot Shield"			
   SWEP.Slot      = 7
    if CLIENT then   
      SWEP.Icon = "vgui/ttt/icon_aurora_riotshield"
      end
      SWEP.EquipMenuData = {
      type = "item_defence",
      desc = "A riot shield used to deflect bullets!"
    };


SWEP.Base       = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_EQUIP1

SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay = 2.5
SWEP.Primary.Ammo       = "none"

SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.CanBuy = {ROLE_DETECTIVE} -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once

local sound_single = Sound("phx/epicmetal_soft5.wav")

SWEP.WorldModel = "models/arleitiss/riotshield/shield.mdl" -- The reason im having a world model is that, when it lies on the ground, it should have a model then too.
SWEP.ViewModel  = ""

function SWEP:Deploy()
  if SERVER then
    if IsValid(self.Owner) then self.Owner:DrawViewModel(false) end
    if IsValid(self.ent) then return end --Makes it not able to spawn multiple entities.
    self:SetNoDraw(true)
    self.ent = ents.Create("prop_physics")
      self.ent:SetModel("models/arleitiss/riotshield/shield.mdl")
      self.ent:SetPos(self.Owner:GetPos() + Vector(0,0,5) + (self.Owner:GetForward()*20))
      self.ent:SetAngles(Angle(0,self.Owner:EyeAngles().y,self.Owner:EyeAngles().r))
      self.ent:SetParent(self.Owner)
      self.ent:Fire("SetParentAttachmentMaintainOffset", "eyes", 0.01) -- Garry fucked up the parenting on players in latest patch..
      self.ent:SetCollisionGroup( COLLISION_GROUP_WORLD ) -- Lets it not collide to anything but world. Taken from Nocollide Rightclick Code
      self.ent:Spawn()
      self.ent:Activate()
  end
  return true
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 )

   local tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 80, {self.Owner, self.ent})

   if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and (self.Owner:EyePos() - tr.HitPos):Length() < 100 then
      local ply = tr.Entity

      if SERVER and (not ply:IsFrozen()) then
         local pushvel = tr.Normal * 300

         -- limit the upward force to prevent launching
         pushvel.z = math.Clamp(pushvel.z, 250, 300)

         ply:SetVelocity(ply:GetVelocity() + pushvel)
         self.Owner:SetAnimation( PLAYER_ATTACK1 )

         ply.was_pushed = {att=self.Owner, t=CurTime()} --, infl=self}
      end
      
      if SERVER then
        self.Owner:EmitSound(sound_single)
        self.ent:SetPos(self.Owner:GetPos() + Vector(0,0,0) + (self.Owner:GetForward()*20))
        timer.Simple(0.05, function () self.ent:SetPos(self.Owner:GetPos() + Vector(0,0,5) + (self.Owner:GetForward()*20)) end)
      end

      self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   end
end

function SWEP:Holster()
  if SERVER then
    if not IsValid(self.ent) then return end
    self.ent:Remove()
  end
  return true
end

function SWEP:OnDrop()
  if SERVER then
    self:SetColor(Color(255,255,255,255))
    if not IsValid(self.ent) then return end
    self.ent:Remove()
  end
end

function SWEP:OnRemove()
  if SERVER then
    self:SetColor(Color(255,255,255,255))
    if not IsValid(self.ent) then return end
    self.ent:Remove()
  end
end