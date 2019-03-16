hook.Add( "PostGamemodeLoaded", "AuroraMOTD Override", function()
	ulx.motdmenu_exists = true

	local isUrl
	local url
	local topMenu

	local textslides = {
		"AuroraRP Beta",
		"A DarkRP modification.",
		"This introduction will only appear once.",
		"You must comply with all the rules.",
		"Punishments are harsh and severe.",
		"The rules may be different from other servers.",
		"It is YOUR responsiblity to familiarize yourself with the rules.",
		"You can read the rules in the MOTD or on the forums.",
		"Ignorance is not an excuse.",
		"You cannot block ANY doors with props. All entrances must be accessible.",
		"When you die, you forget everything from your past life. This is basic roleplay.",
		"You should not come near your place of death within 3 minutes.",
		"Advertising mugs is optional as long as you make your intentions clear in RP.",
		"Using props to scale buildings or fly is prohibited.",
		"Making any (D)DoS threats will get you permanently banned along with your IP logged.",
		"There are more specific rules, but I've kept you waiting long enough.",
		"You will spawn soon.",
		"21:00 Somewhere in a city.",
		"Your life begins... now."
	}

	surface.CreateFont("CutsceneFont", {
		font = "Roboto",
		size = 40,
		weight = 500,
		antialias = true
		})

	function ulx.showMotdMenu()
		local window = vgui.Create( "DFrame" )
		if ScrW() > 640 then -- Make it larger if we can.
			window:SetSize( ScrW()*0.9, ScrH()*0.9 )
		else
			window:SetSize( 640, 480 )
		end
		window:Center()
		window:SetTitle( "AuroraTTT MOTD" )
		window:SetVisible( true )
		window:MakePopup()

		local html = vgui.Create( "HTML", window )

		local button = vgui.Create( "DButton", window )
		button:SetText( "Close" )
		button.DoClick = function() window:Close() 

		
	end
		button:SetSize( 100, 40 )
		button:SetPos( (window:GetWide() - button:GetWide()) / 2, window:GetTall() - button:GetTall() - 10 )

		html:SetSize( window:GetWide() - 20, window:GetTall() - button:GetTall() - 50 )
		html:SetPos( 10, 30 )
		if not isUrl then
			html:SetHTML( file.Read( "ulx_motd.txt", "DATA" ) )
		else
			html:OpenURL( url )
		end
	end

	function fadescreen()
		--toggleChatbox(false)
		topMenu = vgui.Create( 'DPanel', self )
		local n = 5
		topMenu:Dock( FILL )
		topMenu:SetSize( surface.ScreenWidth(), surface.ScreenHeight() )
		topMenu.Paint = function() surface.SetDrawColor( 0, 0, 0, 0 ) end
		timer.Create("fader", 0.1, 0, function()
			if n >= 300 then timer.Destroy("fader") textlabel() end
			topMenu.Paint = function()
					n = n+5
					surface.SetDrawColor( 0, 0, 0, n )
					surface.DrawRect(0,0, surface.ScreenWidth(), surface.ScreenHeight() )
				end
		end)
	end

	function timerpause(timerd, length, textd)
		timer.Pause(timerd)

		timer.Create("timerpause", length, 1.75, function()
			timer.UnPause(timerd)
				textd:SetText("")
				textd:SizeToContents()
			timer.Destroy("timerpause")
			end)
	end



	function textlabel()
		local lines = table.Count(textslides)
		local curline = 1
		local curchar = 1
		local nextline = 2
		local text = vgui.Create("DLabel", topMenu)
		text:SetText("")
		text:SizeToContents()
		text:SetPos(ScrW() / 2 - (text:GetWide() / 2),  ScrH()/2)
		text:SetContentAlignment(5)
		text:SetFont("CutsceneFont")
		local music = CreateSound(LocalPlayer(), "music/HL2_song20_submix0.mp3")
		music:Play()
		timer.Create("textfader", 0.03, 0, function()
			if not (curline > lines) then

				--if (curchar == 1) or (curchar == 11) then
				--	surface.PlaySound("ambient/machines/keyboard_fast1_1second.wav")
				--end
				local chars = string.len(textslides[curline])
				if not (curchar > chars) then

					text:SetText(text:GetText() .. string.sub(textslides[curline], curchar,curchar))
					text:SetPos(ScrW() / 2 - (text:GetWide() / 2),  ScrH()/2)
					text:SizeToContents()
					curchar = curchar + 1
				else

					curline = curline + 1
					curchar = 1
					timerpause("textfader", 2, text)
				end
			else
				local n = 255
				music:FadeOut(20)
				timer.Create("unfader", 0.1, 0, function()
					if n < 0 then timer.Destroy("unfader") topMenu:Remove() end
					topMenu.Paint = function()
					n = n-5
					surface.SetDrawColor( 0, 0, 0, n )
					surface.DrawRect(0,0, surface.ScreenWidth(), surface.ScreenHeight() )
				end
					end)
				LocalPlayer():SetPData("PlayedCutScene3", true)
				timer.Destroy("textfader")
				--toggleChatbox(true)
				
			end

			end)
		--[[
		if not timer.Exists("fader") then
			local text = vgui.Create("DLabel")
			local n = 5
			local textnum = 2
			text:SetText(textslides[1])
			text:SizeToContents()
			text:SetPos(ScrW() / 2 - (text:GetWide() / 2),  ScrH()/2)
			text:SetContentAlignment(5)
			text:SetColor(Color(255,255,255,n))
			timer.Create("textfader", 0.1, 0, function()
				if n >= 300 then timer.Destroy("textfader") end
				text.Paint = function()
						n = n+5
						text:SetColor( Color(255, 255, 255, n) )
					end
			end)
		end
		]]
	end


	function ulx.rcvMotd( isUrl_, text )
		isUrl = isUrl_
		if not isUrl then
			file.Write( "ulx_motd.txt", text )
		else
			if text:find( "://", 1, true ) then
				url = text
			else
				url = "http://" .. text
			end
		end
	end
	
end)