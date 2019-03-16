/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap/cl_healthstation_upgrade.lua
	
	>> The following has parts comprised from the following publicly available works:
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_health_station.lua 
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/entities/ttt_health_station.lua
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
	
	Please do not edit below unless you are a proficient coder!
***/


for k, SWEP in pairs( weapons.GetList() ) do
	if SWEP.ClassName == "weapon_ttt_health_station"  then

		SWEP.ViewModelFOV 	= 80
		SWEP.ViewModelFlip 	= false
		SWEP.HoldType 		= "duel"
		SWEP.ViewModel 		= "models/weapons/v_pist_elite.mdl"
		SWEP.WorldModel 	= "models/weapons/w_pist_elite.mdl"
		
		local BoneAdjustments = {}
		local BonesChanged
		
		function SWEP:Initialize()
			
			self.CSModelEnt = ClientsideModel( BOOBYTRAP.StationModel )
			self.CSModelEnt:SetNoDraw(true)
			
			self.Invis = BOOBYTRAP.AnimDuration and ( not self.DeployTime or ( CurTime() - self.DeployTime < math.Clamp( BOOBYTRAP.AnimDuration/4, 0, BOOBYTRAP.AnimDuration ) ) )

			return self.BaseClass.Initialize(self)
		end

		function SWEP:DrawWorldModel()
			if IsValid(self.Owner) and IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetObserverTarget()) and LocalPlayer():GetObserverTarget() == self.Owner and LocalPlayer():GetObserverMode() == OBS_MODE_IN_EYE then return end
		
			local ply = self.Owner
			local pos = self:GetPos()
			local ang = self:GetAngles()
			if ply:IsValid() then
				local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
				if bone then
					pos,ang = ply:GetBonePosition(bone)
				end
			else 
				--Draw the actual model when not held.
				render.SetColorModulation( 50/255, 50/255, 255/255 )
				self:DrawModel()
				render.SetColorModulation( 255/255, 255/255, 255/255 )
				return
			end
			
			if not ( self.CSModelEnt and self.CSModelEnt:IsValid() ) then
				self.CSModelEnt = ClientsideModel( BOOBYTRAP.StationModel )
				self.CSModelEnt:SetNoDraw(true)
			end
			
			self.CSModelEnt:SetModelScale(.75,0)
			ang:RotateAroundAxis( ang:Up(), 70 )
			ang:RotateAroundAxis( ang:Right(), 15 )
			ang:RotateAroundAxis( ang:Forward(), -18 )
		
			ang:RotateAroundAxis( ang:Right(), 180 )
			self.CSModelEnt:SetPos(pos+ang:Right()*10-ang:Up()*8+ang:Forward()*11)
			self.CSModelEnt:SetAngles( ang )
			
			render.SetColorModulation( 180/255, 180/255, 255/255 )
			self.CSModelEnt:DrawModel()
			render.SetColorModulation( 1,1,1 )
		end

		function SWEP:PreDrawViewModel( vm, ply, weapon ) 
			if self.Invis then
				vm:SetMaterial("debug/hsv")
				self.IsInvis = true
			end
		end

		function SWEP:PostDrawViewModel( vm, ply, weapon ) 
			if self.Invis or self.IsInvis then
				vm:SetMaterial("")
				self.IsInvis = false
			end
		end
		function SWEP:ViewModelDrawn()
			if self.NoBones then
				return
			end
			
			local ply = self.Owner
			if ply:IsValid() then
				local vmodel 	= ply:GetViewModel()			
				local idBase 	= vmodel:LookupBone("v_weapon.Hands_parent")			
				local idParent 	= vmodel:LookupBone("v_weapon.Right_Hand")
				local L1 		= vmodel:LookupBone("v_weapon.Left_Arm")
				local R1 		= vmodel:LookupBone("v_weapon.Right_Arm")			
				local R2 		= vmodel:LookupBone("v_weapon.elite_right")
				local L2 		= vmodel:LookupBone("v_weapon.elite_left")		
				
				if not ( vmodel:IsValid() and idBase and idParent and L1 and R1 ) then 
					return 
				end
				
				local _Bones 	= {}
				local _Mods 	= {
					["Hand"] = { angle = Angle(-4.689, 2.812, 0), mult = 1 };
					["Index01"] = { angle = Angle(-16.271, -4.737, 0), mult = 1 };
					["Index02"] = { angle = Angle(0, -16.105, 0) };
					["Pinky01"] = { angle = Angle(0, -10.421, 0) };
					["Pinky02"] = { angle = Angle(0, -29.369, 0) };
					["Pinky03"] = { angle = Angle(0, -38.842, 0) };
					["Middle01"] = { angle = Angle(0, -32.316, 0) };
					["Middle03"] = { angle = Angle(0, -38.106, 0) };
					["Middle02"] = { angle = Angle(0, -21.264, 0) };
					["Ring01"] = { angle = Angle(0, -25.313, 0) };
					["Ring02"] = { angle = Angle(0, -38.842, 0) };
					["Ring03"] = { angle = Angle(0, -46.422, 0) };
					["Thumb03"] = { angle = Angle(0, 0, 0) };
					["Thumb02"] = { angle = Angle(0, 20, 0) };
					["Thumb01"] = { angle = Angle(26, 50, -10), angle2 = Angle(2, -50, 0) };
				}
				
				BoneAdjustments = BoneAdjustments or {}			
				BoneAdjustments[idBase] 	= 1
				BoneAdjustments[idParent] 	= 1
				BoneAdjustments[L1] 		= 1
				BoneAdjustments[R1] 		= 1
				BoneAdjustments[R2] 		= 1
				BoneAdjustments[L2] 		= 1
				
				for k,v in pairs(_Mods) do
					local lbone = vmodel:LookupBone("v_weapon.Left_" .. k )
					local rbone = vmodel:LookupBone("v_weapon.Right_" .. k )
					
					if not ( lbone and rbone ) then
						-- return
					end
					
					BoneAdjustments[lbone] = 1
					BoneAdjustments[rbone] = 1
					
					_Bones[ lbone ] 	= v.angle*1
					_Bones[ rbone ] 	= v.angle2 or ( v.angle * ( v.mult or -1 ) )
				end
				
				local pos, ang = vmodel:GetBonePosition(idParent)
				ang1 = ply:EyeAngles()				
				
				self:AddBoneHook( vmodel )				
				
				if self.DropTime then
					vmodel:ManipulateBonePosition(idBase, Vector(0,0,0) )
					local time 		= ( CurTime() - self.DropTime )					
					local percent 	= BOOBYTRAP.AnimDuration - math.Clamp( BOOBYTRAP.AnimDuration - time, 0, BOOBYTRAP.AnimDuration )
					-- local percent 	= math.Clamp( time / BOOBYTRAP.AnimDuration, 0, 1 )					
					vmodel:ManipulateBoneAngles(idBase, Angle(0,0,self.IsMicrowave and percent*-90 or percent*-60 ) )
					vmodel:ManipulateBonePosition(idBase, Vector(self.IsMicrowave and 0 or percent*20,0,self.IsMicrowave and percent*5 or 0 ) )
				elseif self.DeployTime then
					vmodel:ManipulateBonePosition(idBase, Vector(0,0,0) )
					local time 		= ( CurTime() - self.DeployTime )
					local percent 	= math.Clamp( time / BOOBYTRAP.AnimDuration, 0, 1 )
					vmodel:ManipulateBoneAngles(idBase, Angle(0,0, 20-(20*percent)) )
				else
					vmodel:ManipulateBonePosition(idBase, Vector(0,0,-900) )
				end
				
				// REMOVE GUNS
				vmodel:ManipulateBoneScale(R2, Vector(0.01,0.01,0.01))
				vmodel:ManipulateBoneScale(L2, Vector(0.01,0.01,0.01))
				vmodel:ManipulateBonePosition(L2, Vector(0,-5000,-5000)) -- turns our left gun sticks around... so move?
				vmodel:ManipulateBonePosition(R2, Vector(0,-5000,-5000)) -- whynotboth.jpg
				
				/*** 76561198101347368 ***/
				// ADJUST FINGERSSSS
				for k, v in pairs(_Bones) do
					vmodel:ManipulateBoneAngles( k, v )
				end				
						
				if self.Invis then
					return 
				end
		
				// DISCOUNT DOUBLECHECK
				if not ( self.CSModelEnt and self.CSModelEnt:IsValid() ) then
					self.CSModelEnt = ClientsideModel( BOOBYTRAP.StationModel )
					self.CSModelEnt:SetNoDraw(true)
				end
				self.CSModelEnt:SetPos(pos+ang1:Forward()*3-ang1:Up()*3-5.6*ang1:Right())
				ang1:RotateAroundAxis(ang1:Up(),90)
				ang1:RotateAroundAxis(ang1:Forward(),15)
				self.CSModelEnt:SetModelScale(0.27,0)
				self.CSModelEnt:SetAngles( ang1 )
				
				render.SetColorModulation( 180/255, 180/255, 255/255 )
				self.CSModelEnt:DrawModel()
				render.SetColorModulation( 1,1,1 )
				
			end
		end

		
		local function BoneReset( vm )		
			BonesChanged = nil			
			if not BoneAdjustments then 
				return true
			end		
			
			local vm = vm or LocalPlayer():GetViewModel()			
			local rtn = false		
			if IsValid( vm ) and vm:GetBoneCount() then			
				for i, v in pairs( BoneAdjustments ) do				
					if vm:GetBoneMatrix( i ) then
						vm:ManipulateBoneScale( i, Vector(1,1,1) )
						vm:ManipulateBonePosition( i, Vector(0,0,0) )
						vm:ManipulateBoneAngles( i, Angle(0,0,0) )
						BoneAdjustments[ i ] = nil
						rtn = (table.Count( BoneAdjustments ) == 0)
						if rtn then
							BoneAdjustments = nil
						end
					end
				end
			end
			return rtn
		end
		
		function SWEP:Holster()
			if IsValid(self.Owner) then
				if self.CSModelEnt and self.CSModelEnt:IsValid() then
					self.CSModelEnt:SetNoDraw(true)
				end
				
				self.DropTime 		= nil
				self.DeployTime 	= nil
				
				self.NoBones = true
				BoneReset( self.Owner:GetViewModel() )
			end	
			return true
		end

		function SWEP:OnRemove()
			
			self:Holster()
			
			if IsValid(self.Owner) and self.Owner == LocalPlayer() and LocalPlayer():Alive() then
				if LocalPlayer():HasWeapon("weapon_ttt_unarmed") then
					RunConsoleCommand("use", "weapon_ttt_unarmed")
				elseif LocalPlayer():HasWeapon("weapon_zm_improvised") then -- no holstered? lets try crowbar...
					RunConsoleCommand("use", "weapon_zm_improvised")
				elseif LocalPlayer():HasWeapon("weapon_zm_carry") then -- no crowbar? wtfx2...
					RunConsoleCommand("use", "weapon_zm_carry")
				end
			end
			
		end
		
		function SWEP:Deploy()
			self.Invis = true
			self.NoBones = false
			return self.BaseClass.Deploy( self )
		end
		
				
		
		function SWEP:PrimaryAttack()
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
			if not self.DropTime then
				self.DropTime = CurTime()
			end
		end
		
		function SWEP:SecondaryAttack()
			self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
			self:PrimaryAttack()
		end

		function SWEP:Think()	
	
			if IsValid(self.Owner) and IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetObserverTarget()) and LocalPlayer():GetObserverTarget() == self.Owner and LocalPlayer():GetObserverMode() == OBS_MODE_IN_EYE then 
				self.NoBones = false
			end
		
			if not self.DeployTime then
				self.DeployTime = CurTime()
			end
			
			self.Invis = BOOBYTRAP.AnimDuration and ( not self.DeployTime or ( CurTime() - self.DeployTime < math.Clamp( BOOBYTRAP.AnimDuration/4, 0, BOOBYTRAP.AnimDuration ) ) )

		end

		function SWEP:AddBoneHook( vm )		
			if not IsValid(BonesChanged) or ( IsValid(vm) and not ( BonesChanged == vm ) ) then
				if IsValid(BonesChanged) then
					BoneReset( BonesChanged )
				end
				BonesChanged 	= vm
				
				hook.Add("Think", "HP::BoneFix", function()
					if not IsValid(LocalPlayer()) then return end
					if BoneAdjustments then
						local weapon = LocalPlayer():GetActiveWeapon()
						if not ( IsValid( weapon ) and weapon:GetClass() == "weapon_ttt_health_station" ) then
							if BoneReset() then
								hook.Remove("Think", "HP::BoneFix")
							end
						end
					else
						hook.Remove("Think", "HP::BoneFix")
					end
				end )
				
			end
		end
		
	end
end

/*** TTT Realistic Booby Trap 76561198101347368 ***/