AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   

self.flightvector = self.Entity:GetUp() * ((260*52.5)/66)
self.timeleft = CurTime() + 25
self.Owner = self:GetOwner()
self.Entity:SetModel( "models/led.mdl" )
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_FLY )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3           
self.Entity:SetColor(0,255,128,255)

Glow = ents.Create("env_sprite")
Glow:SetKeyValue("model","orangecore2.vmt")
Glow:SetKeyValue("rendercolor","0 255 128")
Glow:SetKeyValue("scale","0.01")
Glow:SetPos(self.Entity:GetPos()-(self.Entity:GetUp()*15))
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

Shine = ents.Create("env_sprite")
Shine:SetPos(self.Entity:GetPos()-(self.Entity:GetUp()*15))
Shine:SetKeyValue("renderfx", "0")
Shine:SetKeyValue("rendermode", "5")
Shine:SetKeyValue("renderamt", "255")
Shine:SetKeyValue("rendercolor", "0 255 128")
Shine:SetKeyValue("framerate12", "20")
Shine:SetKeyValue("model", "light_glow03.spr")
Shine:SetKeyValue("scale", "0.2")
Shine:SetKeyValue("GlowProxySize", "1")
Shine:SetParent(self.Entity)
Shine:Spawn()
Shine:Activate()

end   

 function ENT:Think()
	

		if self.timeleft < CurTime() then
		self.Entity:Remove()				
		end

	Table	={} 			//Table name is table name
	Table[1]	=self.Owner 		//The person holding the gat
	Table[2]	=self.Entity 		//The cap

	local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + self.flightvector
		trace.filter = Table
	local tr = util.TraceLine( trace )
	

			if tr.HitSky then
			self.Entity:Remove()
			return true
			end
	
				if tr.Hit then

				for k, v in pairs ( ents.FindInSphere( tr.HitPos, 500 ) ) do	// Find anything within ~50 feet
				if v:IsPlayer() || v:IsNPC() then				// If its alive then
				local trace = {}						// Make sure there's not a wall in between
				trace.start = tr.HitPos+tr.HitNormal*30
				trace.endpos = v:GetPos() + Vector(0,0,30)			// Trace to the torso
				trace.filter = self.Entity
				local wp = util.TraceLine( trace )				// If the trace hits a living thing then
				if wp.Entity:IsNPC() then v:Ignite( 5, 0 ) end end	// Fry it for 5 seconds
				end	

					util.BlastDamage(self.Entity, self.Owner, tr.HitPos, 80, 85)
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)			// Where is hits
					effectdata:SetNormal(tr.HitNormal)		// Direction of particles
					effectdata:SetEntity(self.Entity)		// Who done it?
					effectdata:SetScale(0.5)			// Size of explosion
					effectdata:SetRadius(tr.MatType)		// What texture it hits
					effectdata:SetMagnitude(5)			// Length of explosion trails
					util.Effect( "gdca_rayimpact", effectdata )
					util.ScreenShake(tr.HitPos, 10, 5, 1, 10 )
					util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

					self.Entity:Remove()	
					end
	
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector - (self.flightvector/500)  + Vector(math.Rand(-0.2,0.2), math.Rand(-0.2,0.2),math.Rand(-0.1,0.1)) + Vector(0,0,-0.111)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 