 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering.        
 self.Entity:DrawModel()       // Draw the model.   
 end
 
 function ENT:Initialize()
                self.SmokeTimer = CurTime() + 0.05 --keeps the smoke out of your face when firing
        end
 
        function ENT:Draw()
                self.Entity:DrawModel()
        end
        --Smoke effect, shamelessly stolen from dear Garry:
        --   <_<   >_>   :D   XD   :P   >:D
        function ENT:Think()
                self.SmokeTimer = self.SmokeTimer or 0
                if ( self.SmokeTimer > CurTime() ) then return end
                self.SmokeTimer = CurTime() + 0.01
                local vOffset = self.Entity:LocalToWorld( vector_origin ) + Vector( math.Rand( -3, 3 ), math.Rand( -3, 3 ), math.Rand( -3, 3 ) )
                local vNormal = (vOffset - self.Entity:GetPos()):GetNormalized()
                local emitter = self:GetEmitter( vOffset, false )
                local particle = emitter:Add( "particles/ring", vOffset )
                        particle:SetVelocity( vNormal * math.Rand( 5, 5 ) )
                        particle:SetDieTime( 0.14 )
                        particle:SetStartAlpha( math.Rand( 15, 15 ) )
                        particle:SetStartSize( math.Rand( 15, 25 ) ) -- 20, 36
                        particle:SetEndSize( math.Rand( 2, 6 ) ) --24, 48
                        particle:SetRoll( math.Rand( 0, 0 ) )
                        particle:SetColor( 255, 255, 20 )
        end
       
        function ENT:GetEmitter( Pos, b3D )
                if ( self.Emitter ) then         
                        if ( self.EmitterIs3D == b3D && self.EmitterTime > CurTime() ) then
                                return self.Emitter
                        end
                end
                self.Emitter = ParticleEmitter( Pos, b3D )
                self.EmitterIs3D = b3D
                self.EmitterTime = CurTime() + 2
                return self.Emitter
        end