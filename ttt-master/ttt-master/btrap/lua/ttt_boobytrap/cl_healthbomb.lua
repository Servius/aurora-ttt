/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap/cl_healthbomb.lua
	
	>> The following has parts comprised from the following publicly available works:
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_health_station.lua 
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/entities/ttt_health_station.lua
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
		
	Please do not edit below unless you are a proficient coder!
***/

local ENT 		= {}
ENT.Type		= "anim"

ENT.PrintName 		= BOOBYTRAP.PrintName
ENT.Model 			= BOOBYTRAP.StationModel
ENT.Icon 			= BOOBYTRAP.Icon

ENT.CanUseKey 		= true
-- ENT.CanHavePrints 	= not BOOBYTRAP.DNAOnlyOnTNT
ENT.CanHavePrints 	= true
-- ENT.Projectile 		= true 
--  76561198101347368 

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)	
	self:SetHealth(200)
	self:SetColor( Color(180, 180, 255 ) )
end

local GetPTranslation = LANG and LANG.GetParamTranslation
ENT.TargetIDHint = {
	name = "hstation_name",
	hint = "hstation_hint",
	fmt  = function(ent, txt)
		if LocalPlayer():IsActiveTraitor() then
			return "WARNING: press USE to explode this microwave!"
		end
		local txtfm = GetPTranslation and GetPTranslation(txt, { usekey = Key("+use", "USE"), num = 200 } ) or "Press +use to get health";
		return txtfm
	end
}

function ENT:Draw()
	self:SetColor(Color(180, 180, 255, 255))
	if LocalPlayer():IsActiveTraitor() then
		self:SetColor( Color( 255, 50, 50, 255) )
	end
	self:DrawModel()
end

for k, SWEP in pairs( weapons.GetList() ) do

	if BOOBYTRAP.Conflicts and type(BOOBYTRAP.Conflicts) == "table" and table.HasValue( BOOBYTRAP.Conflicts, SWEP.ClassName ) then
		SWEP.Kind 	= nil
		SWEP.CanBuy = nil
	end
	
	if SWEP.ClassName == "weapon_ttt_defuser" then
		SWEP.Initialize = function ( self )
			self:AddHUDHelp(BOOBYTRAP.DefuserHint, nil )
			return self.BaseClass.Initialize(self)
		end
		SWEP.EquipMenuData.desc = BOOBYTRAP.DefuserDesc
	end
end



scripted_ents.Register( ENT, "ttt_boobytrap", true )

/*** TTT Realistic Booby Trap 76561198101347368 ***/