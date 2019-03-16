/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap/sv_dynamite.lua
	
	>> The following has parts comprised from the following publicly available works:
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_health_station.lua 
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/entities/ttt_health_station.lua
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
	
	Please do not edit below unless you are a proficient coder!
***/


local ENT 		= {}
ENT.Type 	 		= "anim"


ENT.Model 	 		= Model( "models/props_junk/metal_paintcan001a.mdl" )


ENT.PrintName 		= "Dynamite"

function ENT:SetupDataTables()
	self:DTVar("Float",	 0,	"Exploding")
end
function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON )
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:AddEffects(EF_NOSHADOW)
	self:SetNoDraw(false)
	
	if BOOBYTRAP.BreakToDefuse then
		self:SetHealth( BOOBYTRAP.BreakToDefuse )
	end
	
	local physobj = self.Entity:GetPhysicsObject()
	if physobj:IsValid() then
		physobj:AddGameFlag( FVPHYSICS_NO_PLAYER_PICKUP )
	end
	
	self.dt.Exploding = 0
	
end


function ENT:SparkDissolve( TNT )
	if not self.Sparked then
		self.Sparked = true
		local effect = EffectData()
		local pos = IsValid( TNT ) and TNT:GetPos() or self:GetPos()
		effect:SetOrigin( pos )
		util.Effect("cball_explode", effect, nil, true )
		sound.Play( BOOBYTRAP.SparkSound, pos )
	end
end

function ENT:OnRemove()
	if IsValid( self:GetParent() ) then
		constraint.RemoveAll( self:GetParent() )
	end
end

function ENT:OnTakeDamage( dmginfo )
	if BOOBYTRAP.BreakToDefuse then
	
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "BloodImpact", effectdata, true, true )
		
		self:SetHealth(self:Health() - dmginfo:GetDamage())
		if IsValid(self) and self.dt.Exploding == 0 and self:Health() <= 0 and self.Disarm and self.GetArmed and self:GetArmed() then
			
			local dmger = dmginfo:GetAttacker()
			local gun 	= dminfo:GetInflictor()
			self:Disarm( (IsValid(dmger) and dmger:IsPlayer() and dmger) or (IsValid(gun) and gun:IsPlayer() and gun) )
			
			sound.Play( BOOBYTRAP.DefuseSound, self:GetPos() )
		end
		
	else -- damage parent. /* 76561198101347368 */
	
		if IsValid( self:GetParent() ) and self:GetParent().OnTakeDamage then
			self:GetParent():OnTakeDamage( dmginfo )
		end
		
	end
end

function ENT:GetArmed()
	return BOOBYTRAP.DefuseDuringExplode or ( self.dt.Exploding == 0 )
end  


function ENT:Disarm(ply)
	local parent 	= self:GetParent()
	if not IsValid(parent) then return end
	
	local owner 	= parent:GetOwner()
	
	
	SCORE:AddEvent({
		id = BOOBYTRAP.EventDefuse.ID;
		ni = IsValid(ply) and ply:Nick() or "something";
		own = IsValid( owner ) and owner:Nick() or "someone";
	})
	
	local health = ents.Create("ttt_health_station")
	if IsValid(health) then
		health:SetAngles( parent.Entity:GetAngles() )
		health:SetPos( parent.Entity:GetPos() )
		
		parent.Planted = true
		parent:SparkDissolve( parent.TNT )
		parent:Remove()
		health:Spawn()
		
		if BOOBYTRAP.DNAAfterDefuse then
			health.fingerprints = { owner }
		end
		health:SetPlacer( owner )
		
		health:PhysWake() 
	end	
end
	
	
	
scripted_ents.Register( ENT, "ttt_dynamite", true )

/*** TTT Realistic Booby Trap 76561198101347368 ***/