--[[

░█▀▀█ █░░█ █▀▀█ █▀▀█ █▀▀█ █▀▀█ 　 ▒█░▒█ ▒█░▒█ ▒█▀▀▄ 
▒█▄▄█ █░░█ █▄▄▀ █░░█ █▄▄▀ █▄▄█ 　 ▒█▀▀█ ▒█░▒█ ▒█░▒█ 
▒█░▒█ ░▀▀▀ ▀░▀▀ ▀▀▀▀ ▀░▀▀ ▀░░▀ 　 ▒█░▒█ ░▀▄▄▀ ▒█▄▄▀ 

]]

local table = table
local surface = surface
local draw = draw
local math = math
local string = string

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation
local GetLang = LANG.GetUnsafeLanguageTable
local interp = string.Interp

surface.CreateFont("AHUD_State", {font = "Roboto Cn",
	size = 28,
	weight = 700})
surface.CreateFont("AHUD_TimeLeft",     {font = "Roboto Cn",
	size = 24,
	weight = 400})
surface.CreateFont("AHUD_HealthAmmo",   {font = "Roboto Cn",
	size = 24,
	weight = 400})

local bg_colors = {
	background_main = Color(0, 0, 10, 200),

	noround = Color(64,64,64,200),
	traitor = Color(200, 25, 25, 200),
	innocent = Color(0,163,0, 200),
	detective = Color(25, 25, 200, 200)
}

local health_colors = {
	border = COLOR_WHITE,
	background = Color(100, 25, 25, 200),
	fill = Color(200, 50, 50, 200)
}

local ammo_colors = {
	border = COLOR_WHITE,
	background = Color(20, 20, 5, 222),
	fill = Color(205, 155, 0, 255)
}

local Tex_Corner8 = surface.GetTextureID( "gui/corner8" )
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

---- The bar painting is loosely based on:
---- http://wiki.garrysmod.com/?title=Creating_a_HUD

-- Paints a graphical meter bar
local function PaintBar(x, y, w, h, colors, value)
   -- Background
   -- slightly enlarged to make a subtle border
   draw.RoundedBox(8, x-1, y-1, w+2, h+2, colors.background)

   -- Fill
   local width = w * math.Clamp(value, 0, 1)

   if width > 0 then
   	RoundedMeter(8, x, y, width, h, colors.fill)
   end
end

local roundstate_string = {
	[ROUND_WAIT]   = "round_wait",
	[ROUND_PREP]   = "round_prep",
	[ROUND_ACTIVE] = "round_active",
	[ROUND_POST]   = "round_post"
	};

-- Returns player's ammo information
local function GetAmmo(ply)
	local weap = ply:GetActiveWeapon()
	if not weap or not ply:Alive() then return -1 end

	local ammo_inv = weap:Ammo1() or 0
	local ammo_clip = weap:Clip1() or 0
	local ammo_max = weap.Primary.ClipSize or 0

	return ammo_clip, ammo_max, ammo_inv
end

local function DrawBg(x, y, width, height, client)
   -- Traitor area sizes
   local th = 30
   local tw = 170

   -- Adjust for these
   y = y - th
   height = height + th

   -- main bg area, invariant
   -- encompasses entire area
   draw.RoundedBox(8, x, y, width, height, bg_colors.background_main)

   -- main border, traitor based
   local col = bg_colors.innocent
   if GAMEMODE.round_state != ROUND_ACTIVE then
   	col = bg_colors.noround
   elseif client:GetTraitor() then
   	col = bg_colors.traitor
   elseif client:GetDetective() then
   	col = bg_colors.detective
   end

   draw.RoundedBox(8, x, y, tw, th, col)
end

local sf = surface
local dr = draw

local function ShadowedText(text, font, x, y, color, xalign, yalign)

	dr.SimpleText(text, font, x+1, y+1, COLOR_BLACK, xalign, yalign)

	dr.SimpleText(text, font, x, y, color, xalign, yalign)
end

local margin = 10

-- Paint punch-o-meter
local function PunchPaint(client)
   --[[
   local L = GetLang()
   local punch = client:GetNWFloat("specpunches", 0)

   local width, height = 200, 25
   local x = ScrW() / 2 - width/2
   local y = margin/2 + height

   PaintBar(x, y, width, height, ammo_colors, punch)

   local color = bg_colors.background_main

   dr.SimpleText(L.punch_title, "HealthAmmo", ScrW() / 2, y, color, TEXT_ALIGN_CENTER)

   dr.SimpleText(L.punch_help, "TabLarge", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)

   local bonus = client:GetNWInt("bonuspunches", 0)
   if bonus != 0 then
      local text
      if bonus < 0 then
         text = interp(L.punch_bonus, {num = bonus})
      else
         text = interp(L.punch_malus, {num = bonus})
      end

      dr.SimpleText(text, "TabLarge", ScrW() / 2, y * 2, COLOR_WHITE, TEXT_ALIGN_CENTER)
   end
   ]]
end

local key_params = { usekey = Key("+use", "USE") }

local function SpecHUDPaint(client)
	local L = GetLang()

	local x = margin
	local height = 32
	local width = 250
	local round_y = ScrH() - height - margin

	if ScrW() < 1000 then round_y = round_y - 15 end

	local time_x = x + 173
	local time_y = round_y + 5

  -- surface.SetFont( "AHUD_State" )
  -- local text = L[ roundstate_string[GAMEMODE.round_state] ]
  -- local wh, hw = surface.GetTextSize(text)

  draw.RoundedBox(0, x, round_y, width, height, bg_colors.background_main)
  draw.RoundedBox(0, x, round_y, time_x - x, height, bg_colors.noround)

  local text = L[ roundstate_string[GAMEMODE.round_state] ]:gsub("(%a)([%w_']*)", function(a, b) return a:upper()..b:lower() end)
  ShadowedText(text, "AHUD_State", x + margin, round_y + 2, COLOR_WHITE, TEXT_ALIGN_LEFT)

  local text = util.SimpleTime(math.max(0, GetGlobalFloat("ttt_round_end", 0) - CurTime()), "%02i:%02i")
  draw.SimpleText(text, "AHUD_TimeLeft", time_x + margin + 5, time_y , COLOR_WHITE)

  local tgt = client:GetObserverTarget()
  if IsValid(tgt) and tgt:IsPlayer() then
  	draw.SimpleText(tgt:Nick(), "AHUD_TimeLeft", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)

  elseif IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == client then
  	PunchPaint(client)
  else
  	ShadowedText(interp(L.spec_help, key_params), "TabLarge", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
  end

   --[[
   local L = GetLang() -- for fast direct table lookups

   -- Draw round state
   local x       = margin
   local height  = 32
   local width   = 250
   local round_y = ScrH() - height - margin

   -- move up a little on low resolutions to allow space for spectator hints
   if ScrW() < 1000 then round_y = round_y - 15 end

   local time_x = x + 170
   local time_y = round_y + 4

   draw.RoundedBox(8, x, round_y, width, height, bg_colors.background_main)
   draw.RoundedBox(8, x, round_y, time_x - x, height, bg_colors.noround)

   local text = L[ roundstate_string[GAMEMODE.round_state] ]
   ShadowedText(text, "TraitorState", x + margin, round_y, COLOR_WHITE)

   -- Draw round/prep/post time remaining
   local text = util.SimpleTime(math.max(0, GetGlobalFloat("ttt_round_end", 0) - CurTime()), "%02i:%02i")
   ShadowedText(text, "TimeLeft", time_x + margin, time_y, COLOR_WHITE)

   local tgt = client:GetObserverTarget()
   if IsValid(tgt) and tgt:IsPlayer() then
      ShadowedText(tgt:Nick(), "TimeLeft", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)

   elseif IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == client then
      PunchPaint(client)
   else
      ShadowedText(interp(L.spec_help, key_params), "TabLarge", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
   end
   ]]
end

local ttt_health_label = CreateClientConVar("ttt_health_label", "0", true)

local Health, Ammo = 0, 0

local function InfoPaint(client)
	local L = GetLang()

	local width = 250
	local height = 82

	local x = margin
	local y = ScrH() - margin - height

	local th = 32
	local tw = 180 

	local col = bg_colors.innocent
	if GAMEMODE.round_state != ROUND_ACTIVE then
		col = bg_colors.noround
	elseif client:GetTraitor() then
		col = bg_colors.traitor
	elseif client:GetDetective() then
		col = bg_colors.detective
	end

	draw.RoundedBoxEx(0, x + 22, y - 31, tw - 40, th, col)
	draw.RoundedBoxEx(0, 0, y - 31, 32, 32, Color(61,64,61,255))
	surface.SetDrawColor(255,255,255)
	surface.SetTexture( surface.GetTextureID("hud/ahud-user") )
	surface.DrawTexturedRect(6, y - 25, 20, 20)

	local round_state = GAMEMODE.round_state

	local traitor_y = y - 31
	local text = nil
	if round_state == ROUND_ACTIVE then
		text = L[ client:GetRoleStringRaw() ]
	else
		text = L[ roundstate_string[round_state] ]
	end

	ShadowedText(text, "AHUD_State", x + margin + 20, traitor_y+2, COLOR_WHITE)


	Health = math.min(100, (Health == LocalPlayer():Health() and Health) or Lerp(0.05, Health, LocalPlayer():Health()))

	local DrawHealth = math.Min(Health / 100, 1)

	local health = math.max(0, client:Health())
	local health_y = y + margin

	draw.RoundedBoxEx(0, x + 22, y + 10, tw, th, health_colors.background)
	draw.RoundedBoxEx(0, x + 22, y + 10, (tw * DrawHealth), th, health_colors.fill)
	draw.RoundedBoxEx(0, 0, y + 10, 32, 32, Color(61,64,61,255))

	ShadowedText(LocalPlayer():Health(), "AHUD_HealthAmmo", x + margin + 20, y + 14, COLOR_WHITE)

	surface.SetDrawColor(255,255,255)
	surface.SetTexture( surface.GetTextureID("hud/ahud-health") )
	surface.DrawTexturedRect(6, y + 17, 20, 20)

	if client:GetActiveWeapon().Primary then
		local ammo_clip, ammo_max, ammo_inv = GetAmmo(client)
		if ammo_clip != -1 then
			Ammo = math.min(ammo_max, (Ammo == ammo_clip and Ammo) or Lerp(0.25, Ammo, ammo_clip))
			local DrawAmmo = math.Min(Ammo / ammo_max, 1)

			draw.RoundedBoxEx(0, x + 22, y + 51, tw, th, ammo_colors.background)
			draw.RoundedBoxEx(0, x + 22, y + 51, tw * DrawAmmo, th, ammo_colors.fill)
			draw.RoundedBoxEx(0, 0, y + 51, 32, 32, Color(61,64,61,255))
			surface.SetTexture( surface.GetTextureID("hud/ahud-ammo") )
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRect(6, y + 57, 20, 20)

			local text = string.format("%i + %02i", ammo_clip, ammo_inv)

			ShadowedText(text, "AHUD_HealthAmmo", x + margin + 20, y + 55, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		end
	end


	draw.RoundedBoxEx(0, 0, 0, 32, 32, Color(61,64,61,255))
	draw.RoundedBoxEx(0, 32, 0, 75, 32, bg_colors.noround)
	surface.SetTexture( surface.GetTextureID("hud/ahud-clock") )
	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(6, 6, 20, 20)

	local is_haste = HasteMode() and round_state == ROUND_ACTIVE
	local is_traitor = client:IsActiveTraitor()

	local endtime = GetGlobalFloat("ttt_round_end", 0) - CurTime()

	local text
	local font = "AHUD_TimeLeft"
	local color = COLOR_WHITE
	local rx = x + margin + 170
	local ry = traitor_y + 3

   -- Time displays differently depending on whether haste mode is on,
   -- whether the player is traitor or not, and whether it is overtime.
   if is_haste then
   	local hastetime = GetGlobalFloat("ttt_haste_end", 0) - CurTime()
   	if hastetime < 0 then
   		if (not is_traitor) or (math.ceil(CurTime()) % 7 <= 2) then
            -- innocent or blinking "overtime"
            text = "OT"
            font = "AHUD_TimeLeft"

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

  ShadowedText(text, font, 67, 4, color, TEXT_ALIGN_CENTER)



   --[[
   local L = GetLang()

   local width = 250
   local height = 90

   local x = margin
   local y = ScrH() - margin - height

   DrawBg(x, y, width, height, client)

   local bar_height = 25
   local bar_width = width - (margin*2)

   -- Draw health
   local health = math.max(0, client:Health())
   local health_y = y + margin

   PaintBar(x + margin, health_y, bar_width, bar_height, health_colors, health/100)

   ShadowedText(tostring(health), "HealthAmmo", bar_width, health_y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)

   if ttt_health_label:GetBool() then
      local health_status = util.HealthToString(health)
      draw.SimpleText(L[health_status], "TabLarge", x + margin*2, health_y + bar_height/2, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
   end

   -- Draw ammo
   if client:GetActiveWeapon().Primary then
      local ammo_clip, ammo_max, ammo_inv = GetAmmo(client)
      if ammo_clip != -1 then
         local ammo_y = health_y + bar_height + margin
         PaintBar(x+margin, ammo_y, bar_width, bar_height, ammo_colors, ammo_clip/ammo_max)
         local text = string.format("%i + %02i", ammo_clip, ammo_inv)

         ShadowedText(text, "HealthAmmo", bar_width, ammo_y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
      end
   end

   -- Draw traitor state
   local round_state = GAMEMODE.round_state

   local traitor_y = y - 30
   local text = nil
   if round_state == ROUND_ACTIVE then
      text = L[ client:GetRoleStringRaw() ]
   else
      text = L[ roundstate_string[round_state] ]
   end

   ShadowedText(text, "TraitorState", x + margin + 73, traitor_y, COLOR_WHITE, TEXT_ALIGN_CENTER)

   -- Draw round time
   local is_haste = HasteMode() and round_state == ROUND_ACTIVE
   local is_traitor = client:IsActiveTraitor()

   local endtime = GetGlobalFloat("ttt_round_end", 0) - CurTime()

   local text
   local font = "TimeLeft"
   local color = COLOR_WHITE
   local rx = x + margin + 170
   local ry = traitor_y + 3

   -- Time displays differently depending on whether haste mode is on,
   -- whether the player is traitor or not, and whether it is overtime.
   if is_haste then
      local hastetime = GetGlobalFloat("ttt_haste_end", 0) - CurTime()
      if hastetime < 0 then
         if (not is_traitor) or (math.ceil(CurTime()) % 7 <= 2) then
            -- innocent or blinking "overtime"
            text = L.overtime
            font = "Trebuchet18"

            -- need to hack the position a little because of the font switch
            ry = ry + 5
            rx = rx - 3
         else
            -- traitor and not blinking "overtime" right now, so standard endtime display
            text  = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
            color = COLOR_RED
         end
      else
         -- still in starting period
         local t = hastetime
         if is_traitor and math.ceil(CurTime()) % 6 < 2 then
            t = endtime
            color = COLOR_RED
         end
         text = util.SimpleTime(math.max(0, t), "%02i:%02i")
      end
   else
      -- bog standard time when haste mode is off (or round not active)
      text = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
   end

   ShadowedText(text, font, rx, ry, color)

   if is_haste then
      dr.SimpleText(L.hastemode, "TabLarge", x + margin + 165, traitor_y - 8)
   end
   ]]

end

-- Paints player status HUD element in the bottom left
function GAMEMODE:HUDPaint()

	local client = LocalPlayer()

	if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTTargetID" ) then
		hook.Call( "HUDDrawTargetID", GAMEMODE )
	end

	if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTMStack" ) then
		MSTACK:Draw(client)
	end

	if (not client:Alive()) or client:Team() == TEAM_SPEC then
		if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTSpecHUD" ) then
			SpecHUDPaint(client)
		end

		return
	end

	if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTRadar" ) then
		RADAR:Draw(client)
	end

	if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTTButton" ) then
		TBHUD:Draw(client)
	end

	if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTWSwitch" ) then
		WSWITCH:Draw(client)
	end

	if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTVoice" ) then
		VOICE.Draw(client)
	end

	if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTDisguise" ) then
		DISGUISE.Draw(client)
	end

	if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTPickupHistory" ) then
		hook.Call( "HUDDrawPickupHistory", GAMEMODE )
	end

   -- Draw bottom left info panel
   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTInfoPanel" ) then
   	InfoPaint(client)
   end

end

-- Hide the standard HUD stuff
local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
function GAMEMODE:HUDShouldDraw(name)
	for k, v in pairs(hud) do
		if name == v then return false end
	end

	return true
end

