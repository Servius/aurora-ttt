local function CompareScore(pa, pb)
	if not ValidPanel(pa) then return false end
	if not ValidPanel(pb) then return true end

	local a = pa:GetPlayer()
	local b = pb:GetPlayer()

	if not IsValid(a) then return false end
	if not IsValid(b) then return true end

	if a:Frags() == b:Frags() then return a:Deaths() < b:Deaths() end

	return a:Frags() > b:Frags()
end

local PANEL = {}

function PANEL:Init()
	self.name = "Unnamed"

	self.color = COLOR_WHITE

	self.rows = {}
	self.rowcount = 0

	self.rows_sorted = {}

	self.group = "spec"
end

function PANEL:SetGroupInfo(name, color, group)
	self.name = name
	self.color = color
	self.group = group
end

local bgcolor = ScoreboardConfig.BG2_Color
function PANEL:Paint()
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), bgcolor)

	surface.SetFont("minimal_small")

	local txt = self.name .. " | " .. self.rowcount .. ""
	local w, h = surface.GetTextSize(txt)
	draw.RoundedBox(0, 0, 0, w + 24, 20, self.color)
	if ScoreboardConfig.WhiteStrike then
		draw.RoundedBox(0, 0, 19, w + 24 , 1.5, COLOR_WHITE)
	end

	surface.SetTextPos(11, 11 - h/2)
	surface.SetTextColor(0,0,0, 200)
	surface.DrawText(txt)

	surface.SetTextPos(10, 10 - h/2)
	surface.SetTextColor(255,255,255,255)
	surface.DrawText(txt)

	local y = 24
	for i, row in ipairs(self.rows_sorted) do
		if (i % 2) != 0 then
			surface.SetDrawColor(75,75,75, 100)
			surface.DrawRect(0, y, self:GetWide(), row:GetTall())
		end

		y = y + row:GetTall() + 1
	end

	local scr = 0
	surface.SetDrawColor(0,0,0, 80)
	if sboard_panel.cols then
		local cx = self:GetWide() - scr
		for k,v in ipairs(sboard_panel.cols) do
			cx = cx - v.Width
			if k % 2 == 1 then
				surface.DrawRect(cx-v.Width/2, 0, v.Width, self:GetTall())
			end
		end
	else
		surface.DrawRect(self:GetWide() - 175 - 25 - scr, 0, 50, self:GetTall())
		surface.DrawRect(self:GetWide() - 75 - 25 - scr, 0, 50, self:GetTall())
	end

end

function PANEL:AddPlayerRow(ply)
	if ((self.group == 5 and ScoreboardConfig.UsingSpecDM) or ScoreGroup(ply) == self.group) and not self.rows[ply] then
		local row = vgui.Create("TTTScorePlayerRow", self)
		row:SetPlayer(ply)
		self.rows[ply] = row
		self.rowcount = table.Count(self.rows)

		self:PerformLayout()

	end
end

function PANEL:HasPlayerRow(ply)
	return self.rows[ply] != nil
end

function PANEL:HasRows()
	return self.rowcount > 0
end

function PANEL:UpdateSortCache()
	self.rows_sorted = {}
	for k,v in pairs(self.rows) do
		table.insert(self.rows_sorted, v)
	end

	table.sort(self.rows_sorted, CompareScore)
end



function PANEL:UpdatePlayerData()
	local to_remove = {}
	for k,v in pairs(self.rows) do
		if ValidPanel(v) and IsValid(v:GetPlayer()) and ((ScoreboardConfig.UsingSpecDM and (self.group == 5 and v:GetPlayer():IsGhost() and (LocalPlayer():IsSpec() or LocalPlayer():IsActiveTraitor()))) or ScoreGroup(v:GetPlayer()) == self.group) then
			v:UpdatePlayerData()
		else
			table.insert(to_remove, k)
		end
	end

	if #to_remove == 0 then return end

	for k,ply in pairs(to_remove) do
		local pnl = self.rows[ply]
		if ValidPanel(pnl) then
			pnl:Remove()
		end
		self.rows[ply] = nil
	end
	self.rowcount = table.Count(self.rows)

	self:UpdateSortCache()

	self:InvalidateLayout()
end


function PANEL:PerformLayout()
	if self.rowcount < 1 then
		self:SetVisible(false)
		return
	end

	self:SetSize(self:GetWide(), 30 + self.rowcount + self.rowcount * SB_ROW_HEIGHT)

   -- Sort and layout player rows
   self:UpdateSortCache()

   local y = 24
   for k, v in ipairs(self.rows_sorted) do
   	v:SetPos(0, y)
   	v:SetSize(self:GetWide(), v:GetTall())

   	y = y + v:GetTall() + 1
   end

   self:SetSize(self:GetWide(), 30 + (y - 24))
end

vgui.Register("TTTScoreGroup", PANEL, "Panel")
