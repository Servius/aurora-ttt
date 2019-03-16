--[[

╔══╗───────╔══╗──╔╗────╔═╗
║╔╗╠╦╦╦╦═╗─╚║║╬═╦╣╚╦═╦╦╣═╬═╗╔═╦═╗
║╠╣║║║╔╣╬╚╗╔║║╣║║║╔╣╩╣╔╣╔╣╬╚╣═╣╩╣
╚╝╚╩═╩╝╚══╝╚══╩╩═╩═╩═╩╝╚╝╚══╩═╩═╝
────────────────────────────────
  Designed and Coded by Divine
        www.AuroraEN.com
────────────────────────────────

]]

print("AFrame defined!")

local PANEL = {}

surface.CreateFont( "AFrameTitle", {
	font = "Bebas Neue",
	size = 24,
	weight = 0,
	antialias = true
} )

AccessorFunc( PANEL, "m_bIsMenuComponent", 		"IsMenu", 			FORCE_BOOL )
AccessorFunc( PANEL, "m_bDraggable", 			"Draggable", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bSizable", 				"Sizable", 			FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock", 			"ScreenLock", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bDeleteOnClose", 		"DeleteOnClose", 	FORCE_BOOL )
AccessorFunc( PANEL, "m_bPaintShadow", 			"PaintShadow", 		FORCE_BOOL )

AccessorFunc( PANEL, "m_iMinWidth", 			"MinWidth" )
AccessorFunc( PANEL, "m_iMinHeight", 			"MinHeight" )

AccessorFunc( PANEL, "m_bBackgroundBlur", 		"BackgroundBlur", 	FORCE_BOOL )

AccessorFunc( PANEL, "m_pulseOffset", 			"PulseOffset" )
AccessorFunc( PANEL, "m_titleFont", 			"TitleFont" )
AccessorFunc( PANEL, "m_fadeOffset", 			"FadeOffset" )

function PANEL:Init()
	self.createdTime = CurTime()
	self.alpha = 0
	self.initClose = false
	self.initCloseTime = nil

	self:SetPulseOffset(10)
	self.pulseOffset = 5*(math.sin((self:GetPulseOffset())*(CurTime())))
	self:SetTitleFont("AFrameTitle")
	self:SetFadeOffset(0.15)

	self:SetFocusTopLevel( true )

--	self:SetCursor( "sizeall" )

	self:SetPaintShadow( true )

	self.btnClose = vgui.Create("DButton", self)
	self.btnClose:SetSize(32, 32)
	self.btnClose:SetPos(self:GetWide() - 38, 6)
	self.btnClose:SetText("r")
	self.btnClose:SetFont( "marlett" )
	self.btnClose.Paint = function(self)
		self:SetTextColor(Color(166, 169, 172, 255))
	end
	self.btnClose.DoClick = function ( button ) self:StartClose() end

	self.lblTitle = vgui.Create( "DLabel", self )
	self.lblTitle.UpdateColours = function( label, skin )

		if ( self:IsActive() ) then return label:SetTextStyleColor( skin.Colours.Window.TitleActive ) end

		return label:SetTextStyleColor( skin.Colours.Window.TitleInactive )

	end
	self.lblTitle:SetFont(self:GetTitleFont())

	self:SetDraggable( true )
	self:SetSizable( false )
	self:SetScreenLock( false )
	self:SetDeleteOnClose( true )
	self:SetTitle( "Window" )

	self:SetMinWidth( 50 )
	self:SetMinHeight( 50 )
	self:SetAlpha(0)

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

	self.m_fCreateTime = SysTime()

	self:DockPadding( 5, 24 + 5, 5, 5 )

end

function PANEL:StartClose()
	self.initCloseTime = CurTime()
	self.initClose = true
end

function PANEL:ShowCloseButton( bShow )

	self.btnClose:SetVisible( bShow )

end

function PANEL:SetTitle( strTitle )

	self.lblTitle:SetText( strTitle )

end

function PANEL:Close()

	self:SetVisible( false )

	if ( self:GetDeleteOnClose() ) then
		self:Remove()
	end

	self:OnClose()

end

function PANEL:OnClose()

end

function PANEL:Center()

	self:InvalidateLayout( true )
	self:SetPos( ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2 )

end

function PANEL:IsActive()

	if ( self:HasFocus() ) then return true end
	if ( vgui.FocusedHasParent( self ) ) then return true end

	return false

end

function PANEL:SetIcon( str )

	if ( !str && IsValid( self.imgIcon ) ) then
		return self.imgIcon:Remove() -- We are instructed to get rid of the icon, do it and bail.
	end

	if ( !IsValid( self.imgIcon ) ) then
		self.imgIcon = vgui.Create( "DImage", self )
	end

	if ( IsValid( self.imgIcon ) ) then
		self.imgIcon:SetMaterial( Material( str ) )
	end

end

function PANEL:Think()
	pulseOffset = 5*(math.sin((self:GetPulseOffset())*(CurTime())))
	self.lblTitle:SetColor(Color(math.Clamp(0 + pulseOffset * 4, 0, 255), math.Clamp(153 + pulseOffset*3, 0, 255),math.Clamp(204 + pulseOffset*5,0,255), 255))

	local mousex = math.Clamp( gui.MouseX(), 1, ScrW()-1 )
	local mousey = math.Clamp( gui.MouseY(), 1, ScrH()-1 )

	if ( self.Dragging ) then

		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		-- Lock to screen bounds if screenlock is enabled
		if ( self:GetScreenLock() ) then

			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )

		end

		self:SetPos( x, y )

	end

	if ( self.Sizing ) then

		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]
		local px, py = self:GetPos()

		if ( x < self.m_iMinWidth ) then x = self.m_iMinWidth elseif ( x > ScrW() - px and self:GetScreenLock() ) then x = ScrW() - px end
		if ( y < self.m_iMinHeight ) then y = self.m_iMinHeight elseif ( y > ScrH() - py and self:GetScreenLock() ) then y = ScrH() - py end

		self:SetSize( x, y )
		self:SetCursor( "sizenwse" )
		return

	end

	if ( self.Hovered && self.m_bSizable &&
		 mousex > ( self.x + self:GetWide() - 20 ) &&
		 mousey > ( self.y + self:GetTall() - 20 ) ) then

		self:SetCursor( "sizenwse" )
		return

	end

	if ( self.Hovered && self:GetDraggable() && mousey < ( self.y + 24 ) ) then
		self:SetCursor( "sizeall" )
		return
	end

	self:SetCursor( "arrow" )

	-- Don't allow the frame to go higher than 0
	if ( self.y < 0 ) then
		self:SetPos( self.x, 0 )
	end

end

function PANEL:Paint( w, h )

	if ( self.m_bBackgroundBlur ) then
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
	end

	if !self.initClose and !(self.alpha == 1) then
		self.alpha = math.Clamp((CurTime()-self.createdTime)/self:GetFadeOffset(),0,1)
		self:SetAlpha(255*self.alpha)
	elseif self.initClose then
		self.alpha = (self.alpha < 0.01) and self:Close() and 0 or math.Clamp((-(CurTime()-self.initCloseTime)/self:GetFadeOffset())+ 1,0,1)
		self:SetAlpha(255*self.alpha)
	end

	local topBarHeight = 36

	draw.RoundedBoxEx( 4, 0, 0, w, topBarHeight, Color( 211, 211, 211, 200 ), true, true, false, false )
	draw.RoundedBoxEx( 4, 1, 1, w-2, topBarHeight-2, Color( 222, 222, 222, 255 ), true, true, false, false )

	draw.RoundedBoxEx( 4, 0, topBarHeight, w, h - topBarHeight, Color( 200, 200, 200, 200 ), false, false, true, true )
	draw.RoundedBoxEx( 4, 1, topBarHeight + 1, w-2, h - topBarHeight-2, Color( 241, 241, 241, 255 ), false, false, true, true )

	surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 )

	surface.DrawLine( 0, 35, w, 35 )
	return true

end

function PANEL:OnMousePressed()

	if ( self.m_bSizable ) then

		if ( gui.MouseX() > ( self.x + self:GetWide() - 20 ) &&
			gui.MouseY() > ( self.y + self:GetTall() - 20 ) ) then

			self.Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
			self:MouseCapture( true )
			return
		end

	end

	if ( self:GetDraggable() && gui.MouseY() < (self.y + 24) ) then
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end

end

function PANEL:OnMouseReleased()

	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture( false )

end

function PANEL:PerformLayout()

	local titlePush = 0

	if ( IsValid( self.imgIcon ) ) then

		self.imgIcon:SetPos( 5, 5 )
		self.imgIcon:SetSize( 16, 16 )
		titlePush = 16

	end

	self.btnClose:SetPos( self:GetWide() - 31 - 4, 3 )
	self.btnClose:SetSize( 31, 31 )

	self.lblTitle:SetPos( 8 + titlePush, 8 )
	self.lblTitle:SetSize( self:GetWide() - 25 - titlePush, 22 )

end

derma.DefineControl("AFrame", "Aura Interface: AFrame", PANEL, "EditablePanel")