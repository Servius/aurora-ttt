AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Projectile 		= true
ENT.hasKilled		= false
ENT.canPickup		= true

if SERVER then

function ENT:Initialize()
	
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	--self.NextThink = CurTime() +  1

	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10)
	end
	
	self.InFlight = true

	util.PrecacheSound("physics/metal/metal_grenade_impact_hard3.wav")
	util.PrecacheSound("physics/metal/metal_grenade_impact_hard2.wav")
	util.PrecacheSound("physics/metal/metal_grenade_impact_hard1.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet1.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet2.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet3.wav")

	self.Hit = { 
	Sound("physics/metal/metal_grenade_impact_hard1.wav"),
	Sound("physics/metal/metal_grenade_impact_hard2.wav"),
	Sound("physics/metal/metal_grenade_impact_hard3.wav")};

	self.FleshHit = { 
	Sound("physics/flesh/flesh_impact_bullet1.wav"),
	Sound("physics/flesh/flesh_impact_bullet2.wav"),
	Sound("physics/flesh/flesh_impact_bullet3.wav")}

	self:GetPhysicsObject():SetMass(2)	

	self.Entity:SetUseType(SIMPLE_USE)
end

function ENT:Think()
	
	--[[
	self.lifetime = self.lifetime or CurTime() + 20

	if CurTime() > self.lifetime then
		self:Remove()
	end
	]]
	
	if self.InFlight and self.Entity:GetAngles().pitch <= 55 then
		self.Entity:GetPhysicsObject():AddAngleVelocity(Vector(0, 10, 0))
	end
	
end

function ENT:Disable()

	self.PhysicsCollide = function() end
	--self.lifetime = CurTime() + 30
	self.InFlight = false
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function ENT:PhysicsCollide(data, phys)
	
	pain = math.max((data.Speed/4), 100)
	
	local Ent = data.HitEntity
	if !(Ent:IsValid() or Ent:IsWorld()) then return end

	if Ent:IsWorld() and self.InFlight then
	
			if data.Speed > 500 then
				self:EmitSound(Sound("weapons/blades/impact.wav"))
				self:SetPos(data.HitPos - data.HitNormal * 10)
				self:SetAngles(self.Entity:GetAngles())
				self:GetPhysicsObject():EnableMotion(false)
			else
				self:EmitSound(self.Hit[math.random(1, #self.Hit)])
			end

			self:Disable()
			
	elseif Ent.Health then
		if not(Ent:IsPlayer() or Ent:IsNPC() or Ent:GetClass() == "prop_ragdoll") then 
			util.Decal("ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
			self:EmitSound(self.Hit[math.random(1, #self.Hit)])
			self:Disable()
		else
			local effectdata = EffectData()
			effectdata:SetStart(data.HitPos)
			effectdata:SetOrigin(data.HitPos)
			effectdata:SetScale(1)
			util.Effect("BloodImpact", effectdata)

			self:EmitSound(self.FleshHit[math.random(1,#self.Hit)])
		end

			local spos = self.Owner:GetShootPos()
			local sdest = spos + (self.Owner:GetAimVector() * 70)
			local dmg = DamageInfo()
				dmg:SetDamage(pain)
				dmg:SetAttacker(self.Owner)
				dmg:SetInflictor(self.Entity)
				dmg:SetDamageForce(self.Owner:GetAimVector() * (10 * pain))
				dmg:SetDamagePosition(self.Owner:GetPos())
				dmg:SetDamageType(DMG_CLUB)

			local tr = util.TraceLine({start=self:GetPos(), endpos=Ent:LocalToWorld(Ent:OBBCenter()), filter={self.Entity, self:GetOwner()}, mask=MASK_SHOT_HULL})
			Ent:DispatchTraceAttack(dmg, tr, sdest)
		if Ent:IsPlayer() then
			self.hasKilled = true

			local harpoon = self.Entity
   		local prints = self.fingerprints
   		local bone = tr.PhysicsBone
			local pos = tr.HitPos
			local norm = tr.Normal
			local ang = Angle(-28,0,0) + norm:Angle()
			ang:RotateAroundAxis(ang:Right(), -90)
			pos = pos - (ang:Forward() * 8)
			Ent.effect_fn = function(rag)
                if not IsValid(harpoon) or not IsValid(rag) then return end

                harpoon:SetPos(pos)
                harpoon:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                harpoon:SetAngles(ang)

                harpoon:SetMoveCollide(MOVECOLLIDE_DEFAULT)
                harpoon:SetMoveType(MOVETYPE_VPHYSICS)

                harpoon.fingerprints = prints
                harpoon:SetNWBool("HasPrints", true)

                --harpoon:SetSolid(SOLID_NONE)
                -- harpoon needs to be trace-able to get prints
                local phys = harpoon:GetPhysicsObject()
                if IsValid(phys) then
                   phys:EnableCollisions(false)
                end

                constraint.Weld(rag, harpoon, bone, 0, 0, true)

                rag:CallOnRemove("ttt_harpoon_cleanup", function() SafeRemoveEntity(harpoon) end)
            end
		end
	end

	self.Entity:SetOwner(nil)
end

function ENT:Use(activator, caller) 
	if not self.hasKilled and self.canPickup and (activator:IsPlayer()) and activator:GetWeapon("weapon_ttt_harpoon") == NULL then
		activator:Give("weapon_ttt_harpoon")
		self.Entity:Remove()
	end
end

end

if CLIENT then

ENT.PrintName = "Harpoon"
ENT.Icon = "vgui/ttt/icon_aurora_harpoon"

function ENT:Draw()
	self.Entity:DrawModel()
end

end 