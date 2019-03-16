/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap/sv_boobytrap.lua
	
	>> The following has parts comprised from the following publicly available works:
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_health_station.lua
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/entities/ttt_health_station.lua
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
		
	Please do not edit below unless you are a proficient coder!
***/


local SWEP 					= weapons.Get("weapon_tttbase")
SWEP.Base 					= "weapon_tttbase"

SWEP.HoldType 				= "duel"
SWEP.Slot 					= 6

SWEP.NoSights 				= true
SWEP.DrawCrosshair      	= true
SWEP.ViewModelFlip 			= false
SWEP.ViewModelFOV 			= 80
SWEP.ViewModel				= "models/weapons/v_pist_elite.mdl"
SWEP.WorldModel         	= "models/weapons/w_pist_elite.mdl"

SWEP.Sound 					= BOOBYTRAP.DropSound
SWEP.Icon 					= BOOBYTRAP.Icon
SWEP.PrintName 				= BOOBYTRAP.Name

SWEP.Kind 					= WEAPON_EQUIP
SWEP.LimitedStock 			= BOOBYTRAP.LimitedStock
SWEP.AllowDrop 				= BOOBYTRAP.AllowDrop

SWEP.CanBuy 				= {ROLE_TRAITOR}

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       	= "none"
SWEP.Primary.Delay 			= 1 + ( BOOBYTRAP.AnimDuration or 0.2 )

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     	= "none"
SWEP.Secondary.Delay 		= 1 + ( BOOBYTRAP.AnimDuration or 0.2 )


SWEP.FoundStation 			= false
SWEP.IsMicrowave 			= true

/*** NORMALIZE
	Force the model angles to be normal, or parallel, relative to the health station.
	Not in the config because it causes the model to be partially hidden and would just plain confuse some clients.
***/
SWEP.PlantNormal 			= true
 
function SWEP:Think()
	if self.NextDrop and self.NextDrop < CurTime() then
		self:HealthDrop()
	end	
	
	local found = false
	local position = self.Owner:GetShootPos()
	local epos = position + self.Owner:GetAimVector() * BOOBYTRAP.MaxDistance
	local trace = util.TraceLine({start=position, endpos=epos, filter={self.Owner, self}, mask=MASK_SOLID})
	-- local trace = self.Owner:GetEyeTrace()
	if ( trace.HitNonWorld and trace.Entity and trace.Entity:IsValid() and  trace.Entity:GetClass() == "ttt_health_station" ) then
	
		-- local targetpos = trace.Entity:GetPos()
		-- local difr = math.abs( ( targetpos - position ):Length() )
	
		-- if difr <= BOOBYTRAP.MaxDistance then
			found = trace.Entity
		-- end
	end
	
	if found then 
		self.FoundStation = trace.Entity
		if self.IsMicrowave then
			self.DeployTime = CurTime()
			self.IsMicrowave 	= false
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
			self:SendWeaponAnim( ACT_VM_IDLE_EMPTY ) 
		end 
	else
		self.FoundStation = false 
		if not self.IsMicrowave then
			self.DeployTime = CurTime()
			self.IsMicrowave 	= true
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
			self:SendWeaponAnim( ACT_VM_IDLE_EMPTY ) 
		end
	end		
	
end

function SWEP:HealthDrop()
	local ply = self.Owner
	if not IsValid(ply) then return end
	if self.Planted then return end	 
	
	local vsrc, vang, vangle, vvel, vpos, vthrow, pos
	
	if self.IsMicrowave then
		vsrc 	= ply:GetShootPos()
		vang 	= ply:GetAimVector()
		vangle 	= vang:Angle()
		vvel 	= ply:GetVelocity()
		vpos 	= vsrc + vang*15 + vangle:Up()*(-10)
		vthrow 	= vvel + vang*200
		vangle:RotateAroundAxis(vangle:Up(), 90)
	else
		vpos 	= self.FoundStation:GetPos()
		vangle 	= self.FoundStation:GetAngles()
		
	end
	
	local health = ents.Create("ttt_boobytrap")
	if IsValid(health) then
		-- self:EmitSound( BOOBYTRAP.DropSound )
		sound.Play( BOOBYTRAP.StickSound, self:GetPos() )
		self.Planted = true
		self:Remove()
		
		local StationOwner
		if not self.IsMicrowave and IsValid(self.FoundStation) then
			StationOwner = self.FoundStation.GetPlacer and self.FoundStation:GetPlacer()
			self.FoundStation:Remove()
		end
		
		health:SetAngles( vangle )
		health:SetPos(vpos)
		health:SetOwner(ply)
		health:Spawn()
		health:PhysWake() 
		if not self.IsMicrowave and self.ToPos then
			
			-- TODO: CLAMP TO LOOK BETTER/*** 76561198101347368 ***/
			
			-- self:EmitSound( BOOBYTRAP.StickSound )
			sound.Play( BOOBYTRAP.StickSound, self.ToPos )
			health:AddDynamite( self.ToPos, self.ToAngle )
		else
			health:AddDynamite( vpos + vangle:Up()*6 + vangle:Right() * -10.1 + vangle:Forward() * -6.9, vang, true )
			local phys = health:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(vthrow)
			end
		end
		
		
		if not BOOBYTRAP.DNAOnlyOnTNT then
			health.fingerprints = { ply }
		end
		health.TNT.fingerprints = { ply }
		

		SCORE:AddEvent({
			id 	= BOOBYTRAP.EventPlant.ID;
			ni 	= ply:Nick();
			own = IsValid(StationOwner) and StationOwner:Nick();
		})
		
		CustomMsg( ply, BOOBYTRAP.OnPlanted, BOOBYTRAP.OnPlantedColor )
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
	if not self.NextDrop then
	
		local ply = self.Owner
		if not IsValid(ply) then return end
		if self.Planted then return end	  
		
		if self.IsMicrowave then
		else
			local position = self.Owner:GetShootPos()
			local epos = position + self.Owner:GetAimVector() * BOOBYTRAP.MaxDistance
			local trace = util.TraceLine({start=position, endpos=epos, filter={self.Owner, self}, mask=MASK_SOLID})
			-- local trace = self.Owner:GetEyeTrace()
			if ( trace.HitNonWorld and trace.Entity and trace.Entity:IsValid() and  trace.Entity:GetClass() == "ttt_health_station" ) then
				self.ToPos 		= trace.HitPos
				self.ToAngle 	= self.PlantNormal and trace.HitNormal or ply:GetAimVector()
			else
				return
			end
		end
		
		self.NextDrop 	= CurTime() + ( BOOBYTRAP.AnimDuration or 0 )
		
	end
end

function SWEP:SecondaryAttack()
	-- self:PrimaryAttack( true )
end

function SWEP:CallHide()
	self:CallOnClient("Holster", "")
end
function SWEP:PreDrop()
	self:CallHide()
end
function SWEP:OnDrop()
	self:CallHide()
	self:Remove()
end
function SWEP:OnRemove()
	self:CallHide()
end
function SWEP:Holster()
	self:CallHide()
	return self.BaseClass.Holster(self)
end

function SWEP:Reload()
   return false
end

function SWEP:Deploy()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay + 0.1 ) 
	self.Owner:SetAnimation( PLAYER_IDLE )
	-- self:SendWeaponAnim( ACT_VM_IDLE_EMPTY )
	self:CallOnClient("Deploy", "")	
	return true
end


weapons.Register(SWEP, "weapon_ttt_boobytrap")

/*** TTT Realistic Booby Trap 76561198101347368 ***/