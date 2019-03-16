AddCSLuaFile()
if SERVER then
	util.AddNetworkString( "ttt_weaponjammer_apply" )
else
	net.Receive("ttt_weaponjammer_apply", function()
		
		local activeWeapon = net.ReadEntity()
		
		if not activeWeapon:IsValid() then return end
		
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
	end)
end