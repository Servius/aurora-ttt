/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap/sv_healthstation_upgrade.lua
	
	>> The following has parts comprised from the following publicly available works:
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_health_station.lua 
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/entities/ttt_health_station.lua
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
	
	Please do not edit below unless you are a proficient coder!
***/

for k, SWEP in pairs( weapons.GetList() ) do
	if SWEP.ClassName == "weapon_ttt_health_station"  then

		SWEP.ViewModelFlip 			= false
		SWEP.HoldType 				= "duel"
		SWEP.ViewModel				= "models/weapons/v_pist_elite.mdl"
		SWEP.WorldModel         	= "models/weapons/w_pist_elite.mdl"

		
		function SWEP:PrimaryAttack()
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
			if not self.NextDrop then
				self.NextDrop 	= CurTime() + ( BOOBYTRAP.AnimDuration or 0 )
			end
		end
		
		function SWEP:SecondaryAttack()
			self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
			self:PrimaryAttack()
		end

		function SWEP:Think()		
			if self.NextDrop and self.NextDrop < CurTime() then
				self:HealthDrop()
			end			
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
		
		function SWEP:Deploy()
			self:CallOnClient("Deploy", "")
			-- self.Owner:SetAnimation( PLAYER_IDLE )
			return self.BaseClass.Deploy( self )
		end
		
	end
end

/*** TTT Realistic Booby Trap 76561198101347368 ***/