/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap/cl_boobytrap.lua
	
	>> The following has parts comprised from the following publicly available works:
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_health_station.lua 
		>> [clavus] swep construction kit: https://github.com/Clavus/SWEP_Construction_Kit/
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
		
	Please do not edit below unless you are a proficient coder!
***/


local SWEP 					= weapons.Get("weapon_tttbase")
SWEP.Base 					= "weapon_tttbase"


SWEP.ViewModelFlip 			= false
SWEP.Color 					= Color( 255, 50, 50,255 )


SWEP.Base 					= "weapon_tttbase"
SWEP.HoldType 				= "duel"
SWEP.Slot 					= 6

SWEP.ViewModel				= "models/weapons/v_pist_elite.mdl"
SWEP.WorldModel         	= "models/weapons/w_pist_elite.mdl"

SWEP.PrintName 				= BOOBYTRAP.Name
SWEP.EquipMenuData 			= {
	type = "item_explosive",
	desc = BOOBYTRAP.Desc
}

SWEP.Icon 					= ( BOOBYTRAP.Icon and file.Exists( "materials/" .. BOOBYTRAP.Icon, "GAME" ) ) and BOOBYTRAP.Icon or "vgui/ttt/icon_nades"



SWEP.DrawCrosshair      	= true
SWEP.ViewModelFOV 			= 80

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       	= "none"
SWEP.Primary.Delay 			= 0.8 + ( BOOBYTRAP.AnimDuration or 0.2 )

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     	= "none"
SWEP.Secondary.Delay 		= 0.8 + ( BOOBYTRAP.AnimDuration or 0.2 )

SWEP.Kind 					= WEAPON_EQUIP
SWEP.LimitedStock 			= BOOBYTRAP.LimitedStock
SWEP.AllowDrop 				= BOOBYTRAP.AllowDrop

SWEP.CanBuy 				= {ROLE_TRAITOR}

SWEP.NoSights 				= true

SWEP.NextTick 				= 0
SWEP.FoundStation 			= false


SWEP.IsMicrowave 			= true

// Used outside of the swep
local BoneAdjustments = {}
local BonesChanged
 
function SWEP:FindMicrowave()

	if self.NextTick < CurTime() then
		self.NextTick = CurTime() + 0.1
		
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
				if CLIENT then
					self.CSModelEnt:SetModel( BOOBYTRAP.TNTModel )
				else
					self:SendWeaponAnim( ACT_VM_IDLE_EMPTY ) 
				end 
			end 
		else
			self.FoundStation = false 
			if not self.IsMicrowave then
				self.DeployTime = CurTime()
				self.IsMicrowave 	= true
				if CLIENT then
					self.CSModelEnt:SetModel( BOOBYTRAP.StationModel )
				else
					self:SendWeaponAnim( ACT_VM_IDLE_EMPTY ) 
				end
			end
		end
		
	end

end
function SWEP:Think()
		
	if IsValid(self.Owner) and IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetObserverTarget()) and LocalPlayer():GetObserverTarget() == self.Owner and LocalPlayer():GetObserverMode() == OBS_MODE_IN_EYE then 
		self.NoBones = false
	end

	self.DeployTime = self.DeployTime or CurTime()
	
	self.Invis = BOOBYTRAP.AnimDuration and ( not self.DeployTime or ( CurTime() - self.DeployTime < math.Clamp( BOOBYTRAP.AnimDuration/4, 0, BOOBYTRAP.AnimDuration ) ) )

	
	self:FindMicrowave()
	
end

function SWEP:PrimaryAttack(seperate)
	self.DropTime = CurTime()
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

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	
	self.CSModelEnt = ClientsideModel( BOOBYTRAP.StationModel )
	self.CSModelEnt:SetNoDraw(true)
	
	self.MiniTNT = ClientsideModel( BOOBYTRAP.TNTModel )
	self.MiniTNT:SetNoDraw(true)
	
	
	self.Invis = BOOBYTRAP.AnimDuration and ( not self.DeployTime or ( CurTime() - self.DeployTime < math.Clamp( BOOBYTRAP.AnimDuration/4, 0, BOOBYTRAP.AnimDuration ) ) )
	-- self.Invis = BOOBYTRAP.AnimDuration and BOOBYTRAP.AnimDuration > 0
	-- local vm = IsValid( self.Owner) and self.Owner:GetViewModel()
	-- if self.Invis and IsValid( vm ) then
		-- vm:SetMaterial("Debug/hsv")
	-- end
	
	return self.BaseClass.Initialize(self)
end



// A bunch this code is from the health station, however now with actual models a bunch of it seems unnecessary...
-- local hudtxt = {text="", font="TabLarge", xalign=TEXT_ALIGN_RIGHT, pos = {ScrW() - 75, ScrH() - 80} }
-- local hudtxt2 = {text="", font="TabLarge", xalign=TEXT_ALIGN_RIGHT, pos = {ScrW() - 75, ScrH() - 60} }
local hudtxt3 = {text="This station can be booby trapped.", color=Color(255,0,0,255), font="TabLarge", xalign=TEXT_ALIGN_CENTER}
-- local hudtxt4 = {text="Press primary attack to booby trap this health station...", color=Color(255,0,0,255), font="TabLarge", xalign=TEXT_ALIGN_CENTER}
function SWEP:DrawHUD()
	-- hudtxt.text 	= "Drop this booby-trapped health station"
	-- hudtxt2.text 	= "or find a detective's to rig instead."
	
	
	if self.FoundStation and IsValid(self.FoundStation) then	
		local size = 24
		
		-- surface.SetTexture(surface.GetTextureID("gui/html/refresh"))
		-- surface.SetTextColor(255, 255, 255, 240)
		-- surface.SetDrawColor(255, 0, 0, 230)
		-- surface.DrawTexturedRect( ScrW() - (size/2) + 5, ScrW()/2 - (size/2), size, size )
		
		-- hudtxt.text = "Click to booby-trap this health station."
		-- hudtxt2.text = "Secondary attack to place independant kill station."
		-- hudtxt2.text = ""
		local scrpos = self.FoundStation:GetPos():ToScreen()
		cam.IgnoreZ(true)
			local sz = IsOffScreen(scrpos) and size/2 or size
			scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
			scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
			
			-- surface.SetTexture(surface.GetTextureID("VGUI/ttt/det_beacon")) -- ?
			-- surface.SetTextColor(255, 255, 255, 240)
			-- surface.SetDrawColor(255, 0, 0, 230)
			-- surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz - 30, sz * 2, sz * 2)
			
		cam.IgnoreZ(false)
		
		if self.IsMicrowave then
			-- hudtxt4.pos = { scrpos.x, scrpos.y } 
			draw.TextShadow(hudtxt3, 2)
		else
			hudtxt3.pos = { scrpos.x, scrpos.y } 
			draw.TextShadow(hudtxt3, 2)
		end
		
	end	
	
	-- draw.TextShadow(hudtxt, 2)
	-- draw.TextShadow(hudtxt2, 2)
	
end

function SWEP:DrawWorldModel()

	if IsValid(self.Owner) and IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetObserverTarget()) and LocalPlayer():GetObserverTarget() == self.Owner and LocalPlayer():GetObserverMode() == OBS_MODE_IN_EYE then return end
		
	local ply = self.Owner
	
	if not ( ply == LocalPlayer() ) then
		self:FindMicrowave()
	end
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	if ply:IsValid() then
		local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
		if bone then
			pos,ang = ply:GetBonePosition(bone)
		end
	else 
		render.SetColorModulation( 255/255, 50/255, 50/255 )
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
	
	if self.IsMicrowave then
		ang:RotateAroundAxis( ang:Right(), 180 )
		self.CSModelEnt:SetPos(pos+ang:Right()*10-ang:Up()*8+ang:Forward()*11)
	else
		ang:RotateAroundAxis( ang:Right(), 90 )
		self.CSModelEnt:SetPos(pos+ang:Right()*4+ang:Up()*5-ang:Forward()*0)
	end
	
	self.CSModelEnt:SetAngles(ang)
	
	if LocalPlayer():IsActiveTraitor() and self.IsMicrowave then
		render.SetColorModulation( 255/255, 50/255, 50/255 )
	else
		render.SetColorModulation( 180/255, 180/255, 255/255 )
	end
	self.CSModelEnt:DrawModel()
	render.SetColorModulation( 1,1,1 )
end

function SWEP:ViewModelDrawn()
	if self.NoBones then
		return
	end
	
	local ply = self.Owner
	-- if ply:IsValid() and ply == LocalPlayer() then
	if ply:IsValid() then
		local vmodel = ply:GetViewModel()
			
		
		local idBase 	= vmodel:LookupBone("v_weapon.Hands_parent")
		
		local idParent 	= vmodel:LookupBone("v_weapon.Right_Hand")
		local L1 		= vmodel:LookupBone("v_weapon.Left_Arm")
		local R1 		= vmodel:LookupBone("v_weapon.Right_Arm")
		
		local R2 = vmodel:LookupBone("v_weapon.elite_right")
		local L2 = vmodel:LookupBone("v_weapon.elite_left")
		
		if not ( vmodel:IsValid() and idBase and idParent and L1 and R1 ) then return end
		
		
		local _Bones 	= {}
		local _Mods 	= {
			["Hand"] = { angle = Angle(-4.689, 2.812, 0) };
			["Index01"] = { angle = Angle(-16.271, -4.737, 0) };
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
			-- ["Thumb01"] = { angle = Angle(12, 50, -10) };
			["Thumb01"] = { angle = Angle(26, 50, -10), angle2 = Angle(2, -50, 0) };
			-- ["Thumb01"] = { angle = Angle(12.812, 22.812, -10), angle2 = Angle(-12.812, -22.812, 10) };
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
				return
			end
			
			BoneAdjustments[lbone] = 1
			BoneAdjustments[rbone] = 1
				
			_Bones[ lbone ] 	= v.angle*1
			_Bones[ rbone ] 	= v.angle2 or ( v.angle * ( ( k=="Hand" or k=="Index01" ) and 1 or -1 ) )
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
		
		// ADJUST FINGERSSSS
		for k, v in pairs(_Bones) do
			vmodel:ManipulateBoneAngles( k, v )
		end
		
		if self.Invis then
			return 
		end
		
		// DISCOUNTDOUBLECHECK 76561198101347368 
		if not ( self.CSModelEnt and self.CSModelEnt:IsValid() ) then
			self.CSModelEnt = ClientsideModel( BOOBYTRAP.StationModel )
			self.CSModelEnt:SetNoDraw(true)
		end
		
		if self.IsMicrowave then
			if not ( self.MiniTNT and self.MiniTNT:IsValid() ) then
				self.MiniTNT = ClientsideModel( BOOBYTRAP.TNTModel )
				self.MiniTNT:SetNoDraw(true)
			end
			self.CSModelEnt:SetPos(pos+ang1:Forward()*3-ang1:Up()*3-5.6*ang1:Right())
			ang1:RotateAroundAxis(ang1:Up(),90)
			ang1:RotateAroundAxis(ang1:Forward(),15)
			self.CSModelEnt:SetModelScale(0.27,0)
			
			self.MiniTNT:SetPos(pos+ang1:Forward()*3.75-ang1:Up()*0.7+0.8*ang1:Right())
			self.MiniTNT:SetModelScale(0.08,0)
			self.MiniTNT:SetAngles( ang1 )			
		else
			self.CSModelEnt:SetPos(pos+ang1:Forward()*3+ang1:Up()*0.3-2.7*ang1:Right())
			ang1:RotateAroundAxis(ang1:Forward(),90)
			ang1:RotateAroundAxis(ang1:Up(),90)
			ang1:RotateAroundAxis(ang1:Right(),180)
			self.CSModelEnt:SetModelScale(0.32,0)
		end
		
		self.CSModelEnt:SetAngles( ang1 )
		
		if LocalPlayer():IsActiveTraitor() and self.IsMicrowave then
			render.SetColorModulation( 255/255, 50/255, 50/255 )
		else
			render.SetColorModulation( 180/255, 180/255, 255/255 )
		end
		
		self.CSModelEnt:DrawModel()
		
		render.SetColorModulation( 1,1,1 )
		
		if self.IsMicrowave then
			self.MiniTNT:DrawModel()
		end
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
					-- LocalPlayer():ChatPrint("Bones reset.")
					BoneAdjustments = nil
				end
			end
		end
	end
	
	return rtn
end


function SWEP:AddBoneHook( vm )		
	if not IsValid(BonesChanged) or ( IsValid(vm) and not ( BonesChanged == vm ) ) then
		if IsValid(BonesChanged) then
			BoneReset( BonesChanged )
		end
		
		BonesChanged 	= vm
		
		hook.Add("Think", "HPRIG::BoneFix", function()
			if not IsValid(LocalPlayer()) then return end
			if BoneAdjustments then
				local weapon = LocalPlayer():GetActiveWeapon()
				if not ( IsValid( weapon ) and weapon:GetClass() == "weapon_ttt_boobytrap" ) then
					if BoneReset() then
						-- LocalPlayer():ChatPrint("View model cleaned.")	
						hook.Remove("Think", "HPRIG::BoneFix")
					end
				end
			else
				hook.Remove("Think", "HPRIG::BoneFix")
			end
		end )
		
	end
end

function SWEP:Holster()
	if IsValid(self.Owner) then
		if self.CSModelEnt and self.CSModelEnt:IsValid() then
			self.CSModelEnt:SetNoDraw(true)
		end
		if self.MiniTNT and self.MiniTNT:IsValid() then
			self.MiniTNT:SetNoDraw(true)
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
		else
			// welp shit...
		end
	end
	
	
end


function SWEP:Deploy()
	self.Invis = true
	self.NoBones = false
	return self.BaseClass.Deploy( self )
end	




/*** TTT Events ****/
CLSCORE.DeclareEventDisplay(BOOBYTRAP.EventDefuse.ID, { 
	text = function(e)
		return string.format( BOOBYTRAP.EventDefuse.Text, e.ni, e.own or "aliens" )
	end,
	icon = function(e)
		return Material(BOOBYTRAP.EventDefuse.Icon), BOOBYTRAP.EventDefuse.Short
	end
} )
CLSCORE.DeclareEventDisplay(BOOBYTRAP.EventExplode.ID, { 
	text = function(e)
		return string.format( BOOBYTRAP.EventExplode.Text, e.ni )
	end,
	icon = function(e)
		return Material(BOOBYTRAP.EventExplode.Icon), BOOBYTRAP.EventExplode.Short
	end
} )
CLSCORE.DeclareEventDisplay(BOOBYTRAP.EventPlant.ID, { 
	text = function(e)
		return string.format( e.own and BOOBYTRAP.EventPlant.Text or BOOBYTRAP.EventDrop.Text, e.ni, e.own )
	end,
	icon = function(e)
		return Material( e.own and BOOBYTRAP.EventPlant.Icon or BOOBYTRAP.EventDrop.Icon), e.own and BOOBYTRAP.EventPlant.Short or BOOBYTRAP.EventDrop.Short
	end
} )


weapons.Register(SWEP, "weapon_ttt_boobytrap")

/*** TTT Realistic Booby Trap 76561198101347368 ***/