local surface = surface
local draw = draw
local math = math
local string = string
local vgui = vgui

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

surface.CreateFont("cool_small", {font = "coolvetica",
   size = 20,
   weight = 400})
surface.CreateFont("cool_large", {font = "coolvetica",
   size = 24,
   weight = 400})
surface.CreateFont("treb_small", {font = "Trebuchet18",
   size = 14,
   weight = 700})
surface.CreateFont("minimal_large", {font="Roboto Cn",
 size = 30,
 weight = 400,
 shadow = false,
 antialias=true})
surface.CreateFont("minimal", {font="Roboto Cn",
   size = 25,
   weight = 400,
   shadow = false,
   antialias=true})
surface.CreateFont("minimal_small", {font="Roboto Cn",
   size = 20,
   weight=200,
   antialias=true})
surface.CreateFont("minimal_smaller", {font="Roboto Cn",
   size = 17,
   weight=100,
   antialias=true})

local PANEL = {}

local max = math.max
local floor = math.floor
local function UntilMapChange()
   local rounds_left = max(0, GetGlobalInt("ttt_rounds_left", 6))
   local time_left = floor(max(0, ((GetGlobalInt("ttt_time_limit_minutes") or 60) * 60) - CurTime()))

   local h = floor(time_left / 3600)
   time_left = time_left - floor(h * 3600)
   local m = floor(time_left / 60)
   time_left = time_left - floor(m * 60)
   local s = floor(time_left)

   return rounds_left, string.format("%02i:%02i:%02i", h, m, s)
end


GROUP_TERROR = 1
GROUP_NOTFOUND = 2
GROUP_FOUND = 3
GROUP_SPEC = 4

GROUP_COUNT = ScoreboardConfig.UsingSpecDM and 5 or 4

function ScoreGroup(p)
   if not IsValid(p) then return -1 end

   if DetectiveMode() then
      if p:IsSpec() and (not p:Alive()) then
         if p:GetNWBool("body_found", false) then
            return GROUP_FOUND
         else
            local client = LocalPlayer()
            if client:IsSpec() or
               client:IsActiveTraitor() or
               ((GAMEMODE.round_state != ROUND_ACTIVE) and client:IsTerror()) then
               return GROUP_NOTFOUND
            else
               return GROUP_TERROR
            end
         end
      end
   end

   return p:IsTerror() and GROUP_TERROR or GROUP_SPEC
end

function PANEL:Init()
   self.playercount = vgui.Create("DLabel", self)
   self.playercount:SetText("Players: ")
   self.playercount:SetContentAlignment(9)
   self.playercount.Think = function (text) local r = game:MaxPlayers() local t = table.Count(player.GetAll()) text:SetText(string.Interp("Players: {num} | {max}", {num = t, max = r})) end

   self.hostname = vgui.Create( "DLabel", self )
   self.hostname:SetText( ScoreboardConfig.SB_Name )
   self.hostname:SetContentAlignment(5)

   self.mapchange = vgui.Create("DLabel", self)
   self.mapchange:SetText("Map changes in 00 rounds or in 00:00:00")
   self.mapchange:SetContentAlignment(9)

   self.mapchange.Think = function (sf)
   local r, t = UntilMapChange()

   sf:SetText(GetPTranslation("sb_mapchange",
      {num = r, time = t}))
   sf:SizeToContents()
end


self.ply_frame = vgui.Create( "TTTPlayerFrame", self )

self.ply_groups = {}

local t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
t:SetGroupInfo(GetTranslation("terrorists"), ScoreboardConfig.TerroristColour, GROUP_TERROR)
self.ply_groups[GROUP_TERROR] = t

t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
t:SetGroupInfo(GetTranslation("spectators"), ScoreboardConfig.SpectatorColour, GROUP_SPEC)
self.ply_groups[GROUP_SPEC] = t

if DetectiveMode() then
   t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
   t:SetGroupInfo(GetTranslation("sb_mia"), ScoreboardConfig.MissingInActionColour, GROUP_NOTFOUND)
   self.ply_groups[GROUP_NOTFOUND] = t

   t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
   t:SetGroupInfo(GetTranslation("sb_confirmed"), ScoreboardConfig.ConfirmedColour, GROUP_FOUND)
   self.ply_groups[GROUP_FOUND] = t
end

if ScoreboardConfig.UsingSpecDM then
   local specdm = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
   specdm:SetGroupInfo("Spectator Deathmatch", Color(255, 127, 39, 100), 5)
   self.ply_groups[5] = specdm
end

   -- the various score column headers
   self.cols = {}
   self:AddColumn( GetTranslation("sb_ping") )
   self:AddColumn( GetTranslation("sb_deaths") )
   self:AddColumn( GetTranslation("sb_score") )

   if KARMA.IsEnabled() then
      self:AddColumn( GetTranslation("sb_karma") )
   end

   if ScoreboardConfig.PS then
      self:AddColumn(ScoreboardConfig.PS_Name or "Points")
   end

   -- Let hooks add their column headers (via AddColumn())
   hook.Call( "TTTScoreboardColumns", nil, self )

   self:UpdateScoreboard()
   self:StartUpdateTimer()
end

-- For headings only the label parameter is relevant, func is included for
-- parity with sb_row
function PANEL:AddColumn( label, func, width )
   local lbl = vgui.Create( "DLabel", self )
   lbl:SetText( label )
   lbl.IsHeading = true
   lbl.Width = width or 50 -- Retain compatibility with existing code

   table.insert( self.cols, lbl )
   return lbl
end

function PANEL:StartUpdateTimer()
   if not timer.Exists("TTTScoreboardUpdater") then
      timer.Create( "TTTScoreboardUpdater", 0.3, 0,
         function()
            local pnl = GAMEMODE:GetScoreboardPanel()
            if IsValid(pnl) then
               pnl:UpdateScoreboard()
            end
         end)
   end
end

local colors = {
bg = ScoreboardConfig.BG_Color,
bar = ScoreboardConfig.BAR_Color
};

local y_logo_off = 72

function PANEL:Paint()
   draw.RoundedBox( 0, 0, y_logo_off, self:GetWide(), self:GetTall() - y_logo_off - 20, colors.bg)
   draw.RoundedBox( 0, 0, y_logo_off + 25, self:GetWide(), 32, colors.bar)
end

function PANEL:PerformLayout()
   -- position groups and find their total size
   local gy = 0
   -- can't just use pairs (undefined ordering) or ipairs (group 2 and 3 might not exist)
   for i=1, GROUP_COUNT do
      local group = self.ply_groups[i]
      if ValidPanel(group) then
         if group:HasRows() then
            group:SetVisible(true)
            group:SetPos(0, gy)
            group:SetSize(self.ply_frame:GetWide(), group:GetTall())
            group:InvalidateLayout()
            gy = gy + group:GetTall() + 5
         else
            group:SetVisible(false)
         end
      end
   end

   self.ply_frame:GetCanvas():SetSize(self.ply_frame:GetCanvas():GetWide(), gy)

   local h = y_logo_off + 110 + self.ply_frame:GetCanvas():GetTall()


   local scrolling = h > ScrH() * 0.95

   self.ply_frame:SetScroll(scrolling)

   h = math.Clamp(h, 110 + y_logo_off, ScrH() * 0.95)

   local w = math.max(ScrW() * 0.6, 640)

   self:SetSize(w, h)
   self:SetPos( (ScrW() - w) / 2, math.min(72, (ScrH() - h) / 4))

   self.ply_frame:SetPos(8, y_logo_off + 85)
   self.ply_frame:SetSize(self:GetWide() - 16, self:GetTall() - 109 - y_logo_off - 5)

   -- server stuff
   self.playercount:SizeToContents()
   self.playercount:SetPos(w - self.playercount:GetWide() - 8, y_logo_off + 2)

   local hw = w - 180 - 8
   self.hostname:SetSize(hw, 32)
   self.hostname:SetPos(w/2 - self.hostname:GetWide()/2, y_logo_off + 25)

   surface.SetFont("minimal_large")
   local hname = ScoreboardConfig.SB_Name
   local tw, _ = surface.GetTextSize(hname)
   while tw > hw do
      hname = string.sub(hname, 1, -6) .. "..."
      tw, th = surface.GetTextSize(hname)
   end

   self.hostname:SetText(hname)

   self.mapchange:SizeToContents()
   self.mapchange:SetPos(8, y_logo_off + 2)

   -- score columns
   local cy = y_logo_off + 64
   local cx = w - 8 -(0)
   for k,v in ipairs(self.cols) do
      v:SizeToContents()
      cx = cx - v.Width
      v:SetPos(cx - v:GetWide()/2, cy)
   end
end

function PANEL:ApplySchemeSettings()
   self.playercount:SetFont("minimal_small")
   self.hostname:SetFont("minimal")
   self.mapchange:SetFont("minimal_small")

   self.playercount:SetTextColor(COLOR_WHITE)
   self.hostname:SetTextColor(COLOR_WHITE)
   self.mapchange:SetTextColor(COLOR_WHITE)

   for k,v in pairs(self.cols) do
      v:SetFont("minimal_smaller")
      v:SetTextColor(COLOR_WHITE)
   end
end

function PANEL:UpdateScoreboard( force )
   if not force and not self:IsVisible() then return end

   if ScoreboardConfig.UsingSpecDM then
      for k,v in pairs(player.GetAll()) do
         if v:IsGhost() and (LocalPlayer():IsSpec() or LocalPlayer():IsActiveTraitor()) then
            if self.ply_groups[5] and not self.ply_groups[5]:HasPlayerRow(v) then
               self.ply_groups[5]:AddPlayerRow(v)
            end
         end
      end
   end

   local layout = false

   -- Put players where they belong. Groups will dump them as soon as they don't
   -- anymore.
   for k, p in pairs(player.GetAll()) do
      if IsValid(p) then
         local group = ScoreGroup(p)
         if self.ply_groups[group] and not self.ply_groups[group]:HasPlayerRow(p) then
            self.ply_groups[group]:AddPlayerRow(p)
            layout = true
         end
      end
   end

   for k, group in pairs(self.ply_groups) do
      if ValidPanel(group) then
         group:SetVisible( group:HasRows() )
         group:UpdatePlayerData()
      end
   end

   if layout then
      self:PerformLayout()
   else
      self:InvalidateLayout()
   end
end

vgui.Register( "TTTScoreboard", PANEL, "Panel" )

---- PlayerFrame is defined in sandbox and is basically a little scrolling
---- hack. Just putting it here (slightly modified) because it's tiny.

local PANEL = {}
function PANEL:Init()
   self.pnlCanvas  = vgui.Create( "Panel", self )
   self.YOffset = 0

   self.scroll = vgui.Create("DVScrollBar", self)
   self.scroll.Paint = function( s, w, h )
   --   draw.RoundedBox( 4, 3, 13, 8, h-24, Color(15,15,15,0))
   end
   
   self.scroll.btnUp.Paint = function( s, w, h ) end
   self.scroll.btnDown.Paint = function( s, w, h ) end
   self.scroll.btnGrip.Paint = function( s, w, h )
   --   draw.RoundedBox( 4, 5, 0, 4, h+22, Color(30,30,30,0))
   end
end

function PANEL:GetCanvas() return self.pnlCanvas end

function PANEL:OnMouseWheeled( dlta )
   self.scroll:AddScroll(dlta * -2)

   self:InvalidateLayout()
end

function PANEL:SetScroll(st)
   self.scroll:SetEnabled(st)
end

function PANEL:PerformLayout()
   self.pnlCanvas:SetVisible(self:IsVisible())

   -- scrollbar
   self.scroll:SetPos(self:GetWide() - 16, 0)
   self.scroll:SetSize(16, self:GetTall())

   local was_on = self.scroll.Enabled
   self.scroll:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
   self.scroll:SetEnabled(was_on) -- setup mangles enabled state

   self.YOffset = self.scroll:GetOffset()

   self.pnlCanvas:SetPos( 0, self.YOffset )
   self.pnlCanvas:SetSize( self:GetWide(), self.pnlCanvas:GetTall() )
end
vgui.Register( "TTTPlayerFrame", PANEL, "Panel" )
