
surface.CreateFont("WTEVEventHeader", {
	font = "Roboto Condensed",
	size = 64
})
surface.CreateFont("WTEVEventTitleHeader", {
	font = "Roboto Condensed",
	size = 90
})
surface.CreateFont("WTEVEventSmallMsg", {
	font = "Roboto Condensed",
	size = 45
})

local function CubicInterp(t, b, c)
	return c*t*t*t + b
end

local MainData
local SubData = {}

net.Receive("wyozitev_message", function()
	local t = net.ReadUInt(8)
	local msg = net.ReadTable()
	local length = net.ReadUInt(8)
	if length == 0 then length = 5 end

	local data = {
		Start = CurTime(),
		Message = msg,
		SlideInLength = 2,
		FadeOutStart = length,
		FadeOutLength = 1
	}
	if t == 1 then
		MainData = data
	elseif t == 2 then
		table.insert(SubData, data)
	end
end)

local function ComputeFracs(data)
	local initial_frac = math.Clamp((CurTime() - data.Start) / data.SlideInLength, 0, 1)
	local end_frac = math.Clamp(((data.Start + data.FadeOutStart + data.FadeOutLength) - CurTime()) / data.FadeOutLength, 0, 1)
	local mid_frac = math.Clamp((CurTime() - data.Start - data.SlideInLength) / data.FadeOutStart, 0, 1)
	return initial_frac, end_frac, mid_frac
end

hook.Add("HUDPaint", "MiEventsSetup", function()
	if MainData then
		local initial_frac, end_frac = ComputeFracs(MainData)

		if end_frac > 0 then
			local alphamul = end_frac
			local y = CubicInterp(initial_frac, -170, 270)

			local scalewidth =  ScreenScale( 250 ) 
			draw.RoundedBox( 2, ScrW()/2-(scalewidth/2), y, scalewidth, 170, Color( 0, 0, 0, 200*alphamul ) )
			draw.SimpleText("Preparing TTT Event", "WTEVEventHeader", ScrW()/2, y+10, Color(255, 255, 255, 255*alphamul), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(MainData.Message[1], "WTEVEventTitleHeader", ScrW()/2, y+70, Color(52, 152, 219, 255*alphamul), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end
	end
	for _, sd in pairs(SubData) do
		local initial_frac, end_frac, mid_frac = ComputeFracs(sd)

		if end_frac > 0 then

			local height = 60

			local endy = 200 + #sd.Message * 50

			local y = CubicInterp(initial_frac, -10, endy)
			y = ScrH() - y

			local scalewidth =  ScreenScale( 400 ) 

			for k,msg in pairs(sd.Message) do
				local ys = k-1
				local salpha = (k == 1) and
										end_frac or
										math.min(end_frac, math.Clamp((mid_frac - ys*0.1)*15, 0, 1))

				draw.RoundedBox( 2, ScrW()/2-(scalewidth/2), y+height*ys, scalewidth, height, Color( 0, 0, 0, 200*salpha ) )
				draw.SimpleText(msg, "WTEVEventSmallMsg", ScrW()/2, y+height*ys+10, Color(236, 240, 241, 255*salpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			end
		else
			table.RemoveByValue(SubData, sd)
		end
	end
end)