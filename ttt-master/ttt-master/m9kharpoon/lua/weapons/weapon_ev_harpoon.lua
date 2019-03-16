if SERVER then
   AddCSLuaFile()
   resource.AddFile("materials/vgui/ttt/icon_aurora_harpoon.vmt")
   resource.AddSingleFile("sound/weapons/blades/impact.wav")
end
    
SWEP.HoldType = "melee"

if CLIENT then

   SWEP.PrintName    = "Harpoon"
   SWEP.Slot         = 6
  
   SWEP.ViewModelFlip = false
   SWEP.ViewModelFOV   = 70

   
end

SWEP.Base               = "weapon_tttbase"
SWEP.Icon = "vgui/ttt/icon_aurora_harpoon"

SWEP.UseHands     = true
SWEP.ViewModel          = "models/props_junk/harpoon002a.mdl"
SWEP.WorldModel         = "models/weapons/w_package.mdl"
SWEP.ShowWorldModel     = false

SWEP.DrawCrosshair      = false
SWEP.Primary.Damage         = 100
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay = 1.1
SWEP.Primary.Ammo       = "none"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.4

SWEP.AllowDrop = false  -- dropping wont reset bones for already equipped weapons, also shadow of a package

SWEP.IsSilent = true

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2

SWEP.WElements = {
  ["harpoon"] = { type = "Model", model = "models/props_junk/harpoon002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.413, 5.945, -0.894), angle = Angle(-5.52, -71.026, -122.169), size = Vector(0.578, 0.578, 0.578), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

if file.Exists( "models/weapons/v_knife_t.mdl", "GAME" ) then
  SWEP.ViewModel        = "models/weapons/v_knife_t.mdl"  -- Weapon view model
  SWEP.VElements = {
    ["harpoon"] = { type = "Model", model = "models/props_junk/harpoon002a.mdl", bone = "v_weapon.knife_Parent", rel = "", pos = Vector(6.3, -6.481, -5.825), angle = Angle(128.731, -17.442, -142.782), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
    }
  SWEP.ViewModelBoneMods = {
    ["v_weapon.Knife_Handle"] = { scale = Vector(1, 1, 1), pos = Vector(-30, 30, -30), angle = Angle(0, 0, 0) },
    ["v_weapon.Right_Arm"] = { scale = Vector(1, 1, 1), pos = Vector(-30, 30, 30), angle = Angle(0, 0, 0) }
    }
end

function SWEP:Initialize()
   if CLIENT and self:Clip1() == -1 then
      self:SetClip1(self.Primary.DefaultClip)
   elseif SERVER then
      self.fingerprints = {}

      self:SetIronsights(false)
   end

   self:SetDeploySpeed(self.DeploySpeed)

   -- compat for gmod update
   if self.SetHoldType then
      self:SetHoldType(self.HoldType or "pistol")
   end

   if CLIENT then
      -- // Create a new table for every weapon instance
      self.VElements = table.FullCopy( self.VElements )
      self.WElements = table.FullCopy( self.WElements )
      self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

      self:CreateModels(self.VElements) -- create viewmodels
      self:CreateModels(self.WElements) -- create worldmodels
      
      -- // init view model bone build function
      if IsValid(self.Owner) and self.Owner:IsPlayer() then
         if self.Owner:Alive() then
            local vm = self.Owner:GetViewModel()
            if IsValid(vm) then
               self:ResetBonePositions(vm)
               -- // Init viewmodel visibility
               if (self.ShowViewModel == nil or self.ShowViewModel) then
                  vm:SetColor(Color(255,255,255,255))
               else
                  -- // however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
                  vm:SetMaterial("Debug/hsv")         
               end
            end
            
         end
      end
   end
end

function SWEP:Holster()
   if CLIENT and IsValid(self.Owner) and not self.Owner:IsNPC() then
      local vm = self.Owner:GetViewModel()
      if IsValid(vm) then
         self:ResetBonePositions(vm)
      end
   end

   return true
end

function SWEP:Equip()
   self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 1) )
end

function SWEP:OnRemove()
  if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
    RunConsoleCommand("lastinv")
  end
end

function SWEP:PrimaryAttack()
    self:FireRocket()
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    self.Weapon:SetNextPrimaryFire(CurTime()+1/(60/60)) 
    self.Weapon:EmitSound(Sound("Weapon_Knife.Slash"))
    self:CheckWeaponsAndAmmo()
end

local function launchRocket(ent, owner, angle)
  if not IsValid(ent) then return false end

  local pos = owner:GetShootPos()
  local ourVector = owner:GetAimVector()
  local aimAngle = ourVector:Angle()
  ent:SetAngles(aimAngle)
  ent:SetPos(pos)
  ent:SetOwner(owner)
  ent:SetPhysicsAttacker(owner)
  ent:Spawn()
  ent.Owner = owner
  ent:Activate()
  eyes = owner:EyeAngles()
  local phys = ent:GetPhysicsObject()
  ourVector:Rotate(angle)
  local velocity = ourVector
  phys:SetVelocity(velocity * 2000)
end

function SWEP:FireRocket()
  if SERVER then
    local rocket = ents.Create("ttt_harpoon")
    launchRocket(rocket, self.Owner, Angle(0,0,0))
    if self.Owner.TripleHarpoon then
      local rocket2 = ents.Create("ttt_harpoon")
      local rocket3 = ents.Create("ttt_harpoon")
      rocket2.canPickup = false
      rocket3.canPickup = false
      launchRocket(rocket2, self.Owner, Angle(0,5,0))
      launchRocket(rocket3, self.Owner, Angle(0,-5,0))
    end
  end
    if SERVER and !self.Owner:IsNPC() then
    local anglo = Angle(-10, -5, 0)   
    self.Owner:ViewPunch(anglo)
    end
end

function SWEP:CheckWeaponsAndAmmo()
  if self.Weapon ~= nil then 
    timer.Simple(.01, function() 
      if not IsValid(self) then return end 
      if not IsValid(self.Owner) then return end

      local owner = self.Owner -- After we strip weapon, self.Owner is no longer valid
      if SERVER then
        self.Owner:StripWeapon("weapon_ev_harpoon")
        timer.Simple(0.2, function()
          owner:Give("weapon_ev_harpoon") end)
      end

      if CLIENT then
        local vm = owner:GetViewModel()
        if IsValid(vm) then
          self:ResetBonePositions(vm)
        end
      end

      end)
  end
end

function SWEP:SecondaryAttack()
return false
end 

function SWEP:Think()
end

function SWEP:GetViewModelPosition( pos, ang )
   if not self.IronSightsPos then return pos, ang end

   local bIron = self:GetIronsights()

   if bIron != self.bLastIron then
      self.bLastIron = bIron
      self.fIronTime = CurTime()

      if bIron then
         self.SwayScale = 0.3
         self.BobScale = 0.1
      else
         self.SwayScale = 1.0
         self.BobScale = 1.0
      end

   end

   local fIronTime = self.fIronTime or 0
   if (not bIron) and fIronTime < CurTime() - IRONSIGHT_TIME then
      return pos, ang
   end

   local mul = 1.0

   if fIronTime > CurTime() - IRONSIGHT_TIME then

      mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )

      if not bIron then mul = 1 - mul end
   end

   local offset = self.IronSightsPos + (ttt_lowered:GetBool() and LOWER_POS or vector_origin)

   if self.IronSightsAng then
      ang = ang * 1
      ang:RotateAroundAxis( ang:Right(),    self.IronSightsAng.x * mul )
      ang:RotateAroundAxis( ang:Up(),       self.IronSightsAng.y * mul )
      ang:RotateAroundAxis( ang:Forward(),  self.IronSightsAng.z * mul )
   end

   pos = pos + offset.x * ang:Right() * mul
   pos = pos + offset.y * ang:Forward() * mul
   pos = pos + offset.z * ang:Up() * mul

   return pos, ang
end

if CLIENT then
   SWEP.vRenderOrder = nil
   function SWEP:ViewModelDrawn()
      if not IsValid(self.Owner) then return end

      local vm = self.Owner:GetViewModel()
      if !IsValid(vm) then return end
      
      if (!self.VElements) then return end
      
      self:UpdateBonePositions(vm)

      if (!self.vRenderOrder) then
         
         -- // we build a render order because sprites need to be drawn after models
         self.vRenderOrder = {}

         for k, v in pairs( self.VElements ) do
            if (v.type == "Model") then
               table.insert(self.vRenderOrder, 1, k)
            elseif (v.type == "Sprite" or v.type == "Quad") then
               table.insert(self.vRenderOrder, k)
            end
         end
         
      end

      for k, name in ipairs( self.vRenderOrder ) do
      
         local v = self.VElements[name]
         if (!v) then self.vRenderOrder = nil break end
         if (v.hide) then continue end
         
         local model = v.modelEnt
         local sprite = v.spriteMaterial
         
         if (!v.bone) then continue end
         
         local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
         
         if (!pos) then continue end
         
         if (v.type == "Model" and IsValid(model)) then

            model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            model:SetAngles(ang)
            -- //model:SetModelScale(v.size)
            local matrix = Matrix()
            matrix:Scale(v.size)
            model:EnableMatrix( "RenderMultiply", matrix )
            
            if (v.material == "") then
               model:SetMaterial("")
            elseif (model:GetMaterial() != v.material) then
               model:SetMaterial( v.material )
            end
            
            if (v.skin and v.skin != model:GetSkin()) then
               model:SetSkin(v.skin)
            end
            
            if (v.bodygroup) then
               for k, v in pairs( v.bodygroup ) do
                  if (model:GetBodygroup(k) != v) then
                     model:SetBodygroup(k, v)
                  end
               end
            end
            
            if (v.surpresslightning) then
               render.SuppressEngineLighting(true)
            end
            
            render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
            render.SetBlend(v.color.a/255)
            model:DrawModel()
            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)
            
            if (v.surpresslightning) then
               render.SuppressEngineLighting(false)
            end
            
         elseif (v.type == "Sprite" and sprite) then
            
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            render.SetMaterial(sprite)
            render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
            
         elseif (v.type == "Quad" and v.draw_func) then
            
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
            
            cam.Start3D2D(drawpos, ang, v.size)
               v.draw_func( self )
            cam.End3D2D()

         end
         
      end
      
   end

   SWEP.wRenderOrder = nil
   function SWEP:DrawWorldModel()
      
      if (self.ShowWorldModel == nil or self.ShowWorldModel) then
         self:DrawModel()
      end
      
      if (!self.WElements) then return end
      
      if (!self.wRenderOrder) then

         self.wRenderOrder = {}

         for k, v in pairs( self.WElements ) do
            if (v.type == "Model") then
               table.insert(self.wRenderOrder, 1, k)
            elseif (v.type == "Sprite" or v.type == "Quad") then
               table.insert(self.wRenderOrder, k)
            end
         end

      end
      
      if (IsValid(self.Owner)) then
         bone_ent = self.Owner
      else
         -- // when the weapon is dropped
         bone_ent = self
      end
      
      for k, name in pairs( self.wRenderOrder ) do
      
         local v = self.WElements[name]
         if (!v) then self.wRenderOrder = nil break end
         if (v.hide) then continue end
         
         local pos, ang
         
         if (v.bone) then
            pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
         else
            pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
         end
         
         if (!pos) then continue end
         
         local model = v.modelEnt
         local sprite = v.spriteMaterial
         
         if (v.type == "Model" and IsValid(model)) then

            model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            model:SetAngles(ang)
            -- //model:SetModelScale(v.size)
            local matrix = Matrix()
            matrix:Scale(v.size)
            model:EnableMatrix( "RenderMultiply", matrix )
            
            if (v.material == "") then
               model:SetMaterial("")
            elseif (model:GetMaterial() != v.material) then
               model:SetMaterial( v.material )
            end
            
            if (v.skin and v.skin != model:GetSkin()) then
               model:SetSkin(v.skin)
            end
            
            if (v.bodygroup) then
               for k, v in pairs( v.bodygroup ) do
                  if (model:GetBodygroup(k) != v) then
                     model:SetBodygroup(k, v)
                  end
               end
            end
            
            if (v.surpresslightning) then
               render.SuppressEngineLighting(true)
            end
            
            render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
            render.SetBlend(v.color.a/255)
            model:DrawModel()
            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)
            
            if (v.surpresslightning) then
               render.SuppressEngineLighting(false)
            end
            
         elseif (v.type == "Sprite" and sprite) then
            
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            render.SetMaterial(sprite)
            render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
            
         elseif (v.type == "Quad" and v.draw_func) then
            
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
            
            cam.Start3D2D(drawpos, ang, v.size)
               v.draw_func( self )
            cam.End3D2D()

         end
         
      end
      
   end

   function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
      
      local bone, pos, ang
      if (tab.rel and tab.rel != "") then
         
         local v = basetab[tab.rel]
         
         if (!v) then return end
         
         -- // Technically, if there exists an element with the same name as a bone
         -- // you can get in an infinite loop. Let's just hope nobody's that stupid.
         pos, ang = self:GetBoneOrientation( basetab, v, ent )
         
         if (!pos) then return end
         
         pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
         ang:RotateAroundAxis(ang:Up(), v.angle.y)
         ang:RotateAroundAxis(ang:Right(), v.angle.p)
         ang:RotateAroundAxis(ang:Forward(), v.angle.r)
            
      else
      
         bone = ent:LookupBone(bone_override or tab.bone)

         if (!bone) then return end
         
         pos, ang = Vector(0,0,0), Angle(0,0,0)
         local m = ent:GetBoneMatrix(bone)
         if (m) then
            pos, ang = m:GetTranslation(), m:GetAngles()
         end
         
         if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
            ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
            ang.r = -ang.r --// Fixes mirrored models
         end
      
      end
      
      return pos, ang
   end

   function SWEP:CreateModels( tab )

      if (!tab) then return end

      -- // Create the clientside models here because Garry says we can't do it in the render hook
      for k, v in pairs( tab ) do
         if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
               string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
            
            v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
            if (IsValid(v.modelEnt)) then
               v.modelEnt:SetPos(self:GetPos())
               v.modelEnt:SetAngles(self:GetAngles())
               v.modelEnt:SetParent(self)
               v.modelEnt:SetNoDraw(true)
               v.createdModel = v.model
            else
               v.modelEnt = nil
            end
            
         elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
            and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
            
            local name = v.sprite.."-"
            local params = { ["$basetexture"] = v.sprite }
            -- // make sure we create a unique name based on the selected options
            local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
            for i, j in pairs( tocheck ) do
               if (v[j]) then
                  params["$"..j] = 1
                  name = name.."1"
               else
                  name = name.."0"
               end
            end

            v.createdSprite = v.sprite
            v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
            
         end
      end
      
   end
   
   local allbones
   local hasGarryFixedBoneScalingYet = false

   function SWEP:UpdateBonePositions(vm)
      
      if self.ViewModelBoneMods then
         
         if (!vm:GetBoneCount()) then return end
         
         -- // !! WORKAROUND !! --//
         -- // We need to check all model names :/
         local loopthrough = self.ViewModelBoneMods
         if (!hasGarryFixedBoneScalingYet) then
            allbones = {}
            for i=0, vm:GetBoneCount() do
               local bonename = vm:GetBoneName(i)
               if (self.ViewModelBoneMods[bonename]) then 
                  allbones[bonename] = self.ViewModelBoneMods[bonename]
               else
                  allbones[bonename] = { 
                     scale = Vector(1,1,1),
                     pos = Vector(0,0,0),
                     angle = Angle(0,0,0)
                  }
               end
            end
            
            loopthrough = allbones
         end
         //!! ----------- !! --
         
         for k, v in pairs( loopthrough ) do
            local bone = vm:LookupBone(k)
            if (!bone) then continue end
            
            -- // !! WORKAROUND !! --//
            local s = Vector(v.scale.x,v.scale.y,v.scale.z)
            local p = Vector(v.pos.x,v.pos.y,v.pos.z)
            local ms = Vector(1,1,1)
            if (!hasGarryFixedBoneScalingYet) then
               local cur = vm:GetBoneParent(bone)
               while(cur >= 0) do
                  local pscale = loopthrough[vm:GetBoneName(cur)].scale
                  ms = ms * pscale
                  cur = vm:GetBoneParent(cur)
               end
            end
            
            s = s * ms
            //!! ----------- !! --
            
            if vm:GetManipulateBoneScale(bone) != s then
               vm:ManipulateBoneScale( bone, s )
            end
            if vm:GetManipulateBoneAngles(bone) != v.angle then
               vm:ManipulateBoneAngles( bone, v.angle )
            end
            if vm:GetManipulateBonePosition(bone) != p then
               vm:ManipulateBonePosition( bone, p )
            end
         end
      else
         self:ResetBonePositions(vm)
      end
         
   end
    
   function SWEP:ResetBonePositions(vm)
      
      if (!vm:GetBoneCount()) then return end
      for i=0, vm:GetBoneCount() do
         vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
         vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
         vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
      end
      
   end

   -- // Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
   -- // Does not copy entities of course, only copies their reference.
   -- // WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
   function table.FullCopy( tab )

      if (!tab) then return nil end
      
      local res = {}
      for k, v in pairs( tab ) do
         if (type(v) == "table") then
            res[k] = table.FullCopy(v) --// recursion ho!
         elseif (type(v) == "Vector") then
            res[k] = Vector(v.x, v.y, v.z)
         elseif (type(v) == "Angle") then
            res[k] = Angle(v.p, v.y, v.r)
         else
            res[k] = v
         end
      end
      
      return res
      
   end
end