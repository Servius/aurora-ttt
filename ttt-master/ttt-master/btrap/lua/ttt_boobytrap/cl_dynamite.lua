/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap/cl_dynamite.lua
	
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
		
	Please do not edit below unless you are a proficient coder!
***/


local ENT 			= {}
ENT.Type 	 		= "anim"
ENT.PrintName 		= "Dynamite"
ENT.Model 	 		= Model( "models/props_junk/metal_paintcan001a.mdl" )
ENT.PrintName 		= BOOBYTRAP.PrintName
ENT.Icon 			= BOOBYTRAP.Icon
ENT.CanHavePrints 	= true

function ENT:SetupDataTables()
	self:DTVar("Float",	 0,	"Exploding")	
end

function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if BOOBYTRAP.BreakToDefuse then
		self:SetHealth( BOOBYTRAP.BreakToDefuse )
	end
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON )
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:AddEffects(EF_NOSHADOW)
	self:SetNoDraw(false)
end
/*** 76561198101347368 ***/
function ENT:Draw()

	if not ( self.CSModelEnt and self.CSModelEnt:IsValid() ) then
		self.CSModelEnt = ClientsideModel( BOOBYTRAP.TNTModel )
		self.CSModelEnt:SetNoDraw(true)
	end
	
	local add = Vector( 0,0,0 )
	if self.dt.Exploding > 0 then
		local percent = ( CurTime() - self.dt.Exploding ) / BOOBYTRAP.ExplosionDelay
		add.x, add.y, add.z = math.Rand(-1*percent,percent), math.Rand(-1*percent,percent), math.Rand(-1*percent,percent)
	end
	
	self.CSModelEnt:SetModelScale( BOOBYTRAP.TNTScale or 0.3,0)
	self.CSModelEnt:SetPos(self:GetPos() + add )
	self.CSModelEnt:SetAngles(self:GetAngles())
	self.CSModelEnt:DrawModel()
	
end



scripted_ents.Register( ENT, "ttt_dynamite", true )

/*** TTT Realistic Booby Trap 76561198101347368 ***/