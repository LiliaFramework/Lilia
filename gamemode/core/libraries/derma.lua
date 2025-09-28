lia.derma = lia.derma or {}
function lia.derma.button(parent, icon, iconSize, color, radius, noGradient, hoverColor, noHover)
    if parent ~= nil and not IsValid(parent) then return end
    local button = vgui.Create("liaButton", parent)
    button:SetTall(32)
    button:SetRadius(radius or 6)
    if icon then button:SetIcon(icon, iconSize or 16) end
    if color then button:SetColor(color) end
    if hoverColor then button:SetColorHover(hoverColor) end
    if noGradient then button:SetGradient(false) end
    if noHover then button:SetHover(false) end
    return button
end

function lia.derma.frame(parent, title, width, height, closeButton, animate)
    if parent ~= nil and not IsValid(parent) then return end
    local frame = vgui.Create("liaFrame", parent)
    frame:SetSize(width or 300, height or 200)
    frame:SetTitle(title or L("frame_title"))
    if closeButton then
        frame:ShowCloseButton(true)
    else
        frame:DisableCloseBtn()
    end

    if animate then frame:ShowAnimation() end
    return frame
end

function lia.derma.checkbox(parent, text, convar)
    local panel = vgui.Create("liaBasePanel", parent)
    panel:Dock(TOP)
    panel:DockMargin(4, 0, 4, 0)
    panel:SetTall(28)
    panel.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, lia.color.theme.panel_alpha[2])
        draw.SimpleText(text, "Fated.18", 8, h * 0.5 - 1, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local checkbox = vgui.Create("liaCheckBox", panel)
    checkbox:Dock(RIGHT)
    checkbox:DockMargin(0, 0, 14, 0)
    checkbox:SetText(text)
    checkbox:SetTall(28)
    if convar then checkbox:SetConvar(convar) end
    return panel, checkbox
end

function lia.derma.descEntry(parent, title, placeholder, offTitle)
    local entry, entry_bg
    if not offTitle and title then
        local label = vgui.Create("liaText", parent)
        label:Dock(TOP)
        label:DockMargin(4, 0, 4, 0)
        label:SetText(title)
        label:SetFont("Fated.16")
        label:SetTextColor(lia.color.theme.text)
    end

    entry_bg = vgui.Create("liaBasePanel", parent)
    entry_bg:Dock(TOP)
    entry_bg:DockMargin(4, 4, 4, 0)
    entry_bg:SetTall(24)
    entry = vgui.Create("liaEntry", entry_bg)
    entry:Dock(FILL)
    entry:DockMargin(2, 4, 2, 4)
    entry:SetPlaceholder(placeholder or "")
    entry.Font = "Fated.16"
    return entry, entry_bg
end

function lia.derma.scrollPanel(scrollPanel)
    if not IsValid(scrollPanel) then return end
    local vbar = scrollPanel:GetVBar()
    if IsValid(vbar) then
        vbar:SetWide(12)
        vbar.HideButtons = true
        vbar.Paint = function(_, w, h) draw.RoundedBox(32, 0, 0, w, h, lia.color.theme.focus_panel) end
        local btnGrip = vbar.btnGrip
        if IsValid(btnGrip) then
            btnGrip.Paint = function(s, w, h)
                if s.Depressed then s:SetCursor("sizens") end
                draw.RoundedBox(6, 6, 0, w - 6, h, lia.color.theme.accent)
            end
        end
    end
end

function lia.derma.panelTabs(parent)
    if parent ~= nil and not IsValid(parent) then return end
    local tabs = vgui.Create("liaTabs", parent)
    tabs:Dock(FILL)
    local originalAddTab = tabs.AddTab
    function tabs:AddTab(title, panel, icon, _, _)
        local newPanel = panel or vgui.Create("liaBasePanel")
        originalAddTab(self, title, newPanel, icon)
    end

    function tabs:ActiveTab(title)
        self:SetActiveTab(title)
    end
    return tabs
end

function lia.derma.slideBox(parent, label, minValue, maxValue, convar, decimals)
    if parent ~= nil and not IsValid(parent) then return end
    local slider = vgui.Create("liaButton", parent)
    slider:Dock(TOP)
    slider:DockMargin(0, 6, 0, 0)
    slider:SetTall(40)
    slider:SetText("")
    local value = convar and GetConVar(convar):GetFloat() or minValue
    local sections = maxValue - minValue
    local smoothPos = 0
    local targetPos = 0
    decimals = decimals or 0
    local function UpdateSliderPosition(newValue)
        local progress = (newValue - minValue) / sections
        targetPos = (slider:GetWide() - 16) * progress
        if convar then LocalPlayer():ConCommand(convar .. " " .. newValue) end
        value = newValue
    end

    UpdateSliderPosition(value)
    slider.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, h - 16, w, 6, lia.color.theme.panel_alpha[1])
        smoothPos = Lerp(FrameTime() * 10, smoothPos, targetPos)
        draw.RoundedBox(16, smoothPos, 18, 16, 16, lia.color.theme.accent)
        draw.SimpleText(label, "Fated.18", 4, 0, lia.color.theme.text)
        draw.SimpleText(math.Round(value, decimals), "Fated.18", w - 4, 0, lia.color.theme.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end

    local function UpdateSliderByCursorPos(x)
        local progress = math.Clamp(x / (slider:GetWide() - 16), 0, 1)
        local newValue = math.Round(minValue + (progress * sections), decimals)
        UpdateSliderPosition(newValue)
    end

    slider.OnMousePressed = function(_, mcode)
        if mcode == MOUSE_LEFT then
            UpdateSliderByCursorPos(slider:CursorPos())
            slider:MouseCapture(true)
        end
    end

    slider.OnMouseReleased = function(_, mcode) if mcode == MOUSE_LEFT then slider:MouseCapture(false) end end
    slider.OnCursorMoved = function(_, x, _) if input.IsMouseDown(MOUSE_LEFT) then UpdateSliderByCursorPos(x) end end
    return slider
end

function lia.derma.dermaMenu()
    if IsValid(lia.derma.menu_derma_menu) then lia.derma.menu_derma_menu:CloseMenu() end
    local mouseX, mouseY = input.GetCursorPos()
    local menu = vgui.Create("liaDermaMenu")
    menu:SetPos(mouseX, mouseY)
    lia.util.clampMenuPosition(menu)
    menu._targetX, menu._targetY = menu:GetPos()
    lia.derma.menu_derma_menu = menu
    return menu
end

function lia.derma.radialMenu(options)
    if IsValid(lia.derma.menu_radial) then lia.derma.menu_radial:Remove() end
    local m = vgui.Create("liaRadialPanel")
    m:Init(options)
    lia.derma.menu_radial = m
    return m
end

function lia.derma.attribBar(parent, text, maxValue)
    if parent ~= nil and not IsValid(parent) then return end
    local bar = vgui.Create("liaAttribBar", parent)
    bar:Dock(TOP)
    bar:DockMargin(4, 4, 4, 0)
    bar:SetTall(20)
    if text then bar:SetText(text) end
    if maxValue then bar:setMax(maxValue) end
    return bar
end

function lia.derma.characterAttribs(parent)
    if parent ~= nil and not IsValid(parent) then return end
    local attribs = vgui.Create("liaCharacterAttribs", parent)
    attribs:Dock(FILL)
    return attribs
end

function lia.derma.characterAttribRow(parent, attributeKey, attributeData)
    if parent ~= nil and not IsValid(parent) then return end
    local row = vgui.Create("liaCharacterAttribsRow", parent)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 4)
    row:SetTall(36)
    if attributeKey and attributeData then row:setAttribute(attributeKey, attributeData) end
    return row
end

function lia.derma.category(parent, title, expanded)
    if parent ~= nil and not IsValid(parent) then return end
    local category = vgui.Create("liaCategory", parent)
    category:Dock(TOP)
    category:DockMargin(0, 0, 0, 8)
    if title then category:SetTitle(title) end
    if expanded ~= nil then category:SetExpanded(expanded) end
    return category
end

function lia.derma.colorPicker(callback, defaultColor)
    if IsValid(lia.derma.menu_color_picker) then lia.derma.menu_color_picker:Remove() end
    local selectedColor = defaultColor or Color(255, 255, 255)
    local hue = 0
    local saturation = 1
    local value = 1
    if defaultColor then hue, saturation, value = ColorToHSV(defaultColor) end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(300, 378)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetAlpha(0)
    local container = vgui.Create("Panel", frame)
    container:Dock(FILL)
    container:DockMargin(10, 10, 10, 10)
    local preview = vgui.Create("Panel", container)
    preview:Dock(TOP)
    preview:SetTall(40)
    preview:DockMargin(0, 0, 0, 10)
    preview.Paint = function(_, w, h) draw.RoundedBox(8, 2, 2, w - 4, h - 4, selectedColor) end
    local colorField = vgui.Create("Panel", container)
    colorField:Dock(TOP)
    colorField:SetTall(200)
    colorField:DockMargin(0, 0, 0, 10)
    local colorCursor = {
        x = 0,
        y = 0
    }

    local isDraggingColor = false
    colorField.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingColor = true
            self:OnCursorMoved(self:CursorPos())
        end
    end

    colorField.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingColor = false end end
    colorField.OnCursorMoved = function(self, x, y)
        if isDraggingColor then
            local w, h = self:GetSize()
            x = math.Clamp(x, 0, w)
            y = math.Clamp(y, 0, h)
            colorCursor.x = x
            colorCursor.y = y
            saturation = x / w
            value = 1 - (y / h)
            selectedColor = HSVToColor(hue, saturation, value)
        end
    end

    colorField.Paint = function(_, w, h)
        local segments = 80
        local segmentSize = w / segments
        for x = 0, segments do
            for y = 0, segments do
                local s = x / segments
                local v = 1 - (y / segments)
                local segX = x * segmentSize
                local segY = y * segmentSize
                surface.SetDrawColor(HSVToColor(hue, s, v))
                surface.DrawRect(segX, segY, segmentSize + 1, segmentSize + 1)
            end
        end

        lia.rndx.DrawCircle(colorCursor.x, colorCursor.y, 6, Color(255, 255, 255, 200))
    end

    local hueSlider = vgui.Create("Panel", container)
    hueSlider:Dock(TOP)
    hueSlider:SetTall(20)
    hueSlider:DockMargin(0, 0, 0, 10)
    local huePos = 0
    local isDraggingHue = false
    hueSlider.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingHue = true
            self:OnCursorMoved(self:CursorPos())
        end
    end

    hueSlider.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingHue = false end end
    hueSlider.OnCursorMoved = function(self, x, _)
        if isDraggingHue then
            local w = self:GetWide()
            x = math.Clamp(x, 0, w)
            huePos = x
            hue = (x / w) * 360
            selectedColor = HSVToColor(hue, saturation, value)
        end
    end

    hueSlider.Paint = function(_, w, h)
        local segments = 100
        local segmentWidth = w / segments
        for i = 0, segments - 1 do
            local hueVal = (i / segments) * 360
            local x = i * segmentWidth
            surface.SetDrawColor(HSVToColor(hueVal, 1, 1))
            surface.DrawRect(x, 1, segmentWidth + 1, h - 2)
        end

        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawRect(huePos - 2, 0, 4, h)
    end

    local btnContainer = vgui.Create("Panel", container)
    btnContainer:Dock(BOTTOM)
    btnContainer:SetTall(30)
    local btnCancel = vgui.Create("liaButton", btnContainer)
    btnCancel:Dock(LEFT)
    btnCancel:SetWide(90)
    btnCancel:SetText(L("cancel"))
    btnCancel.DoClick = function() frame:Remove() end
    local btnSelect = vgui.Create("liaButton", btnContainer)
    btnSelect:Dock(RIGHT)
    btnSelect:SetWide(90)
    btnSelect:SetText(L("select"))
    btnSelect.DoClick = function()
        callback(selectedColor)
        frame:Remove()
    end

    timer.Simple(0, function()
        if IsValid(colorField) and IsValid(hueSlider) then
            colorCursor.x = saturation * colorField:GetWide()
            colorCursor.y = (1 - value) * colorField:GetTall()
            huePos = (hue / 360) * hueSlider:GetWide()
        end
    end)

    timer.Simple(0.1, function() frame:SetAlpha(255) end)
    lia.derma.menu_color_picker = frame
    return frame
end

function lia.derma.scrollpanel(parent)
    if parent ~= nil and not IsValid(parent) then return end
    local scrollpanel = vgui.Create("liaScrollPanel", parent)
    lia.derma.scrollPanel(scrollpanel)
    return scrollpanel
end

function lia.derma.playerSelector(callback, validationFunc)
    if IsValid(lia.derma.menu_player_selector) then lia.derma.menu_player_selector:Remove() end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(340, 398)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowAnimation()
    local contentPanel = vgui.Create("liaBasePanel", frame)
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(8, 0, 8, 8)
    local scrollPanel = vgui.Create("liaScrollPanel", contentPanel)
    scrollPanel:Dock(FILL)
    lia.derma.scrollPanel(scrollPanel)
    local function createPlayerCard(player)
        local card = vgui.Create("liaButton", scrollPanel)
        card:Dock(TOP)
        card:DockMargin(0, 5, 0, 0)
        card:SetTall(44)
        card:SetText("")
        card.DoClick = function()
            if IsValid(player) and (not validationFunc or validationFunc(player)) then callback(player) end
            frame:Remove()
        end

        card.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, lia.color.theme.panel_alpha[1])
            if not IsValid(player) then
                draw.SimpleText(L("offlineStatus"), "Fated.18", 50, h * 0.5, Color(210, 65, 65), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                return
            end

            draw.SimpleText(player:Name(), "Fated.18", 50, 6, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local group = player:GetUserGroup() or "user"
            group = string.upper(string.sub(group, 1, 1)) .. string.sub(group, 2)
            draw.SimpleText(group, "Fated.14", 50, h - 6, lia.color.theme.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(player:Ping() .. " " .. L("player_ping"), "Fated.16", w - 20, h - 6, lia.color.theme.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            local statusColor = team.GetColor(player:Team()) or Color(120, 180, 70)
            draw.RoundedBox(50, w - 30, 6, 24, 24, statusColor)
        end

        local avatar = vgui.Create("AvatarImage", card)
        avatar:SetSize(32, 32)
        avatar:SetPos(6, 6)
        if IsValid(player) then avatar:SetSteamID(player:SteamID64(), 64) end
        return card
    end

    for _, player in player.iterator do
        createPlayerCard(player)
    end

    local btnClose = vgui.Create("liaButton", frame)
    btnClose:Dock(BOTTOM)
    btnClose:DockMargin(16, 8, 16, 12)
    btnClose:SetTall(36)
    btnClose:SetText(L("close"))
    btnClose.DoClick = function() frame:Remove() end
    lia.derma.menu_player_selector = frame
    return frame
end

function lia.derma.textBox(title, description, callback)
    if not IsValid(lia.derma.menu_text_box) then
        local frame = vgui.Create("liaFrame")
        frame:SetSize(300, 134)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle(title)
        frame:DockPadding(12, 30, 12, 12)
        local entry = vgui.Create("liaEntry", frame)
        entry:Dock(TOP)
        entry:SetPlaceholder(description)
        entry:SetFont("Fated.16")
        local function applyFunc()
            callback(entry:GetValue())
            frame:Remove()
        end

        entry.OnEnter = function() applyFunc() end
        local btnAccept = vgui.Create("liaButton", frame)
        btnAccept:Dock(BOTTOM)
        btnAccept:SetTall(30)
        btnAccept:SetText(L("accept"))
        btnAccept.DoClick = function() applyFunc() end
        lia.derma.menu_text_box = frame
        return frame
    end
end
