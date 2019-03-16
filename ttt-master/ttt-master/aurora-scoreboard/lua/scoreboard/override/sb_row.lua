local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation


SB_ROW_HEIGHT = 24 --16

local PANEL = {}

function PANEL:Init()
	self.info = nil

	self.open = false

	self.cols = {}
	self:AddColumn( GetTranslation("sb_ping"), function(ply) return ply:Ping() end )
	self:AddColumn( GetTranslation("sb_deaths"), function(ply) return ply:Deaths() end )
	self:AddColumn( GetTranslation("sb_score"), function(ply) return ply:Frags() end )

	if KARMA.IsEnabled() then
		self:AddColumn( GetTranslation("sb_karma"), function(ply) return math.Round(ply:GetBaseKarma()) end )
	end

	if ScoreboardConfig.PS then
		pcall(self:AddColumn("Points", function(ply) return ply:PS2_GetPoints() end))
	end

	hook.Call("TTTScoreboardColumns", nil, self)

	for _, c in ipairs(self.cols) do
		c:SetMouseInputEnabled(false)
	end

	self.tag = vgui.Create("DLabel", self)
	self.tag:SetText("")
	self.tag:SetMouseInputEnabled(false)

	self.sresult = vgui.Create("DImage", self)
	self.sresult:SetSize(16,16)
	self.sresult:SetMouseInputEnabled(false)

	self.avatar = vgui.Create( "AvatarImage", self )
	self.avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)
	self.avatar:SetMouseInputEnabled(false)

	self.nick = vgui.Create("DLabel", self)
	self.nick:SetMouseInputEnabled(false)

	self.voice = vgui.Create("DImageButton", self)
	self.voice:SetSize(16,16)

	self.rankicon = vgui.Create("DImageButton", self)
	self.rankicon:SetSize(16,16)

	self:SetCursor( "hand" )
end

function PANEL:AddColumn( label, func, width )
	local lbl = vgui.Create( "DLabel", self )
	lbl.GetPlayerText = func
	lbl.IsHeading = false
	lbl.Width = width or 50 

	table.insert( self.cols, lbl )
	return lbl
end

function GAMEMODE:TTTScoreboardColorForPlayer(ply)
	if not IsValid(ply) then return ScoreboardConfig.DefaultPlayerColor end

	for v,z in pairs(ScoreboardConfig.SB_RankNameColors) do
		if ply:GetUserGroup() == z[1] then return z[2] end
	end

	if ply:IsAdmin() and GetGlobalBool("ttt_highlight_admins", true) then
		return ScoreboardConfig.DefaultAdminColor
	end
	return ScoreboardConfig.DefaultPlayerColor
end

local function ColorForPlayer(ply)
	if IsValid(ply) then
		local c = hook.Call("TTTScoreboardColorForPlayer", GAMEMODE, ply)

		if c and type(c) == "table" and c.r and c.b and c.g and c.a then
			return c
		else
			ErrorNoHalt("TTTScoreboardColorForPlayer hook returned something that isn't a color!\n")
		end
	end
	return ScoreboardConfig.DefaultPlayerColor
end

function PANEL:Paint()
	if not IsValid(self.Player) then return end

	local ply = self.Player

	if ply:IsTraitor() then
		surface.SetDrawColor(255, 0, 0, 30)
		surface.DrawRect(0, 0, self:GetWide(), SB_ROW_HEIGHT)
	elseif ply:IsDetective() then
		surface.SetDrawColor(0, 0, 255, 30)
		surface.DrawRect(0, 0, self:GetWide(), SB_ROW_HEIGHT)
	end


	if ply == LocalPlayer() then
		surface.SetDrawColor( 200, 200, 200, math.Clamp(math.sin(RealTime() * 2) * 50, 0, 100))
		surface.DrawRect(0, 0, self:GetWide(), SB_ROW_HEIGHT )
	end

	return true
end

function PANEL:SetPlayer(ply)
	self.Player = ply
	self.avatar:SetPlayer(ply)

	if not self.info then
		local g = ScoreGroup(ply)
		if g == GROUP_TERROR and ply != LocalPlayer() then
			self.info = vgui.Create("TTTScorePlayerInfoTags", self)
			self.info:SetPlayer(ply)

			self:InvalidateLayout()
		elseif g == GROUP_FOUND or g == GROUP_NOTFOUND then
			self.info = vgui.Create("TTTScorePlayerInfoSearch", self)
			self.info:SetPlayer(ply)
			self:InvalidateLayout()
		end
	else
		self.info:SetPlayer(ply)

		self:InvalidateLayout()
	end

	self.voice.DoClick = function()
	if IsValid(ply) and ply != LocalPlayer() then
		ply:SetMuted(not ply:IsMuted())
	end
end

self:UpdatePlayerData()
end

function PANEL:GetPlayer() return self.Player end

function PANEL:UpdatePlayerData()
	if not IsValid(self.Player) then return end

	local ply = self.Player
	for i=1,#self.cols do
		self.cols[i]:SetText( self.cols[i].GetPlayerText(ply, self.cols[i]) )
	end
	

	self.nick:SetText(ply:Nick())
	self.nick:SizeToContents()
	self.nick:SetTextColor(ColorForPlayer(ply))

	local ptag = ply.sb_tag
	if ScoreGroup(ply) != GROUP_TERROR then
		ptag = nil
	end

	self.tag:SetText(ptag and GetTranslation(ptag.txt) or "")
	self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)

	self.sresult:SetVisible(ply.search_result != nil)

	if ply.search_result and (LocalPlayer():IsDetective() or (not ply.search_result.show)) then
		self.sresult:SetImageColor(Color(200, 200, 255))
	end

	self:LayoutColumns()

	if self.info then
		self.info:UpdatePlayerData()
	end

	if self.Player != LocalPlayer() then
		local muted = self.Player:IsMuted()
		self.voice:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
	else
		self.voice:Hide()
	end

	for v,z in pairs(ScoreboardConfig.SB_Ranks) do
		if self.Player:GetUserGroup() == z[1] then self.rankicon:SetImage(z[2]) end
	end
end

function PANEL:ApplySchemeSettings()
	for k,v in pairs(self.cols) do
		v:SetFont("minimal_small")
		v:SetTextColor(COLOR_WHITE)
	end

	self.nick:SetFont("minimal_small")
	self.nick:SetTextColor(ColorForPlayer(self.Player))

	local ptag = self.Player and self.Player.sb_tag
	self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)
	self.tag:SetFont("minimal_small")

	self.sresult:SetImage("icon16/magnifier.png")
	self.sresult:SetImageColor(Color(170, 170, 170, 150))
end

function PANEL:LayoutColumns()
	local cx = self:GetWide()
	for k,v in ipairs(self.cols) do
		v:SizeToContents()
		cx = cx - v.Width
		v:SetPos(cx - v:GetWide()/2, (SB_ROW_HEIGHT - v:GetTall()) / 2)
	end

	self.tag:SizeToContents()
	cx = cx - 90
	self.tag:SetPos(cx - self.tag:GetWide()/2 - 15, (SB_ROW_HEIGHT - self.tag:GetTall()) / 2)

	self.sresult:SetPos(cx - 8, (SB_ROW_HEIGHT - 16) / 2)
end

function PANEL:PerformLayout()
	self.avatar:SetPos(0,0)
	self.avatar:SetSize(SB_ROW_HEIGHT,SB_ROW_HEIGHT)

	local fw = sboard_panel.ply_frame:GetWide()
	self:SetWide( fw )

	if not self.open then
		self:SetSize(self:GetWide(), SB_ROW_HEIGHT)

		if self.info then self.info:SetVisible(false) end
	elseif self.info then
		self:SetSize(self:GetWide(), 100 + SB_ROW_HEIGHT)

		self.info:SetVisible(true)
		self.info:SetPos(5, SB_ROW_HEIGHT + 5)
		self.info:SetSize(self:GetWide(), 100)
		self.info:PerformLayout()

		self:SetSize(self:GetWide(), SB_ROW_HEIGHT + self.info:GetTall())
	end

	self.nick:SizeToContents()

	self.nick:SetPos(SB_ROW_HEIGHT + 10, (SB_ROW_HEIGHT - self.nick:GetTall()) / 2)

	self:LayoutColumns()

	self.voice:SetVisible(not self.open)
	self.voice:SetSize(16, 16)
	self.voice:DockMargin(4, 4, 4, 4)
	self.voice:Dock(RIGHT)

	self.rankicon:SetVisible(true)
	self.rankicon:SetSize(16,16)
	self.rankicon:SetPos(self.nick:GetWide() +40, 4)
end

function PANEL:DoClick(x, y)
	self:SetOpen(not self.open)
end

function PANEL:SetOpen(o)
	if self.open then
		surface.PlaySound("ui/buttonclickrelease.wav")
	else
		surface.PlaySound("ui/buttonclick.wav")
	end

	self.open = o

	self:PerformLayout()
	self:GetParent():PerformLayout()
	sboard_panel:PerformLayout()
end

function PANEL:DoRightClick()

	local ply = self.Player

	if IsValid(ply) then
		local context = DermaMenu()

		context:AddOption("Copy Name", function() SetClipboardText(ply:Nick()) end):SetImage("icon16/user_edit.png")
		context:AddOption("Copy SteamID", function() SetClipboardText(ply:SteamID()) end):SetImage("icon16/tag_blue.png")
		context:AddOption("Steam Community Profile", function() ply:ShowProfile() end):SetImage("icon16/world.png")

		if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then   
			local admintools,menuimg = context:AddSubMenu("Admin")
			menuimg:SetImage("icon16/shield.png")
			admintools:AddOption("Kick", function() Derma_StringRequest( "Kick Reason", "Reason why you are kicking the player", "", function(r) RunConsoleCommand("ulx","kick",ply:Nick(),r) end, nil, "Kick", "Cancel" ) end):SetImage("icon16/door_out.png")
			admintools:AddOption("Ban", function() Derma_StringRequest( "Ban Reason", "Reason why you are banning the player", "", function(r)  
				Derma_StringRequest("Ban Length", "Enter the length of the ban", ScoreboardConfig.BanTime, function(t) 
					RunConsoleCommand("ulx","ban",ply:Nick(),t,r) end , nil, "Okay", "Cancel") end, nil, "Ban", "Cancel" ) end):SetImage("icon16/door_out.png")

			admintools:AddSpacer()

			admintools:AddOption("Slay", function() RunConsoleCommand("ulx","slay",ply:Nick()) end):SetImage("icon16/bomb.png")
			if ScoreboardConfig.SlayNR then
				admintools:AddOption("Slay Next Round", function () RunConsoleCommand("ulx", "slaynr", ply:Nick(), 1) end):SetImage("icon16/controller_delete.png")
			end

			admintools:AddSpacer()

			admintools:AddOption("Mute", function() RunConsoleCommand("ulx","mute",ply:Nick()) end):SetImage("icon16/box.png")
			admintools:AddOption("Gag", function() RunConsoleCommand("ulx","gag",ply:Nick()) end):SetImage("icon16/bell_delete.png")

			admintools:AddSpacer()

			admintools:AddOption("Spectate", function() RunConsoleCommand("ulx","spectate",ply:Nick()) end):SetImage("icon16/zoom.png")

			admintools:AddSpacer()
		end
		if ScoreboardConfig.UseWyozi then
			if hook.Call("WTEHasPermission", gmod.GetGamemode(), LocalPlayer(), "setsbcolor", self.Player) or hook.Call("WTEHasPermission", gmod.GetGamemode(), LocalPlayer(), "setsbtagcolor", self.Player) or hook.Call("WTEHasPermission", gmod.GetGamemode(), LocalPlayer(), "setsbtagcolor", self.Player) then
				local wyozi,menuimg = context:AddSubMenu("Tag Editor")
				menuimg:SetImage("icon16/wand.png")
				if hook.Call("WTEHasPermission", gmod.GetGamemode(), LocalPlayer(), "setsbcolor", self.Player) then
					wyozi:AddOption("Modify name color", function()

						local Frame = vgui.Create( "DFrame" ) 
						Frame:SetSize( 267,186 )
						Frame:Center()
						Frame:MakePopup()
						Frame:SetTitle("Select name color")

						local Mixer = vgui.Create( "DColorMixer", Frame )
						Mixer:Dock( FILL )		
						Mixer:SetPalette( true ) 
						Mixer:SetAlphaBar( false )
						Mixer:SetWangs( true )	

						local v = self.Player:GetNWVector("wte_sbclr")
						Mixer:SetColor( (v and (v.x ~= 0 or v.y ~= 0 or v.z ~= 0)) and Color(v.x,v.y,v.z) or Color(255, 255, 255) )

						Frame.OnClose = function()
						if not IsValid(self.Player) then return end
						local clr = Mixer:GetColor()
						hook.Call("WTESetNameColor", gmod.GetGamemode(), self.Player, clr)
					end
				end):SetIcon("icon16/color_wheel.png")
				end
				if hook.Call("WTEHasPermission", gmod.GetGamemode(), LocalPlayer(), "setsbtagcolor", self.Player) then
					wyozi:AddOption("Modify tag color", function()

						local Frame = vgui.Create( "DFrame" )
						Frame:SetSize( 270, 166*2 + 45 )
						Frame:Center()
						Frame:MakePopup()
						Frame:SetTitle("Select tag color")

						local Mixer = vgui.Create( "DColorMixer", Frame )
						Mixer:SetPos(0, 22)
						Mixer:SetSize( 267, 166)
						Mixer:SetPalette( true ) 
						Mixer:SetAlphaBar( false )
						Mixer:SetWangs( true )	

						local lbl = vgui.Create("DLabel", Frame)
						lbl:SetText("Glow color (set to solid black to disable):")
						lbl:SetPos(10, 187)
						lbl:SetSize(200, 20)

						local Mixer2 = vgui.Create( "DColorMixer", Frame )
						Mixer2:SetPos(0, 207)
						Mixer2:SetSize( 267, 166)
						Mixer2:SetPalette( true ) 
						Mixer2:SetAlphaBar( false )
						Mixer2:SetWangs( true )

						local v = self.Player:GetNWVector("wte_sbtclr")
						Mixer:SetColor( (v and (v.x ~= 0 or v.y ~= 0 or v.z ~= 0)) and Color(v.x,v.y,v.z) or Color(255, 255, 255) )
						local v = self.Player:GetNWVector("wte_sbtclr2")
						Mixer2:SetColor( (v and (v.x ~= 0 or v.y ~= 0 or v.z ~= 0)) and Color(v.x,v.y,v.z) or Color(0, 0, 0) )

						Frame.OnClose = function()
						if not IsValid(self.Player) then return end
						local clr, clr2 = Mixer:GetColor(), Mixer2:GetColor()
						hook.Call("WTESetTagColor", gmod.GetGamemode(), self.Player, clr, clr2)
					end
				end):SetIcon("icon16/tag_blue.png")
end
if hook.Call("WTEHasPermission", gmod.GetGamemode(), LocalPlayer(), "setsbtagtext", self.Player) then
	wyozi:AddOption("Modify tag text", function()

		local Frame = vgui.Create( "DFrame" )
		Frame:SetSize( 267, 60 )
		Frame:Center()
		Frame:MakePopup()
		Frame:SetTitle("Select tag text")

		local Mixer = vgui.Create( "DTextEntry", Frame )
		Mixer:Dock( FILL )
		Mixer:SetText(self.Player:GetNWString("wte_sbtstr") or "")

		Mixer:RequestFocus()

		local function WeBeDone()
			if not IsValid(self.Player) then return end
			hook.Call("WTESetTagText", gmod.GetGamemode(), self.Player, Mixer:GetText())
		end

		Frame.OnClose = WeBeDone
		Mixer.OnEnter = function() Frame:Close() end
	end):SetIcon("icon16/tag_blue_edit.png")
end
end


end
context:Open()
end

end

vgui.Register( "TTTScorePlayerRow", PANEL, "Button" )
