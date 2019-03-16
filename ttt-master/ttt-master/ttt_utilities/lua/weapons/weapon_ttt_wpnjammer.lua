AddCSLuaFile()

SWEP.HoldType               = "normal"

if CLIENT then
   SWEP.PrintName           = "Weapon Jammer"
   SWEP.Slot                = 6
   
   SWEP.ViewModelFOV        = 10
   SWEP.DrawCrosshair      = true

   SWEP.EquipMenuData = {
      type  = "item_weapon",
      name  = "Weapon Jammer",
      desc  = [[Disable someone's equipped weapon entirely.

To use, press 'E' on a target while having any weapon selected.]]
   };

   SWEP.Icon                = "vgui/ttt/icon_jammer"
   SWEP.IconLetter          = "I"
end

SWEP.Base                   = "weapon_tttbase"

SWEP.Kind                   = WEAPON_EQUIP2
SWEP.CanBuy                 = {ROLE_TRAITOR} -- only traitors can buy
SWEP.WeaponID               = 94
SWEP.LimitedStock			= true

SWEP.ViewModel              = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel             = "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Delay          = 0

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 0

SWEP.NoSights               = true
SWEP.AllowDrop              = false

function SWEP:GetClass()
	return "weapon_ttt_wpnjammer"
end

function SWEP:Initialize()
	if SERVER then
		hook.Add("Think", "weapon_ttt_wpnjammer_think", function()
			for tid,traitor in pairs(player.GetAll()) do
				if traitor:HasWeapon("weapon_ttt_wpnjammer") and traitor:Alive() and traitor:KeyDown( IN_USE ) then
					local eyeTrace = traitor:GetEyeTraceNoCursor()
					if eyeTrace.Entity:IsValid() then
						local target = eyeTrace.Entity
						if target:IsPlayer() then
							if eyeTrace.HitPos:Distance(traitor:EyePos()) then
								local activeWeapon = target:GetActiveWeapon()
								if activeWeapon:IsValid() then
									local isSWEP = activeWeapon:IsScripted()
									if isSWEP then
										if activeWeapon.PrimaryAttack and activeWeapon.Kind and (activeWeapon.Kind == WEAPON_HEAVY or activeWeapon.Kind == WEAPON_PISTOL) then
											function activeWeapon:PrimaryAttack(worldsnd)
												self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
												self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
												
												if not self:CanPrimaryAttack() then return end
												
												if not worldsnd then
													self:EmitSound("Weapon_Pistol.Empty", self.Primary.SoundLevel )
												elseif SERVER then
													sound.Play("Weapon_Pistol.Empty", self:GetPos(), self.Primary.SoundLevel)
												end

												--self:TakePrimaryAmmo( 1 )
											end
											net.Start("ttt_weaponjammer_apply")
												net.WriteEntity(activeWeapon)
											net.Broadcast()
											traitor:GetWeapon("weapon_ttt_wpnjammer"):Remove()
											traitor:PrintMessage(HUD_PRINTTALK, "Weapon jammed.")
										else
											-- Weapon cannot be jammed (doesn't shoot!)
											-- traitor:PrintMessage(HUD_PRINTTALK, "Weapon cannot be jammed.")
										end
									else
										-- Weapon is not a SWEP
										-- traitor:PrintMessage(HUD_PRINTTALK, "Weapon cannot be jammed.")
									end
								else
									-- Weapon is not valid
									-- traitor:PrintMessage(HUD_PRINTTALK, "Weapon cannot be jammed.")
								end
							else
								-- Too far away!
								-- traitor:PrintMessage(HUD_PRINTTALK, "You can't jam their weapon from here!")
							end
						else
							-- Target is no player
						end
					else
						-- Target is not valid
					end
				end
			end
		end)
	end
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Deploy()
	if SERVER and IsValid(self.Owner) then
		self.Owner:DrawViewModel(false)
	end
	
	self:DrawShadow(false)
	
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end
