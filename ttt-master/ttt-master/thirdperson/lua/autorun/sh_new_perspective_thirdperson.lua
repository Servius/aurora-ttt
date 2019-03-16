------------------------------------
----------Hat's ThirdPerson---------
------------------------------------
--Copyright (c) 2014 my_hat_stinks--
------------------------------------

// Permissions //
local function SetupPermission( Permission, DefaultGroup, Help, Cat )
	if ULib then
		local grp = ULib.ACCESS_ALL
		
		return ULib.ucl.registerAccess( Permission, nil, Help, Cat )
	end
	if evolve and evolve.privileges then
		table.Add( evolve.privileges, {Permission} )
		table.sort( evolve.privileges )
		return
	end
	if exsto then
		exsto.CreateFlag( Permission:lower(), Help )
		return
	end
end
local function HasPermission( ply, Permission, Default )
	if not IsValid(ply) then return Default end
	
	if ULib then
		return ULib.ucl.query( ply, Permission, true )
	end
	if ply.EV_HasPrivilege then
		return ply:EV_HasPrivilege( Permission )
	end
	if exsto then
		return ply:IsAllowed( Permission:lower() ) --This probably works, can't find a reasonably working exsto version to test properly...
	end
	
	return Default
end

if SERVER then
	AddCSLuaFile()
	
	hook.Add( "Initialize", "NewPerspective SetupPermissions", function() --Short delay, to load after admin mods
		SetupPermission( "NewPerspective_ThirdPerson", nil, "User can enable third person", "New Perspective" )
		SetupPermission( "NewPerspective_Crosshair", nil, "User can enable New Perspective crosshair", "New Perspective" )
	end)
else
	// Convars //
	--Generic stuff
	CreateClientConVar( "hat_thirdperson_enable", 0, true, true )
	CreateClientConVar( "hat_thirdperson_fixangles", 0, true, true ) --Centre crosshair on screen
	CreateClientConVar( "hat_thirdperson_rightshoulder", 1, true, true ) --Change this to change shoulder
	CreateClientConVar( "hat_thirdperson_disablesights", 1, true, true ) --Disable third person during ironsights
	
	CreateClientConVar( "hat_thirdperson_aimcorrection", 1, true, true )

	--Position stuff
	CreateClientConVar( "hat_thirdperson_upoffset", 0, true, true )
	CreateClientConVar( "hat_thirdperson_rightoffset", 20, true, true )
	CreateClientConVar( "hat_thirdperson_forwardoffset", 30, true, true )

	CreateClientConVar( "hat_thirdperson_fov", 75, true, true )

	--Crosshair stuff
	CreateClientConVar( "hat_thirdperson_crosshair", 1, true, false )
	CreateClientConVar( "hat_thirdperson_crossfp", 0, true, false ) --Draw in first person too?
	CreateClientConVar( "hat_thirdperson_crosstype", 1, true, false )

	CreateClientConVar( "hat_thirdperson_crossred", 100, true, false )
	CreateClientConVar( "hat_thirdperson_crossgreen", 200, true, false )
	CreateClientConVar( "hat_thirdperson_crossblue", 100, true, false )
	CreateClientConVar( "hat_thirdperson_crossalpha", 255, true, false )

	--Binds
	CreateClientConVar( "hat_thirdperson_bindmenu", 72, true, false ) --See KEY_ enums (Default - 72 (Ins))
	CreateClientConVar( "hat_thirdperson_bindtoggle", 70, true, false )
	CreateClientConVar( "hat_thirdperson_bindshoulder", 70, true, false )
	CreateClientConVar( "hat_thirdperson_bindangle", 70, true, false )
	CreateClientConVar( "hat_thirdperson_bindcross", 70, true, false )
	CreateClientConVar( "hat_thirdperson_bindcorrect", 70, true, false )
end

local AllowCustomCrosshair = true

// Helper functions //
local function CheckSights( wep )
	if not IsValid(wep) then return false end
	--Compatible with: TTT default, DarkRP default, M9K
	return (wep.GetIronsights and wep:GetIronsights()) or
		(wep.IsFAS2Weapon and wep.dt and (wep.dt.Status==FAS_STAT_ADS or wep.dt.Status==FAS_STAT_CUSTOMIZE))
end

local function GetBool( var, ply )
	if CLIENT then return cvars.Bool(var) end
	return ply:GetInfo( var )=="1"
end
local function GetNum( var, ply )
	if CLIENT then return cvars.Number( var ) end
	return ply:GetInfoNum( var, 0 )
end

// Camera calculations //
local HeldAngle, LastAng, LastPos, CamPos, SetAng
local function CalcView( ply, pos, ang, fov, nearz, farz )
	if CLIENT and not HasPermission( LocalPlayer(), "NewPerspective_ThirdPerson", true ) then return end
	
	if GetBool( "hat_thirdperson_enable", ply ) and not ply:InVehicle() then
		if ply:KeyDown( IN_ZOOM ) and ply:GetCanZoom() then return end
		if ply:GetObserverMode()~=OBS_MODE_NONE then return end
		if GetBool("hat_thirdperson_disablesights", ply) and HeldAngle then return end
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and GetBool("hat_thirdperson_disablesights", ply) and CheckSights(wep) then return end
		local ret = {}
		
		ret.origin = pos + (ang:Forward()*(- math.Clamp(GetNum("hat_thirdperson_forwardoffset", ply), -10, 500) )) +
			(ang:Up()*( math.Clamp(GetNum("hat_thirdperson_upoffset", ply), -10, 100) )) +
			(ang:Right()*(GetBool("hat_thirdperson_rightshoulder", ply) and 1 or (-1))*( math.Clamp(GetNum("hat_thirdperson_rightoffset", ply), 0, 100) ))
		local tr_wall = util.TraceLine( {start=ply:GetShootPos(), endpos=ret.origin, filter=ply, mask = MASK_SOLID} )
		if tr_wall.Hit and tr_wall.HitPos then
			ret.origin = tr_wall.HitPos + (ply:GetShootPos()-tr_wall.HitPos):GetNormal()*7
		end
		
		ret.fov = math.Clamp( GetNum( "hat_thirdperson_fov", ply ), 10, 175 )
		
		if GetBool( "hat_thirdperson_fixangles", ply ) then
			if HeldAngle then ret.angles = HeldAngle else
				local tr = ply:GetEyeTrace()
				
				if tr.HitPos then
					ret.angles = (tr.HitPos - ret.origin):Angle()
				else
					ret.angles = ang
				end
			end
		else
			ret.angles = ang
		end
		LastAng = ret.angles
		
		return ret
	end
end
hook.Add( "CalcView", "HatsThirdPerson CalcView", CalcView )
local function StartHoldAngle() HeldAngle = LastAng end
local function EndHoldAngle() HeldAngle = nil end
hook.Add( "OnContextMenuOpen", "HatsThirdPerson ContextOpen", StartHoldAngle )
hook.Add( "OnContextMenuClose", "HatsThirdPerson ContextClose", EndHoldAngle )

// Local player drawing //
local function ShouldDrawLocal()
	local ply = LocalPlayer()
	if not HasPermission( ply, "NewPerspective_ThirdPerson", true ) then return end
	
	if ply:KeyDown( IN_ZOOM ) and ply:GetCanZoom() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid(wep) and cvars.Bool("hat_thirdperson_disablesights") and CheckSights(wep) then return end
	if cvars.Bool("hat_thirdperson_disablesights") and HeldAngle then return end
	if cvars.Bool( "hat_thirdperson_enable" ) then
		return true --Don't want an explicit false, just in case
	end
end
hook.Add( "ShouldDrawLocalPlayer", "HatsThirdPerson DrawLocalPly", ShouldDrawLocal )

// Crosshairs //
local crossfunc = {
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawLine( x-10, y, x+10, y )
		surface.DrawLine( x, y-10, x, y+10 )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawLine( x-13, y, x-6, y )
		surface.DrawLine( x+13, y, x+6, y )
		surface.DrawLine( x, y-13, x, y-6 )
		surface.DrawLine( x, y+13, x, y+6 )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawLine( x-10, y-10, x+11, y+11 )
		surface.DrawLine( x-10, y+10, x+11, y-11 )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawLine( x-13, y-13, x-5, y-5 )
		surface.DrawLine( x-13, y+13, x-5, y+5 )
		surface.DrawLine( x+12, y-12, x+5, y-5 )
		surface.DrawLine( x+12, y+12, x+5, y+5 )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawLine( x+7, y+15, x, y )
		surface.DrawLine( x-7, y+15, x, y )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawLine( x+7, y+15, x, y )
		surface.DrawLine( x-7, y+15, x, y )
		
		surface.DrawLine( x-45, y-6, x-45, y+6 )
		surface.DrawLine( x+45, y-6, x+45, y+6 )
		
		surface.DrawLine( x-90, y-6, x-90, y+6 )
		surface.DrawLine( x+90, y-6, x+90, y+6 )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawCircle( x, y, 0, col )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawCircle( x, y, 1, col )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawCircle( x, y, 0, col )
		surface.DrawCircle( x, y, 10, col )
	end,
	function(x,y, col)
		surface.SetDrawColor( col )
		surface.DrawCircle( x, y, 1, col )
		surface.DrawCircle( x, y, 10, col )
	end,
}
local function DrawCrosshair()
	if not AllowCustomCrosshair then return end
	if not HasPermission( LocalPlayer(), "NewPerspective_Crosshair", true ) then return end
	
	if cvars.Bool( "hat_thirdperson_crosshair" ) and (cvars.Bool( "hat_thirdperson_enable" ) or cvars.Bool( "hat_thirdperson_crossfp" )) then
		local func = math.Clamp(math.Round(cvars.Number( "hat_thirdperson_crosstype" )), 1, #crossfunc)
		local CrossCol = Color( cvars.Number( "hat_thirdperson_crossred" ), cvars.Number( "hat_thirdperson_crossgreen" ), cvars.Number( "hat_thirdperson_crossblue" ) )
		CrossCol.a = cvars.Number( "hat_thirdperson_crossalpha" )
		
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		local x,y
		if cvars.Bool( "hat_thirdperson_fixangles" ) or cvars.Bool( "hat_thirdperson_aimcorrection" ) or ply:GetObserverMode()~=OBS_MODE_NONE then
			x,y = ScrW()/2, ScrH()/2
		elseif IsValid(wep) and cvars.Bool("hat_thirdperson_disablesights") and CheckSights(wep) then
				x,y = ScrW()/2, ScrH()/2
		else
			local tr = util.TraceLine( {start=ply:GetShootPos(), endpos=(ply:GetShootPos()+(ply:GetAimVector()*10000))} )
			if tr.HitPos then
				local scr = tr.HitPos:ToScreen()
				x,y = scr.x, scr.y
			else
				x,y = ScrW()/2, ScrH()/2
			end
		end
		if crossfunc[func] then crossfunc[func](x,y, CrossCol) else crossfunc[1](x,y, CrossCol) end
	end
end
hook.Add( "HUDPaintBackground", "HatsThirdPerson DrawCrosshair", DrawCrosshair ) --Just to make sure it's under anything important

local function ShouldDrawCrosshair( str )
	if not AllowCustomCrosshair then return end
	if str=="CHudCrosshair" then
		if cvars.Bool( "hat_thirdperson_crosshair" ) and (cvars.Bool( "hat_thirdperson_enable" ) or cvars.Bool( "hat_thirdperson_crossfp" )) then
			return false
		end
	end
end
hook.Add( "HUDShouldDraw", "HatsThirdPerson DrawCrosshair", ShouldDrawCrosshair )

// Menu //
local MenuCols = {
	MainShadow = Color(50,50,50), MainLight = Color(190,190,200), MainMain = Color(140,140,150),
	IndentShadow = Color(80,80,80), IndentMain = Color(130,130,140),
}
local Menu
local function OpenMenu()
	--if IsValid(Menu) then Menu:Remove() end
	if IsValid(Menu) then return end
	if not HasPermission( LocalPlayer(), "NewPerspective_ThirdPerson", true ) then return end
	
	local frame = vgui.Create( "DFrame" )
	Menu = frame
	frame:SetTitle( "New Perspective Client Settings" )
	frame:SetSize( math.min(400, ScrW()), math.min(800,ScrH()) )
	frame:SetPos( (ScrW()/2)-(frame:GetWide()/2), (ScrH()/2)-(frame:GetTall()/2) )
	frame.Paint = function( s,w,h )
		--Main frame
		surface.SetDrawColor( MenuCols.MainShadow ) surface.DrawRect( 0,0, w,h )
		surface.SetDrawColor( MenuCols.MainLight ) surface.DrawRect( 0,0, w-1,h-1 )
		surface.SetDrawColor( MenuCols.MainMain ) surface.DrawRect( 1,1, w-2,h-2 )
		
		--Title bar
		surface.SetDrawColor( MenuCols.MainLight ) surface.DrawRect( 2,2, w-4,21 )
		surface.SetDrawColor( MenuCols.IndentShadow ) surface.DrawRect( 2,2, w-5,20 )
		surface.SetDrawColor( MenuCols.IndentMain ) surface.DrawRect( 3,3, w-6,19 )
	end
	frame:DockPadding( 2,25,2,2 )
	frame:MakePopup()
	
	--DPanelList doesn't accept padding for items added to it, use a standard panel behind it as workaround
	local fpnl = vgui.Create( "DScrollPanel", frame )
	fpnl:Dock( FILL )
	fpnl.Paint = function( s,w,h )
		surface.SetDrawColor( MenuCols.MainLight ) surface.DrawRect( 0,0, w,h )
		surface.SetDrawColor( MenuCols.IndentShadow ) surface.DrawRect( 0,0, w-1,h-1 )
		surface.SetDrawColor( MenuCols.IndentMain ) surface.DrawRect( 1,1, w-2,h-2 )
	end
	fpnl:DockPadding( 2,2,2,2 )
	
	local pnl = vgui.Create( "DPanelList", fpnl )
	pnl:SetPos( 2,2 )
	pnl:SetSize( math.min(400,ScrW())-8, 845 )
	pnl.Paint = function() end
	pnl.OnMouseWheeled = function( s, ... )
		fpnl.OnMouseWheeled( fpnl, ... )
	end
	
	--Generic stuff
	local set = vgui.Create( "DForm", pnl )
	set:SetName( "Standard settings" )
	set:CheckBox( "Enable third person", "hat_thirdperson_enable" )
	set:CheckBox( "Centre camera to crosshair", "hat_thirdperson_fixangles" )
	set:CheckBox( "First person during ironsights/context menu (Recommended)", "hat_thirdperson_disablesights" )
	set:CheckBox( "Correct aim (Experimental)", "hat_thirdperson_aimcorrection" )
	
	pnl:AddItem( set )
	
	--Position stuff
	set = vgui.Create( "DForm", pnl )
	set:SetName( "Camera settings" )
	set:CheckBox( "Over Right shoulder", "hat_thirdperson_rightshoulder" )
	set:NumSlider( "Offset (Up)", "hat_thirdperson_upoffset", -10, 100, 0 )
	set:NumSlider( "Offset (Back)", "hat_thirdperson_forwardoffset", -10, 500, 0 )
	set:NumSlider( "Offset (Side)", "hat_thirdperson_rightoffset", 0, 100, 0 )
	set:NumSlider( "Field of view", "hat_thirdperson_fov", 10, 175, 0 )
	
	pnl:AddItem( set )
	
	if AllowCustomCrosshair then
		--Crosshair stuff
		set = vgui.Create( "DForm", pnl )
		set:SetName( "Crosshair settings" )
		set:CheckBox( "Use custom crosshair", "hat_thirdperson_crosshair" )
		set:CheckBox( "Use crosshair in first person too", "hat_thirdperson_crossfp" )
		set:NumSlider( "Crosshair Type", "hat_thirdperson_crosstype", 1, #crossfunc, 0 )
		
		set:NumSlider( "Color (Red)", "hat_thirdperson_crossred", 0, 255, 0 )
		set:NumSlider( "Color (Green)", "hat_thirdperson_crossgreen", 0, 255, 0 )
		set:NumSlider( "Color (Blue)", "hat_thirdperson_crossblue", 0, 255, 0 )
		set:NumSlider( "Crosshair alpha", "hat_thirdperson_crossalpha", 0, 255, 0 )
		
		pnl:AddItem( set )
	end
	
	--Binds
	set = vgui.Create( "DForm", pnl )
	set:SetName( "Key Binds" )
	
	--Toggle bind
	local BPnl = vgui.Create( "DPanel", set ) BPnl:SetSize( 80, 20 ) BPnl.Paint = function() end
	local BindEnable = vgui.Create( "DButton", BPnl )
	BindEnable:Dock( LEFT ) BindEnable:SetText( "[N/A" )
	BindEnable.Think = function( s )
		local str = input.GetKeyName(cvars.Number("hat_thirdperson_bindtoggle"))
		s:SetText( (s.TakeInput and "[Enter key]") or (str=="ESCAPE" and "None") or str )
		if input.IsKeyDown(KEY_ESCAPE) and s.TakeInput and not s.EscWasDown then s:OnKeyCodePressed( KEY_ESCAPE ) end s.EscWasDown = input.IsKeyDown(KEY_ESCAPE)
	end
	BindEnable.DoClick = function( s )
		s.TakeInput = true
		s:RequestFocus()
	end
	BindEnable.OnKeyCodePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindtoggle", key )
			gui.HideGameUI()
		end
		s.TakeInput = false
	end
	BindEnable.OnMousePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindtoggle", key )
			s.TakeInput = false
		else
			return DLabel.OnMousePressed( s, key )
		end
	end
	local LabelEnable = vgui.Create( "DLabel", BPnl ) LabelEnable:Dock( LEFT )
	LabelEnable:SetText( "Toggle third person" ) LabelEnable:SizeToContents() LabelEnable:SetDark( true ) LabelEnable:DockMargin( 12,0,0,0 )
	set:AddItem( BPnl )
	
	--Shoulder bind
	local BPnl = vgui.Create( "DPanel", set ) BPnl:SetSize( 80, 20 ) BPnl.Paint = function() end
	local BindEnable = vgui.Create( "DButton", BPnl )
	BindEnable:Dock( LEFT ) BindEnable:SetText( "[N/A" )
	BindEnable.Think = function( s )
		local str = input.GetKeyName(cvars.Number("hat_thirdperson_bindshoulder"))
		s:SetText( (s.TakeInput and "[Enter key]") or (str=="ESCAPE" and "None") or str )
		if input.IsKeyDown(KEY_ESCAPE) and s.TakeInput and not s.EscWasDown then s:OnKeyCodePressed( KEY_ESCAPE ) end s.EscWasDown = input.IsKeyDown(KEY_ESCAPE)
	end
	BindEnable.DoClick = function( s )
		s.TakeInput = true
		s:RequestFocus()
	end
	BindEnable.OnKeyCodePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindshoulder", key )
			gui.HideGameUI()
		end
		s.TakeInput = false
	end
	BindEnable.OnMousePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindshoulder", key )
			s.TakeInput = false
		else
			return DLabel.OnMousePressed( s, key )
		end
	end
	BindEnable.OnLoseFocus = function(s) s.TakeInput = false end
	local LabelEnable = vgui.Create( "DLabel", BPnl ) LabelEnable:Dock( LEFT )
	LabelEnable:SetText( "Switch shoulder" ) LabelEnable:SizeToContents() LabelEnable:SetDark( true ) LabelEnable:DockMargin( 12,0,0,0 )
	set:AddItem( BPnl )
	
	--Crosshair bind
	local BPnl = vgui.Create( "DPanel", set ) BPnl:SetSize( 80, 20 ) BPnl.Paint = function() end
	local BindEnable = vgui.Create( "DButton", BPnl )
	BindEnable:Dock( LEFT ) BindEnable:SetText( "[N/A" )
	BindEnable.Think = function( s )
		local str = input.GetKeyName(cvars.Number("hat_thirdperson_bindcross"))
		s:SetText( (s.TakeInput and "[Enter key]") or (str=="ESCAPE" and "None") or str )
		if input.IsKeyDown(KEY_ESCAPE) and s.TakeInput and not s.EscWasDown then s:OnKeyCodePressed( KEY_ESCAPE ) end s.EscWasDown = input.IsKeyDown(KEY_ESCAPE)
	end
	BindEnable.DoClick = function( s )
		s.TakeInput = true
		s:RequestFocus()
	end
	BindEnable.OnKeyCodePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindcross", key )
			gui.HideGameUI()
		end
		s.TakeInput = false
	end
	BindEnable.OnMousePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindcross", key )
			s.TakeInput = false
		else
			return DLabel.OnMousePressed( s, key )
		end
	end
	local LabelEnable = vgui.Create( "DLabel", BPnl ) LabelEnable:Dock( LEFT )
	LabelEnable:SetText( "Toggle custom crosshair" ) LabelEnable:SizeToContents() LabelEnable:SetDark( true ) LabelEnable:DockMargin( 12,0,0,0 )
	set:AddItem( BPnl )
	
	--Angle bind
	local BPnl = vgui.Create( "DPanel", set ) BPnl:SetSize( 80, 20 ) BPnl.Paint = function() end
	local BindEnable = vgui.Create( "DButton", BPnl )
	BindEnable:Dock( LEFT ) BindEnable:SetText( "[N/A" )
	BindEnable.Think = function( s )
		local str = input.GetKeyName(cvars.Number("hat_thirdperson_bindangle"))
		s:SetText( (s.TakeInput and "[Enter key]") or (str=="ESCAPE" and "None") or str )
		if input.IsKeyDown(KEY_ESCAPE) and s.TakeInput and not s.EscWasDown then s:OnKeyCodePressed( KEY_ESCAPE ) end s.EscWasDown = input.IsKeyDown(KEY_ESCAPE)
	end
	BindEnable.DoClick = function( s )
		s.TakeInput = true
		s:RequestFocus()
	end
	BindEnable.OnKeyCodePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindangle", key )
			gui.HideGameUI()
		end
		s.TakeInput = false
	end
	BindEnable.OnMousePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindangle", key )
			s.TakeInput = false
		else
			return DLabel.OnMousePressed( s, key )
		end
	end
	local LabelEnable = vgui.Create( "DLabel", BPnl ) LabelEnable:Dock( LEFT )
	LabelEnable:SetText( "Toggle centre crosshair" ) LabelEnable:SizeToContents() LabelEnable:SetDark( true ) LabelEnable:DockMargin( 12,0,0,0 )
	set:AddItem( BPnl )
	
	// Bind - Correct Aim
	local BPnl = vgui.Create( "DPanel", set ) BPnl:SetSize( 80, 20 ) BPnl.Paint = function() end
	local BindEnable = vgui.Create( "DButton", BPnl )
	BindEnable:Dock( LEFT ) BindEnable:SetText( "[N/A" )
	BindEnable.Think = function( s )
		local str = input.GetKeyName(cvars.Number("hat_thirdperson_bindcorrect"))
		s:SetText( (s.TakeInput and "[Enter key]") or (str=="ESCAPE" and "None") or str )
		if input.IsKeyDown(KEY_ESCAPE) and s.TakeInput and not s.EscWasDown then s:OnKeyCodePressed( KEY_ESCAPE ) end s.EscWasDown = input.IsKeyDown(KEY_ESCAPE)
	end
	BindEnable.DoClick = function( s )
		s.TakeInput = true
		s:RequestFocus()
	end
	BindEnable.OnKeyCodePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindcorrect", key )
			gui.HideGameUI()
		end
		s.TakeInput = false
	end
	BindEnable.OnMousePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindcorrect", key )
			s.TakeInput = false
		else
			return DLabel.OnMousePressed( s, key )
		end
	end
	local LabelEnable = vgui.Create( "DLabel", BPnl ) LabelEnable:Dock( LEFT )
	LabelEnable:SetText( "Toggle aim correction" ) LabelEnable:SizeToContents() LabelEnable:SetDark( true ) LabelEnable:DockMargin( 12,0,0,0 )
	set:AddItem( BPnl )
	
	--Menu bind
	local BPnl = vgui.Create( "DPanel", set ) BPnl:SetSize( 80, 20 ) BPnl.Paint = function() end
	local BindEnable = vgui.Create( "DButton", BPnl )
	BindEnable:Dock( LEFT ) BindEnable:SetText( "[N/A" )
	BindEnable.Think = function( s )
		local str = input.GetKeyName(cvars.Number("hat_thirdperson_bindmenu"))
		s:SetText( (s.TakeInput and "[Enter key]") or (str=="ESCAPE" and "None") or str )
		if input.IsKeyDown(KEY_ESCAPE) and s.TakeInput and not s.EscWasDown then s:OnKeyCodePressed( KEY_ESCAPE ) end s.EscWasDown = input.IsKeyDown(KEY_ESCAPE)
	end
	BindEnable.DoClick = function( s )
		s.TakeInput = true
		s:RequestFocus()
	end
	BindEnable.OnKeyCodePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindmenu", key )
			gui.HideGameUI()
		end
		s.TakeInput = false
	end
	BindEnable.OnMousePressed = function( s, key )
		if s.TakeInput then
			RunConsoleCommand( "hat_thirdperson_bindmenu", key )
			s.TakeInput = false
		else
			return DLabel.OnMousePressed( s, key )
		end
	end
	local LabelEnable = vgui.Create( "DLabel", BPnl ) LabelEnable:Dock( LEFT )
	LabelEnable:SetText( "Open settings menu" ) LabelEnable:SizeToContents() LabelEnable:SetDark( true ) LabelEnable:DockMargin( 12,0,0,0 )
	set:AddItem( BPnl )
	
	pnl:AddItem( set )
end
concommand.Add( "hat_thirdperson", OpenMenu )

// Toggle funcs //
local function ToggleShoulder()
	RunConsoleCommand( "hat_thirdperson_rightshoulder", cvars.Bool( "hat_thirdperson_rightshoulder" ) and "0" or "1" )
end
local function ToggleEnabled()
	RunConsoleCommand( "hat_thirdperson_enable", cvars.Bool( "hat_thirdperson_enable" ) and "0" or "1" )
end
local function ToggleAngle()
	RunConsoleCommand( "hat_thirdperson_fixangles", cvars.Bool( "hat_thirdperson_fixangles" ) and "0" or "1" )
end
local function ToggleCross()
	RunConsoleCommand( "hat_thirdperson_crosshair", cvars.Bool( "hat_thirdperson_crosshair" ) and "0" or "1" )
end
local function ToggleCorrect()
	RunConsoleCommand( "hat_thirdperson_aimcorrection", cvars.Bool( "hat_thirdperson_aimcorrection" ) and "0" or "1" )
end

if CLIENT then
	// Binds //
	local MenuWasDown,EnableWasDown,ShoulderWasDown,AngleWasDown,CrossWasDown,CorrectWasDown
	local function KeyPress()
		--input.WasKeyPressed doesn't seem to work here, it's probably only for draw/tick hooks
		--There's no overlap between MOUSE and KEY enums (Why not just use one func? :/)
		local BindMenu = cvars.Number("hat_thirdperson_bindmenu")
		local BindIsKey = (BindMenu>=KEY_FIRST and BindMenu<=KEY_LAST)
		if BindMenu and BindMenu~=KEY_ESCAPE and ((BindIsKey and input.IsKeyDown(BindMenu)) or (input.IsMouseDown(BindMenu) and not BindIsKey)) then
			if not MenuWasDown then OpenMenu() end
			MenuWasDown = true
		else MenuWasDown = false end
		
		local BindCorrect = cvars.Number("hat_thirdperson_bindcorrect")
		local BindIsKey = (BindCorrect>=KEY_FIRST and BindCorrect<=KEY_LAST)
		if BindCorrect and BindCorrect~=KEY_ESCAPE and ((BindIsKey and input.IsKeyDown(BindCorrect)) or (input.IsMouseDown(BindCorrect) and not BindIsKey)) then
			if not CorrectWasDown then ToggleCorrect() end
			CorrectWasDown = true
		else CorrectWasDown = false end
		
		local BindToggle = cvars.Number("hat_thirdperson_bindtoggle")
		local BindIsKey = (BindToggle>=KEY_FIRST and BindToggle<=KEY_LAST)
		if BindToggle and BindToggle~=KEY_ESCAPE and ((BindIsKey and input.IsKeyDown(BindToggle)) or (input.IsMouseDown(BindToggle) and not BindIsKey)) then
			if not EnableWasDown then ToggleEnabled() end
			EnableWasDown = true
		else EnableWasDown = false end
		
		local BindShoulder = cvars.Number("hat_thirdperson_bindshoulder") 
		local BindIsKey = (BindShoulder>=KEY_FIRST and BindShoulder<=KEY_LAST)
		if BindShoulder and BindShoulder~=KEY_ESCAPE and ((BindIsKey and input.IsKeyDown(BindShoulder)) or (input.IsMouseDown(BindShoulder) and not BindIsKey)) then
			if not ShoulderWasDown then ToggleShoulder() end
			ShoulderWasDown = true
		else ShoulderWasDown = false end
		
		local BindAngle = cvars.Number("hat_thirdperson_bindangle") 
		local BindIsKey = (BindAngle>=KEY_FIRST and BindAngle<=KEY_LAST)
		if BindAngle and BindAngle~=KEY_ESCAPE and ((BindAngle and input.IsKeyDown(BindAngle)) or (input.IsMouseDown(BindAngle) and not BindIsKey)) then
			if not AngleWasDown then ToggleAngle() end
			AngleWasDown = true
		else AngleWasDown = false end
		
		local BindCross = cvars.Number("hat_thirdperson_bindcross") 
		local BindIsKey = (BindCross>=KEY_FIRST and BindCross<=KEY_LAST)
		if BindCross and BindCross~=KEY_ESCAPE and ((BindCross and input.IsKeyDown(BindCross)) or (input.IsMouseDown(BindCross) and not BindIsKey)) then
			if not CrossWasDown then ToggleCross() end
			CrossWasDown = true
		else CrossWasDown = false end
	end
	hook.Add( "Think", "HatsThirdPerson BindDetection", KeyPress )
end

// Chat commands //
local OpenMenuCommands = {
	["!thirdperson"] = true, ["!newperspective"] = true, ["!perspective"] = true,
	["/thirdperson"] = true, ["/newperspective"] = true, ["/perspective"] = true,
}
hook.Add( "OnPlayerChat", "NewPerspective ChatCommands", function(ply,str)
	if str and OpenMenuCommands[str:lower()] then
		if ply==LocalPlayer() then
			OpenMenu()
		end
		
		return true
	end
end)

// Bullet Correction //
local function ShouldCorrect(ply)
	if not (IsValid(ply) and ply:IsPlayer()) then return false end
	if CLIENT then
		if ply~=LocalPlayer() then return false end
		return cvars.Bool( "hat_thirdperson_enable" ) and cvars.Bool( "hat_thirdperson_aimcorrection" ) and not cvars.Bool( "hat_thirdperson_fixangles" )
	end
	if SERVER then
		return ply:GetInfo( "hat_thirdperson_enable" )=="1" and ply:GetInfo( "hat_thirdperson_aimcorrection" )=="1" and ply:GetInfo( "hat_thirdperson_fixangles" )~="1"
	end
end
hook.Add( "EntityFireBullets", "NewPerspective BulletCorrection", function(ent,data)
	if not ShouldCorrect(ent) then return end
	if not data then return end
	
	local offset = Vector(0,0,0)
	if data.Dir:GetNormal()~=ent:GetAimVector():GetNormal() then
		offset = (data.Dir:GetNormal() - ent:GetAimVector():GetNormal())
	end
	
	local cm = (CalcView(ent,ent:EyePos(),ent:EyeAngles(),10,0,0))
	if not cm then return end
	
	local tr = util.TraceLine( {start=cm.origin, endpos=cm.origin+((cm.angles:Forward()+offset)*100000), filter=ent, mask=MASK_SHOT} )
	if not (tr.Hit and tr.HitPos) then return end
	
	data.Dir = (tr.HitPos - data.Src):GetNormal()
	
	return true
end)
