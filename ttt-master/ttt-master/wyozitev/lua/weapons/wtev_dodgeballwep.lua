AddCSLuaFile()

SWEP.HoldType = "melee"

SWEP.Base = "weapon_tttbase"
SWEP.PrintName = "Dodge ball"

SWEP.Kind = WEAPON_HEAVY

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize		= 100					// Size of a clip
SWEP.Primary.DefaultClip	= 100				// Default number of bullets in a clip
SWEP.Primary.Automatic		= true			// Automatic/Semi Auto
SWEP.Primary.Ammo			= "CombineCannon"

SWEP.Secondary.ClipSize		= 0					// Size of a clip
SWEP.Secondary.DefaultClip	= 0				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""

SWEP.AllowDelete = false -- never removed for weapon reduction
SWEP.AllowDrop = false

function SWEP:SetupDataTables()
	self:NetworkVar("Vector", 0, "BallColor")
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
    local vm = self.Owner:GetViewModel()
    vm:ResetSequence( vm:LookupSequence( "fists_idle01" ) )

    return true
end

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		
		self.Weapon:SendWeaponAnim( ACT_GRENADE_TOSS )
		self.Owner:MuzzleFlash()
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		self:EmitSound("weapons/slam/throw.wav")

		if SERVER then

			self.Owner:LagCompensation(true)

			local ball = ents.Create("wtev_dodgeball")
				ball:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 20)
				ball:SetOwner(self.Owner)
				ball:Spawn()
				ball:Activate()

				ball:SetBallColor(self:GetBallColor())

			local ballphys = ball:GetPhysicsObject()
			if ballphys:IsValid() then
				ballphys:SetVelocity(self.Owner:GetAimVector() * 2000)
			end

 			self.Owner:LagCompensation(false)

			if self:Clip1() <= 0 then
				self:Remove()
			end
			
		end

	else
		self.Weapon:EmitSound("Buttons.snd14")
	end
	self.Weapon:SetNextPrimaryFire(CurTime()+0.6)
end

if CLIENT then
	local matBall = Material( "sprites/sent_ball" )
	function SWEP:DrawWorldModel()
		local pos = self:GetPos()
		if IsValid(self.Owner) then
			local attachment = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_RH"))
			if attachment then pos = attachment.Pos end
		end

		render.SetMaterial( matBall )
		
		local lcolor = render.ComputeLighting( self:GetPos(), Vector( 0, 0, 1 ) )
		local c = self:GetBallColor()
		
		lcolor.x = c.r * (math.Clamp( lcolor.x, 0, 1 ) + 0.5) * 255
		lcolor.y = c.g * (math.Clamp( lcolor.y, 0, 1 ) + 0.5) * 255
		lcolor.z = c.b * (math.Clamp( lcolor.z, 0, 1 ) + 0.5) * 255
			
		render.DrawSprite( pos, 16, 16, Color( lcolor.x, lcolor.y, lcolor.z, 255 ) )
	
	end
end