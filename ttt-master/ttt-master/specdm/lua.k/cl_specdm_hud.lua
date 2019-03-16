
local dr = draw
local function ShadowedText(text, font, x, y, color, xalign, yalign)
	dr.SimpleText(text, font, x+2, y+2, COLOR_BLACK, xalign, yalign)
	dr.SimpleText(text, font, x, y, color, xalign, yalign)
end

local bg_colors = {
	background_main = Color(0, 0, 10, 200),
	noround = Color(100,100,100,200),
	traitor = Color(200, 25, 25, 200),
	innocent = Color(25, 200, 25, 200),
	detective = Color(25, 25, 200, 200)
};

local health_colors = {
	border = COLOR_WHITE,
	background = Color(100, 25, 25, 222),
	fill = Color(200, 50, 50, 250)
};

local ammo_colors = {
	border = COLOR_WHITE,
	background = Color(20, 20, 5, 222),
	fill = Color(205, 155, 0, 255)
};


local function DrawBg(x, y, width, height, client)
	local th = 32
	local tw = 170
	y = y - th
	height = height + th
	--draw.RoundedBox(0, x, y, width, height, bg_colors.background_main)
	local col = bg_colors.innocent
	if LocalPlayer():IsGhost() then
	elseif GAMEMODE.round_state != ROUND_ACTIVE then
		col = bg_colors.noround
	elseif LocalPlayer():GetTraitor() then
		col = bg_colors.traitor
	elseif LocalPlayer():GetDetective() then
		col = bg_colors.detective
	end
	draw.RoundedBox(0, x + 22, y+2, tw, th, col)
end

local Tex_Corner8 = surface.GetTextureID("gui/corner8")
local function RoundedMeter( bs, x, y, w, h, color)
	surface.SetDrawColor(clr(color))
	surface.DrawRect( x+bs, y, w-bs*2, h )
	surface.DrawRect( x, y+bs, bs, h-bs*2 )
	surface.SetTexture( Tex_Corner8 )
	surface.DrawTexturedRectRotated( x + bs/2 , y + bs/2, bs, bs, 0 )
	surface.DrawTexturedRectRotated( x + bs/2 , y + h -bs/2, bs, bs, 90 )
	if w > 14 then
		surface.DrawRect( x+w-bs, y+bs, bs, h-bs*2 )
		surface.DrawTexturedRectRotated( x + w - bs/2 , y + bs/2, bs, bs, 270 )
		surface.DrawTexturedRectRotated( x + w - bs/2 , y + h - bs/2, bs, bs, 180 )
	else
		surface.DrawRect( x + math.max(w-bs, bs), y, bs/2, h )
	end
end

local function GetAmmo(ply)
	local weap = ply:GetActiveWeapon()
	if not weap or not ply:Alive() then return -1 end
	local ammo_inv = weap:Ammo1() or 0
	local ammo_clip = weap:Clip1() or 0
	local ammo_max = weap.Primary.ClipSize or 0
	return ammo_clip, ammo_max, ammo_inv
end

local function PaintBar(x, y, w, h, colors, value)
   -- Background
   -- slightly enlarged to make a subtle border
   draw.RoundedBox(0, x, y, w, h, colors.background)

   -- Fill
   local width = w * math.Clamp(value, 0, 1)

   if width > 0 then
   	RoundedMeter(0, x, y, width, h, colors.fill)
   end
end

hook.Add("Initialize", "Initialize_GhostHUD", function()

	local GetLang = LANG.GetUnsafeLanguageTable

	local ttt_health_label = GetConVar("ttt_health_label")

	local margin = 10
	local old_DrawHUD = GAMEMODE.HUDPaint
	function GAMEMODE:HUDPaint()
		if LocalPlayer():IsGhost() then
			self:HUDDrawTargetID()
			MSTACK:Draw(LocalPlayer())		
			TBHUD:Draw(LocalPlayer())
			WSWITCH:Draw(LocalPlayer())
			self:HUDDrawPickupHistory()
			local L = GetLang()
			local width = 250
			local height = 90
			local x = margin
			local y = ScrH() - margin - height
			DrawBg(x, y, width, height, LocalPlayer())
			local bar_height = 32
			local bar_width = width - (margin*2)
			local health = math.max(0, LocalPlayer():Health())
			local health_y = y + margin
			PaintBar(x + margin+12, health_y, bar_width, bar_height, health_colors, health/100)

			surface.SetDrawColor(255,255,255)
			surface.SetTexture( surface.GetTextureID("/VGUI/ttt/user1") )
			surface.DrawTexturedRect(0, y - 30, 32, 32)
			
			draw.RoundedBox(0,32,0,100,32,Color(64,64,64,200))

			surface.SetTexture( surface.GetTextureID("/VGUI/ttt/clock") )
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRect(0, 0, 32, 32)

			surface.SetTexture( surface.GetTextureID("/VGUI/ttt/heart") )
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRect(0, y+10, 32, 32)


			if system.IsOSX() then
			  	ShadowedText(tostring(health), "minimal_large", 42, health_y+5, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			  else
			  	ShadowedText(tostring(health), "minimal_large", 42, health_y+1, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			  end
			if ttt_health_label:GetBool() then
				local health_status = util.HealthToString(health)
				if system.IsOSX() then
					ShadowedText(L[health_status], "minimal_large", x + margin*2 +60, health_y + bar_height/2 +1, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else
					ShadowedText(L[health_status], "minimal_large", x + margin*2 +60, health_y + bar_height/2, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end
			if LocalPlayer():GetActiveWeapon().Primary then
				local ammo_clip, ammo_max, ammo_inv = GetAmmo(LocalPlayer())
				if ammo_clip != -1 then

				   		surface.SetTexture( surface.GetTextureID("/VGUI/ttt/ammo") )
				   		surface.SetDrawColor(255,255,255)
				   		surface.DrawTexturedRect(0, y+50, 32, 32)
				   		local ammo_y = health_y + bar_height + margin -2
				   		PaintBar(x+margin+12, ammo_y, bar_width, bar_height, ammo_colors, ammo_clip/ammo_max)
				   		local text = string.format("%i + %02i", ammo_clip, ammo_inv)

				   		if system.IsOSX() then
				   			ShadowedText(text, "minimal_large", 42, ammo_y+5, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				   		else
				   			ShadowedText(text, "minimal_large", 42, ammo_y+1, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				   		end
				   	end
			end
			local text = "Spectator DM"
			local traitor_y = y - 31
			if system.IsOSX() then
				ShadowedText(text, "minimal_large", x + margin + 20, traitor_y+5, COLOR_WHITE)
			else
				ShadowedText(text, "minimal_large", x + margin + 20, traitor_y+2, COLOR_WHITE)
			end
			local is_haste = HasteMode() and round_state == ROUND_ACTIVE
			local endtime = GetGlobalFloat("ttt_round_end", 0) - CurTime()
			local text
			if system.IsOSX() then
				local font = "minimal_large"
			else
				local font = "minimal"
			end
			local color = COLOR_WHITE
			local rx = x + margin + 170
			local ry = traitor_y + 3
			   if is_haste then
			   	local hastetime = GetGlobalFloat("ttt_haste_end", 0) - CurTime()
			   	if hastetime < 0 then
			   		if (not is_traitor) or (math.ceil(CurTime()) % 7 <= 2) then
			            -- innocent or blinking "overtime"
			            text = "OT"
			            font = "minimal_large"

			            -- need to hack the position a little because of the font switch
			            ry = ry + 5
			            rx = rx - 3
			         else
			            -- traitor and not blinking "overtime" right now, so standard endtime display
			            text  = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
			            --color = COLOR_RED
			         end
			      else
			         -- still in starting period
			         local t = hastetime
			         if is_traitor and math.ceil(CurTime()) % 6 < 2 then
			         	t = endtime
			           -- color = COLOR_RED
			        end
			        text = util.SimpleTime(math.max(0, t), "%02i:%02i")
			     end
			  else
			      -- bog standard time when haste mode is off (or round not active)
			      text = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
			   end

			   if system.IsOSX() then
			     dr.SimpleText(text, "minimal_large", 50, 5, color)
			  else
			   dr.SimpleText(text, "minimal", 53, 2, color)
			end
			if is_haste then
				--dr.SimpleText(L.hastemode, "TabLarge", x + margin + 165, traitor_y - 8)
			end
			return
		end
		return old_DrawHUD(self)
	end
		
end)