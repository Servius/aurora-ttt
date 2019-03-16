if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile( "sound/siege/jihad.wav" );
   resource.AddFile( "sound/siege/big_explosion.wav" );
   resource.AddFile( "materials/vgui/ttt/icon_aurora_jihadbomb.vmt" );

   resource.AddFile( "models/weapons/v_jb.mdl" );
   resource.AddFile( "models/weapons/v_jb.dx80" );
   resource.AddFile( "models/weapons/v_jb.dx90" );
   resource.AddFile( "models/weapons/v_jb.sw.vtx" );
   resource.AddFile( "models/weapons/v_jb.vvd" );
   resource.AddFile( "models/weapons/w_jb.mdl" );
   resource.AddFile( "models/weapons/w_jb.dx80" );
   resource.AddFile( "models/weapons/w_jb.dx90" );
   resource.AddFile( "models/weapons/w_jb.sw.vtx" );
   resource.AddFile( "models/weapons/w_jb.vvd" );
   resource.AddFile( "models/weapons/w_jb.phy" );
end
 
SWEP.HoldType                   = "slam"
 

   SWEP.PrintName                       = "Dead Man's Switch"
   SWEP.Slot                            = 7
 if CLIENT then
   SWEP.EquipMenuData = {
      type  = "item_explosive",
      name  = "Dead Man's Switch",
      desc  = "Sacrifice yourself for Allah.\nLeft Click to make yourself EXPLODE.\nRight click to taunt."
   };
 
   SWEP.Icon = "vgui/ttt/icon_aurora_jihadbomb"
end
 
SWEP.Base = "weapon_tttbase"
 
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}
--SWEP.WeaponID = AMMO_C4
SWEP.LimitedStock = true
 
SWEP.ViewModel  = Model("models/weapons/v_jb.mdl")
SWEP.WorldModel = Model("models/weapons/w_jb.mdl")
 
SWEP.DrawCrosshair      = false
SWEP.ViewModelFlip      = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 5.0
 
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo     = "none"
SWEP.AutoSpawnable      = false
SWEP.AdminSpawnable = true
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
 
SWEP.NoSights = true
 
----------------------
--  Weapon its self --
----------------------
 
-- Reload does nothing
function SWEP:Reload()
end  
 
function SWEP:Initialize()
    util.PrecacheSound("siege/big_explosion.wav")
    util.PrecacheSound("siege/jihad.wav")
end
 
 
-- Think does nothing
function SWEP:Think()  
end
 
 
-- PrimaryAttack
function SWEP:PrimaryAttack()
self.Weapon:SetNextPrimaryFire(CurTime() + 3)
 
       
        local effectdata = EffectData()
                effectdata:SetOrigin( self.Owner:GetPos() )
                effectdata:SetNormal( self.Owner:GetPos() )
                effectdata:SetMagnitude( 8 )
                effectdata:SetScale( 1 )
                effectdata:SetRadius( 16 )
        util.Effect( "Sparks", effectdata )
        self.BaseClass.ShootEffects( self )
       
        -- The rest is only done on the server
        if (SERVER) then
                timer.Simple(2, function() self:Asplode() end )
                self.Owner:EmitSound( "siege/jihad.wav" )
        end
 
end
 
-- The asplode function
function SWEP:Asplode()
local k, v
       
        -- Make an explosion at your position
        local ent = ents.Create( "env_explosion" )
                ent:SetPos( self.Owner:GetPos() )
                ent:SetOwner( self.Owner )
                ent:Spawn()
                ent:SetKeyValue( "iMagnitude", "450" )
                ent:Fire( "Explode", 0, 0 )
                ent:EmitSound( "siege/big_explosion.wav", 500, 500 )
                self:Remove()
                self.Owner:Kill( )
 
                for k, v in pairs( player.GetAll( ) ) do
                  v:ConCommand( "play siege/big_explosion.wav\n" )
                end

 
end
 
 
-- SecondaryAttack
function SWEP:SecondaryAttack()
        self.Weapon:SetNextSecondaryFire( CurTime() + 1 )
		
		local TauntSound = {
               "vo/npc/male01/overhere01.wav",
               "vo/npc/male01/help01.wav",
               "vo/npc/male01/waitingsomebody.wav",
               "vo/npc/male01/watchout.wav",
               "vo/npc/male01/watchout.wav",
               "vo/npc/male01/moan01.wav",
               "vo/npc/male01/runforyourlife01.wav",
               "vo/npc/male01/pain09.wav",
               "vo/npc/male01/hacks01.wav",
               "vo/npc/male01/hacks02.wav",
               "vo/npc/male01/doingsomething.wav",
               "vo/npc/male01/behindyou01.wav",
               "vo/npc/male01/behindyou02.wav",
               "vo/npc/male01/ammo03.wav",
               "vo/npc/male01/ammo04.wav",
               "vo/npc/male01/ammo05.wav",
			   "vo/npc/male01/excuseme01.wav",
			   "vo/npc/male01/excuseme02.wav"
        }
		
        local random = math.random(1, #TauntSound)
 
        -- The rest is only done on the server
        if (!SERVER) then return end
		self.Owner:EmitSound(TauntSound[random])
		
end
 
-- Bewm
function SWEP:WorldBoom()
        surface.EmitSound( "siege/big_explosion.wav" )
end
