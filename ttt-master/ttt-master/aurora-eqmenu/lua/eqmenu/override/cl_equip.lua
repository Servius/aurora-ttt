  local function ItemIsWeapon(item) return not tonumber(item.id) end
  local function CanCarryWeapon(item) return LocalPlayer():CanCarryType(item.kind) end

  local Equipment = nil
  function GetEquipmentForRole(role)
    -- need to build equipment cache?
    if not Equipment then
      -- start with all the non-weapon goodies
      local tbl = table.Copy(EquipmentItems)

      -- find buyable weapons to load info from
      for k, v in pairs(weapons.GetList()) do
        if v and v.CanBuy then
          local data = v.EquipMenuData or {}
          local base = {
          id       = WEPS.GetClass(v),
          name     = v.PrintName or "Unnamed",
          limited  = v.LimitedStock,
          kind     = v.Kind or WEAPON_NONE,
          slot     = (v.Slot or 0) + 1,
          material = v.Icon or "VGUI/ttt/icon_id",
          -- the below should be specified in EquipMenuData, in which case
          -- these values are overwritten
          type     = "Type not specified",
          model    = "models/weapons/w_bugbait.mdl",
          desc     = "No description specified."
          };

          -- Force material to nil so that model key is used when we are
          -- explicitly told to do so (ie. material is false rather than nil).
          if data.modelicon then
            base.material = nil
          end

          table.Merge(base, data)

          -- add this buyable weapon to all relevant equipment tables
          for _, r in pairs(v.CanBuy) do
            table.insert(tbl[r], base)
          end
        end
      end

      -- mark custom items
      for r, is in pairs(tbl) do
        for _, i in pairs(is) do
          if i and i.id then
            i.custom = not table.HasValue(DefaultEquipment[r], i.id)
          end
        end
      end

      Equipment = tbl
    end

    return Equipment and Equipment[role] or {}
  end

  function NewCMenu()
    
    local r = GetRoundState()
    if r == ROUND_ACTIVE and not (LocalPlayer():GetTraitor() or LocalPlayer():GetDetective()) then
      return
    elseif r == ROUND_POST or r == ROUND_PREP then
      CLSCORE:Reopen()
      return
    elseif r != ROUND_ACTIVE then
      return
    end
    
    if IsValid(eqframe) then
      if eqframe:IsVisible() then
        eqframe:SetVisible(false)
      else
        eqframe:SetVisible(true)
      end
      return
    end
    
    ----- Settings
    
    local dat = { Settings = { Uncat = false, Hidecus = false, Memory = false }, Favourites = {} }
    
    local set = file.Read("ttt_menu_settings.txt", "DATA")
    if set != nil then
      local dec = util.JSONToTable( set )
      
      if dec != nil and type(dec) == "table" then
        table.Merge( dat, dec )
      end
    end
    
    eqframe = vgui.Create("DFrame")
    eqframe:SetTitle( "" )
    eqframe:SetSize( 500, 364 )
    eqframe:Center()
    eqframe:SetDraggable( false )
    eqframe:MakePopup()
    eqframe.Settings = table.Copy(dat)
    eqframe.Close = function( s )
      if s.Settings["Settings"]["Memory"] then
        s:SetKeyboardInputEnabled(false)
        s.ItemPanel.Search.TextboxB:SetVisible(true)
        s:SetVisible(false)
      else
        s:Remove()
      end
      
      local cod = util.TableToJSON(s.Settings)
      file.Write( "ttt_menu_settings.txt", cod )    
    end
    
    eqframe.Sheets = {"ITEMS", "RADAR", "DISGUISE", "RADIO", "TRANSFER", "CLOSE"}
    eqframe.Windows = {}
    eqframe.Buttons = {}
    eqframe.Buttons2 = {}
    
    local ip = 0
    
    for k, v in pairs(eqframe.Sheets) do
      
      local b = 83
      
      if v == "ITEMS" or v == "CLOSE" then b = 84 end
      
      but = vgui.Create("DButton", eqframe)
      but:SetPos( ip, 0 )
      but:SetSize( b, 30 )
      but.Text = v
      but.HoverOn = 0
      but.Hover = 0
      but:SetText("")
      but.Paint = function( s, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
        
        if b == 83 then
          draw.RoundedBox( 0, 1, 2, w-2, h-4, eqframe.Color1 )
        elseif v == "ITEMS" then
          draw.RoundedBox( 0, 2, 2, w-3, h-4, eqframe.Color1 )
        elseif v == "CLOSE" then
          draw.RoundedBox( 0, 1, 2, w-3, h-4, eqframe.Color1 )
        end
        
        local col = Color( 15, 15, 15, 255 )
        
        if eqframe.Selected == s then
          s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
          col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
        else
          s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
          col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
        end
        
        draw.SimpleText(s.Text, "minimal_small", w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
        
        if s:GetDisabled() == false then
          if s:IsHovered() then
            s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
          else
            s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
          end
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
        else
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 200 ) )
        end
      end
      but.Think = function( s )
        
        local ply = LocalPlayer()
        
        if v == "RADAR" then
          if ply:HasEquipmentItem(EQUIP_RADAR) then
            eqframe.Buttons2[v]:SetDisabled(false)
          else
            eqframe.Buttons2[v]:SetDisabled(true)
          end
        elseif v == "DISGUISE" then
          if ply:HasEquipmentItem(EQUIP_DISGUISE) then
            eqframe.Buttons2[v]:SetDisabled(false)
          else
            eqframe.Buttons2[v]:SetDisabled(true)
          end
        elseif v == "RADIO" then
          if (IsValid(ply.radio) or ply:HasWeapon("weapon_ttt_radio")) then
            eqframe.Buttons2[v]:SetDisabled(false)
          else
            eqframe.Buttons2[v]:SetDisabled(true)
          end
        elseif v == "TRANSFER" then
          if LocalPlayer():GetCredits() > 0 then
            eqframe.Buttons2[v]:SetDisabled(false)
          else
            eqframe.Buttons2[v]:SetDisabled(true)
          end
        end
      end
      but.DoClick = function( s )
        if v == "CLOSE" then
          eqframe:Close()
          return
        end
        
        if eqframe.Selected != s then
          eqframe.Selected = s
          
          for i, o in pairs(eqframe.Windows) do
            o:SetVisible(false)
          end
          if IsValid(eqframe.Windows[v]) then
            eqframe.Windows[v]:SetVisible(true)
          end
        end
      end
      
      if b != 84 then
        but:SetDisabled(true)
      end
      
      table.insert(eqframe.Buttons, but)
      eqframe.Buttons2[v] = but
    
      ip = ip + b
    end
    
    eqframe.Color1 = Color(50,70,100,255)
    eqframe.Equipment = GetEquipmentForRole(LocalPlayer():GetRole())
    eqframe.Categories = {}
    
    for k, v in pairs(eqframe.Equipment) do
      if !table.HasValue( eqframe.Categories, v.type ) then 
        table.insert( eqframe.Categories, v.type )
      end
    end
    
    ---------------------
    
    eqframe.ItemPanel = vgui.Create("DPanel", eqframe)
    eqframe.ItemPanel:SetPos( 0, 28 )
    eqframe.ItemPanel:SetSize( 500, 336 )
    eqframe.ItemPanel.Paint = function( s, w, h )
    
      draw.RoundedBox( 0, 0, 0, w, h, Color( 60, 60, 60, 255 ) )
      
      draw.RoundedBox( 0, 0, 32, w, 184, Color( 40, 40, 40, 255 ) )
    end
    
    eqframe.ItemPanel.Items = vgui.Create("DPanelList", eqframe.ItemPanel)
    eqframe.ItemPanel.Items:SetPos( 128, 32 )
    eqframe.ItemPanel.Items:SetSize( 372, 184 )
    eqframe.ItemPanel.Items:EnableVerticalScrollbar( true )
    eqframe.ItemPanel.Items:EnableHorizontal( true )
    eqframe.ItemPanel.Items:SetPadding( 4 )
    eqframe.ItemPanel.Items:SetSpacing( 4 )
    eqframe.ItemPanel.Items.Selected = nil
    eqframe.ItemPanel.Items.Paint = function( s, w, h )
      surface.SetDrawColor( 15, 15, 15, 255 )
      surface.DrawOutlinedRect( -1, -1, w, h+2)
      surface.DrawOutlinedRect( -1, -1, w+1, h+2)
      
      /*local w2 = 18
      
      if s.VBar:IsVisible() then w2 = 44 end
      
      if !s.VBar:IsVisible() then
        draw.RoundedBox( 0, 8, 8, w-w2, h-16, Color(0, 0, 0, 255) )
      end
      
      surface.SetMaterial(eqframe.ItemPanel.Items.Grad)
      surface.SetDrawColor(0,0,0,255)
      
      //surface.DrawTexturedRectRotated( w/2 - (w-8)/2, h/2, h-16, 8, 270)
      //surface.DrawTexturedRectRotated( w/2 + (w-8)/2 - 2 - (w2-18), h/2, h-16, 8, 90)
      surface.DrawTexturedRectRotated( w/2 - (w2/2) + 8, h/2 - (h-8)/2, w-(w2), 8, 180)
      surface.DrawTexturedRectRotated( w/2 - (w2/2) + 8, h/2 + (h-8)/2, w-(w2), 8, 0)*/
      
    end
    eqframe.ItemPanel.Items.pnlCanvas.Paint = function( s, w, h )
      
      /*if s:GetParent().VBar:IsVisible() then
        draw.RoundedBox( 0, 8, 8, w-44, h-16, Color(0, 0, 0, 255) )
      end*/
    end
    eqframe.ItemPanel.Items.PerformLayout = function(s)

      local Wide = s:GetWide()
      local YPos = 0
      
      if ( !s.Rebuild ) then
        debug.Trace()
      end
      
      s:Rebuild()
      
      if ( s.VBar && !m_bSizeToContents ) then
        s.VBar:SetPos( s:GetWide() - 28, 4 )
        s.VBar:SetSize( 22, s:GetTall() - 8 )
        s.VBar:SetUp( s:GetTall(), s.pnlCanvas:GetTall() )
        YPos = s.VBar:GetOffset()
      end

      s.pnlCanvas:SetPos( 0, YPos )
      s.pnlCanvas:SetWide( Wide )
      
      s:Rebuild()
      
      if ( s:GetAutoSize() ) then
        s:SetTall( s.pnlCanvas:GetTall() )
        s.pnlCanvas:SetPos( 0, 0 )
      end 

    end
    eqframe.ItemPanel.Items.VBar.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 8, 0, w-16, h, Color(50, 50, 50, 255) )
    end
    eqframe.ItemPanel.Items.VBar.btnDown.Hover = 0
    eqframe.ItemPanel.Items.VBar.btnDown.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 0, w-4, h-2, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
      
      local arrow = {{ },{ },{ }}

      arrow[1]["x"] = 4
      arrow[1]["y"] = 8

      arrow[2]["x"] = w - 4
      arrow[2]["y"] = 8
      
      arrow[3]["x"] = w/2
      arrow[3]["y"] = 18
      
      local x, y = s:GetPos()
      surface.SetMaterial( eqframe.ItemPanel.Items.White )
      surface.SetDrawColor( 150 + s.Hover * 70, 150 + s.Hover * 70, 150 + s.Hover * 70, 255 )
      surface.DrawPoly( arrow )
    end
    eqframe.ItemPanel.Items.VBar.btnUp.Hover = 0
    eqframe.ItemPanel.Items.VBar.btnUp.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 2, w-4, h-2, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
      
      local arrow = {{ },{ },{ }}

      arrow[1]["x"] = 4
      arrow[1]["y"] = 16
      
      arrow[2]["x"] = w/2
      arrow[2]["y"] = 6

      arrow[3]["x"] = w - 4
      arrow[3]["y"] = 16
      
      local x, y = s:GetPos()
      surface.SetMaterial( eqframe.ItemPanel.Items.White )
      surface.SetDrawColor( 150 + s.Hover * 70, 150 + s.Hover * 70, 150 + s.Hover * 70, 255 )
      surface.DrawPoly( arrow )
    end
    eqframe.ItemPanel.Items.VBar.btnGrip.Hover = 0
    eqframe.ItemPanel.Items.VBar.btnGrip.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 255) )
      draw.RoundedBox( 0, 2, 0, w-4, h, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
    end
    
    eqframe.ItemPanel.Items.Grad = Material("vgui/gradient_down")
    eqframe.ItemPanel.Items.Custom = Material("vgui/ttt/custom_marker")
    eqframe.ItemPanel.Items.White = Material("vgui/white")
    eqframe.ItemPanel.Items.Tick = Material("icon16/tick.png")
    eqframe.ItemPanel.Items.Heart = Material("icon16/heart.png")
    
    eqframe.ItemPanel.InfoPanel = vgui.Create("DPanel", eqframe.ItemPanel)
    eqframe.ItemPanel.InfoPanel:SetPos( 128, 216 )
    eqframe.ItemPanel.InfoPanel:SetSize( 372, 120 )
    eqframe.ItemPanel.InfoPanel.CName = {" credits.", " credit.", "no credits."}
    eqframe.ItemPanel.InfoPanel.Paint = function( s, w, h )
      surface.SetDrawColor( 15, 15, 15, 255 )
      surface.DrawOutlinedRect( -1, 0, w, h)
      surface.DrawOutlinedRect( -1, 1, w+1, h-2)
      
      draw.RoundedBox( 0, 208, 0, 2, h, Color(15, 15, 15, 255) )
      
      if IsValid(eqframe.ItemPanel.Items.Selected) then
        
        local tab = eqframe.ItemPanel.Items.Selected.Table
        
        -----
        
        local c = LocalPlayer():GetCredits()

        if c > 0 then
          if c > 1 then
            draw.SimpleText("O", "minimal_smaller", 210 + 15, 10, Color(15,250,15,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(("You have "..c..s.CName[1]), "minimal_smaller", 210 + 30, 10, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
          else
            draw.SimpleText("O", "minimal_smaller", 210 + 15, 10, Color(15,250,15,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(("You have "..c..s.CName[2]), "minimal_smaller", 210 + 30, 10, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
          end
        else
          draw.SimpleText("X", "minimal_smaller", 210 + 15, 10, Color(250,15,15,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
          draw.SimpleText(("You have "..s.CName[3]), "minimal_smaller", 210 + 30, 10, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
        
        -----
        
        if ItemIsWeapon(tab) and (not CanCarryWeapon(tab)) then
          draw.SimpleText("X", "minimal_smaller", 210 + 15, 32, Color(250,15,15,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
          draw.SimpleText("Slot "..tab.slot.." is not empty.", "minimal_smaller", 210 + 30, 32, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        elseif (not ItemIsWeapon(tab)) and LocalPlayer():HasEquipmentItem(tab.id) then
          draw.SimpleText("X", "minimal_smaller", 210 + 15, 32, Color(250,15,15,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
          draw.SimpleText("You already have this item.", "minimal_smaller", 210 + 30, 32, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        else
          draw.SimpleText("O", "minimal_smaller", 210 + 15, 32, Color(15,250,15,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
          draw.SimpleText("You can carry this item.", "minimal_smaller", 210 + 30, 32, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
        
        -----
        
        if tab.limited and LocalPlayer():HasBought(tostring(tab.id)) then
          draw.SimpleText("X", "minimal_smaller", 210 + 15, 54, Color(250,15,15,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
          draw.SimpleText("Item is out of stock.", "minimal_smaller", 210 + 30, 54, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        else
          draw.SimpleText("O", "minimal_smaller", 210 + 15, 54, Color(15,250,15,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
          draw.SimpleText("Item is in stock.", "minimal_smaller", 210 + 30, 54, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
        
      end
    end
    
    eqframe.ItemPanel.InfoPanel.Name = vgui.Create("DLabel", eqframe.ItemPanel.InfoPanel)
    eqframe.ItemPanel.InfoPanel.Name:SetPos( 10, 10 )
    eqframe.ItemPanel.InfoPanel.Name:SizeToContents()
    eqframe.ItemPanel.InfoPanel.Name:SetText("")
    eqframe.ItemPanel.InfoPanel.Name.Hover = 0
    eqframe.ItemPanel.InfoPanel.Name.PaintOver = function(s, w, h)
      if s.Hover < 1 then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        s:SetTextColor( Color( 220, 220, 220, 255 * s.Hover ) )
      end
    end

    eqframe.ItemPanel.InfoPanel.Desc = vgui.Create("DLabel", eqframe.ItemPanel.InfoPanel)
    eqframe.ItemPanel.InfoPanel.Desc:SetPos( 10, 32 )
    eqframe.ItemPanel.InfoPanel.Desc:SetSize( 200, 80 )
    eqframe.ItemPanel.InfoPanel.Desc:SetText("")
    eqframe.ItemPanel.InfoPanel.Desc:SetAutoStretchVertical(true)
    eqframe.ItemPanel.InfoPanel.Desc.Hover = 0
    eqframe.ItemPanel.InfoPanel.Desc.PaintOver = function(s, w, h)
      if s.Hover < 1 then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        s:SetTextColor( Color( 220, 220, 220, 255 * s.Hover ) )
      end
    end
    
    eqframe.ItemPanel.InfoPanel.Buy = vgui.Create("DButton", eqframe.ItemPanel.InfoPanel)
    eqframe.ItemPanel.InfoPanel.Buy:SetPos( 260, 80 )
    eqframe.ItemPanel.InfoPanel.Buy:SetSize( 100, 30 )
    eqframe.ItemPanel.InfoPanel.Buy:SetText("")
    eqframe.ItemPanel.InfoPanel.Buy.HoverOn = 0
    eqframe.ItemPanel.InfoPanel.Buy.Hover = 0
    eqframe.ItemPanel.InfoPanel.Buy.Hover1 = 0
    eqframe.ItemPanel.InfoPanel.Buy.Hover2 = 0
    eqframe.ItemPanel.InfoPanel.Buy.Hover3 = 0
    eqframe.ItemPanel.InfoPanel.Buy.Paint = function( s, w, h )
    
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 )
      
      local col1, col2, col3
      
      if IsValid(eqframe.ItemPanel.Items.Selected) then
        
        local tab = eqframe.ItemPanel.Items.Selected.Table
        
        local c = LocalPlayer():GetCredits()

        if c > 0 then
          col1 = true
        end
        
        if ItemIsWeapon(tab) and (not CanCarryWeapon(tab)) then
        elseif (not ItemIsWeapon(tab)) and LocalPlayer():HasEquipmentItem(tab.id) then
        else
          col2 = true
        end
        
        if tab.limited and LocalPlayer():HasBought(tostring(tab.id)) then
        else
          col3 = true
        end
        
      end
      
      if col1 then
        s.Hover1 = math.Clamp( s.Hover1 + FrameTime() * 5, 0, 1 )
      else
        s.Hover1 = math.Clamp( s.Hover1 - FrameTime() * 5, 0, 1 )
      end
      
      if col2 then
        s.Hover2 = math.Clamp( s.Hover2 + FrameTime() * 5, 0, 1 )
      else
        s.Hover2 = math.Clamp( s.Hover2 - FrameTime() * 5, 0, 1 )
      end
      
      if col3 then
        s.Hover3 = math.Clamp( s.Hover3 + FrameTime() * 5, 0, 1 )
      else
        s.Hover3 = math.Clamp( s.Hover3 - FrameTime() * 5, 0, 1 )
      end
      
      local a1, a2, a3 = (15 + (col1 and 205 * s.Hover1 or 0)), (15 + (col2 and 205 * s.Hover2 or 0)), (15 + (col3 and 205 * s.Hover3 or 0))
      
      draw.RoundedBox( 0, 5, 5, 10, 20, Color( a1, a1, a1, 255 ) )
      draw.RoundedBox( 0, 17, 5, 10, 20, Color( a2, a2, a2, 255 ) )
      draw.RoundedBox( 0, 29, 5, 10, 20, Color( a3, a3, a3, 255 ) )
      
      local arrow = {{ },{ },{ }}

      arrow[1]["x"] = 41
      arrow[1]["y"] = 5

      arrow[2]["x"] = 51
      arrow[2]["y"] = 15
      
      arrow[3]["x"] = 41
      arrow[3]["y"] = 25
      
      surface.SetMaterial( eqframe.ItemPanel.Items.White )
      
      local col = Color( 15, 15, 15, 255 )
      
      if col1 and col2 and col3 then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      end
      
      surface.SetDrawColor( col )
      surface.DrawPoly( arrow )
      
      draw.SimpleText("BUY", "minimal_small", w-15, h/2-1, col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
      
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
    
      if s:IsHovered() then
        s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
      else
        s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
      end
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
      
    end
    eqframe.ItemPanel.InfoPanel.Buy.Think = function( s, w, h )
      if eqframe.ItemPanel.Items.Selected == nil then
        s:SetDisabled(true)
      else
        s:SetDisabled(false)
      end
    end
    eqframe.ItemPanel.InfoPanel.Buy.DoClick = function( s )
      
      local col1, col2, col3
      
      if IsValid(eqframe.ItemPanel.Items.Selected) then
        
        local tab = eqframe.ItemPanel.Items.Selected.Table
        
        local c = LocalPlayer():GetCredits()

        if c > 0 then
          col1 = true
        end
        
        if ItemIsWeapon(tab) and (not CanCarryWeapon(tab)) then
        elseif (not ItemIsWeapon(tab)) and LocalPlayer():HasEquipmentItem(tab.id) then
        else
          col2 = true
        end
        
        if tab.limited and LocalPlayer():HasBought(tostring(tab.id)) then
        else
          col3 = true
        end
        
        if col1 and col2 and col3 then
          
          RunConsoleCommand("ttt_order_equipment", tab.id)
          eqframe:Close()
        
        end
      end
    end
    
    eqframe.ItemPanel.InfoPanel.Fav = vgui.Create("DButton", eqframe.ItemPanel.InfoPanel)
    eqframe.ItemPanel.InfoPanel.Fav:SetPos( 220, 80 )
    eqframe.ItemPanel.InfoPanel.Fav:SetSize( 40, 30 )
    eqframe.ItemPanel.InfoPanel.Fav:SetText("")
    eqframe.ItemPanel.InfoPanel.Fav.HoverOn = 0
    eqframe.ItemPanel.InfoPanel.Fav.Hover = 0
    eqframe.ItemPanel.InfoPanel.Fav.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 2, w-2, h-4, eqframe.Color1 )
      
      local col = Color( 15, 15, 15, 255 )
      
      if eqframe.ItemPanel.Items.Selected != nil and table.HasValue(eqframe.Settings["Favourites"], eqframe.ItemPanel.Items.Selected.Table.id ) then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      end
      
      draw.SimpleText("+FAV", "minimal_small", w/2+1, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
    
      if s:IsHovered() then
        s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
      else
        s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
      end
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
      
    end
    eqframe.ItemPanel.InfoPanel.Fav.Think = function( s, w, h )
      if eqframe.ItemPanel.Items.Selected == nil then
        s:SetDisabled(true)
      else
        s:SetDisabled(false)
      end
    end
    eqframe.ItemPanel.InfoPanel.Fav.DoClick = function( s )
      if eqframe.ItemPanel.Items.Selected != nil then
        local ik = nil
        for k, v in pairs(eqframe.Settings["Favourites"]) do
          if v == eqframe.ItemPanel.Items.Selected.Table.id then
            ik = k
            break
          end
        end
        
        if ik == nil then
          table.insert(eqframe.Settings["Favourites"], eqframe.ItemPanel.Items.Selected.Table.id)
        else
          table.remove(eqframe.Settings["Favourites"], ik)
          if eqframe.ItemPanel.CategoryList.Selected and eqframe.ItemPanel.CategoryList.Selected.Text == "FAVOURITES" then
            eqframe.ItemPanel.Items:RebuildItems(true)
          end
        end     
      end 
    end
    
    eqframe.ItemPanel.CategoryList = vgui.Create("DPanelList", eqframe.ItemPanel)
    eqframe.ItemPanel.CategoryList:SetPos( 0, 32 )
    eqframe.ItemPanel.CategoryList:SetSize( 128, 184 )
    eqframe.ItemPanel.CategoryList:EnableVerticalScrollbar( true )
    eqframe.ItemPanel.CategoryList:SetPadding( 4 )
    eqframe.ItemPanel.CategoryList:SetSpacing( 4 )
    eqframe.ItemPanel.CategoryList.Selected = nil
    eqframe.ItemPanel.CategoryList.Paint = function( s, w, h )
      surface.SetDrawColor( 15, 15, 15, 255 )
      surface.DrawOutlinedRect( 0, -1, w-1, h+2)
      surface.DrawOutlinedRect( 1, -1, w-1, h+2)
    end
    eqframe.ItemPanel.CategoryList.PerformLayout = function(s)

      local Wide = s:GetWide()
      local YPos = 0
      
      if ( !s.Rebuild ) then
        debug.Trace()
      end
      
      s:Rebuild()
      
      if ( s.VBar && !m_bSizeToContents ) then
        s.VBar:SetPos( s:GetWide() - 28, 4 )
        s.VBar:SetSize( 22, s:GetTall() - 8 )
        s.VBar:SetUp( s:GetTall(), s.pnlCanvas:GetTall() )
        YPos = s.VBar:GetOffset()
        if s.VBar:IsVisible() then Wide = Wide - 28 end
      end

      s.pnlCanvas:SetPos( 0, YPos )
      s.pnlCanvas:SetWide( Wide )
      
      s:Rebuild()
      
      if ( s:GetAutoSize() ) then
        s:SetTall( s.pnlCanvas:GetTall() )
        s.pnlCanvas:SetPos( 0, 0 )
      end 

    end
    eqframe.ItemPanel.CategoryList.VBar.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 8, 0, w-16, h, Color(50, 50, 50, 255) )
    end
    eqframe.ItemPanel.CategoryList.VBar.btnDown.Hover = 0
    eqframe.ItemPanel.CategoryList.VBar.btnDown.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 0, w-4, h-2, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
      
      local arrow = {{ },{ },{ }}

      arrow[1]["x"] = 4
      arrow[1]["y"] = 8

      arrow[2]["x"] = w - 4
      arrow[2]["y"] = 8
      
      arrow[3]["x"] = w/2
      arrow[3]["y"] = 18
      
      local x, y = s:GetPos()
      surface.SetMaterial( eqframe.ItemPanel.Items.White )
      surface.SetDrawColor( 150 + s.Hover * 70, 150 + s.Hover * 70, 150 + s.Hover * 70, 255 )
      surface.DrawPoly( arrow )
    end
    eqframe.ItemPanel.CategoryList.VBar.btnUp.Hover = 0
    eqframe.ItemPanel.CategoryList.VBar.btnUp.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 2, w-4, h-2, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
      
      local arrow = {{ },{ },{ }}

      arrow[1]["x"] = 4
      arrow[1]["y"] = 16
      
      arrow[2]["x"] = w/2
      arrow[2]["y"] = 6

      arrow[3]["x"] = w - 4
      arrow[3]["y"] = 16
      
      local x, y = s:GetPos()
      surface.SetMaterial( eqframe.ItemPanel.Items.White )
      surface.SetDrawColor( 150 + s.Hover * 70, 150 + s.Hover * 70, 150 + s.Hover * 70, 255 )
      surface.DrawPoly( arrow )
    end
    eqframe.ItemPanel.CategoryList.VBar.btnGrip.Hover = 0
    eqframe.ItemPanel.CategoryList.VBar.btnGrip.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 255) )
      draw.RoundedBox( 0, 2, 0, w-4, h, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
    end
    
    for k, v in pairs(eqframe.Categories) do
      
      local nam = v
      if string.Left(nam, 5) == "item_" then nam = string.Right(nam, string.len(nam)-5) end
      
      local cat = vgui.Create("Button")
      cat:SetText("")
      cat:SetSize( 108, 30 )
      cat.Hover = 0
      cat.HoverOn = 0
      cat.Category = v
      cat.Text = string.upper(nam)
      cat.Paint = function( s, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
        draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 )
        
        local col = Color( 15, 15, 15, 255 )
        
        if eqframe.ItemPanel.CategoryList.Selected == s then
          s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
          col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
        else
          s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
          col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
        end
        
        draw.SimpleText(s.Text, "minimal_small", w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
        
        if s:IsHovered() then
          s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
        else
          s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
        end
        draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
        
      end
      cat.DoClick = function( s )
        local prev = eqframe.ItemPanel.CategoryList.Selected
        eqframe.ItemPanel.CategoryList.Selected = s
        if eqframe.Settings["Settings"]["Uncat"] == false or (IsValid(prev) and prev.Text == "FAVOURITES") then
          eqframe.ItemPanel.Items:RebuildItems()
        end
      end
      
      eqframe.ItemPanel.CategoryList:AddItem(cat)
    end
    
    eqframe.ItemPanel.FavPanel = vgui.Create("DPanel", eqframe.ItemPanel)
    eqframe.ItemPanel.FavPanel:SetPos( 0, 216 )
    eqframe.ItemPanel.FavPanel:SetSize( 128, 120 )
    eqframe.ItemPanel.FavPanel.Paint = function( s, w, h )
      surface.SetDrawColor( 15, 15, 15, 255 )
      surface.DrawOutlinedRect( 0, 0, w, h )
      surface.DrawOutlinedRect( 1, 1, w-2, h-2 )
    end
    
    eqframe.ItemPanel.FavPanel.Check1 = vgui.Create( "DCheckBoxLabel", eqframe.ItemPanel.FavPanel )
    eqframe.ItemPanel.FavPanel.Check1:SetPos( 10, 10 )
    eqframe.ItemPanel.FavPanel.Check1:SetText( "Uncategorized?" )
    eqframe.ItemPanel.FavPanel.Check1:SizeToContents()
    eqframe.ItemPanel.FavPanel.Check1.Button.Hover = 0
    eqframe.ItemPanel.FavPanel.Check1.Button.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 )
      
      if s:GetChecked() then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      draw.SimpleText("X", "minimal_small", w/2, h/2-1, Color(15, 15, 15, 255 * s.Hover), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end
    eqframe.ItemPanel.FavPanel.Check1.OnChange = function( s, val )
      eqframe.Settings["Settings"]["Uncat"] = val
      if eqframe.ItemPanel.CategoryList.Selected and eqframe.ItemPanel.CategoryList.Selected.Text != "FAVOURITES" then
        eqframe.ItemPanel.Items:RebuildItems()
      end
    end
    if eqframe.Settings["Settings"]["Uncat"] then
      eqframe.ItemPanel.FavPanel.Check1:SetChecked(true)
    end
    
    eqframe.ItemPanel.FavPanel.Check2 = vgui.Create( "DCheckBoxLabel", eqframe.ItemPanel.FavPanel )
    eqframe.ItemPanel.FavPanel.Check2:SetPos( 10, 32 )
    eqframe.ItemPanel.FavPanel.Check2:SetText( "Hide customs?" )
    eqframe.ItemPanel.FavPanel.Check2:SizeToContents()
    eqframe.ItemPanel.FavPanel.Check2.Button.Hover = 0
    eqframe.ItemPanel.FavPanel.Check2.Button.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 )
      
      if s:GetChecked() then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      draw.SimpleText("X", "minimal_small", w/2, h/2-1, Color(15, 15, 15, 255 * s.Hover), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end
    eqframe.ItemPanel.FavPanel.Check2.OnChange = function( s, val )
      eqframe.Settings["Settings"]["Hidecus"] = val
      if eqframe.ItemPanel.CategoryList.Selected and eqframe.ItemPanel.CategoryList.Selected.Text != "FAVOURITES" then
        eqframe.ItemPanel.Items:RebuildItems()
      end
    end
    if eqframe.Settings["Settings"]["Hidecus"] then
      eqframe.ItemPanel.FavPanel.Check2:SetChecked(true)
    end
    
    eqframe.ItemPanel.FavPanel.Check3 = vgui.Create( "DCheckBoxLabel", eqframe.ItemPanel.FavPanel )
    eqframe.ItemPanel.FavPanel.Check3:SetPos( 10, 54 )
    eqframe.ItemPanel.FavPanel.Check3:SetText( "Memory window?" )
    eqframe.ItemPanel.FavPanel.Check3:SizeToContents()
    eqframe.ItemPanel.FavPanel.Check3.Button.Hover = 0
    eqframe.ItemPanel.FavPanel.Check3.Button.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 )
      
      if s:GetChecked() then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      draw.SimpleText("X", "minimal_small", w/2, h/2-1, Color(15, 15, 15, 255 * s.Hover), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end
    eqframe.ItemPanel.FavPanel.Check3.OnChange = function( s, val )
      eqframe.Settings["Settings"]["Memory"] = val
    end
    if eqframe.Settings["Settings"]["Memory"] then
      eqframe.ItemPanel.FavPanel.Check3:SetChecked(true)
    end
    
    eqframe.ItemPanel.FavPanel.Button = vgui.Create("DButton", eqframe.ItemPanel.FavPanel)
    eqframe.ItemPanel.FavPanel.Button:SetPos( 10, 80 )
    eqframe.ItemPanel.FavPanel.Button:SetSize( 108, 30 )
    eqframe.ItemPanel.FavPanel.Button.Text = "FAVOURITES"
    eqframe.ItemPanel.FavPanel.Button.HoverOn = 0
    eqframe.ItemPanel.FavPanel.Button.Hover = 0
    eqframe.ItemPanel.FavPanel.Button:SetText("")
    eqframe.ItemPanel.FavPanel.Button.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 )
      
      local col = Color( 15, 15, 15, 255 )
      
      if eqframe.ItemPanel.CategoryList.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      end
      
      draw.SimpleText(s.Text, "minimal_small", w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      
      if s:IsHovered() then
        s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
      else
        s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
      end
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
    end
    eqframe.ItemPanel.FavPanel.Button.DoClick = function( s )
      if eqframe.ItemPanel.CategoryList.Selected != s then
        eqframe.ItemPanel.CategoryList.Selected = s
        eqframe.ItemPanel.Items:RebuildItems(true)
      else
        if table.Count(eqframe.ItemPanel.CategoryList.Items) > 0 then
          eqframe.ItemPanel.CategoryList.Items[1]:DoClick()
        end
        eqframe.ItemPanel.Items:RebuildItems()
      end
    end
    
    eqframe.ItemPanel.Search = vgui.Create("DPanel", eqframe.ItemPanel)
    eqframe.ItemPanel.Search:SetPos( 0, 0 )
    eqframe.ItemPanel.Search:SetSize( 500, 32 )
    eqframe.ItemPanel.Search.Paint = function( s, w, h )
    
      surface.SetDrawColor( 15, 15, 15, 255 )
      surface.DrawOutlinedRect( 0, 0, w, h )
      surface.DrawOutlinedRect( 1, 1, w-2, h-2 )
      
      draw.RoundedBox( 0, 126, 0, 2, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 466, 0, 2, h, Color(15, 15, 15, 255) )
      
      
      draw.SimpleText("SEARCH FOR:", "minimal_small", 64, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      
    end
    
    eqframe.ItemPanel.Search.Textbox = vgui.Create("DTextEntry", eqframe.ItemPanel.Search)
    eqframe.ItemPanel.Search.Textbox:SetDrawBackground( false )
    eqframe.ItemPanel.Search.Textbox:SetFont( "minimal_small" )
    eqframe.ItemPanel.Search.Textbox:SetMultiline(false)
    eqframe.ItemPanel.Search.Textbox:SetTextColor( Color( 220, 220, 220, 255 ) )
    eqframe.ItemPanel.Search.Textbox:SetPos(130,2)
    eqframe.ItemPanel.Search.Textbox:SetSize(336,28)
    eqframe.ItemPanel.Search.Textbox.OnTextChanged = function( s, a, b, c )
      if eqframe.ItemPanel.CategoryList.Selected and eqframe.ItemPanel.CategoryList.Selected.Text != "FAVOURITES" then
        eqframe.ItemPanel.Items:RebuildItems()
      elseif eqframe.ItemPanel.CategoryList.Selected and eqframe.ItemPanel.CategoryList.Selected.Text == "FAVOURITES" then
        eqframe.ItemPanel.Items:RebuildItems(true)
      end
    end
    
    eqframe.ItemPanel.Search.TextboxB = vgui.Create("DButton", eqframe.ItemPanel.Search)
    eqframe.ItemPanel.Search.TextboxB:SetPos(130,2)
    eqframe.ItemPanel.Search.TextboxB:SetSize(336,28)
    eqframe.ItemPanel.Search.TextboxB:SetText("")
    eqframe.ItemPanel.Search.TextboxB.Paint = function() end
    eqframe.ItemPanel.Search.TextboxB.DoClick = function(s)
      eqframe:SetKeyboardInputEnabled(true)
      eqframe.ItemPanel.Search.Textbox:RequestFocus()
      s:SetVisible(false)
    end
    
    eqframe.ItemPanel.Search.Button = vgui.Create("DButton", eqframe.ItemPanel.Search)
    eqframe.ItemPanel.Search.Button:SetPos( 468, 2 )
    eqframe.ItemPanel.Search.Button:SetSize( 30, 28 )
    eqframe.ItemPanel.Search.Button.Text = "X"
    eqframe.ItemPanel.Search.Button.Hover = 0
    eqframe.ItemPanel.Search.Button:SetText("")
    eqframe.ItemPanel.Search.Button.Paint = function( s, w, h )
    
      draw.RoundedBox( 0, 0, 0, w, h, eqframe.Color1 )
      
      local col = Color( 15, 15, 15, 255 )
      
      if s:IsHovered() then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      end
      
      draw.SimpleText(s.Text, "minimal_small", w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      
    end
    eqframe.ItemPanel.Search.Button.DoClick = function( s )
      eqframe.ItemPanel.Search.Textbox:SetValue("")
      if eqframe.ItemPanel.CategoryList.Selected and eqframe.ItemPanel.CategoryList.Selected.Text != "FAVOURITES" then
        eqframe.ItemPanel.Items:RebuildItems()
      elseif eqframe.ItemPanel.CategoryList.Selected and eqframe.ItemPanel.CategoryList.Selected.Text == "FAVOURITES" then
        eqframe.ItemPanel.Items:RebuildItems(true)
      end
      eqframe.ItemPanel.Search.Textbox:RequestFocus()
    end
    
    eqframe.ItemPanel.Items.RebuildItems = function( s, fav )
      
      eqframe.ItemPanel.Items.VBar:SetScroll(0)
      eqframe.ItemPanel.Items.Selected = nil
      
      eqframe.ItemPanel.InfoPanel.Name:SetText( "" )
      eqframe.ItemPanel.InfoPanel.Name.Hover = 0
      eqframe.ItemPanel.InfoPanel.Name:SizeToContents()
      
      eqframe.ItemPanel.InfoPanel.Desc:SetText( "" )
      eqframe.ItemPanel.InfoPanel.Desc.Hover = 0
      
      for k, v in pairs(eqframe.ItemPanel.Items.Items) do
        v:Remove()
      end
      
      for k, v in pairs(eqframe.Equipment) do
        
        local filter = eqframe.ItemPanel.Search.Textbox:GetValue()
        local name = (LANG.GetRawTranslation( (v.name) ) or (v.name or ""))
        
        if filter != nil and filter != "" then
          if string.find(name, filter) == nil then
            continue
          end
        end
        
        if !fav then
        
          if eqframe.Settings["Settings"]["Uncat"] then
            if eqframe.Settings["Settings"]["Hidecus"] and v.custom then
              continue
            end
          else
            if eqframe.ItemPanel.CategoryList.Selected and eqframe.ItemPanel.CategoryList.Selected.Category == v.type then
              if eqframe.Settings["Settings"]["Hidecus"] and v.custom then
                continue
              end
            else
              continue
            end
          end
        else
          if table.HasValue(eqframe.Settings["Favourites"], v.id) == false then
            continue
          end
        end
        
        local item = vgui.Create("DButton")
        item:SetSize( 64, 64 )
        item:SetText("")
        item.Table = v
        item.Hover = 0
        item.Icon = Material(item.Table.material)
        item.Paint = function( s, w, h )
        
          if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
            s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
          elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
            s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
          end
          
          draw.RoundedBox( 0, 0, 0, w, h, Color(20, 20, 20, 225) )
          
          surface.SetMaterial(s.Icon)
          surface.SetDrawColor(255,255,255,230 + 25 * s.Hover)
          surface.DrawTexturedRect( 0, 0, w, h )
          
          if eqframe.ItemPanel.Items.Selected == s then
            draw.RoundedBox( 0, 2, 2, w - 4, 2, Color(255, 255, 20, 225) )
            draw.RoundedBox( 0, 2, h-4, w - 4, 2, Color(255, 255, 20, 225) )
            draw.RoundedBox( 0, 2, 4, 2, h-8, Color(255, 255, 20, 225) )
            draw.RoundedBox( 0, w-4, 4, 2, h-8, Color(255, 255, 20, 225) )
          end
          
          if s.Table.slot then
            draw.RoundedBox( 6, 4, 4, 14, 14, Color(225,25,25,230 + 25 * s.Hover) )
            draw.SimpleText(s.Table.slot, "minimal_small", 11, 10, Color(15, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end
          
          if !fav and table.HasValue(eqframe.Settings["Favourites"], s.Table.id) then
            draw.RoundedBox( 6, 4, h-18, 14, 14, Color(225,185,225,230 + 25 * s.Hover) )
            surface.SetMaterial(eqframe.ItemPanel.Items.Heart)
            surface.SetDrawColor(15, 50, 50, 230 + 25 * s.Hover)
            surface.DrawTexturedRect( 7, h - 15, 8, 8 )
          end
          
          if s.Table.custom then
            surface.SetMaterial(eqframe.ItemPanel.Items.Custom)
            surface.SetDrawColor(255,255,255,230 + 25 * s.Hover)
            surface.DrawTexturedRect( w - 20, h - 20, 16, 16 )
          end
          
          surface.SetMaterial(eqframe.ItemPanel.Items.Grad)
          surface.SetDrawColor(0,0,0,255 - 25 * s.Hover)
          surface.DrawTexturedRectRotated( w/2 - (w-16)/2, h/2, w, 16, 90)
          surface.DrawTexturedRectRotated( w/2 + (w-16)/2, h/2, w, 16, 270)
          surface.DrawTexturedRectRotated( w/2, h/2 + (h-16)/2, w, 16, 180)
          surface.DrawTexturedRectRotated( w/2, h/2 - (h-16)/2, w, 16, 0)
          
          local col1, col2, col3
          
          local tab = s.Table
        
          local c = LocalPlayer():GetCredits()

          if c > 0 then
            col1 = true
          end
          
          if ItemIsWeapon(tab) and (not CanCarryWeapon(tab)) then
          elseif (not ItemIsWeapon(tab)) and LocalPlayer():HasEquipmentItem(tab.id) then
          else
            col2 = true
          end
          
          if tab.limited and LocalPlayer():HasBought(tostring(tab.id)) then
          else
            col3 = true
          end
          
          if !col1 or !col2 or !col3 then
            draw.RoundedBox(0, 0, 0, w, h, Color(15,15,15,230))
          end
          
        end
        item.DoClick = function(s)
          eqframe.ItemPanel.Items.Selected = s
          
          eqframe.ItemPanel.InfoPanel.Name:SetText( (LANG.GetRawTranslation( (s.Table.name) ) or (s.Table.name or "")) )
          eqframe.ItemPanel.InfoPanel.Name:SetTextColor( Color(220, 220, 220, 0) )
          eqframe.ItemPanel.InfoPanel.Name.Hover = 0
          eqframe.ItemPanel.InfoPanel.Name:SizeToContents()
          
          eqframe.ItemPanel.InfoPanel.Desc:SetText( (LANG.GetRawTranslation( (s.Table.desc) ) or (s.Table.desc or "")) )
          eqframe.ItemPanel.InfoPanel.Desc:SetTextColor( Color(220, 220, 220, 0) )
          eqframe.ItemPanel.InfoPanel.Desc.Hover = 0
        end
        eqframe.ItemPanel.Items:AddItem( item )
      end
    end
    
    if table.Count(eqframe.ItemPanel.CategoryList.Items) > 0 then
      eqframe.ItemPanel.CategoryList.Items[1]:DoClick()
    end
    
    eqframe.ItemPanel.Items:RebuildItems()
    eqframe.ItemPanel:SetVisible(false)
    eqframe.Windows["ITEMS"] = eqframe.ItemPanel
    ---------------------
      
    -- Item control
    eqframe.Windows["RADAR"] = RADAR.CreateMenu(eqframe, eqframe)
    eqframe.Windows["RADAR"]:SetPos(0, 28)
    eqframe.Windows["RADAR"]:SetSize( 500, 336 )
    eqframe.Windows["RADAR"]:SetVisible(false)
      
    eqframe.Windows["DISGUISE"] = DISGUISE.CreateMenu(eqframe)
    eqframe.Windows["DISGUISE"]:SetPos(0, 28)
    eqframe.Windows["DISGUISE"]:SetSize( 500, 336 )
    eqframe.Windows["DISGUISE"]:SetVisible(false)
      
    -- Weapon/item control
    eqframe.Windows["RADIO"] = TRADIO.CreateMenu(eqframe)
    eqframe.Windows["RADIO"]:SetPos(0, 28)
    eqframe.Windows["RADIO"]:SetSize( 500, 336 )
    eqframe.Windows["RADIO"]:SetVisible(false)
    
    -- Credit transferring
    
    eqframe.Windows["TRANSFER"] = CreateTransferMenu(eqframe)
    eqframe.Windows["TRANSFER"]:SetPos(0, 28)
    eqframe.Windows["TRANSFER"]:SetSize( 500, 336 )
    eqframe.Windows["TRANSFER"]:SetVisible(false)
    
    
    if table.Count(eqframe.Buttons) > 0 then
      eqframe.Buttons[1]:DoClick()
    end
    
    eqframe:SetKeyboardInputEnabled(false)
    
  end
  concommand.Add("ttt_cl_traitorpopup", NewCMenu)

  ---------------

  function RADAR.CreateMenu(parent, frame)
    local w, h = parent:GetSize()

    local dform = vgui.Create("DPanel", parent)
    dform:StretchToParent(0,0,0,28)
    dform.Paint = function(s, w, h)
      draw.RoundedBox( 0, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
    end

    local bw, bh = 100, 25
    local dscan = vgui.Create("DButton", dform)
    dscan:SetSize(dform:GetWide(), dform:GetTall()/2)
    dscan:SetText("")
    dscan.Text = string.upper(LANG.GetTranslation("radar_scan"))
    dscan.Hover = 0
    dscan.HoverOn = 0
    dscan.Think = function(s)
      if RADAR.enable or not LocalPlayer():HasEquipmentItem(EQUIP_RADAR) then
        s:SetDisabled(true)
      else
        s:SetDisabled(false)
      end
    end
    dscan.Paint = function(s, w, h)
      draw.RoundedBox( 0, 0, 0, 74, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 2, 70, h-3, eqframe.Color1 )
      
      draw.RoundedBox( 0, w-74, 0, 74, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, w-72, 2, 70, h-3, eqframe.Color1 )
      
      draw.RoundedBox( 0, 74, 0, w-148, h-18, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 72, 2, w-144, h-22, eqframe.Color1 )
      
      local col = Color( 15, 15, 15, 255 )
      
      if s:GetDisabled() == false then  
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      end
      
      draw.SimpleText(s.Text, "minimal_small", w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      
      draw.RoundedBox( 0, 0, 0, w, h-20, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      draw.RoundedBox( 0, 0, h-20, 72, 20, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      draw.RoundedBox( 0, w-72, h-20, 72, 20, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
    
      if s:IsHovered() then
        s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
      else
        s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h-20, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
      draw.RoundedBox( 0, 0, h-20, 72, 20, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
      draw.RoundedBox( 0, w-72, h-20, 72, 20, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
    end
    dscan.DoClick = function(s)
      s:SetDisabled(true)
      RunConsoleCommand("ttt_radar_scan")
      frame:Close()
    end

    local dlabel = vgui.Create("DLabel", dform)
    dlabel:SetPos( dform:GetWide()/2 - 160, dform:GetTall()/2 - 26 )
    dlabel:SetSize( 340, 50 )
    dlabel:SetFont( "minimal_small" )
    dlabel:SetText( string.upper(LANG.GetParamTranslation("radar_help", {num = RADAR.duration})) )
    dlabel:SetWrap(true)
    dlabel:CenterHorizontal()

    local but = vgui.Create("DButton", dform)
    but.Value = RADAR.repeating
    but:SetPos(0, dform:GetTall()/2)
    but:SetSize(dform:GetWide(), dform:GetTall()/2)
    but:SetText("")
    but.Text = "AUTO-REPEAT:"
    but.Hover = 0
    but.HoverOn = 0
    but.Paint = function(s, w, h)
      draw.RoundedBox( 0, 0, 0, 74, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 1, 70, h-3, eqframe.Color1 )
      
      draw.RoundedBox( 0, w-74, 0, 74, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, w-72, 1, 70, h-3, eqframe.Color1 )
      
      draw.RoundedBox( 0, 74, 18, w-148, h-18, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 72, 20, w-144, h-22, eqframe.Color1 )
      
      local col = Color( 15, 15, 15, 255 )
      
      if s.Value then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      end
      
      draw.SimpleText(s.Text, "minimal_small", w/2, h/2-1-30, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText(s.Value and "ON" or "OFF", "minimal_small", w/2, h/2-1+30, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      
      draw.RoundedBox( 0, 0,20, w, h-20, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      draw.RoundedBox( 0, 0, 0, 72, 20, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      draw.RoundedBox( 0, w-72, 0, 72, 20, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
    
      if s:IsHovered() then
        s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
      else
        s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 20, w, h-20, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
      draw.RoundedBox( 0, 0, 0, 72, 20, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
      draw.RoundedBox( 0, w-72, 0, 72, 20, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
    end
    but.DoClick = function( s )
      RADAR.repeating = !s.Value
    end
    but.Think = function( s )
      s.Value = RADAR.repeating
    end
    
    /*local dcheck = vgui.Create("DCheckBoxLabel", dform)
    dcheck:SetText(trans("radar_auto"))
    dcheck:SetIndent(5)
    dcheck:SetValue(RADAR.repeating)
    dcheck.OnChange = function(s, val)
      RADAR.repeating = val
    end*/

    dform:SetVisible(true)

    return dform
  end

  ---------------

  function DISGUISE.CreateMenu(parent)
    local dform = vgui.Create("DPanel", parent)
    dform:StretchToParent( 0, 0, 0, 28 )
    dform.Paint = function( s, w, h )
    end
    
    local but = vgui.Create("DButton", dform)
    but:StretchToParent( 0, 0, 0, 0 )
    but.Value = LocalPlayer():GetNWBool("disguised", false) and 1 or 0
    but.HoverOn = 0
    but.Hover = 0
    but:SetText("")
    but.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 or Color( 50, 70, 100, 255 ) )
      
      local col = Color( 15, 15, 15, 255 )
      
      if s.Value == 1 then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      else
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
        col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
      end
      
      draw.SimpleText("DISGUISE:", "minimal_small", w/2, h/2-1-50, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText(s.Value == 1 and "ON" or "OFF", "minimal_small", w/2, h/2-1+50, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
      
      if s:IsHovered() then
        s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
      else
        s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
      end
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
    end
    but.DoClick = function( s )
      RunConsoleCommand("ttt_set_disguise", tostring(s.Value == 1 and 0 or 1))
    end
    but.Think = function( s )
      s.Value = LocalPlayer():GetNWBool("disguised", false) and 1 or 0
    end

    return dform
  end

  ---------------

  TRADIO = {}

  local sound_names = {
     scream   ="radio_button_scream",
     explosion="radio_button_expl",
     pistol   ="radio_button_pistol",
     m16      ="radio_button_m16",
     deagle   ="radio_button_deagle",
     mac10    ="radio_button_mac10",
     shotgun  ="radio_button_shotgun",
     rifle    ="radio_button_rifle",
     huge     ="radio_button_huge",
     beeps    ="radio_button_c4",
     burning  ="radio_button_burn",
     footsteps="radio_button_steps"
  };

  local smatrix = {
     {"scream", "burning", "explosion"},
     {"footsteps", "pistol", "shotgun"},
     {"mac10", "deagle", "m16"},
     {"rifle", "huge", "beeps"}
  };

  local function PlayRadioSound(snd)
     local r = LocalPlayer().radio
     if IsValid(r) then
      RunConsoleCommand("ttt_radio_play", tostring(r:EntIndex()), snd)
     end
  end

  local function ButtonClickPlay(s) PlayRadioSound(s.snd) end

  local function CreateSoundBoard(parent)
    local b = vgui.Create("DPanel", parent)

    b:SetPaintBackground(false)

    local bh, bw = 60, 120
    local m = 4
    local ver = #smatrix
    local hor = #smatrix[1]

    local x, y = 0, 0
    for ri, row in ipairs(smatrix) do
      local rj = ri - 1 -- easier for computing x,y
      for rk, snd in ipairs(row) do
        local rl = rk - 1
        y = (rj * m) + (rj * bh)
        x = (rl * m) + (rl * bw)

        local but = vgui.Create("DButton", b)
        but:SetPos(x, y)
        but:SetSize(bw, bh)
        but:SetText("")
        but.Text = string.upper(LANG.GetTranslation(sound_names[snd]))
        but.snd = snd
        but.DoClick = ButtonClickPlay
        but.Hover = 0
        but.HoverOn = 0
        but.Paint = function(s, w, h)
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
          draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 )
          
          local col = Color( 15, 15, 15, 255 )
          
          if s:GetDisabled() == false then
            s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
            col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
          else
            s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
            col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
          end
          
          draw.SimpleText(s.Text, "minimal_small", w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
        
          if s:IsHovered() then
            s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
          else
            s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
          end
          
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
        end
      end
    end

    b:SetSize(bw * hor + m * (hor - 1), bh * ver + m * (ver - 1))
    b:SetPos(m, 50)
    b:CenterHorizontal()

    return b
  end

  function TRADIO.CreateMenu(parent)
    local w, h = parent:GetSize()

    local wrap = vgui.Create("DPanel", parent)
    wrap:SetSize(w, h)
    wrap.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 2, w-4, h-4, Color( 60, 60, 60, 255 ) )
      
      draw.RoundedBox( 0, 0, 50, w, 252, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 52, w-4, 248, Color( 40, 40, 40, 255 ) )
    end

    local dhelp = vgui.Create("DLabel", wrap)
    dhelp:SetFont("minimal_small")
    dhelp:SetText(string.upper(LANG.GetTranslation("radio_help")))
    dhelp:SetTextColor(Color(220,220,220,255))

    local board = CreateSoundBoard(wrap)

    dhelp:SizeToContents()
    dhelp:SetPos(10, 20)
    dhelp:CenterHorizontal()

    return wrap
  end

  ---------------

  function CreateTransferMenu(parent)
    local dform = vgui.Create("DPanel", parent)
    dform:StretchToParent(0,0,0,28)
    dform.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 2, w-4, h-4, Color( 60, 60, 60, 255 ) )
      
      draw.RoundedBox( 0, 0, 50, w, 252, Color( 15, 15, 15, 255 ) )
      draw.RoundedBox( 0, 2, 52, w-4, 248, Color( 40, 40, 40, 255 ) )
    end

    local dhelp = vgui.Create("DLabel", dform)
    dhelp:SetFont("minimal_small")
    dhelp:SetText(string.upper(LANG.GetParamTranslation("xfer_help", {role = LocalPlayer():GetRoleString()})))
    dhelp:SetTextColor(Color(220,220,220,255))
    dhelp:SizeToContents()
    dhelp:SetPos(10, 20)
    dhelp:CenterHorizontal()

    local pl = vgui.Create("DPanelList", dform)
    pl:SetPos( (dform:GetWide()-368)/2, 50 )
    pl:SetSize( 368, 252 )
    pl.Paint = function( s, w, h )
    end

    local plist = vgui.Create("DPanelList", pl)
    plist:SetPos( 0, 0 )
    plist:SetSize( 368, 252 )
    plist:EnableVerticalScrollbar( true )
    plist:SetPadding( 4 )
    plist:SetSpacing( 4 )
    plist.Paint = function( s, w, h )
    end
    plist.PerformLayout = function(s)

      local Wide = s:GetWide()
      local YPos = 0
      
      if ( !s.Rebuild ) then
        debug.Trace()
      end
      
      s:Rebuild()
      
      if ( s.VBar && !m_bSizeToContents ) then
        s.VBar:SetPos( s:GetWide() - 28, 4 )
        s.VBar:SetSize( 22, s:GetTall() - 8 )
        s.VBar:SetUp( s:GetTall(), s.pnlCanvas:GetTall() )
        YPos = s.VBar:GetOffset()
        if s.VBar:IsVisible() then Wide = Wide - 28 end
      end

      s.pnlCanvas:SetPos( 0, YPos )
      s.pnlCanvas:SetWide( Wide )
      
      s:Rebuild()
      
      if ( s:GetAutoSize() ) then
        s:SetTall( s.pnlCanvas:GetTall() )
        s.pnlCanvas:SetPos( 0, 0 )
      end 

    end
    plist.VBar.Paint = function( s, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 8, 0, w-16, h, Color(50, 50, 50, 255) )
    end
    plist.VBar.btnDown.Hover = 0
    plist.VBar.btnDown.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 0, w-4, h-2, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
      
      local arrow = {{ },{ },{ }}

      arrow[1]["x"] = 4
      arrow[1]["y"] = 8

      arrow[2]["x"] = w - 4
      arrow[2]["y"] = 8
      
      arrow[3]["x"] = w/2
      arrow[3]["y"] = 18
      
      local x, y = s:GetPos()
      surface.SetMaterial( eqframe.ItemPanel.Items.White )
      surface.SetDrawColor( 150 + s.Hover * 70, 150 + s.Hover * 70, 150 + s.Hover * 70, 255 )
      surface.DrawPoly( arrow )
    end
    plist.VBar.btnUp.Hover = 0
    plist.VBar.btnUp.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(15, 15, 15, 255) )
      draw.RoundedBox( 0, 2, 2, w-4, h-2, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
      
      local arrow = {{ },{ },{ }}

      arrow[1]["x"] = 4
      arrow[1]["y"] = 16
      
      arrow[2]["x"] = w/2
      arrow[2]["y"] = 6

      arrow[3]["x"] = w - 4
      arrow[3]["y"] = 16
      
      local x, y = s:GetPos()
      surface.SetMaterial( eqframe.ItemPanel.Items.White )
      surface.SetDrawColor( 150 + s.Hover * 70, 150 + s.Hover * 70, 150 + s.Hover * 70, 255 )
      surface.DrawPoly( arrow )
    end
    plist.VBar.btnGrip.Hover = 0
    plist.VBar.btnGrip.Paint = function( s, w, h )
    
      if s:IsHovered() or eqframe.ItemPanel.Items.Selected == s then
        s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
      elseif s:IsHovered() == false and eqframe.ItemPanel.Items.Selected != s then
        s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
      end
      
      draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 255) )
      draw.RoundedBox( 0, 2, 0, w-4, h, Color(50 + 25 * s.Hover, 50 + 25 * s.Hover, 50 + 25 * s.Hover, 255) )
    end
    
    local r = LocalPlayer():GetRole()
    for _, p in pairs(player.GetAll()) do
      if IsValid(p) and p:IsActiveRole(r) and p != LocalPlayer() then
        local plypl = vgui.Create("DPanel")
        plypl:SetSize( 100, 30 )
        plypl.ply = p
        plypl.Name = p:GetName()
        plypl.UID = p:UniqueID()
        plypl.Paint = function( s, w, h )
          if !IsValid(s.ply) or !s.ply:IsActiveRole(r) or s.ply == LocalPlayer() then return end
          
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
          draw.RoundedBox( 0, 2, 2, w-4, h-4, Color( 60, 60, 60, 255 ) )
          
          draw.SimpleText(s.Name, "minimal_small", 10, h/2-1, Color(220,220,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
          //draw.SimpleText("HAS "..s.ply:GetCredits().. " CREDITS", "minimal_small", 250, h/2-1, Color(220,220,220,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        plypl.Think = function(s)
          local r = LocalPlayer():GetRole()
          if !IsValid(s.ply) or !s.ply:IsActiveRole(r) or s.ply == LocalPlayer() then
            s:Remove()
          end
        end
        
        local giveb = vgui.Create("DButton", plypl)
        giveb:SetSize(100, 30)
        giveb:SetPos(260, 0)
        giveb:SetText("")
        giveb.Text = "GIVE 1 CREDIT"
        giveb.Hover = 0
        giveb.HoverOn = 0
        giveb.Think = function( s )
          if LocalPlayer():GetCredits() > 0 then
            s:SetDisabled(false)
          else
            s:SetDisabled(true)
          end
        end
        giveb.DoClick = function( s )
          RunConsoleCommand("ttt_transfer_credits", tostring(plypl.UID) or "-1", "1")
        end
        giveb.Paint = function(s, w, h)
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 255 ) )
          draw.RoundedBox( 0, 2, 2, w-4, h-4, eqframe.Color1 )
          
          local col = Color( 15, 15, 15, 255 )
          
          if s:GetDisabled() == false then
            s.Hover = math.Clamp( s.Hover + FrameTime() * 5, 0, 1 )
            col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
          else
            s.Hover = math.Clamp( s.Hover - FrameTime() * 5, 0, 1 )
            col = Color(15 + 205 * s.Hover, 15 + 205 * s.Hover, 15 + 205 * s.Hover, 255)
          end
          
          draw.SimpleText(s.Text, "minimal_small", w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 100 - 100 * s.Hover ) )
        
          if s:IsHovered() then
            s.HoverOn = math.Clamp( s.HoverOn + FrameTime() * 5, 0, 1 )
          else
            s.HoverOn = math.Clamp( s.HoverOn - FrameTime() * 5, 0, 1 )
          end
          
          draw.RoundedBox( 0, 0, 0, w, h, Color( 15, 15, 15, 50 - 50 * s.HoverOn ) )
        end
        
        plist:AddItem(plypl)
      end
    end
    
    hook.Add("TTTEndRound", "CloseFancyPants", function()
      if IsValid(eqframe) then
        eqframe:Remove()
      end
    end)

     return dform
  end

---- Traitor equipment menu
--[[
local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

-- Buyable weapons are loaded automatically. Buyable items are defined in
-- equip_items_shd.lua

local Equipment = nil
function GetEquipmentForRole(role)
   -- need to build equipment cache?
   if not Equipment then
      -- start with all the non-weapon goodies
      local tbl = table.Copy(EquipmentItems)

      -- find buyable weapons to load info from
      for k, v in pairs(weapons.GetList()) do
         if v and v.CanBuy then
            local data = v.EquipMenuData or {}
            local base = {
               id       = WEPS.GetClass(v),
               name     = v.PrintName or "Unnamed",
               limited  = v.LimitedStock,
               kind     = v.Kind or WEAPON_NONE,
               slot     = (v.Slot or 0) + 1,
               material = v.Icon or "vgui/ttt/icon_id",
               -- the below should be specified in EquipMenuData, in which case
               -- these values are overwritten
               type     = "Type not specified",
               model    = "models/weapons/w_bugbait.mdl",
               desc     = "No description specified."
            };

            -- Force material to nil so that model key is used when we are
            -- explicitly told to do so (ie. material is false rather than nil).
            if data.modelicon then
               base.material = nil
            end

            table.Merge(base, data)

            -- add this buyable weapon to all relevant equipment tables
            for _, r in pairs(v.CanBuy) do
               table.insert(tbl[r], base)
            end
         end
      end

      -- mark custom items
      for r, is in pairs(tbl) do
         for _, i in pairs(is) do
            if i and i.id then
               i.custom = not table.HasValue(DefaultEquipment[r], i.id)
            end
         end
      end

      Equipment = tbl
   end

   return Equipment and Equipment[role] or {}
end


local function ItemIsWeapon(item) return not tonumber(item.id) end
local function CanCarryWeapon(item) return LocalPlayer():CanCarryType(item.kind) end

local color_bad = Color(220, 60, 60, 255)
local color_good = Color(0, 200, 0, 255)

-- Creates tabel of labels showing the status of ordering prerequisites
local function PreqLabels(parent, x, y)
   local tbl = {}

   tbl.credits = vgui.Create("DLabel", parent)
   tbl.credits:SetToolTip(GetTranslation("equip_help_cost"))
   tbl.credits:SetPos(x, y)
   tbl.credits.Check = function(s, sel)
                          local credits = LocalPlayer():GetCredits()
                          return credits > 0, GetPTranslation("equip_cost", {num = credits})
                       end

   tbl.owned = vgui.Create("DLabel", parent)
   tbl.owned:SetToolTip(GetTranslation("equip_help_carry"))
   tbl.owned:CopyPos(tbl.credits)
   tbl.owned:MoveBelow(tbl.credits, y)
   tbl.owned.Check = function(s, sel)
                        if ItemIsWeapon(sel) and (not CanCarryWeapon(sel)) then
                           return false, GetPTranslation("equip_carry_slot", {slot = sel.slot})
                        elseif (not ItemIsWeapon(sel)) and LocalPlayer():HasEquipmentItem(sel.id) then
                           return false, GetTranslation("equip_carry_own")
                        else
                           return true, GetTranslation("equip_carry")
                        end
                     end

   tbl.bought = vgui.Create("DLabel", parent)
   tbl.bought:SetToolTip(GetTranslation("equip_help_stock"))
   tbl.bought:CopyPos(tbl.owned)
   tbl.bought:MoveBelow(tbl.owned, y)
   tbl.bought.Check = function(s, sel)
                         if sel.limited and LocalPlayer():HasBought(tostring(sel.id)) then
                            return false, GetTranslation("equip_stock_deny")
                         else
                            return true, GetTranslation("equip_stock_ok")
                         end
                      end

   for k, pnl in pairs(tbl) do
      pnl:SetFont("TabLarge")
   end

   return function(selected)
             local allow = true
             for k, pnl in pairs(tbl) do
                local result, text = pnl:Check(selected)
                pnl:SetTextColor(result and color_good or color_bad)
                pnl:SetText(text)
                pnl:SizeToContents()

                allow = allow and result
             end
             return allow
          end
end

-- quick, very basic override of DPanelSelect
local PANEL = {}
local function DrawSelectedEquipment(pnl)
   surface.SetDrawColor(255, 200, 0, 255)
   surface.DrawOutlinedRect(0, 0, pnl:GetWide(), pnl:GetTall())
end

function PANEL:SelectPanel(pnl)
   self.BaseClass.SelectPanel(self, pnl)
   if pnl then
      pnl.PaintOver = DrawSelectedEquipment
   end
end
vgui.Register("EquipSelect", PANEL, "DPanelSelect")


local SafeTranslate = LANG.TryTranslation

local color_darkened = Color(255,255,255, 80)
-- TODO: make set of global role colour defs, these are same as wepswitch
local color_slot = {
   [ROLE_TRAITOR]   = Color(180, 50, 40, 255),
   [ROLE_DETECTIVE] = Color(50, 60, 180, 255)
};

local eqframe = nil
local function TraitorMenuPopup()
  local ply = LocalPlayer()
  if not IsValid(ply) or not ply:IsActiveSpecial() then
     return
  end


end
concommand.Add("ttt_cl_traitorpopup", TraitorMenuPopup)

local function ForceCloseTraitorMenu(ply, cmd, args)
   if IsValid(eqframe) then
      eqframe:Close()
   end
end
concommand.Add("ttt_cl_traitorpopup_close", ForceCloseTraitorMenu)

function GAMEMODE:OnContextMenuOpen()
   local r = GetRoundState()
   if r == ROUND_ACTIVE and not (LocalPlayer():GetTraitor() or LocalPlayer():GetDetective()) then
      return
   elseif r == ROUND_POST or r == ROUND_PREP then
      CLSCORE:Reopen()
      return
   end

   RunConsoleCommand("ttt_cl_traitorpopup")
end

local function ReceiveEquipment()
   local ply = LocalPlayer()
   if not IsValid(ply) then return end

   ply.equipment_items = net.ReadUInt(16)
end
net.Receive("TTT_Equipment", ReceiveEquipment)

local function ReceiveCredits()
   local ply = LocalPlayer()
   if not IsValid(ply) then return end

   ply.equipment_credits = net.ReadUInt(8)
end
net.Receive("TTT_Credits", ReceiveCredits)

local r = 0
local function ReceiveBought()
   local ply = LocalPlayer()
   if not IsValid(ply) then return end

   ply.bought = {}
   local num = net.ReadUInt(8)
   for i=1,num do
      local s = net.ReadString()
      if s != "" then
         table.insert(ply.bought, s)
      end
   end

   -- This usermessage sometimes fails to contain the last weapon that was
   -- bought, even though resending then works perfectly. Possibly a bug in
   -- bf_read. Anyway, this hack is a workaround: we just request a new umsg.
   if num != #ply.bought and r < 10 then -- r is an infinite loop guard
      RunConsoleCommand("ttt_resend_bought")
      r = r + 1
   else
      r = 0
   end
end
net.Receive("TTT_Bought", ReceiveBought)

-- Player received the item he has just bought, so run clientside init
local function ReceiveBoughtItem()
   local is_item = net.ReadBit() == 1
   local id = is_item and net.ReadUInt(16) or net.ReadString()

   -- I can imagine custom equipment wanting this, so making a hook
   hook.Run("TTTBoughtItem", is_item, id)
end
net.Receive("TTT_BoughtItem", ReceiveBoughtItem)

]]