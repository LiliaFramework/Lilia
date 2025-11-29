--[[
    Derma Library

    Advanced UI rendering and interaction system for the Lilia framework.
]]
--[[
    Overview:
        The derma library provides comprehensive UI rendering and interaction functionality for the Lilia framework. It handles advanced drawing operations including rounded rectangles, circles, shadows, blur effects, and gradients using custom shaders. The library offers a fluent API for creating complex UI elements with smooth animations, color pickers, player selectors, and various input dialogs. It includes utility functions for text rendering with shadows and outlines, entity text display, and menu positioning. The library operates primarily on the client side and provides both low-level drawing functions and high-level UI components for creating modern, visually appealing interfaces.
]]
lia.derma = lia.derma or {}
local color_disconnect = Color(210, 65, 65)
local color_bot = Color(70, 150, 220)
local color_online = Color(120, 180, 70)
local color_close = Color(210, 65, 65)
local color_accept = Color(44, 124, 62)
local color_target = Color(255, 255, 255, 200)
--[[
    Purpose:
        Creates a context menu at the current mouse cursor position

    When Called:
        When right-clicking or when a context menu is needed

    Parameters:
        None

    Returns:
        Panel - The created context menu panel

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Create a basic context menu
    local menu = lia.derma.dermaMenu()
    menu:AddOption("Option 1", function() print("Option 1 clicked") end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Create context menu with multiple options
    local menu = lia.derma.dermaMenu()
    menu:AddOption("Edit", function() editItem() end)
    menu:AddOption("Delete", function() deleteItem() end)
    menu:AddSpacer()
    menu:AddOption("Properties", function() showProperties() end)
    ```

    High Complexity:
    ```lua
    -- High: Create dynamic context menu based on conditions
    local menu = lia.derma.dermaMenu()
    if player:IsAdmin() then
        menu:AddOption("Admin Action", function() adminAction() end)
    end
    if item:CanUse() then
        menu:AddOption("Use Item", function() item:Use() end)
    end
    menu:AddOption("Inspect", function() inspectItem(item) end)
    ```
]]
function lia.derma.dermaMenu()
    if IsValid(lia.gui.menuDermaMenu) then lia.gui.menuDermaMenu:CloseMenu() end
    local mouseX, mouseY = input.GetCursorPos()
    local m = vgui.Create("liaDermaMenu")
    m:SetPos(mouseX, mouseY)
    lia.util.clampMenuPosition(m)
    lia.gui.menuDermaMenu = m
    return m
end

local function liaDermaIsSequential(tbl)
    if not istable(tbl) then return false end
    local i = 0
    for _ in pairs(tbl) do
        i = i + 1
        if tbl[i] == nil then return false end
    end
    return true
end

--[[
    Purpose:
        Creates a generic options menu that can display interaction/action menus or arbitrary option lists

    When Called:
        When displaying a menu with selectable options (interactions, actions, or custom options)

    Parameters:
        - rawOptions (table): Options to display. Can be:
            * Dictionary table (keyed by option ID) for interaction/action menus
            * Sequential array of option tables for custom menus
        - config (table, optional): Configuration options including:
            - mode (string, optional): "interaction", "action", or "custom" (defaults to "custom")
            - title (string, optional): Menu title text
            - closeKey (number, optional): Key code that closes menu when released
            - netMsg (string, optional): Network message name for server-only options
            - preFiltered (boolean, optional): Whether options are already filtered (defaults to false)
            - entity (Entity, optional): Target entity for interaction mode
            - resolveEntity (boolean, optional): Whether to resolve traced entity (defaults to true for non-custom modes)
            - emitHooks (boolean, optional): Whether to emit InteractionMenuOpened/Closed hooks (defaults to true for non-custom modes)
            - registryKey (string, optional): Key for storing menu in lia.gui (defaults to "InteractionMenu" or "OptionsMenu")
            - fadeSpeed (number, optional): Animation fade speed in seconds (defaults to 0.05)
            - frameW (number, optional): Frame width in pixels (defaults to 450)
            - frameH (number, optional): Frame height in pixels (auto-calculated if not provided)
            - entryH (number, optional): Height of each option button (defaults to 30)
            - maxHeight (number, optional): Maximum frame height (defaults to 60% of screen height)
            - titleHeight (number, optional): Title label height (defaults to 36 or 16 based on mode)
            - titleOffsetY (number, optional): Y offset for title (defaults to 2)
            - verticalGap (number, optional): Vertical spacing between title and scroll area (defaults to 24)
            - screenPadding (number, optional): Screen padding for frame positioning (defaults to 15% of screen width)
            - x (number, optional): Custom X position (auto-calculated if not provided)
            - y (number, optional): Custom Y position (auto-calculated if not provided)
            - titleFont (string, optional): Font for title text (defaults to "LiliaFont.17")
            - titleColor (Color, optional): Color for title text (defaults to color_white)
            - buttonFont (string, optional): Font for option buttons (defaults to "LiliaFont.17")
            - buttonTextColor (Color, optional): Color for button text (defaults to color_white)
            - closeOnSelect (boolean, optional): Whether to close menu when option is selected (defaults to true)
            - timerName (string, optional): Name for auto-close timer
            - autoCloseDelay (number, optional): Seconds until auto-close (defaults to 30, 0 to disable)

    Returns:
        Panel - The created menu frame, or nil if no valid options or invalid client

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Display a basic custom options menu
    lia.derma.optionsMenu({
    {name = "Option 1", callback = function() print("Selected 1") end},
    {name = "Option 2", callback = function() print("Selected 2") end}
    })
    ```

    Medium Complexity:
    ```lua
    -- Medium: Custom menu with descriptions and custom positioning
    lia.derma.optionsMenu({
    {
    name = "Save Game",
    description = "Save your current progress",
    callback = function() saveGame() end
    },
    {
    name = "Load Game",
    description = "Load a previously saved game",
    callback = function() loadGame() end
    },
    {
    name = "Settings",
    description = "Open game settings",
    callback = function() openSettings() end
    }
    }, {
    title = "Main Menu",
    x = ScrW() / 2 - 225,
    y = ScrH() / 2 - 150,
    frameW = 450,
    closeOnSelect = false
    })
    ```

    High Complexity:
    ```lua
    -- High: Advanced menu with custom callbacks and network messaging
    lia.derma.optionsMenu({
    {
    name = "Radio Preset 1",
    description = "Switch to preset frequency 1",
    callback = function(client, entity, entry, frame)
    -- Custom callback with context
    lia.radio.setFrequency(100.0)
    client:notify("Switched to radio preset 1")
    end,
    passContext = true -- Pass client, entity, entry, frame to callback
    },
    {
    name = "Radio Preset 2",
    description = "Switch to preset frequency 2",
    serverOnly = true,
    netMessage = "liaRadioSetPreset",
    networkID = "preset2"
    },
    {
    name = "Custom Frequency",
    description = "Enter a custom frequency",
    callback = function()
    -- Open frequency input dialog
    lia.derma.requestString("Enter Frequency", "Enter radio frequency (MHz):", function(freq)
    local numFreq = tonumber(freq)
    if numFreq and numFreq >= 80 and numFreq <= 200 then
        lia.radio.setFrequency(numFreq)
        client:notify("Frequency set to " .. freq .. " MHz")
        else
            client:notify("Invalid frequency range (80-200 MHz)")
        end
    end)
    end
    }
    }, {
    title = "Radio Presets",
    mode = "custom",
    closeKey = KEY_R,
    fadeSpeed = 0.1,
    autoCloseDelay = 60
    })
    ```
]]
function lia.derma.optionsMenu(rawOptions, config)
    config = config or {}
    local mode = config.mode
    if mode ~= "interaction" and mode ~= "action" then mode = "custom" end
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local ent = config.entity
    if ent == nil and (mode ~= "custom" or config.resolveEntity ~= false) then
        if isfunction(client.getTracedEntity) then
            ent = client:getTracedEntity()
        else
            ent = NULL
        end
    end

    local netMsg = config.netMsg
    local preFiltered = config.preFiltered == true
    local emitHooks = config.emitHooks
    if emitHooks == nil then emitHooks = mode ~= "custom" end
    local registryKey = config.registryKey
    if registryKey == nil then registryKey = mode ~= "custom" and "InteractionMenu" or "OptionsMenu" end
    lia.gui = lia.gui or {}
    if registryKey and IsValid(lia.gui[registryKey]) then lia.gui[registryKey]:Remove() end
    local visible = {}
    local function addOption(id, option, overrideLabel)
        if not option then return end
        local label = overrideLabel or option.displayName or option.label or option.title or option.name or id
        visible[#visible + 1] = {
            id = id or label,
            label = label,
            opt = option
        }
    end

    if preFiltered then
        if liaDermaIsSequential(rawOptions) then
            for _, entry in ipairs(rawOptions) do
                if istable(entry) then addOption(entry.id or entry.name or tostring(), entry.opt or entry, entry.label) end
            end
        else
            for id, option in pairs(rawOptions) do
                addOption(id, option)
            end
        end
    elseif mode == "interaction" then
        if not IsValid(ent) then return end
        for id, option in pairs(rawOptions or {}) do
            if option.type == "interaction" and lia.playerinteract and lia.playerinteract.isWithinRange(client, ent, option.range) then
                local targetType = option.target or "player"
                local isPlayerTarget = ent:IsPlayer()
                local targetMatches = targetType == "any" or targetType == "player" and isPlayerTarget or targetType == "entity" and not isPlayerTarget
                if targetMatches then
                    local shouldShow = true
                    if option.shouldShow then shouldShow = option.shouldShow(client, ent) end
                    if shouldShow then addOption(id, option) end
                end
            end
        end
    elseif mode == "action" then
        for id, option in pairs(rawOptions or {}) do
            if option.type == "action" and (not option.shouldShow or option.shouldShow(client)) then addOption(id, option) end
        end
    else
        if liaDermaIsSequential(rawOptions) then
            for index, option in ipairs(rawOptions) do
                if istable(option) then
                    local id = option.identifier or option.id or option.name or tostring(index)
                    addOption(id, option)
                end
            end
        else
            for id, option in pairs(rawOptions or {}) do
                if istable(option) then addOption(option.identifier or option.id or id, option) end
            end
        end
    end

    if #visible == 0 then return end
    local optionsList
    if mode ~= "custom" and lia.playerinteract and lia.playerinteract.getCategorizedOptions then
        optionsList = lia.playerinteract.getCategorizedOptions(visible)
    else
        optionsList = visible
    end

    local fadeSpeed = config.fadeSpeed or 0.05
    local frameW = config.frameW or 550
    local entryH = config.entryH or 26
    local titleH = config.titleHeight or 16
    local titleY = config.titleOffsetY or 4
    local gap = config.verticalGap or 12
    local totalHeight = titleH + titleY + gap + 14
    for _, entry in ipairs(optionsList) do
        totalHeight = totalHeight + entryH + (entry.isCategory and 4 or 0)
    end

    local frameH = config.frameH
    if not frameH then
        if mode == "interaction" then
            frameH = totalHeight
        else
            local maxHeight = config.maxHeight or ScrH() * 0.6
            frameH = math.min(totalHeight, maxHeight)
        end
    end

    local padding = config.screenPadding or ScrW() * 0.15
    local xPos = config.x
    if xPos == nil then xPos = ScrW() - frameW - padding end
    local yPos = config.y
    if yPos == nil then yPos = (ScrH() - frameH) / 2 end
    local titleText = config.title
    if not titleText then
        if mode == "interaction" then
            titleText = L("interactionMenu")
        elseif mode == "action" then
            titleText = L("personalActions")
        else
            titleText = L("options")
        end
    end

    local frame = vgui.Create("DPanel")
    frame:SetSize(frameW, frameH)
    frame:SetPos(xPos, yPos)
    frame:MakePopup()
    frame:SetDrawOnTop(true)
    frame:SetZPos(10000)
    frame:DockPadding(6, 7, 6, 7)
    frame:SetAlpha(0)
    frame:AlphaTo(255, fadeSpeed)
    function frame:Paint(w, h)
        local theme = lia.color.theme
        local bgColor = theme and theme.background_alpha or Color(34, 34, 34, 210)
        local headerColor = theme and theme.header or Color(34, 34, 34, 210)
        draw.RoundedBox(6, 0, 0, w, h, bgColor)
        draw.RoundedBox(6, 0, 0, w, 24, headerColor)
        if titleText and titleText ~= "" then draw.SimpleText(titleText, "LiliaFont.16", 6, 4, theme and theme.header_text or Color(255, 255, 255)) end
    end

    if emitHooks then hook.Run("InteractionMenuOpened", frame) end
    local oldOnRemove = frame.OnRemove
    function frame:OnRemove()
        if oldOnRemove then oldOnRemove(self) end
        if emitHooks then hook.Run("InteractionMenuClosed") end
        if registryKey and lia.gui[registryKey] == self then lia.gui[registryKey] = nil end
    end

    local closeKey = config.closeKey
    if closeKey then
        function frame:Think()
            if not input.IsKeyDown(closeKey) then self:Remove() end
        end
    end

    local timerName = config.timerName or (mode ~= "custom" and "InteractionMenu_Frame_Timer" or "OptionsMenu_Frame_Timer")
    local autoCloseDelay = config.autoCloseDelay
    if autoCloseDelay == nil then autoCloseDelay = 30 end
    if timerName and autoCloseDelay and autoCloseDelay > 0 then
        timer.Remove(timerName)
        timer.Create(timerName, autoCloseDelay, 1, function() if IsValid(frame) then frame:Remove() end end)
    end

    local scroll = frame:Add("liaScrollPanel")
    scroll:SetPos(0, 24)
    scroll:SetSize(frameW, frameH - 24)
    scroll.Paint = function(_, w, h)
        local theme = lia.color.theme
        local panelColor = theme and theme.panel and theme.panel[1] or Color(50, 50, 50)
        draw.RoundedBox(8, 0, 0, w, h, panelColor)
    end

    local layout = vgui.Create("DListLayout", scroll)
    layout:Dock(FILL)
    local buttonFont = config.buttonFont or "LiliaFont.17"
    local buttonTextColor = config.buttonTextColor or color_white
    local shouldCloseOnSelect = config.closeOnSelect
    if shouldCloseOnSelect == nil then shouldCloseOnSelect = true end
    for _, entry in ipairs(optionsList) do
        if entry.isCategory then
            local categoryPanel = vgui.Create("DPanel", layout)
            categoryPanel:SetTall(entryH + 4)
            categoryPanel:Dock(TOP)
            categoryPanel:DockMargin(4, 8, 4, 6)
            categoryPanel:SetPaintBackground(false)
            function categoryPanel:Paint(w, h)
                local theme = lia.color.theme
                local bgColor = theme and theme.category_header or Color(35, 45, 55, 180)
                local accentColor = entry.color or (theme and theme.category_accent or Color(100, 150, 200, 255))
                local textColor = theme and theme.text or color_white
                lia.derma.rect(0, 0, w, h):Rad(10):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
                surface.SetDrawColor(accentColor)
                surface.DrawRect(0, 0, 4, h)
                surface.SetDrawColor(Color(255, 255, 255, 20))
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                local displayText = entry.name or ""
                local localized = L(displayText)
                if localized and localized ~= "" then displayText = localized end
                draw.SimpleText(displayText, "LiliaFont.17", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            layout:Add(categoryPanel)
        else
            local btn = vgui.Create("liaButton", layout)
            btn:SetTall(entryH)
            btn:Dock(TOP)
            btn:DockMargin(8, 2, 8, 2)
            local displayText = entry.label or entry.id or ""
            if entry.opt and entry.opt.localized ~= false and L then
                local localized = L(displayText)
                if localized and localized ~= "" then displayText = localized end
            end

            btn:SetText(displayText)
            btn:SetFont(buttonFont)
            btn:SetTextColor(entry.opt and entry.opt.textColor or buttonTextColor)
            btn:SetContentAlignment(5)
            local description = entry.opt and (entry.opt.description or entry.opt.desc)
            if isstring(description) and description ~= "" then
                if entry.opt.localizedDescription ~= false and L then description = L(description) end
                btn:SetTooltip(description)
            end

            btn.DoClick = function()
                if shouldCloseOnSelect then frame:AlphaTo(0, fadeSpeed, 0, function() if IsValid(frame) then frame:Remove() end end) end
                local optionData = entry.opt or {}
                local callback = optionData.callback or optionData.onRun
                local function runOptionCallback()
                    if not callback or optionData.serverOnly then return end
                    if mode == "interaction" then
                        if not IsValid(ent) then return end
                        local target = ent
                        if ent:IsPlayer() and ent:IsBot() and client:Team() == FACTION_STAFF then target = client end
                        callback(client, target)
                        return
                    end

                    if mode == "action" then
                        callback(client, ent)
                        return
                    end

                    local passContext = optionData.passContext
                    if passContext == true then
                        callback(client, ent, entry, frame)
                        return
                    end

                    if istable(passContext) then
                        callback(unpack(passContext))
                        return
                    end

                    callback()
                end

                runOptionCallback()
                local messageName = optionData.serverOnly and (optionData.netMessage or netMsg) or nil
                if messageName then
                    net.Start(messageName)
                    net.WriteString(optionData.networkID or entry.id)
                    net.WriteBool(mode == "interaction")
                    net.WriteEntity(IsValid(ent) and ent or Entity(0))
                    if isfunction(optionData.writePayload) then optionData.writePayload() end
                    net.SendToServer()
                end

                if isfunction(optionData.onSelect) then optionData.onSelect(client, ent, entry, frame) end
            end

            layout:Add(btn)
        end
    end

    if registryKey then lia.gui[registryKey] = frame end
    return frame
end

--[[
    Purpose:
        Opens a color picker dialog for selecting colors

    When Called:
        When user needs to select a color from a visual picker interface

    Parameters:
        func (function) - Callback function called when color is selected
        color_standart (Color, optional) - Default color to display

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Open color picker with callback
    lia.derma.requestColorPicker(function(color)
    print("Selected color:", color.r, color.g, color.b)
    end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Open color picker with default color
    local defaultColor = Color(255, 0, 0)
    lia.derma.requestColorPicker(function(color)
    myPanel:SetColor(color)
    end, defaultColor)
    ```

    High Complexity:
    ```lua
    -- High: Color picker with validation and multiple callbacks
    local currentColor = settings:GetColor("theme_color")
    lia.derma.requestColorPicker(function(color)
    if color:Distance(currentColor) > 50 then
        settings:SetColor("theme_color", color)
        updateTheme(color)
        notify("Theme color updated!")
    end
    end, currentColor)
    ```
]]
function lia.derma.requestColorPicker(func, color_standart)
    if IsValid(lia.gui.menuColorPicker) then lia.gui.menuColorPicker:Remove() end
    local selected_color = color_standart or Color(255, 255, 255)
    local hue = 0
    local saturation = 1
    local value = 1
    if color_standart then
        local r, g, b = color_standart.r / 255, color_standart.g / 255, color_standart.b / 255
        local h, s, v = ColorToHSV(Color(r * 255, g * 255, b * 255))
        hue = h
        saturation = s
        value = v
    end

    lia.gui.menuColorPicker = vgui.Create("liaFrame")
    lia.gui.menuColorPicker:SetSize(300, 378)
    lia.gui.menuColorPicker:Center()
    lia.gui.menuColorPicker:MakePopup()
    lia.gui.menuColorPicker:SetTitle("")
    lia.gui.menuColorPicker:SetCenterTitle(L("colorPicker"))
    local container = vgui.Create("Panel", lia.gui.menuColorPicker)
    container:Dock(FILL)
    container:DockMargin(10, 10, 10, 10)
    container.Paint = nil
    local preview = vgui.Create("Panel", container)
    preview:Dock(TOP)
    preview:SetTall(40)
    preview:DockMargin(0, 0, 0, 10)
    preview.Paint = function(_, w, h)
        lia.derma.rect(2, 2, w - 4, h - 4):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        lia.derma.rect(2, 2, w - 4, h - 4):Rad(16):Color(selected_color):Shape(lia.derma.SHAPE_IOS):Draw()
    end

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
            lia.websound.playButtonSound()
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
            selected_color = HSVToColor(hue, saturation, value)
        end
    end

    colorField.Paint = function(_, w, h)
        local segments = 80
        local segmentSize = w / segments
        lia.derma.rect(0, 0, w, h):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
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

        lia.derma.circle(colorCursor.x, colorCursor.y, 12):Outline(2):Color(color_target):Draw()
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
            lia.websound.playButtonSound()
        end
    end

    hueSlider.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingHue = false end end
    hueSlider.OnCursorMoved = function(self, x)
        if isDraggingHue then
            local w = self:GetWide()
            x = math.Clamp(x, 0, w)
            huePos = x
            hue = (x / w) * 360
            selected_color = HSVToColor(hue, saturation, value)
        end
    end

    hueSlider.Paint = function(_, w, h)
        local segments = 100
        local segmentWidth = w / segments
        lia.derma.rect(0, 0, w, h):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        for i = 0, segments - 1 do
            local hueVal = (i / segments) * 360
            local x = i * segmentWidth
            surface.SetDrawColor(HSVToColor(hueVal, 1, 1))
            surface.DrawRect(x, 1, segmentWidth + 1, h - 2)
        end

        lia.derma.rect(huePos - 2, 0, 4, h):Color(color_target):Draw()
    end

    local rgbContainer = vgui.Create("Panel", container)
    rgbContainer:Dock(TOP)
    rgbContainer:SetTall(60)
    rgbContainer:DockMargin(0, 0, 0, 10)
    rgbContainer.Paint = nil
    local btnContainer = vgui.Create("Panel", container)
    btnContainer:Dock(BOTTOM)
    btnContainer:SetTall(30)
    btnContainer.Paint = nil
    local btnClose = vgui.Create("liaButton", btnContainer)
    btnClose:Dock(LEFT)
    btnClose:SetWide(90)
    btnClose:SetTxt(L("cancel"))
    btnClose:SetColorHover(color_close)
    btnClose.DoClick = function()
        btnClose.BaseClass.DoClick(btnClose)
        lia.gui.menuColorPicker:Remove()
    end

    local btnSelect = vgui.Create("liaButton", btnContainer)
    btnSelect:Dock(RIGHT)
    btnSelect:SetWide(90)
    btnSelect:SetTxt(L("select"))
    btnSelect:SetColorHover(color_accept)
    btnSelect.DoClick = function()
        btnSelect.BaseClass.DoClick(btnSelect)
        func(selected_color)
        lia.gui.menuColorPicker:Remove()
    end

    timer.Simple(0, function()
        if IsValid(colorField) and IsValid(hueSlider) then
            colorCursor.x = saturation * colorField:GetWide()
            colorCursor.y = (1 - value) * colorField:GetTall()
            huePos = (hue / 360) * hueSlider:GetWide()
        end
    end)

    timer.Simple(0.1, function() lia.gui.menuColorPicker:SetAlpha(255) end)
end

--[[
    Purpose:
        Creates a radial menu interface with circular option selection

    When Called:
        When user needs to select from multiple options in a circular menu format

    Parameters:
        options (table, optional) - Configuration table with the following optional fields:
            radius (number) - Outer radius of the radial menu (default: 280)
            inner_radius (number) - Inner radius of the radial menu (default: 96)
            disable_background (boolean) - Whether to disable the background overlay (default: false)
            hover_sound (string) - Sound file to play on hover (default: "ratio_button.wav")
            scale_animation (boolean) - Whether to enable scale animation on open (default: true)

    Returns:
        Panel - The created radial menu panel with methods for adding options

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Create a basic radial menu
    local menu = lia.derma.radialMenu()
    menu:AddOption("Option 1", function() print("Option 1 selected") end)
    menu:AddOption("Option 2", function() print("Option 2 selected") end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Create radial menu with icons and descriptions
    local menu = lia.derma.radialMenu()
    menu:AddOption("Edit", function() editItem() end, "icon16/pencil.png", "Edit this item")
    menu:AddOption("Delete", function() deleteItem() end, "icon16/delete.png", "Delete this item")
    menu:AddOption("Copy", function() copyItem() end, "icon16/copy.png", "Copy this item")
    ```

    High Complexity:
    ```lua
    -- High: Create radial menu with custom options and submenus
    local options = {
    radius = 320,
    inner_radius = 120,
    hover_sound = "ui/buttonclick.wav",
    scale_animation = true
    }
    local menu = lia.derma.radialMenu(options)

    -- Add main options
    menu:AddOption("Actions", nil, "icon16/gear.png", "Perform actions", nil)

    -- Create submenu
    local submenu = menu:CreateSubMenu("Actions", "Choose an action")
    submenu:AddOption("Attack", function() attackTarget() end, "icon16/sword.png", "Attack target")
    submenu:AddOption("Defend", function() defendPosition() end, "icon16/shield.png", "Defend position")

    -- Add submenu option
    menu:AddSubMenuOption("Actions", submenu, "icon16/gear.png", "Access action menu")
    ```

    Panel Methods:
        - AddOption(text, func, icon, desc, submenu) - Adds an option to the menu
        - CreateSubMenu(title, desc) - Creates a submenu for nested options
        - AddSubMenuOption(text, submenu, icon, desc) - Adds a submenu option
        - SetCenterText(title, desc) - Sets the center text and description
    - Remove() - Closes and removes the menu
]]
function lia.derma.radialMenu(options)
    if IsValid(lia.gui.menu_radial) then lia.gui.menu_radial:Remove() end
    local m = vgui.Create("liaRadialPanel")
    m:Init(options)
    lia.gui.menu_radial = m
    return m
end

--[[
    Purpose:
        Opens a player selection dialog showing all connected players

    When Called:
        When user needs to select a player from a list

    Parameters:
        do_click (function) - Callback function called when player is selected

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Open player selector with callback
    lia.derma.requestPlayerSelector(function(player)
    print("Selected player:", player:Name())
    end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Player selector with validation
    lia.derma.requestPlayerSelector(function(player)
    if IsValid(player) and player:IsPlayer() then
        sendMessage(player, "Hello!")
    end
    end)
    ```

    High Complexity:
    ```lua
    -- High: Player selector with admin checks and multiple actions
    lia.derma.requestPlayerSelector(function(player)
    if not IsValid(player) then return end

        local menu = lia.derma.dermaMenu()
        menu:AddOption("Teleport", function() teleportToPlayer(player) end)
        menu:AddOption("Spectate", function() spectatePlayer(player) end)
        if player:IsAdmin() then
            menu:AddOption("Admin Panel", function() openAdminPanel(player) end)
        end
        menu:Open()
    end)
    ```
]]
function lia.derma.requestPlayerSelector(do_click)
    if IsValid(lia.gui.menuPlayerSelector) then lia.gui.menuPlayerSelector:Remove() end
    lia.gui.menuPlayerSelector = vgui.Create("liaFrame")
    lia.gui.menuPlayerSelector:SetSize(340, 398)
    lia.gui.menuPlayerSelector:Center()
    lia.gui.menuPlayerSelector:MakePopup()
    lia.gui.menuPlayerSelector:SetTitle("")
    lia.gui.menuPlayerSelector:SetCenterTitle(L("playerSelector"))
    lia.gui.menuPlayerSelector:ShowAnimation()
    local contentPanel = vgui.Create("Panel", lia.gui.menuPlayerSelector)
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(8, 0, 8, 8)
    lia.gui.menuPlayerSelector.sp = vgui.Create("liaScrollPanel", contentPanel)
    lia.gui.menuPlayerSelector.sp:Dock(FILL)
    local CARD_HEIGHT = 44
    local AVATAR_SIZE = 32
    local AVATAR_X = 14
    local function CreatePlayerCard(pl)
        local card = vgui.Create("DButton", lia.gui.menuPlayerSelector.sp)
        card:Dock(TOP)
        card:DockMargin(0, 5, 0, 0)
        card:SetTall(CARD_HEIGHT)
        card:SetText("")
        card.hover_status = 0
        card.OnCursorEntered = function(self) self:SetCursor("hand") end
        card.OnCursorExited = function(self) self:SetCursor("arrow") end
        card.Think = function(self)
            if self:IsHovered() then
                self.hover_status = math.Clamp(self.hover_status + 4 * FrameTime(), 0, 1)
            else
                self.hover_status = math.Clamp(self.hover_status - 8 * FrameTime(), 0, 1)
            end
        end

        card.DoClick = function()
            if IsValid(pl) then
                card.BaseClass.DoClick(card)
                do_click(pl)
            end

            lia.gui.menuPlayerSelector:Remove()
        end

        card.Paint = function(self, w, h)
            lia.derma.rect(0, 0, w, h):Rad(10):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw()
            if self.hover_status > 0 then lia.derma.rect(0, 0, w, h):Rad(10):Color(Color(0, 0, 0, 40 * self.hover_status)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local infoX = AVATAR_X + AVATAR_SIZE + 10
            if not IsValid(pl) then
                draw.SimpleText(L("disconnected"), "LiliaFont.18", infoX, h * 0.5, color_disconnect, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                return
            end

            draw.SimpleText(pl:Name(), "LiliaFont.18", infoX, 6, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local group = pl:GetUserGroup() or "user"
            group = string.upper(string.sub(group, 1, 1)) .. string.sub(group, 2)
            draw.SimpleText(group, "LiliaFont.14", infoX, h - 6, lia.color.theme.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(pl:Ping() .. " " .. L("ping"), "LiliaFont.16", w - 20, h - 6, lia.color.theme.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            if pl:IsBot() then
                statusColor = color_bot
            else
                statusColor = color_online
            end

            lia.derma.circle(w - 24, 14, 24):Color(statusColor):Draw()
        end

        local avatarImg = vgui.Create("AvatarImage", card)
        avatarImg:SetSize(AVATAR_SIZE, AVATAR_SIZE)
        avatarImg:SetPos(AVATAR_X, (CARD_HEIGHT - AVATAR_SIZE) * 0.5)
        avatarImg:SetPlayer(pl, 64)
        avatarImg:SetMouseInputEnabled(false)
        avatarImg:SetKeyboardInputEnabled(false)
        avatarImg.PaintOver = function() end
        avatarImg:SetPos(AVATAR_X, (card:GetTall() - AVATAR_SIZE) * 0.5)
        return card
    end

    for _, pl in player.Iterator() do
        CreatePlayerCard(pl)
    end

    lia.gui.menuPlayerSelector.btn_close = vgui.Create("liaButton", lia.gui.menuPlayerSelector)
    lia.gui.menuPlayerSelector.btn_close:Dock(BOTTOM)
    lia.gui.menuPlayerSelector.btn_close:DockMargin(16, 8, 16, 12)
    lia.gui.menuPlayerSelector.btn_close:SetTall(36)
    lia.gui.menuPlayerSelector.btn_close:SetTxt(L("close"))
    lia.gui.menuPlayerSelector.btn_close:SetColorHover(color_disconnect)
    lia.gui.menuPlayerSelector.btn_close.DoClick = function() lia.gui.menuPlayerSelector:Remove() end
end

local bit_band = bit.band
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local math_min = math.min
local math_max = math.max
local DisableClipping = DisableClipping
local SHADERS_VERSION = "1757877956"
local SHADERS_GMA = [========[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]========]
do
    local DECODED_SHADERS_GMA = util.Base64Decode(SHADERS_GMA)
    if not DECODED_SHADERS_GMA or #DECODED_SHADERS_GMA == 0 then return end
    file.Write("rndx_shaders_" .. SHADERS_VERSION .. ".gma", DECODED_SHADERS_GMA)
    game.MountGMA("data/rndx_shaders_" .. SHADERS_VERSION .. ".gma")
end

local function getShader(name)
    return SHADERS_VERSION:gsub("%.", "_") .. "_" .. name
end

local blurRt = GetRenderTargetEx("lia.derma" .. SHADERS_VERSION .. SysTime(), 1024, 1024, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(2, 256, 4, 8), 0, IMAGE_FORMAT_BGRA8888)
local newFlag
do
    local flags_n = -1
    function newFlag()
        flags_n = flags_n + 1
        return 2 ^ flags_n
    end
end

local NO_TL, NO_TR, NO_BL, NO_BR = newFlag(), newFlag(), newFlag(), newFlag()
local SHAPE_CIRCLE, SHAPE_FIGMA, SHAPE_IOS = newFlag(), newFlag(), newFlag()
local BLUR = newFlag()
local shader_mat = [==[
screenspace_general
{
	$pixshader ""
	$vertexshader ""
	$basetexture ""
	$texture1    ""
	$texture2    ""
	$texture3    ""
	$ignorez            1
	$vertexcolor        1
	$vertextransform    1
	"<dx90"
	{
		$no_draw 1
	}
	$copyalpha                 0
	$alpha_blend_color_overlay 0
	$alpha_blend               1
	$linearwrite               1
	$linearread_basetexture    1
	$linearread_texture1       1
	$linearread_texture2       1
	$linearread_texture3       1
}
]==]
local matrixes = {}
local function createShaderMat(name, opts)
    assert(name and isstring(name), L("createShaderMatTexMustBeString"))
    local key_values = util.KeyValuesToTable(shader_mat, false, true)
    if opts then
        for k, v in pairs(opts) do
            key_values[k] = v
        end
    end

    local mat = CreateMaterial("rndx_shaders1" .. name .. SysTime(), "screenspace_general", key_values)
    matrixes[mat] = Matrix()
    return mat
end

local roundedMat = createShaderMat("rounded", {
    ["$pixshader"] = getShader("rndx_rounded_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
})

local roundedTextureMat = createShaderMat("rounded_texture", {
    ["$pixshader"] = getShader("rndx_rounded_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
    ["$basetexture"] = "vgui/white",
})

local blurVertical = "$c0_x"
local roundedBlurMat = createShaderMat("blur_horizontal", {
    ["$pixshader"] = getShader("rndx_rounded_blur_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
    ["$basetexture"] = blurRt:GetName(),
    ["$texture1"] = "_rt_FullFrameFB",
})

local shadowsMat = createShaderMat("rounded_shadows", {
    ["$pixshader"] = getShader("rndx_shadows_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
})

local shadowsBlurMat = createShaderMat("shadows_blur_horizontal", {
    ["$pixshader"] = getShader("rndx_shadows_blur_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
    ["$basetexture"] = blurRt:GetName(),
    ["$texture1"] = "_rt_FullFrameFB",
})

local shapes = {
    [SHAPE_CIRCLE] = 2,
    [SHAPE_FIGMA] = 2.2,
    [SHAPE_IOS] = 4,
}

local defaultShape = SHAPE_FIGMA
local materialSetTexture = roundedMat.SetTexture
local materialSetMatrix = roundedMat.SetMatrix
local materialSetFloat = roundedMat.SetFloat
local matrixSetUnpacked = Matrix().SetUnpacked
local MAT
local X, Y, W, H
local TL, TR, BL, BR
local TEXTURE
local USING_BLUR, BLUR_INTENSITY
local COL_R, COL_G, COL_B, COL_A
local SHAPE, OUTLINE_THICKNESS
local START_ANGLE, END_ANGLE, ROTATION
local CLIP_PANEL
local SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY
local function resetParams()
    MAT = nil
    X, Y, W, H = 0, 0, 0, 0
    TL, TR, BL, BR = 0, 0, 0, 0
    TEXTURE = nil
    USING_BLUR, BLUR_INTENSITY = false, 1.0
    COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
    SHAPE, OUTLINE_THICKNESS = shapes[defaultShape], -1
    START_ANGLE, END_ANGLE, ROTATION = 0, 360, 0
    CLIP_PANEL = nil
    SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY = false, 0, 0
end

do
    local HUGE = math.huge
    local function nzr(x)
        if x ~= x or x < 0 then return 0 end
        local lim = math_min(W, H)
        if x == HUGE then return lim end
        return x
    end

    local function clamp0(x)
        return x < 0 and 0 or x
    end

    function normalizeCornerRadii()
        local tl, tr, bl, br = nzr(TL), nzr(TR), nzr(BL), nzr(BR)
        local k = math_max(1, (tl + tr) / W, (bl + br) / W, (tl + bl) / H, (tr + br) / H)
        if k > 1 then
            local inv = 1 / k
            tl, tr, bl, br = tl * inv, tr * inv, bl * inv, br * inv
        end
        return clamp0(tl), clamp0(tr), clamp0(bl), clamp0(br)
    end
end

local function setupDraw()
    local tl, tr, bl, br = normalizeCornerRadii()
    local matrix = matrixes[MAT]
    matrixSetUnpacked(matrix, bl, W, OUTLINE_THICKNESS or -1, END_ANGLE, br, H, SHADOW_INTENSITY, ROTATION, tr, SHAPE, BLUR_INTENSITY or 1.0, 0, tl, TEXTURE and 1 or 0, START_ANGLE, 0)
    materialSetMatrix(MAT, "$viewprojmat", matrix)
    if COL_R then surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A) end
    surface_SetMaterial(MAT)
end

local manualColor = newFlag()
local defaultDrawFlags = defaultShape
local function drawRounded(x, y, w, h, col, flags, tl, tr, bl, br, texture, thickness)
    if col and col.a == 0 then return end
    resetParams()
    if not flags then flags = defaultDrawFlags end
    local using_blur = bit_band(flags, BLUR) ~= 0
    if using_blur then return lia.derma.drawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness) end
    MAT = roundedMat
    if texture then
        MAT = roundedTextureMat
        materialSetTexture(MAT, "$basetexture", texture)
        TEXTURE = texture
    end

    W, H = w, h
    TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0, bit_band(flags, NO_TR) == 0 and tr or 0, bit_band(flags, NO_BL) == 0 and bl or 0, bit_band(flags, NO_BR) == 0 and br or 0
    SHAPE = shapes[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or shapes[defaultShape]
    OUTLINE_THICKNESS = thickness
    if bit_band(flags, manualColor) ~= 0 and not col then
        COL_R = nil
    elseif col then
        COL_R, COL_G, COL_B, COL_A = col.r, col.g, col.b, col.a
    else
        COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
    end

    setupDraw()
    return surface_DrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)
end

--[[
    Purpose:
        Draws a rounded rectangle with specified parameters

    When Called:
        When rendering UI elements that need rounded corners

    Parameters:
        radius (number) - Corner radius for all corners
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height
        col (Color, optional) - Color to draw with
        flags (number, optional) - Drawing flags for customization

    Returns:
        boolean - Success status

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw a basic rounded rectangle
    lia.derma.draw(8, 100, 100, 200, 100, Color(255, 0, 0))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom flags and color
    local flags = lia.derma.SHAPE_IOS
    lia.derma.draw(12, 50, 50, 300, 150, Color(0, 255, 0, 200), flags)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic drawing with conditions
    local radius = isHovered and 16 or 8
    local color = isSelected and Color(255, 255, 0) or Color(100, 100, 100)
    local flags = bit.bor(lia.derma.SHAPE_FIGMA, lia.derma.BLUR)
    lia.derma.draw(radius, x, y, w, h, color, flags)
    ```
]]
function lia.derma.draw(radius, x, y, w, h, col, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius)
end

--[[
    Purpose:
        Draws a rounded rectangle with an outline border

    When Called:
        When rendering UI elements that need outlined rounded corners

    Parameters:
        radius (number) - Corner radius for all corners
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height
        col (Color, optional) - Color to draw with
        thickness (number, optional) - Outline thickness (default: 1)
        flags (number, optional) - Drawing flags for customization

    Returns:
        boolean - Success status

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw outlined rounded rectangle
    lia.derma.drawOutlined(8, 100, 100, 200, 100, Color(255, 0, 0), 2)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom thickness and flags
    local flags = lia.derma.SHAPE_IOS
    lia.derma.drawOutlined(12, 50, 50, 300, 150, Color(0, 255, 0), 3, flags)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic outlined drawing with hover effects
    local thickness = isHovered and 3 or 1
    local color = isActive and Color(255, 255, 0) or Color(100, 100, 100)
    lia.derma.drawOutlined(radius, x, y, w, h, color, thickness, flags)
    ```
]]
function lia.derma.drawOutlined(radius, x, y, w, h, col, thickness, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius, nil, thickness or 1)
end

--[[
    Purpose:
        Draws a rounded rectangle with a texture applied

    When Called:
        When rendering UI elements that need textured rounded backgrounds

    Parameters:
        radius (number) - Corner radius for all corners
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height
        col (Color, optional) - Color tint to apply
        texture (ITexture) - Texture to draw
        flags (number, optional) - Drawing flags for customization

    Returns:
        boolean - Success status

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw textured rounded rectangle
    local texture = Material("icon16/user.png"):GetTexture("$basetexture")
    lia.derma.drawTexture(8, 100, 100, 200, 100, Color(255, 255, 255), texture)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with color tint and custom flags
    local texture = Material("gui/button.png"):GetTexture("$basetexture")
    local flags = lia.derma.SHAPE_IOS
    lia.derma.drawTexture(12, 50, 50, 300, 150, Color(200, 200, 200), texture, flags)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic textured drawing with multiple textures
    local texture = isHovered and hoverTexture or normalTexture
    local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
    lia.derma.drawTexture(radius, x, y, w, h, color, texture, flags)
    ```
]]
function lia.derma.drawTexture(radius, x, y, w, h, col, texture, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius, texture)
end

--[[
    Purpose:
        Draws a rounded rectangle with a material applied

    When Called:
        When rendering UI elements that need material-based rounded backgrounds

    Parameters:
        radius (number) - Corner radius for all corners
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height
        col (Color, optional) - Color tint to apply
        mat (IMaterial) - Material to draw
        flags (number, optional) - Drawing flags for customization

    Returns:
        boolean - Success status (if material has valid texture)

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw material-based rounded rectangle
    local mat = Material("gui/button.png")
    lia.derma.drawMaterial(8, 100, 100, 200, 100, Color(255, 255, 255), mat)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with color tint and validation
    local mat = Material("effects/fire_cloud1")
    if mat and mat:IsValid() then
        lia.derma.drawMaterial(12, 50, 50, 300, 150, Color(255, 200, 0), mat)
    end
    ```

    High Complexity:
    ```lua
    -- High: Dynamic material drawing with fallback
    local mat = getMaterialForState(currentState)
    if mat and mat:IsValid() then
        local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
        lia.derma.drawMaterial(radius, x, y, w, h, color, mat, flags)
        else
            -- Fallback to solid color
            lia.derma.draw(radius, x, y, w, h, fallbackColor, flags)
        end
    ```
]]
function lia.derma.drawMaterial(radius, x, y, w, h, col, mat, flags)
    local tex = mat:GetTexture("$basetexture")
    if tex then return lia.derma.drawTexture(radius, x, y, w, h, col, tex, flags) end
end

--[[
    Purpose:
        Draws a filled circle with specified parameters

    When Called:
        When rendering circular UI elements like buttons or indicators

    Parameters:
        x (number) - Center X position
        y (number) - Center Y position
        radius (number) - Circle radius
        col (Color, optional) - Color to draw with
        flags (number, optional) - Drawing flags for customization

    Returns:
        boolean - Success status

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw a basic circle
    lia.derma.drawCircle(100, 100, 50, Color(255, 0, 0))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw circle with custom flags
    local flags = lia.derma.SHAPE_CIRCLE
    lia.derma.drawCircle(200, 200, 75, Color(0, 255, 0, 200), flags)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic circle drawing with hover effects
    local radius = isHovered and 60 or 50
    local color = isActive and Color(255, 255, 0) or Color(100, 100, 100)
    lia.derma.drawCircle(x, y, radius, color, flags)
    ```
]]
function lia.derma.drawCircle(x, y, radius, col, flags)
    return lia.derma.draw(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, (flags or 0) + SHAPE_CIRCLE)
end

--[[
    Purpose:
        Draws a circle with an outline border

    When Called:
        When rendering circular UI elements that need outlined borders

    Parameters:
        x (number) - Center X position
        y (number) - Center Y position
        radius (number) - Circle radius
        col (Color, optional) - Color to draw with
        thickness (number, optional) - Outline thickness (default: 1)
        flags (number, optional) - Drawing flags for customization

    Returns:
        boolean - Success status

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw outlined circle
    lia.derma.drawCircleOutlined(100, 100, 50, Color(255, 0, 0), 2)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom thickness and flags
    local flags = lia.derma.SHAPE_CIRCLE
    lia.derma.drawCircleOutlined(200, 200, 75, Color(0, 255, 0), 3, flags)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic outlined circle with hover effects
    local thickness = isHovered and 3 or 1
    local color = isActive and Color(255, 255, 0) or Color(100, 100, 100)
    lia.derma.drawCircleOutlined(x, y, radius, color, thickness, flags)
    ```
]]
function lia.derma.drawCircleOutlined(x, y, radius, col, thickness, flags)
    return lia.derma.drawOutlined(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, thickness, (flags or 0) + SHAPE_CIRCLE)
end

--[[
    Purpose:
        Draws a circle with a texture applied

    When Called:
        When rendering circular UI elements that need textured backgrounds

    Parameters:
        x (number) - Center X position
        y (number) - Center Y position
        radius (number) - Circle radius
        col (Color, optional) - Color tint to apply
        texture (ITexture) - Texture to draw
        flags (number, optional) - Drawing flags for customization

    Returns:
        boolean - Success status

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw textured circle
    local texture = Material("icon16/user.png"):GetTexture("$basetexture")
    lia.derma.drawCircleTexture(100, 100, 50, Color(255, 255, 255), texture)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with color tint and custom flags
    local texture = Material("gui/button.png"):GetTexture("$basetexture")
    local flags = lia.derma.SHAPE_CIRCLE
    lia.derma.drawCircleTexture(200, 200, 75, Color(200, 200, 200), texture, flags)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic textured circle with multiple textures
    local texture = isHovered and hoverTexture or normalTexture
    local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
    lia.derma.drawCircleTexture(x, y, radius, color, texture, flags)
    ```
]]
function lia.derma.drawCircleTexture(x, y, radius, col, texture, flags)
    return lia.derma.drawTexture(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, texture, (flags or 0) + SHAPE_CIRCLE)
end

--[[
    Purpose:
        Draws a circle with a material applied

    When Called:
        When rendering circular UI elements that need material-based backgrounds

    Parameters:
        x (number) - Center X position
        y (number) - Center Y position
        radius (number) - Circle radius
        col (Color, optional) - Color tint to apply
        mat (IMaterial) - Material to draw
        flags (number, optional) - Drawing flags for customization

    Returns:
        boolean - Success status (if material has valid texture)

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw material-based circle
    local mat = Material("gui/button.png")
    lia.derma.drawCircleMaterial(100, 100, 50, Color(255, 255, 255), mat)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with color tint and validation
    local mat = Material("effects/fire_cloud1")
    if mat and mat:IsValid() then
        lia.derma.drawCircleMaterial(200, 200, 75, Color(255, 200, 0), mat)
    end
    ```

    High Complexity:
    ```lua
    -- High: Dynamic material circle with fallback
    local mat = getMaterialForState(currentState)
    if mat and mat:IsValid() then
        local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
        lia.derma.drawCircleMaterial(x, y, radius, color, mat, flags)
        else
            -- Fallback to solid color circle
            lia.derma.drawCircle(x, y, radius, fallbackColor, flags)
        end
    ```
]]
function lia.derma.drawCircleMaterial(x, y, radius, col, mat, flags)
    return lia.derma.drawMaterial(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, mat, (flags or 0) + SHAPE_CIRCLE)
end

local useShadowsBlur = false
local function drawBlur()
    if useShadowsBlur then
        MAT = shadowsBlurMat
    else
        MAT = roundedBlurMat
    end

    COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
    setupDraw()
    render_CopyRenderTargetToTexture(blurRt)
    materialSetFloat(MAT, blurVertical, 0)
    surface_DrawTexturedRect(X, Y, W, H)
    render_CopyRenderTargetToTexture(blurRt)
    materialSetFloat(MAT, blurVertical, 1)
    surface_DrawTexturedRect(X, Y, W, H)
end

--[[
    Purpose:
        Draws a blurred rounded rectangle using custom shaders

    When Called:
        When rendering UI elements that need blur effects

    Parameters:
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height
        flags (number, optional) - Drawing flags for customization
        tl (number, optional) - Top-left corner radius
        tr (number, optional) - Top-right corner radius
        bl (number, optional) - Bottom-left corner radius
        br (number, optional) - Bottom-right corner radius
        thickness (number, optional) - Outline thickness

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw blurred rectangle
    lia.derma.drawBlur(100, 100, 200, 100)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom corner radii and flags
    local flags = lia.derma.SHAPE_IOS
    lia.derma.drawBlur(50, 50, 300, 150, flags, 12, 12, 12, 12)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic blur with different corner radii
    local tl = isTopLeft and 16 or 8
    local tr = isTopRight and 16 or 8
    local bl = isBottomLeft and 16 or 8
    local br = isBottomRight and 16 or 8
    lia.derma.drawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
    ```
]]
function lia.derma.drawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
    resetParams()
    if not flags then flags = defaultDrawFlags end
    X, Y = x, y
    W, H = w, h
    TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0, bit_band(flags, NO_TR) == 0 and tr or 0, bit_band(flags, NO_BL) == 0 and bl or 0, bit_band(flags, NO_BR) == 0 and br or 0
    SHAPE = shapes[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or shapes[defaultShape]
    OUTLINE_THICKNESS = thickness
    drawBlur()
end

local function setupShadows()
    X = X - SHADOW_SPREAD
    Y = Y - SHADOW_SPREAD
    W = W + (SHADOW_SPREAD * 2)
    H = H + (SHADOW_SPREAD * 2)
    TL = TL + (SHADOW_SPREAD * 2)
    TR = TR + (SHADOW_SPREAD * 2)
    BL = BL + (SHADOW_SPREAD * 2)
    BR = BR + (SHADOW_SPREAD * 2)
end

local function drawShadows(r, g, b, a)
    if USING_BLUR then
        useShadowsBlur = true
        drawBlur()
        useShadowsBlur = false
    end

    MAT = shadowsMat
    if r == false then
        COL_R = nil
    else
        COL_R, COL_G, COL_B, COL_A = r, g, b, a
    end

    setupDraw()
    surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
end

--[[
    Purpose:
        Draws shadows for rounded rectangles with extensive customization

    When Called:
        When rendering UI elements that need shadow effects

    Parameters:
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height
        col (Color, optional) - Shadow color
        flags (number, optional) - Drawing flags for customization
        tl (number, optional) - Top-left corner radius
        tr (number, optional) - Top-right corner radius
        bl (number, optional) - Bottom-left corner radius
        br (number, optional) - Bottom-right corner radius
        spread (number, optional) - Shadow spread distance (default: 30)
        intensity (number, optional) - Shadow intensity (default: spread * 1.2)
        thickness (number, optional) - Outline thickness

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw basic shadow
    lia.derma.drawShadowsEx(100, 100, 200, 100, Color(0, 0, 0, 100))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom spread and intensity
    lia.derma.drawShadowsEx(50, 50, 300, 150, Color(0, 0, 0, 150), flags, 12, 12, 12, 12, 20, 25)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic shadow with different corner radii
    local spread = isHovered and 40 or 20
    local intensity = spread * 1.5
    lia.derma.drawShadowsEx(x, y, w, h, shadowColor, flags, tl, tr, bl, br, spread, intensity, thickness)
    ```
]]
function lia.derma.drawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
    if col and col.a == 0 then return end
    local OLD_CLIPPING_STATE = DisableClipping(true)
    resetParams()
    if not flags then flags = defaultDrawFlags end
    X, Y = x, y
    W, H = w, h
    SHADOW_SPREAD = spread or 30
    SHADOW_INTENSITY = intensity or SHADOW_SPREAD * 1.2
    TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0, bit_band(flags, NO_TR) == 0 and tr or 0, bit_band(flags, NO_BL) == 0 and bl or 0, bit_band(flags, NO_BR) == 0 and br or 0
    SHAPE = shapes[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or shapes[defaultShape]
    OUTLINE_THICKNESS = thickness
    setupShadows()
    USING_BLUR = bit_band(flags, BLUR) ~= 0
    if bit_band(flags, manualColor) == 0 then drawShadows(col and col.r or 0, col and col.g or 0, col and col.b or 0, col and col.a or 255) end
    DisableClipping(OLD_CLIPPING_STATE)
end

--[[
    Purpose:
        Draws shadows for rounded rectangles with uniform corner radius

    When Called:
        When rendering UI elements that need shadow effects with same corner radius

    Parameters:
        radius (number) - Corner radius for all corners
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height
        col (Color, optional) - Shadow color
        spread (number, optional) - Shadow spread distance (default: 30)
        intensity (number, optional) - Shadow intensity (default: spread * 1.2)
        flags (number, optional) - Drawing flags for customization

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw basic shadow with uniform radius
    lia.derma.drawShadows(8, 100, 100, 200, 100, Color(0, 0, 0, 100))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom spread and intensity
    lia.derma.drawShadows(12, 50, 50, 300, 150, Color(0, 0, 0, 150), 20, 25)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic shadow with hover effects
    local radius = isHovered and 16 or 8
    local spread = isHovered and 40 or 20
    local intensity = spread * 1.5
    lia.derma.drawShadows(radius, x, y, w, h, shadowColor, spread, intensity, flags)
    ```
]]
function lia.derma.drawShadows(radius, x, y, w, h, col, spread, intensity, flags)
    return lia.derma.drawShadowsEx(x, y, w, h, col, flags, radius, radius, radius, radius, spread, intensity)
end

--[[
    Purpose:
        Draws outlined shadows for rounded rectangles with uniform corner radius

    When Called:
        When rendering UI elements that need outlined shadow effects

    Parameters:
        radius (number) - Corner radius for all corners
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height
        col (Color, optional) - Shadow color
        thickness (number, optional) - Outline thickness (default: 1)
        spread (number, optional) - Shadow spread distance (default: 30)
        intensity (number, optional) - Shadow intensity (default: spread * 1.2)
        flags (number, optional) - Drawing flags for customization

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw outlined shadow
    lia.derma.drawShadowsOutlined(8, 100, 100, 200, 100, Color(0, 0, 0, 100), 2)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom thickness and spread
    lia.derma.drawShadowsOutlined(12, 50, 50, 300, 150, Color(0, 0, 0, 150), 3, 20, 25)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic outlined shadow with hover effects
    local thickness = isHovered and 3 or 1
    local spread = isHovered and 40 or 20
    local intensity = spread * 1.5
    lia.derma.drawShadowsOutlined(radius, x, y, w, h, shadowColor, thickness, spread, intensity, flags)
    ```
]]
function lia.derma.drawShadowsOutlined(radius, x, y, w, h, col, thickness, spread, intensity, flags)
    return lia.derma.drawShadowsEx(x, y, w, h, col, flags, radius, radius, radius, radius, spread, intensity, thickness or 1)
end

lia.derma.baseFuncs = {
    Rad = function(self, rad)
        TL, TR, BL, BR = rad, rad, rad, rad
        return self
    end,
    Radii = function(self, tl, tr, bl, br)
        TL, TR, BL, BR = tl or 0, tr or 0, bl or 0, br or 0
        return self
    end,
    Texture = function(self, texture)
        TEXTURE = texture
        return self
    end,
    Material = function(self, mat)
        if mat then
            local tex = mat:GetTexture("$basetexture")
            if tex then TEXTURE = tex end
        end
        return self
    end,
    Outline = function(self, thickness)
        OUTLINE_THICKNESS = thickness
        return self
    end,
    Shape = function(self, shape)
        SHAPE = shapes[shape] or 2.2
        return self
    end,
    Color = function(self, col_or_r, g, b, a)
        if isnumber(col_or_r) then
            COL_R, COL_G, COL_B, COL_A = col_or_r, g or 255, b or 255, a or 255
        else
            COL_R, COL_G, COL_B, COL_A = col_or_r.r, col_or_r.g, col_or_r.b, col_or_r.a
        end
        return self
    end,
    Blur = function(self, intensity)
        if not intensity then intensity = 1.0 end
        intensity = math_max(intensity, 0)
        USING_BLUR, BLUR_INTENSITY = true, intensity
        return self
    end,
    Rotation = function(self, angle)
        ROTATION = math.rad(angle or 0)
        return self
    end,
    StartAngle = function(self, angle)
        START_ANGLE = angle or 0
        return self
    end,
    EndAngle = function(self, angle)
        END_ANGLE = angle or 360
        return self
    end,
    Shadow = function(self, spread, intensity)
        SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY = true, spread or 30, intensity or (spread or 30) * 1.2
        return self
    end,
    Clip = function(self, pnl)
        CLIP_PANEL = pnl
        return self
    end,
    Flags = function(self, flags)
        flags = flags or 0
        if bit_band(flags, NO_TL) ~= 0 then TL = 0 end
        if bit_band(flags, NO_TR) ~= 0 then TR = 0 end
        if bit_band(flags, NO_BL) ~= 0 then BL = 0 end
        if bit_band(flags, NO_BR) ~= 0 then BR = 0 end
        local shape_flag = bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)
        if shape_flag ~= 0 then SHAPE = shapes[shape_flag] or shapes[defaultShape] end
        if bit_band(flags, BLUR) ~= 0 then USING_BLUR, BLUR_INTENSITY = true, 1.0 end
        if bit_band(flags, manualColor) ~= 0 then COL_R = nil end
        return self
    end,
}

lia.derma.Rect = {
    Rad = lia.derma.baseFuncs.Rad,
    Radii = lia.derma.baseFuncs.Radii,
    Texture = lia.derma.baseFuncs.Texture,
    Material = lia.derma.baseFuncs.Material,
    Outline = lia.derma.baseFuncs.Outline,
    Shape = lia.derma.baseFuncs.Shape,
    Color = lia.derma.baseFuncs.Color,
    Blur = lia.derma.baseFuncs.Blur,
    Rotation = lia.derma.baseFuncs.Rotation,
    StartAngle = lia.derma.baseFuncs.StartAngle,
    EndAngle = lia.derma.baseFuncs.EndAngle,
    Clip = lia.derma.baseFuncs.Clip,
    Shadow = lia.derma.baseFuncs.Shadow,
    Flags = lia.derma.baseFuncs.Flags,
    Draw = function()
        if not TEXTURE and not USING_BLUR and not SHADOW_ENABLED and SHAPE == shapes[defaultShape] and OUTLINE_THICKNESS == -1 and START_ANGLE == 0 and END_ANGLE == 360 and not ROTATION and not CLIP_PANEL then
            surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A)
            if TL > 0 then
                draw.RoundedBox(TL, X, Y, W, H, Color(COL_R, COL_G, COL_B, COL_A))
            else
                surface_DrawTexturedRect(X, Y, W, H)
            end
            return
        end

        if START_ANGLE == END_ANGLE then return end
        local OLD_CLIPPING_STATE
        if SHADOW_ENABLED or CLIP_PANEL then OLD_CLIPPING_STATE = DisableClipping(true) end
        if CLIP_PANEL then
            local sx, sy = CLIP_PANEL:LocalToScreen(0, 0)
            local sw, sh = CLIP_PANEL:GetSize()
            render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
        end

        if SHADOW_ENABLED then
            setupShadows()
            drawShadows(COL_R, COL_G, COL_B, COL_A)
        elseif USING_BLUR then
            drawBlur()
        else
            if TEXTURE then
                MAT = roundedTextureMat
                materialSetTexture(MAT, "$basetexture", TEXTURE)
            end

            setupDraw()
            surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
        end

        if CLIP_PANEL then render.SetScissorRect(0, 0, 0, 0, false) end
        if SHADOW_ENABLED or CLIP_PANEL then DisableClipping(OLD_CLIPPING_STATE) end
    end,
    GetMaterial = function()
        if SHADOW_ENABLED or USING_BLUR then error(L("shadowedBlurredRectangleError")) end
        if TEXTURE then
            MAT = roundedTextureMat
            materialSetTexture(MAT, "$basetexture", TEXTURE)
        end

        setupDraw()
        return MAT
    end,
}

lia.derma.Circle = {
    Texture = lia.derma.baseFuncs.Texture,
    Material = lia.derma.baseFuncs.Material,
    Outline = lia.derma.baseFuncs.Outline,
    Color = lia.derma.baseFuncs.Color,
    Blur = lia.derma.baseFuncs.Blur,
    Rotation = lia.derma.baseFuncs.Rotation,
    StartAngle = lia.derma.baseFuncs.StartAngle,
    EndAngle = lia.derma.baseFuncs.EndAngle,
    Clip = lia.derma.baseFuncs.Clip,
    Shadow = lia.derma.baseFuncs.Shadow,
    Flags = lia.derma.baseFuncs.Flags,
    Draw = lia.derma.Rect.Draw,
    GetMaterial = lia.derma.Rect.GetMaterial,
}

lia.derma.Types = {
    Rect = function(x, y, w, h)
        resetParams()
        MAT = roundedMat
        X, Y, W, H = x, y, w, h
        return lia.derma.Rect
    end,
    Circle = function(x, y, r)
        resetParams()
        MAT = roundedMat
        SHAPE = shapes[SHAPE_CIRCLE]
        X, Y, W, H = x - r / 2, y - r / 2, r, r
        r = r / 2
        TL, TR, BL, BR = r, r, r, r
        return lia.derma.Circle
    end
}

--[[
    Purpose:
        Creates a fluent rectangle drawing object for chained operations

    When Called:
        When creating complex UI elements with multiple drawing operations

    Parameters:
        x (number) - X position
        y (number) - Y position
        w (number) - Width
        h (number) - Height

    Returns:
        Table - Fluent drawing object with methods for chaining

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Create and draw a rectangle
    lia.derma.rect(100, 100, 200, 100):Color(Color(255, 0, 0)):Draw()
    ```

    Medium Complexity:
    ```lua
    -- Medium: Create rectangle with multiple properties
    lia.derma.rect(50, 50, 300, 150)
    :Color(Color(0, 255, 0, 200))
    :Rad(12)
    :Shape(lia.derma.SHAPE_IOS)
    :Draw()
    ```

    High Complexity:
    ```lua
    -- High: Complex rectangle with shadows and clipping
    lia.derma.rect(x, y, w, h)
    :Color(backgroundColor)
    :Radii(16, 8, 16, 8)
    :Shadow(20, 25)
    :Clip(parentPanel)
    :Draw()
    ```
]]
function lia.derma.rect(x, y, w, h)
    return lia.derma.Types.Rect(x, y, w, h)
end

--[[
    Purpose:
        Creates a fluent circle drawing object for chained operations

    When Called:
        When creating complex circular UI elements with multiple drawing operations

    Parameters:
        x (number) - Center X position
        y (number) - Center Y position
        r (number) - Circle radius

    Returns:
        Table - Fluent drawing object with methods for chaining

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Create and draw a circle
    lia.derma.circle(100, 100, 50):Color(Color(255, 0, 0)):Draw()
    ```

    Medium Complexity:
    ```lua
    -- Medium: Create circle with multiple properties
    lia.derma.circle(200, 200, 75)
    :Color(Color(0, 255, 0, 200))
    :Outline(2)
    :Draw()
    ```

    High Complexity:
    ```lua
    -- High: Complex circle with shadows and textures
    lia.derma.circle(x, y, radius)
    :Color(circleColor)
    :Texture(circleTexture)
    :Shadow(15, 20)
    :Blur(1.5)
    :Draw()
    ```
]]
function lia.derma.circle(x, y, r)
    return lia.derma.Types.Circle(x, y, r)
end

lia.derma.NO_TL = NO_TL
lia.derma.NO_TR = NO_TR
lia.derma.NO_BL = NO_BL
lia.derma.NO_BR = NO_BR
lia.derma.SHAPE_CIRCLE = SHAPE_CIRCLE
lia.derma.SHAPE_FIGMA = SHAPE_FIGMA
lia.derma.SHAPE_IOS = SHAPE_IOS
lia.derma.BLUR = BLUR
lia.derma.MANUAL_COLOR = manualColor
function lia.derma.setFlag(flags, flag, bool)
    flag = lia.derma[flag] or flag
    if tobool(bool) then
        return bit.bor(flags, flag)
    else
        return bit.band(flags, bit.bnot(flag))
    end
end

function lia.derma.setDefaultShape(shape)
    defaultShape = shape or SHAPE_FIGMA
    defaultDrawFlags = defaultShape
end

--[[
    Purpose:
        Draws text with a shadow effect for better readability

    When Called:
        When rendering text that needs to stand out against backgrounds

    Parameters:
        text (string) - Text to draw
        font (string) - Font to use
        x (number) - X position
        y (number) - Y position
        colortext (Color) - Color of the main text
        colorshadow (Color) - Color of the shadow
        dist (number) - Shadow distance/offset
        xalign (number, optional) - Horizontal text alignment
        yalign (number, optional) - Vertical text alignment

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw text with shadow
    lia.derma.shadowText("Hello World", "DermaDefault", 100, 100, Color(255, 255, 255), Color(0, 0, 0), 2)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom alignment
    lia.derma.shadowText("Centered Text", "LiliaFont.20", 200, 200, Color(255, 255, 255), Color(0, 0, 0, 150), 3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic shadow text with hover effects
    local shadowDist = isHovered and 4 or 2
    local shadowColor = Color(0, 0, 0, isHovered and 200 or 100)
    lia.derma.shadowText(text, font, x, y, textColor, shadowColor, shadowDist, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    ```
]]
function lia.derma.shadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
    surface.SetFont(font)
    local _, h = surface.GetTextSize(text)
    if yalign == TEXT_ALIGN_CENTER then
        y = y - h / 2
    elseif yalign == TEXT_ALIGN_BOTTOM then
        y = y - h
    end

    draw.DrawText(text, font, x + dist, y + dist, colorshadow, xalign)
    draw.DrawText(text, font, x, y, colortext, xalign)
end

--[[
    Purpose:
        Draws text with an outline border for better visibility

    When Called:
        When rendering text that needs to stand out with outline effects

    Parameters:
        text (string) - Text to draw
        font (string) - Font to use
        x (number) - X position
        y (number) - Y position
        colour (Color) - Color of the main text
        xalign (number, optional) - Horizontal text alignment
        outlinewidth (number) - Width of the outline
        outlinecolour (Color) - Color of the outline

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw outlined text
    lia.derma.drawTextOutlined("Hello World", "DermaDefault", 100, 100, Color(255, 255, 255), TEXT_ALIGN_LEFT, 2, Color(0, 0, 0))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom alignment and outline
    lia.derma.drawTextOutlined("Centered Text", "LiliaFont.20", 200, 200, Color(255, 255, 255), TEXT_ALIGN_CENTER, 3, Color(0, 0, 0, 200))
    ```

    High Complexity:
    ```lua
    -- High: Dynamic outlined text with hover effects
    local outlineWidth = isHovered and 4 or 2
    local outlineColor = Color(0, 0, 0, isHovered and 255 or 150)
    lia.derma.drawTextOutlined(text, font, x, y, textColor, TEXT_ALIGN_CENTER, outlineWidth, outlineColor)
    ```
]]
function lia.derma.drawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)
    local steps = (outlinewidth * 2) / 3
    if steps < 1 then steps = 1 end
    for ox = -outlinewidth, outlinewidth, steps do
        for oy = -outlinewidth, outlinewidth, steps do
            draw.DrawText(text, font, x + ox, y + oy, outlinecolour, xalign)
        end
    end
    return draw.DrawText(text, font, x, y, colour, xalign)
end

--[[
    Purpose:
        Draws a tooltip-style speech bubble with text

    When Called:
        When rendering tooltips or help text in speech bubble format

    Parameters:
        x (number) - X position
        y (number) - Y position
        w (number) - Width of the bubble
        h (number) - Height of the bubble
        text (string) - Text to display in the bubble
        font (string) - Font to use for the text
        textCol (Color) - Color of the text
        outlineCol (Color) - Color of the bubble outline

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw basic tooltip
    lia.derma.drawTip(100, 100, 200, 80, "Help text", "DermaDefault", Color(255, 255, 255), Color(0, 0, 0))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom styling
    lia.derma.drawTip(50, 50, 300, 100, "This is a tooltip", "LiliaFont.16", Color(255, 255, 255), Color(100, 100, 100))
    ```

    High Complexity:
    ```lua
    -- High: Dynamic tooltip with hover effects
    local w = math.max(200, surface.GetTextSize(text) + 40)
    local h = 60
    local textColor = Color(255, 255, 255)
    local outlineColor = Color(0, 0, 0, isHovered and 200 or 100)
    lia.derma.drawTip(x, y, w, h, text, font, textColor, outlineColor)
    ```
]]
function lia.derma.drawTip(x, y, w, h, text, font, textCol, outlineCol)
    draw.NoTexture()
    local rectH = 0.85
    local triW = 0.1
    local verts = {
        {
            x = x,
            y = y
        },
        {
            x = x + w,
            y = y
        },
        {
            x = x + w,
            y = y + h * rectH
        },
        {
            x = x + w / 2 + w * triW,
            y = y + h * rectH
        },
        {
            x = x + w / 2,
            y = y + h
        },
        {
            x = x + w / 2 - w * triW,
            y = y + h * rectH
        },
        {
            x = x,
            y = y + h * rectH
        }
    }

    surface.SetDrawColor(outlineCol)
    surface.DrawPoly(verts)
    draw.SimpleText(text, font, x + w / 2, y + h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

--[[
    Purpose:
        Draws text with automatic shadow effect for better readability

    When Called:
        When rendering text that needs consistent shadow styling

    Parameters:
        text (string) - Text to draw
        x (number) - X position
        y (number) - Y position
        color (Color, optional) - Color of the text (default: white)
        alignX (number, optional) - Horizontal text alignment
        alignY (number, optional) - Vertical text alignment
        font (string, optional) - Font to use (default: "LiliaFont.16")
        alpha (number, optional) - Alpha multiplier for shadow

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw text with automatic shadow
    lia.derma.drawText("Hello World", 100, 100)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom color and alignment
    lia.derma.drawText("Centered Text", 200, 200, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic text with hover effects
    local textColor = Color(255, 255, 255)
    local alpha = isHovered and 1.0 or 0.7
    lia.derma.drawText(text, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, font, alpha)
    ```
]]
function lia.derma.drawText(text, x, y, color, alignX, alignY, font, alpha)
    color = color or Color(255, 255, 255)
    return draw.TextShadow({
        text = text,
        font = font or "LiliaFont.16",
        pos = {x, y},
        color = color,
        xalign = alignX or 0,
        yalign = alignY or 0
    }, 1, alpha or color.a * 0.575)
end

function lia.derma.drawBoxWithText(text, x, y, options)
    options = options or {}
    local font = options.font or "LiliaFont.16"
    local textColor = options.textColor or Color(255, 255, 255)
    local backgroundColor = options.backgroundColor or Color(0, 0, 0, 150)
    local borderColor = options.borderColor or lia.color.theme.theme
    local borderRadius = options.borderRadius or 8
    local borderThickness = options.borderThickness or 2
    local padding = options.padding or 20
    local blur = options.blur or {
        enabled = true,
        amount = 3,
        passes = 3,
        alpha = 0.9
    }

    local textAlignX = options.textAlignX or TEXT_ALIGN_CENTER
    local textAlignY = options.textAlignY or TEXT_ALIGN_CENTER
    local autoSize = options.autoSize ~= false
    local lineSpacing = options.lineSpacing or 4
    local textLines = istable(text) and text or {text}
    surface.SetFont(font)
    local maxWidth, totalHeight = 0, 0
    for i, line in ipairs(textLines) do
        local t_w, t_h = surface.GetTextSize(line)
        maxWidth = math.max(maxWidth, t_w)
        if i == 1 then
            totalHeight = t_h
        else
            totalHeight = totalHeight + t_h + lineSpacing
        end
    end

    local boxWidth, boxHeight
    if autoSize then
        boxWidth = maxWidth + padding
        boxHeight = totalHeight + padding
    else
        boxWidth = options.width or maxWidth + padding
        boxHeight = options.height or totalHeight + padding
    end

    local boxX = x
    if textAlignX == TEXT_ALIGN_RIGHT then
        boxX = x - boxWidth
    elseif textAlignX == TEXT_ALIGN_CENTER then
        boxX = x - boxWidth / 2
    end

    local boxY = y
    if textAlignY == TEXT_ALIGN_BOTTOM then
        boxY = y - boxHeight
    elseif textAlignY == TEXT_ALIGN_CENTER then
        boxY = y - boxHeight / 2
    end

    if blur.enabled then lia.util.drawBlurAt(boxX, boxY, boxWidth, boxHeight, blur.amount, blur.passes, blur.alpha) end
    lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(backgroundColor):Rad(borderRadius):Draw()
    if borderThickness > 0 then lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(borderColor):Rad(borderRadius):Outline(borderThickness):Draw() end
    local startY = boxY + padding / 2
    if textAlignY == TEXT_ALIGN_CENTER then
        startY = boxY + (boxHeight - totalHeight) / 2
    elseif textAlignY == TEXT_ALIGN_BOTTOM then
        startY = boxY + boxHeight - padding / 2 - totalHeight
    end

    local currentY = startY
    for i, line in ipairs(textLines) do
        local textX
        if textAlignX == TEXT_ALIGN_CENTER then
            textX = boxX + boxWidth / 2
        elseif textAlignX == TEXT_ALIGN_LEFT then
            textX = boxX + padding / 2
        else
            textX = boxX + boxWidth - padding / 2
        end

        lia.derma.drawText(line, textX, currentY, textColor, textAlignX, TEXT_ALIGN_TOP, font)
        if i < #textLines then
            local _, t_h = surface.GetTextSize(line)
            currentY = currentY + t_h + lineSpacing
        end
    end
    return boxWidth, boxHeight
end

function lia.derma.drawSurfaceTexture(material, color, x, y, w, h)
    surface.SetDrawColor(color or Color(255, 255, 255))
    if isstring(material) then
        surface.SetMaterial(lia.util.getMaterial(material))
    else
        surface.SetMaterial(material)
    end

    surface.DrawTexturedRect(x, y, w, h)
end

function lia.derma.skinFunc(name, panel, a, b, c, d, e, f, g)
    local skin = ispanel(panel) and IsValid(panel) and panel:GetSkin() or derma.GetDefaultSkin()
    if not skin then return end
    local func = skin[name]
    if not func then return end
    return func(skin, panel, a, b, c, d, e, f, g)
end

--[[
    Purpose:
        Performs exponential interpolation between current and target values

    When Called:
        When smooth animation transitions are needed

    Parameters:
        current (number) - Current value
        target (number) - Target value to approach
        speed (number) - Animation speed multiplier
        dt (number) - Delta time (FrameTime())

    Returns:
        number - New interpolated value

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Smooth value transition
    local currentValue = lia.derma.approachExp(currentValue, targetValue, 5, FrameTime())
    ```

    Medium Complexity:
    ```lua
    -- Medium: Animate panel alpha
    local targetAlpha = isVisible and 255 or 0
    panel:SetAlpha(lia.derma.approachExp(panel:GetAlpha(), targetAlpha, 8, FrameTime()))
    ```

    High Complexity:
    ```lua
    -- High: Complex animation with multiple properties
    local dt = FrameTime()
    local targetX = isHovered and hoverX or normalX
    local targetY = isHovered and hoverY or normalY
    local targetScale = isHovered and 1.1 or 1.0

    panel:SetPos(
    lia.derma.approachExp(panel:GetPos(), targetX, 6, dt),
    lia.derma.approachExp(panel:GetPos(), targetY, 6, dt)
    )
    panel:SetSize(
    lia.derma.approachExp(panel:GetWide(), targetW * targetScale, 4, dt),
    lia.derma.approachExp(panel:GetTall(), targetH * targetScale, 4, dt)
    )
    ```
]]
function lia.derma.approachExp(current, target, speed, dt)
    local t = 1 - math.exp(-speed * dt)
    return current + (target - current) * t
end

--[[
    Purpose:
        Applies cubic ease-out easing function to a normalized time value

    When Called:
        When smooth deceleration animations are needed

    Parameters:
        t (number) - Normalized time value (0 to 1)

    Returns:
        number - Eased value

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Apply ease-out to animation progress
    local eased = lia.derma.easeOutCubic(animationProgress)
    panel:SetAlpha(eased * 255)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Smooth panel movement with ease-out
    local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
    local eased = lia.derma.easeOutCubic(progress)
    panel:SetPos(startX + (endX - startX) * eased, startY + (endY - startY) * eased)
    ```

    High Complexity:
    ```lua
    -- High: Complex animation with multiple eased properties
    local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
    local eased = lia.derma.easeOutCubic(progress)

    panel:SetPos(
    startX + (endX - startX) * eased,
    startY + (endY - startY) * eased
    )
    panel:SetSize(
    startW + (endW - startW) * eased,
    startH + (endH - startH) * eased
    )
    panel:SetAlpha(startAlpha + (endAlpha - startAlpha) * eased)
    ```
]]
function lia.derma.easeOutCubic(t)
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

--[[
    Purpose:
        Applies cubic ease-in-out easing function to a normalized time value

    When Called:
        When smooth acceleration and deceleration animations are needed

    Parameters:
        t (number) - Normalized time value (0 to 1)

    Returns:
        number - Eased value

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Apply ease-in-out to animation progress
    local eased = lia.derma.easeInOutCubic(animationProgress)
    panel:SetAlpha(eased * 255)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Smooth panel scaling with ease-in-out
    local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
    local eased = lia.derma.easeInOutCubic(progress)
    local scale = startScale + (endScale - startScale) * eased
    panel:SetSize(baseW * scale, baseH * scale)
    ```

    High Complexity:
    ```lua
    -- High: Complex UI animation with ease-in-out
    local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
    local eased = lia.derma.easeInOutCubic(progress)

    -- Animate position, size, and rotation
    panel:SetPos(
    startX + (endX - startX) * eased,
    startY + (endY - startY) * eased
    )
    panel:SetSize(
    startW + (endW - startW) * eased,
    startH + (endH - startH) * eased
    )
    panel:SetRotation(startRotation + (endRotation - startRotation) * eased)
    ```
]]
function lia.derma.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return 1 - math.pow(-2 * t + 2, 3) / 2
    end
end

--[[
    Purpose:
        Animates panel appearance with scaling and fade effects

    When Called:
        When panels need smooth entrance animations

    Parameters:
        panel (Panel) - Panel to animate
        target_w (number) - Target width
        target_h (number) - Target height
        duration (number, optional) - Animation duration (default: 0.18)
        alpha_dur (number, optional) - Alpha animation duration (default: same as duration)
        callback (function, optional) - Callback function called when animation completes
        scale_factor (number, optional) - Initial scale factor (default: 0.8)

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Animate panel appearance
    lia.derma.animateAppearance(myPanel, 300, 200)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Animate with custom duration and callback
    lia.derma.animateAppearance(myPanel, 400, 300, 0.3, 0.2, function(panel)
    print("Animation completed!")
    end)
    ```

    High Complexity:
    ```lua
    -- High: Complex animation with validation and effects
    if IsValid(panel) then
        local targetW = isExpanded and 500 or 300
        local targetH = isExpanded and 400 or 200
        local duration = isExpanded and 0.25 or 0.15
        local scaleFactor = isExpanded and 0.9 or 0.7

        lia.derma.animateAppearance(panel, targetW, targetH, duration, duration * 0.8, function(animPanel)
        if IsValid(animPanel) then
            onAnimationComplete(animPanel)
        end
    end, scaleFactor)
    end
    ```
]]
function lia.derma.animateAppearance(panel, target_w, target_h, duration, alpha_dur, callback, scale_factor)
    local scaleFactor = 0.8
    if not IsValid(panel) then return end
    duration = (duration and duration > 0) and duration or 0.18
    alpha_dur = (alpha_dur and alpha_dur > 0) and alpha_dur or duration
    local targetX, targetY = panel:GetPos()
    local initialW = target_w * (scale_factor and scale_factor or scaleFactor)
    local initialH = target_h * (scale_factor and scale_factor or scaleFactor)
    local initialX = targetX + (target_w - initialW) / 2
    local initialY = targetY + (target_h - initialH) / 2
    panel:SetSize(initialW, initialH)
    panel:SetPos(initialX, initialY)
    panel:SetAlpha(0)
    local curW, curH = initialW, initialH
    local curX, curY = initialX, initialY
    local curA = 0
    local eps = 0.5
    local alpha_eps = 1
    local speedSize = 3 / math.max(0.0001, duration)
    local speedAlpha = 3 / math.max(0.0001, alpha_dur)
    panel.Think = function()
        if not IsValid(panel) then return end
        local dt = FrameTime()
        curW = lia.derma.approachExp(curW, target_w, speedSize, dt)
        curH = lia.derma.approachExp(curH, target_h, speedSize, dt)
        curX = lia.derma.approachExp(curX, targetX, speedSize, dt)
        curY = lia.derma.approachExp(curY, targetY, speedSize, dt)
        curA = lia.derma.approachExp(curA, 255, speedAlpha, dt)
        panel:SetSize(curW, curH)
        panel:SetPos(curX, curY)
        panel:SetAlpha(math.floor(curA + 0.5))
        local doneSize = math.abs(curW - target_w) <= eps and math.abs(curH - target_h) <= eps
        local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
        local doneAlpha = math.abs(curA - 255) <= alpha_eps
        if doneSize and donePos and doneAlpha then
            panel:SetSize(target_w, target_h)
            panel:SetPos(targetX, targetY)
            panel:SetAlpha(255)
            panel.Think = nil
            if callback then callback(panel) end
        end
    end
end

function lia.derma.clampMenuPosition(panel)
    if not IsValid(panel) then return end
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    local sw, sh = ScrW(), ScrH()
    if x < 5 then
        x = 5
    elseif x + w > sw - 5 then
        x = sw - 5 - w
    end

    if y < 5 then
        y = 5
    elseif y + h > sh - 5 then
        y = sh - 5 - h
    end

    panel:SetPos(x, y)
end

function lia.derma.drawGradient(x, y, w, h, direction, color_shadow, radius, flags)
    local listGradients = {Material("vgui/gradient_up"), Material("vgui/gradient_down"), Material("vgui/gradient-l"), Material("vgui/gradient-r")}
    radius = radius and radius or 0
    lia.derma.drawMaterial(radius, x, y, w, h, color_shadow, listGradients[direction], flags)
end

function lia.derma.wrapText(text, width, font)
    font = font or "LiliaFont.16"
    surface.SetFont(font)
    local exploded = string.Explode("%s", text, true)
    local line = ""
    local lines = {}
    local w = surface.GetTextSize(text)
    local maxW = 0
    if w <= width then
        text, _ = text:gsub("%s", " ")
        return {text}, w
    end

    for i = 1, #exploded do
        local word = exploded[i]
        line = line .. " " .. word
        w = surface.GetTextSize(line)
        if w > width then
            lines[#lines + 1] = line
            line = ""
            if w > maxW then maxW = w end
        end
    end

    if line ~= "" then lines[#lines + 1] = line end
    return lines, maxW
end

--[[
    Purpose:
        Draws blur effect behind a panel using screen space effects

    When Called:
        When rendering panel backgrounds that need blur effects

    Parameters:
        panel (Panel) - Panel to draw blur behind
        amount (number, optional) - Blur intensity (default: 5)
        passes (number, optional) - Number of blur passes (default: 0.2)
        alpha (number, optional) - Blur alpha (default: 255)

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw blur behind panel
    lia.derma.drawBlur(myPanel)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom blur settings
    lia.derma.drawBlur(myPanel, 8, 0.3, 200)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic blur with panel validation
    if IsValid(panel) and panel:IsVisible() then
        local amount = isHovered and 10 or 5
        local alpha = isActive and 255 or 150
        lia.derma.drawBlur(panel, amount, 0.2, alpha)
    end
    ```
]]
function lia.derma.drawBlur(panel, amount, passes, alpha)
    amount = amount or 5
    alpha = alpha or 255
    surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
    surface.SetDrawColor(255, 255, 255, alpha)
    local x, y = panel:LocalToScreen(0, 0)
    for i = -(passes or 0.2), 1, 0.2 do
        lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
        lia.util.getMaterial("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
    end
end

function lia.derma.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)
    if not IsValid(panel) then return end
    amount = amount or 6
    passes = math.max(1, passes or 5)
    alpha = alpha or 255
    darkAlpha = darkAlpha or 220
    local mat = lia.util.getMaterial("pp/blurscreen")
    local x, y = panel:LocalToScreen(0, 0)
    x = math.floor(x)
    y = math.floor(y)
    local sw, sh = ScrW(), ScrH()
    local expand = 4
    render.UpdateScreenEffectTexture()
    surface.SetMaterial(mat)
    surface.SetDrawColor(255, 255, 255, alpha)
    for i = 1, passes do
        mat:SetFloat("$blur", i / passes * amount)
        mat:Recompute()
        surface.DrawTexturedRectUV(-x - expand, -y - expand, sw + expand * 2, sh + expand * 2, 0, 0, 1, 1)
    end

    surface.SetDrawColor(0, 0, 0, darkAlpha)
    surface.DrawRect(x, y, panel:GetWide(), panel:GetTall())
end

--[[
    Purpose:
        Draws blur effect at specific screen coordinates

    When Called:
        When rendering blur effects at specific screen positions

    Parameters:
        x (number) - X position on screen
        y (number) - Y position on screen
        w (number) - Width of blur area
        h (number) - Height of blur area
        amount (number, optional) - Blur intensity (default: 5)
        passes (number, optional) - Number of blur passes (default: 0.2)
        alpha (number, optional) - Blur alpha (default: 255)

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw blur at specific position
    lia.derma.drawBlurAt(100, 100, 200, 100)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom blur settings
    lia.derma.drawBlurAt(50, 50, 300, 150, 8, 0.3, 200)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic blur with screen bounds checking
    local x, y = getScreenPosition()
    local w, h = getBlurSize()
    if x >= 0 and y >= 0 and x + w <= ScrW() and y + h <= ScrH() then
        local amount = isHovered and 10 or 5
        lia.derma.drawBlurAt(x, y, w, h, amount, 0.2, 255)
    end
    ```
]]
function lia.derma.drawBlurAt(x, y, w, h, amount, passes, alpha)
    amount = amount or 5
    alpha = alpha or 255
    surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
    surface.SetDrawColor(255, 255, 255, alpha)
    local x2, y2 = x / ScrW(), y / ScrH()
    local w2, h2 = (x + w) / ScrW(), (y + h) / ScrH()
    for i = -(passes or 0.2), 1, 0.2 do
        lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
        lia.util.getMaterial("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
    end
end

--[[
    Purpose:
        Creates a dialog for requesting multiple arguments from the user

    When Called:
        When user input is needed for multiple fields with different types

    Parameters:
        title (string, optional) - Title of the dialog
        argTypes (table) - Table defining argument types and properties
        onSubmit (function) - Callback function called with results
        defaults (table, optional) - Default values for arguments

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Request basic arguments
    local argTypes = {
    name = "string",
    age = "number",
    isActive = "boolean"
    }
    lia.derma.requestArguments("User Info", argTypes, function(success, results)
    if success then
        print("Name:", results.name, "Age:", results.age)
    end
    end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Request with dropdown and defaults
    local argTypes = {
    {name = "player", type = "player"},
    {name = "action", type = "table", data = {"kick", "ban", "mute"}},
    {name = "reason", type = "string"}
    }
    local defaults = {reason = "No reason provided"}
    lia.derma.requestArguments("Admin Action", argTypes, onSubmit, defaults)
    ```

    High Complexity:
    ```lua
    -- High: Complex argument validation with ordered fields
    local argTypes = {
    {name = "itemName", type = "string"},
    {name = "itemType", type = "table", data = {{"Weapon", "weapon"}, {"Tool", "tool"}}},
    {name = "quantity", type = "number"},
    {name = "isStackable", type = "boolean"}
    }
    lia.derma.requestArguments("Create Item", argTypes, function(success, results)
    if success and validateItemData(results) then
        createItem(results)
    end
    end)
    ```
]]
function lia.derma.requestArguments(title, argTypes, onSubmit, defaults)
    defaults = defaults or {}
    local count = table.Count(argTypes)
    local frameW, frameH = 600, math.min(450 + count * 135, ScrH() * 0.5)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("enterArguments"))
    frame:SetZPos(1000)
    local scroll = vgui.Create("liaScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 40, 10, 10)
    surface.SetFont("LiliaFont.17")
    local controls, watchers = {}, {}
    local validate
    local ordered = {}
    local grouped = {
        strings = {},
        dropdowns = {},
        bools = {},
        rest = {}
    }

    local isOrdered = istable(argTypes) and #argTypes > 0 and istable(argTypes[1])
    if isOrdered then
        for _, argInfo in ipairs(argTypes) do
            local name, typeInfo = argInfo[1], argInfo[2]
            local fieldType, dataTbl, defaultVal = typeInfo, nil, nil
            if istable(typeInfo) then
                fieldType, dataTbl = typeInfo[1], typeInfo[2]
                if typeInfo[3] ~= nil then defaultVal = typeInfo[3] end
            end

            fieldType = string.lower(tostring(fieldType))
            if defaultVal == nil and defaults[name] ~= nil then defaultVal = defaults[name] end
            local info = {
                name = name,
                fieldType = fieldType,
                dataTbl = dataTbl,
                defaultVal = defaultVal
            }

            table.insert(ordered, info)
        end
    else
        for name, typeInfo in pairs(argTypes) do
            local fieldType, dataTbl, defaultVal = typeInfo, nil, nil
            if istable(typeInfo) then
                fieldType, dataTbl = typeInfo[1], typeInfo[2]
                if typeInfo[3] ~= nil then defaultVal = typeInfo[3] end
            end

            fieldType = string.lower(tostring(fieldType))
            if defaultVal == nil and defaults[name] ~= nil then defaultVal = defaults[name] end
            local info = {
                name = name,
                fieldType = fieldType,
                dataTbl = dataTbl,
                defaultVal = defaultVal
            }

            if fieldType == "string" then
                table.insert(grouped.strings, info)
            elseif fieldType == "table" then
                table.insert(grouped.dropdowns, info)
            elseif fieldType == "boolean" then
                table.insert(grouped.bools, info)
            else
                table.insert(grouped.rest, info)
            end
        end

        for _, group in ipairs({grouped.strings, grouped.dropdowns, grouped.bools, grouped.rest}) do
            for _, v in ipairs(group) do
                table.insert(ordered, v)
            end
        end
    end

    for _, info in ipairs(ordered) do
        local name, fieldType, dataTbl, defaultVal = info.name, info.fieldType, info.dataTbl, info.defaultVal
        local panel = vgui.Create("DPanel", scroll)
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 15)
        panel:SetTall(120)
        panel.Paint = nil
        local label = vgui.Create("DLabel", panel)
        label:SetFont("LiliaFont.20")
        label:SetText(name)
        label:SizeToContents()
        local textW = select(1, surface.GetTextSize(name))
        local ctrl
        local isBool = fieldType == "boolean"
        if isBool then
            ctrl = vgui.Create("liaCheckbox", panel)
            if defaultVal ~= nil then ctrl:SetChecked(tobool(defaultVal)) end
        elseif fieldType == "table" then
            ctrl = vgui.Create("liaComboBox", panel)
            local defaultChoiceIndex
            if istable(dataTbl) then
                for idx, v in ipairs(dataTbl) do
                    if istable(v) then
                        ctrl:AddChoice(v[1], v[2])
                        if defaultVal ~= nil and (v[2] == defaultVal or v[1] == defaultVal) then defaultChoiceIndex = idx end
                    else
                        ctrl:AddChoice(tostring(v))
                        if defaultVal ~= nil and v == defaultVal then defaultChoiceIndex = idx end
                    end
                end
            end

            if defaultChoiceIndex then ctrl:ChooseOptionID(defaultChoiceIndex) end
            ctrl:FinishAddingOptions()
            ctrl:PostInit()
        elseif fieldType == "int" or fieldType == "number" then
            ctrl = vgui.Create("liaEntry", panel)
            ctrl:SetFont("LiliaFont.17")
            ctrl:SetTitle("")
            if ctrl.SetNumeric then ctrl:SetNumeric(true) end
            if defaultVal ~= nil then ctrl:SetValue(tostring(defaultVal)) end
        elseif fieldType == "player" then
            ctrl = vgui.Create("liaComboBox", panel)
            ctrl:SetFont("LiliaFont.17")
            ctrl:SetPlaceholder(L("select"))
            ctrl:AddChoice(L("select"), "")
            for _, pl in player.Iterator() do
                if IsValid(pl) then ctrl:AddChoice(pl:Name(), pl:SteamID()) end
            end

            ctrl:FinishAddingOptions()
            ctrl:PostInit()
            if defaultVal ~= nil then
                for i = 1, ctrl:GetOptionCount() do
                    local choiceText, choiceData = ctrl:GetOptionText(i), ctrl:GetOptionData(i)
                    if choiceData == defaultVal or choiceText == defaultVal then
                        ctrl:ChooseOptionID(i)
                        break
                    end
                end
            end
        else
            ctrl = vgui.Create("liaEntry", panel)
            ctrl:SetFont("LiliaFont.17")
            ctrl:SetTitle("")
            if defaultVal ~= nil then ctrl:SetValue(tostring(defaultVal)) end
        end

        panel.PerformLayout = function(_, w, h)
            local ctrlH, ctrlW
            if isBool then
                ctrlH, ctrlW = 22, 60
            else
                ctrlH, ctrlW = 60, w * 0.85
            end

            local ctrlX = (w - ctrlW) / 2
            ctrl:SetPos(ctrlX, (h - ctrlH) / 2 + 6)
            ctrl:SetSize(ctrlW, ctrlH)
            label:SetPos((w - textW) / 2, (h - ctrlH) / 2 - 25)
        end

        controls[name] = {
            ctrl = ctrl,
            type = fieldType
        }

        watchers[#watchers + 1] = function()
            local function trigger()
                validate()
            end

            ctrl.OnValueChange, ctrl.OnTextChanged, ctrl.OnChange, ctrl.OnSelect = trigger, trigger, trigger, trigger
        end
    end

    local btnPanel = vgui.Create("DPanel", frame)
    btnPanel:Dock(BOTTOM)
    btnPanel:SetTall(90)
    btnPanel:DockPadding(15, 15, 15, 15)
    btnPanel.Paint = nil
    local submit = vgui.Create("liaButton", btnPanel)
    submit:Dock(LEFT)
    submit:DockMargin(0, 0, 15, 0)
    submit:SetWide(270)
    submit:SetTxt(L("submit"))
    submit:SetEnabled(false)
    local cancel = vgui.Create("liaButton", btnPanel)
    cancel:Dock(RIGHT)
    cancel:SetWide(270)
    cancel:SetTxt(L("cancel"))
    cancel.DoClick = function()
        if isfunction(onSubmit) then onSubmit(false) end
        frame:Remove()
    end

    validate = function()
        for _, data in pairs(controls) do
            local ctl, ftype, ok = data.ctrl, data.type, true
            if ftype == "boolean" then
                ok = true
            elseif ctl.GetSelected then
                local txt = select(1, ctl:GetSelected())
                ok = txt and txt ~= "" and txt ~= L("select") and txt ~= L("choose")
            elseif ctl.GetValue then
                local val = ctl:GetValue()
                if ftype == "int" or ftype == "number" then
                    ok = val ~= nil and val ~= "" and tonumber(val) ~= nil
                else
                    ok = val ~= nil and val ~= "" and val ~= "nil"
                end
            end

            if not ok then
                submit:SetEnabled(false)
                return
            end
        end

        submit:SetEnabled(true)
    end

    for _, fn in ipairs(watchers) do
        fn()
    end

    validate()
    submit.DoClick = function()
        local result = {}
        for k, data in pairs(controls) do
            local ctl, ftype = data.ctrl, data.type
            if ftype == "boolean" then
                result[k] = ctl:GetChecked()
            elseif ctl.GetSelected then
                local txt, val = ctl:GetSelected()
                result[k] = val or txt
            else
                local val = ctl:GetValue()
                result[k] = (ftype == "int" or ftype == "number") and tonumber(val) or val
            end
        end

        if isfunction(onSubmit) then onSubmit(true, result) end
        frame:Remove()
    end

    frame.OnClose = function() if isfunction(onSubmit) then onSubmit(false) end end
end

function lia.derma.createTableUI(title, columns, data, options, charID)
    if IsValid(lia.gui.menuTableUI) then lia.gui.menuTableUI:Remove() end
    local frameWidth, frameHeight = ScrW() * 0.8, ScrH() * 0.8
    local frame = vgui.Create("liaDListView")
    lia.gui.menuTableUI = frame
    frame:SetWindowTitle(title and L(title) or L("tableListTitle"))
    frame:SetSize(frameWidth, frameHeight)
    frame:Center()
    frame:MakePopup()
    if IsValid(frame.topBar) then frame.topBar:Remove() end
    if IsValid(frame.statusBar) then frame.statusBar:Remove() end
    local listView = frame.listView
    listView:Dock(FILL)
    listView:Clear()
    if listView.ClearColumns then listView:ClearColumns() end
    for _, colInfo in ipairs(columns or {}) do
        local localizedName = colInfo.name and L(colInfo.name) or L("na")
        local col = listView:AddColumn(localizedName)
        surface.SetFont(col.Header:GetFont())
        local textW = surface.GetTextSize(localizedName)
        local minWidth = textW + 16
        col:SetMinWidth(minWidth)
        col:SetWidth(colInfo.width or minWidth)
    end

    for _, row in ipairs(data) do
        local lineData = {}
        for _, colInfo in ipairs(columns) do
            table.insert(lineData, row[colInfo.field] or L("na"))
        end

        local line = listView:AddLine(unpack(lineData))
        line.rowData = row
    end

    listView.OnRowRightClick = function(_, _, line)
        if not IsValid(line) or not line.rowData then return end
        local rowData = line.rowData
        local menu = lia.derma.dermaMenu()
        menu:AddOption(L("copyRow"), function()
            local rowString = ""
            for key, value in pairs(rowData) do
                value = tostring(value or L("na"))
                rowString = rowString .. key:gsub("^%l", string.upper) .. " " .. value .. " | "
            end

            rowString = rowString:sub(1, -4)
            SetClipboardText(rowString)
        end)

        for _, option in ipairs(istable(options) and options or {}) do
            menu:AddOption(option.name and L(option.name) or option.name, function()
                if not option.net then return end
                if option.ExtraFields then
                    local inputPanel = vgui.Create("liaFrame")
                    inputPanel:SetTitle(L("optionsTitle", option.name))
                    inputPanel:SetSize(300, 300 + #table.GetKeys(option.ExtraFields) * 35)
                    inputPanel:Center()
                    inputPanel:MakePopup()
                    local form = vgui.Create("DForm", inputPanel)
                    form:Dock(FILL)
                    form:SetLabel("")
                    form.Paint = function() end
                    local inputs = {}
                    for fName, fType in pairs(option.ExtraFields) do
                        local label = vgui.Create("DLabel", form)
                        label:SetText(fName)
                        label:Dock(TOP)
                        label:DockMargin(5, 10, 5, 0)
                        form:AddItem(label)
                        if isstring(fType) and fType == "text" then
                            local entry = vgui.Create("DTextEntry", form)
                            entry:Dock(TOP)
                            entry:DockMargin(5, 5, 5, 0)
                            entry:SetPlaceholderText(L("typeFieldPrompt", fName))
                            form:AddItem(entry)
                            inputs[fName] = {
                                panel = entry,
                                ftype = "text"
                            }
                        elseif isstring(fType) and fType == "combo" then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(L("selectPrompt", fName))
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        elseif istable(fType) then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(L("selectPrompt", fName))
                            for _, choice in ipairs(fType) do
                                combo:AddChoice(choice)
                            end

                            combo:FinishAddingOptions()
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        end
                    end

                    local submitButton = vgui.Create("DButton", form)
                    submitButton:SetText(L("submit"))
                    submitButton:Dock(TOP)
                    submitButton:DockMargin(5, 10, 5, 0)
                    form:AddItem(submitButton)
                    submitButton.DoClick = function()
                        local values = {}
                        for fName, info in pairs(inputs) do
                            if not IsValid(info.panel) then continue end
                            if info.ftype == "text" then
                                values[fName] = info.panel:GetValue() or ""
                            elseif info.ftype == "combo" then
                                values[fName] = info.panel:GetSelected() or ""
                            end
                        end

                        net.Start(option.net)
                        net.WriteInt(charID, 32)
                        net.WriteTable(rowData)
                        for _, fVal in pairs(values) do
                            if isnumber(fVal) then
                                net.WriteInt(fVal, 32)
                            else
                                net.WriteString(fVal)
                            end
                        end

                        net.SendToServer()
                        inputPanel:Close()
                        frame:Remove()
                    end
                else
                    net.Start(option.net)
                    net.WriteInt(charID, 32)
                    net.WriteTable(rowData)
                    net.SendToServer()
                    frame:Remove()
                end
            end)
        end

        menu:Open()
    end

    frame.OnRemove = function() if lia.gui.menuTableUI == frame then lia.gui.menuTableUI = nil end end
    return frame, listView
end

function lia.derma.openOptionsMenu(title, options)
    if not istable(options) then return end
    if IsValid(lia.gui.menuOpenOptions) then lia.gui.menuOpenOptions:Remove() end
    local entries = {}
    if options[1] then
        for _, opt in ipairs(options) do
            if isstring(opt.name) and isfunction(opt.callback) then entries[#entries + 1] = opt end
        end
    else
        for name, callback in pairs(options) do
            if isfunction(callback) then
                entries[#entries + 1] = {
                    name = name,
                    callback = callback
                }
            end
        end
    end

    if #entries == 0 then return end
    local frameW, entryH = 300, 30
    local frameH = entryH * #entries + 50
    local frame = vgui.Create("liaFrame")
    lia.gui.menuOpenOptions = frame
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(true)
    frame.Paint = function(self, w, h)
        lia.derma.drawBlur(self, 4)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
    end

    local titleLabel = frame:Add("DLabel")
    titleLabel:SetPos(0, 8)
    titleLabel:SetSize(frameW, 20)
    titleLabel:SetText(L(title or "options"))
    titleLabel:SetFont("LiliaFont.17")
    titleLabel:SetColor(Color(255, 255, 255))
    titleLabel:SetContentAlignment(5)
    local layout = frame:Add("DListLayout")
    layout:Dock(FILL)
    layout:DockMargin(10, 32, 10, 10)
    for _, opt in ipairs(entries) do
        local btn = layout:Add("liaCustomFontButton")
        btn:SetTall(entryH)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 5)
        btn:SetText(L(opt.name))
        btn.DoClick = function()
            frame:Remove()
            opt.callback()
        end
    end

    frame.OnRemove = function() if lia.gui.menuOpenOptions == frame then lia.gui.menuOpenOptions = nil end end
    return frame
end

local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta and vectorMeta.ToScreen or function()
    return {
        x = 0,
        y = 0,
        visible = false
    }
end

local defaultTheme = {
    background_alpha = Color(34, 34, 34, 210),
    header = Color(34, 34, 34, 210),
    accent = Color(255, 255, 255, 180),
    text = Color(255, 255, 255)
}

local function scaleColorAlpha(col, scale)
    col = col or defaultTheme.background_alpha
    local a = col.a or 255
    return Color(col.r, col.g, col.b, math.Clamp(a * scale, 0, 255))
end

local function EntText(text, x, y, fade)
    surface.SetFont("LiliaFont.40")
    local tw, th = surface.GetTextSize(text)
    local bx, by = math.Round(x - tw * 0.5 - 18), math.Round(y - 12)
    local bw, bh = tw + 36, th + 24
    local theme = lia.color.theme or defaultTheme
    local fadeAlpha = math.Clamp(fade, 0, 1)
    local headerColor = scaleColorAlpha(theme.background_panelpopup or theme.header or defaultTheme.header, fadeAlpha)
    local accentColor = scaleColorAlpha(theme.theme or theme.text or defaultTheme.accent, fadeAlpha)
    local textColor = scaleColorAlpha(theme.text or defaultTheme.text, fadeAlpha)
    lia.derma.drawBlurAt(bx, by, bw, bh - 6, 6, 0.2, math.floor(fadeAlpha * 255))
    lia.derma.rect(bx, by, bw, bh - 6):Radii(16, 16, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 16, 16):Color(accentColor):Draw()
    draw.SimpleText(text, "LiliaFont.40", math.Round(x), math.Round(y - 2), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    return bh
end

lia.derma.entsScales = lia.derma.entsScales or {}
--[[
    Purpose:
        Draws text above entities in 3D space with distance-based scaling

    When Called:
        When rendering entity labels or information in 3D space

    Parameters:
        ent (Entity) - Entity to draw text above
        text (string) - Text to display
        posY (number, optional) - Y offset from entity center (default: 0)
        alphaOverride (number, optional) - Alpha override for the text

    Returns:
        None

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Draw entity name
    lia.derma.drawEntText(entity, entity:GetName())
    ```

    Medium Complexity:
    ```lua
    -- Medium: Draw with custom offset and alpha
    lia.derma.drawEntText(entity, "Custom Text", 20, 200)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic entity text with conditions
    if IsValid(entity) and entity:IsPlayer() then
        local text = entity:Name()
        if entity:IsAdmin() then
            text = "[ADMIN] " .. text
        end
        local alpha = entity:IsTyping() and 150 or 255
        lia.derma.drawEntText(entity, text, 0, alpha)
    end
    ```
]]
function lia.derma.drawEntText(ent, text, posY, alphaOverride)
    timer.Simple(0, function() if derma.RefreshSkins then derma.RefreshSkins() end end)
    if not (IsValid(ent) and text and text ~= "") then return end
    posY = posY or 0
    local distSqr = EyePos():DistToSqr(ent:GetPos())
    local maxDist = 380
    if distSqr > maxDist * maxDist then return end
    local dist = math.sqrt(distSqr)
    local minDist = 20
    local idx = ent:EntIndex()
    local prev = lia.derma.entsScales[idx] or 0
    local normalized = math.Clamp((maxDist - dist) / math.max(1, maxDist - minDist), 0, 1)
    local appearThreshold = 0.8
    local disappearThreshold = 0.01
    local target
    if normalized <= disappearThreshold then
        target = 0
    elseif normalized >= appearThreshold then
        target = 1
    else
        target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
    end

    local dt = FrameTime() or 0.016
    local appearSpeed = 18
    local disappearSpeed = 12
    local speed = (target > prev) and appearSpeed or disappearSpeed
    local cur = lia.derma.approachExp(prev, target, speed, dt)
    if math.abs(cur - target) < 0.0005 then cur = target end
    if cur == 0 and target == 0 then
        lia.derma.entsScales[idx] = nil
        return
    end

    lia.derma.entsScales[idx] = cur
    local eased = lia.derma.easeInOutCubic(cur)
    if eased <= 0 then return end
    local fade = eased
    if alphaOverride then
        if alphaOverride > 1 then
            fade = fade * math.Clamp(alphaOverride / 255, 0, 1)
        else
            fade = fade * math.Clamp(alphaOverride, 0, 1)
        end
    end

    if fade <= 0 then return end
    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    local _, rotatedMax = ent:GetRotatedAABB(mins, maxs)
    local bob = math.sin(CurTime() + idx) / 3 + 0.5
    local center = ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, math.abs(rotatedMax.z / 2) + 12 + bob)
    local screenPos = toScreen(center)
    if screenPos.visible == false then return end
    EntText(text, screenPos.x, screenPos.y + posY, fade)
end

--[[
    Purpose:
        Creates a dropdown selection dialog for user choice

    When Called:
        When user needs to select from a list of options

    Parameters:
        title (string, optional) - Title of the dialog
        options (table) - Array of options (strings or {text, data} tables)
        callback (function) - Callback function called with selected option
        defaultValue (string/table, optional) - Default selected value

    Returns:
        Panel - The created dialog frame

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Request dropdown selection
    local options = {"Option 1", "Option 2", "Option 3"}
    lia.derma.requestDropdown("Choose Option", options, function(selected)
    print("Selected:", selected)
    end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Request with data values and default
    local options = {
    {"Kick Player", "kick"},
    {"Ban Player", "ban"},
    {"Mute Player", "mute"}
    }
    lia.derma.requestDropdown("Admin Action", options, function(text, data)
    performAction(data)
    end, "kick")
    ```

    High Complexity:
    ```lua
    -- High: Dynamic options with validation
    local options = {}
    for _, player in player.Iterator() do
        if IsValid(player) then
            table.insert(options, {player:Name(), player:SteamID()})
        end
    end
    lia.derma.requestDropdown("Select Player", options, function(name, steamid)
    if steamid and steamid ~= "" then
        processPlayerSelection(steamid)
    end
    end)
    ```
]]
function lia.derma.requestDropdown(title, options, callback, defaultValue)
    if IsValid(lia.gui.menuRequestDropdown) then lia.gui.menuRequestDropdown:Remove() end
    local numOptions = istable(options) and #options or 0
    local itemHeight = 26
    local itemMargin = 2
    local dropdownHeight = math.min(numOptions * (itemHeight + itemMargin) + 12, 400)
    local frameHeight = 140 + dropdownHeight
    local frame = vgui.Create("liaFrame")
    frame:SetSize(300, frameHeight)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("selectOption"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local dropdown = vgui.Create("liaComboBox", frame)
    dropdown:Dock(TOP)
    dropdown:DockMargin(20, 20, 20, 20)
    dropdown:SetTall(30)
    dropdown:SetMouseInputEnabled(true)
    dropdown:SetKeyboardInputEnabled(true)
    if istable(options) then
        for _, option in ipairs(options) do
            if istable(option) then
                dropdown:AddChoice(option[1], option[2])
            else
                dropdown:AddChoice(tostring(option))
            end
        end
    end

    if defaultValue then
        if istable(defaultValue) then
            dropdown:ChooseOptionData(defaultValue[2])
        else
            dropdown:ChooseOption(tostring(defaultValue))
        end
    end

    dropdown:PostInit()
    if #options > 0 then
        local firstOption = options[1]
        if istable(firstOption) then
            dropdown:ChooseOption(firstOption[1])
            dropdown.selectedText = firstOption[1]
            dropdown.selectedData = firstOption[2]
        else
            dropdown:ChooseOption(tostring(firstOption))
            dropdown.selectedText = tostring(firstOption)
        end
    end

    dropdown.OnSelect = function(_, _, value, data)
        dropdown.selectedText = value
        dropdown.selectedData = data
        dropdown.selected = value
    end

    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(RIGHT)
    submitBtn:SetWide(100)
    submitBtn:SetTxt(L("select"))
    submitBtn.DoClick = function()
        local selectedText = dropdown.selectedText or dropdown:GetValue()
        local selectedData = dropdown.selectedData or dropdown:GetSelectedData()
        if not selectedText and #options > 0 then
            local firstOption = options[1]
            if istable(firstOption) then
                selectedText = firstOption[1]
                selectedData = firstOption[2]
            else
                selectedText = tostring(firstOption)
            end
        end

        if callback then
            if selectedData ~= nil then
                callback(selectedText, selectedData)
            else
                callback(selectedText)
            end
        end

        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetWide(100)
    cancelBtn:SetTxt(L("cancel"))
    cancelBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestDropdown = frame
    return frame
end

--[[
    Purpose:
        Creates a text input dialog for user string entry

    When Called:
        When user needs to input text through a dialog

    Parameters:
        title (string, optional) - Title of the dialog
        description (string, optional) - Description text for the input
        callback (function) - Callback function called with entered text
        defaultValue (string, optional) - Default text value
        maxLength (number, optional) - Maximum text length

    Returns:
        Panel - The created dialog frame

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Request text input
    lia.derma.requestString("Enter Name", "Type your name:", function(text)
    if text and text ~= "" then
        print("Name:", text)
    end
    end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Request with default value and max length
    lia.derma.requestString("Set Password", "Enter new password:", function(password)
    if string.len(password) >= 6 then
        setPassword(password)
    end
    end, "", 20)
    ```

    High Complexity:
    ```lua
    -- High: Request with validation and processing
    lia.derma.requestString("Create Item", "Enter item name:", function(name)
    if not name or name == "" then return end

        local cleanName = string.Trim(name)
        if string.len(cleanName) < 3 then
            notify("Name too short!")
            return
        end

        if itemExists(cleanName) then
            notify("Item already exists!")
            return
        end

        createItem(cleanName)
    end, "", 50)
    ```
]]
function lia.derma.requestString(title, description, callback, defaultValue, maxLength)
    if IsValid(lia.gui.menuRequestString) then lia.gui.menuRequestString:Remove() end
    local vendorPanel = lia.gui.vendor
    local vendorEditor = lia.gui.vendorEditor
    if IsValid(vendorPanel) then vendorPanel:SetVisible(false) end
    if IsValid(vendorEditor) then vendorEditor:SetVisible(false) end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(600, 300)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("enterText"))
    frame:ShowAnimation()
    frame.OnRemove = function()
        if IsValid(vendorPanel) then vendorPanel:SetVisible(true) end
        if IsValid(vendorEditor) then vendorEditor:SetVisible(true) end
    end

    local descriptionLabel = vgui.Create("DLabel", frame)
    descriptionLabel:Dock(TOP)
    descriptionLabel:DockMargin(20, 40, 20, 10)
    descriptionLabel:SetText(description or L("enterValue"))
    descriptionLabel:SetFont("LiliaFont.17")
    descriptionLabel:SetTextColor(lia.color.theme.text or color_white)
    descriptionLabel:SetContentAlignment(5)
    descriptionLabel:SizeToContents()
    local textEntry = vgui.Create("liaEntry", frame)
    textEntry:Dock(TOP)
    textEntry:DockMargin(20, 0, 20, 20)
    textEntry:SetTall(30)
    textEntry:SetTitle("")
    if defaultValue then textEntry:SetValue(tostring(defaultValue)) end
    if maxLength then textEntry:SetMaxLength(maxLength) end
    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(RIGHT)
    submitBtn:SetWide(120)
    submitBtn:SetTxt(L("submit"))
    submitBtn.DoClick = function()
        local value = textEntry:GetValue()
        if callback then callback(value) end
        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetWide(120)
    cancelBtn:SetTxt(L("cancel"))
    cancelBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestString = frame
    return frame
end

--[[
    Purpose:
        Creates a multi-select dialog for choosing multiple options

    When Called:
        When user needs to select multiple options from a list

    Parameters:
        title (string, optional) - Title of the dialog
        options (table) - Array of options (strings or {text, data} tables)
        callback (function) - Callback function called with selected options array
        defaults (table, optional) - Array of default selected values

    Returns:
        Panel - The created dialog frame

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Request multiple selections
    local options = {"Option 1", "Option 2", "Option 3"}
    lia.derma.requestOptions("Choose Options", options, function(selected)
    print("Selected:", table.concat(selected, ", "))
    end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Request with data values and defaults
    local options = {
    {"Admin", "admin"},
    {"Moderator", "moderator"},
    {"VIP", "vip"}
    }
    local defaults = {"admin"}
    lia.derma.requestOptions("Select Roles", options, function(selected)
    assignRoles(selected)
    end, defaults)
    ```

    High Complexity:
    ```lua
    -- High: Dynamic options with validation
    local options = {}
    for _, permission in pairs(availablePermissions) do
        table.insert(options, {permission.displayName, permission.id})
    end
    lia.derma.requestOptions("Select Permissions", options, function(selected)
    if #selected > 0 then
        validateAndAssignPermissions(selected)
        else
            notify("Please select at least one permission!")
        end
    end, userPermissions)
    ```
]]
function lia.derma.requestOptions(title, options, callback, defaults)
    if IsValid(lia.gui.menuRequestOptions) then lia.gui.menuRequestOptions:Remove() end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(500, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("selectOptions"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local scrollPanel = vgui.Create("liaScrollPanel", frame)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(20, 40, 20, 60)
    local checkboxes = {}
    if istable(options) then
        for _, option in ipairs(options) do
            local optionText
            local optionData
            if istable(option) then
                optionText = option[1] or tostring(option[2])
                optionData = option[2]
            else
                optionText = tostring(option)
                optionData = option
            end

            local optionPanel = vgui.Create("Panel", scrollPanel)
            optionPanel:Dock(TOP)
            optionPanel:DockMargin(0, 5, 0, 5)
            optionPanel:SetTall(30)
            local checkbox = vgui.Create("liaCheckbox", optionPanel)
            checkbox:Dock(LEFT)
            checkbox:SetWide(30)
            checkbox:SetChecked(defaults and table.HasValue(defaults, optionData))
            local label = vgui.Create("DLabel", optionPanel)
            label:Dock(FILL)
            label:DockMargin(40, 0, 0, 0)
            label:SetText(optionText)
            label:SetFont("LiliaFont.17")
            label:SetTextColor(lia.color.theme.text or color_white)
            label:SetContentAlignment(4)
            checkboxes[optionData] = checkbox
        end
    end

    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(RIGHT)
    submitBtn:SetWide(120)
    submitBtn:SetTxt(L("confirm"))
    submitBtn.DoClick = function()
        local selectedOptions = {}
        for optionData, checkbox in pairs(checkboxes) do
            if checkbox:GetChecked() then table.insert(selectedOptions, optionData) end
        end

        if callback then callback(selectedOptions) end
        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetWide(120)
    cancelBtn:SetTxt(L("cancel"))
    cancelBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestOptions = frame
    return frame
end

--[[
    Purpose:
        Creates a yes/no confirmation dialog

    When Called:
        When user confirmation is needed for an action

    Parameters:
        title (string, optional) - Title of the dialog
        question (string, optional) - Question text to display
        callback (function) - Callback function called with boolean result
        yesText (string, optional) - Text for yes button
        noText (string, optional) - Text for no button

    Returns:
        Panel - The created dialog frame

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Request confirmation
    lia.derma.requestBinaryQuestion("Confirm", "Are you sure?", function(result)
    if result then
        print("User confirmed")
        else
            print("User cancelled")
        end
    end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Request with custom button text
    lia.derma.requestBinaryQuestion("Delete Item", "Delete this item permanently?", function(result)
    if result then
        deleteItem(item)
    end
    end, "Delete", "Cancel")
    ```

    High Complexity:
    ```lua
    -- High: Request with validation and logging
    lia.derma.requestBinaryQuestion("Admin Action", "Execute admin command: " .. command .. "?", function(result)
    if result then
        if validateAdminCommand(command) then
            executeAdminCommand(command)
            logAdminAction(command)
            else
                notify("Invalid command!")
            end
        end
    end, "Execute", "Cancel")
    ```
]]
function lia.derma.requestBinaryQuestion(title, question, callback, yesText, noText)
    if IsValid(lia.gui.menuRequestBinary) then lia.gui.menuRequestBinary:Remove() end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(450, 220)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("question"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local questionLabel = vgui.Create("DLabel", frame)
    questionLabel:Dock(TOP)
    questionLabel:DockMargin(20, 40, 20, 20)
    questionLabel:SetText(question or L("areYouSure"))
    questionLabel:SetFont("LiliaFont.18")
    questionLabel:SetTextColor(lia.color.theme.text or color_white)
    questionLabel:SetContentAlignment(5)
    questionLabel:SizeToContents()
    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local yesBtn = vgui.Create("liaButton", buttonPanel)
    yesBtn:Dock(RIGHT)
    yesBtn:DockMargin(10, 0, 0, 0)
    yesBtn:SetWide(140)
    yesBtn:SetTxt(yesText or L("yes"))
    yesBtn.DoClick = function()
        if callback then callback(true) end
        frame:Remove()
    end

    local noBtn = vgui.Create("liaButton", buttonPanel)
    noBtn:Dock(LEFT)
    noBtn:DockMargin(0, 0, 10, 0)
    noBtn:SetWide(140)
    noBtn:SetTxt(noText or L("no"))
    noBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestBinary = frame
    return frame
end

--[[
    Purpose:
        Creates a dialog with multiple action buttons

    When Called:
        When user needs to choose from multiple actions

    Parameters:
        title (string, optional) - Title of the dialog
        buttons (table) - Array of button definitions (strings or {text, callback, icon} tables)
        callback (function, optional) - Default callback function
        description (string, optional) - Description text for the dialog

    Returns:
        Panel, Table - The created dialog frame and button panels array

    Realm:
        Client

    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Request button selection
    local buttons = {"Option 1", "Option 2", "Option 3"}
    lia.derma.requestButtons("Choose Action", buttons, function(index, text)
    print("Selected:", text)
    end)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Request with custom callbacks and icons
    local buttons = {
    {text = "Edit", callback = function() editItem() end, icon = "icon16/pencil.png"},
    {text = "Delete", callback = function() deleteItem() end, icon = "icon16/delete.png"},
    {text = "Copy", callback = function() copyItem() end, icon = "icon16/copy.png"}
    }
    lia.derma.requestButtons("Item Actions", buttons, nil, "Choose an action for this item")
    ```

    High Complexity:
    ```lua
    -- High: Dynamic buttons with validation
    local buttons = {}
    if player:IsAdmin() then
        table.insert(buttons, {text = "Admin Panel", callback = function() openAdminPanel() end})
    end
    if item:CanEdit() then
        table.insert(buttons, {text = "Edit", callback = function() editItem(item) end})
    end
    table.insert(buttons, {text = "View", callback = function() viewItem(item) end})

    lia.derma.requestButtons("Item Options", buttons, function(index, text)
    logAction("Button clicked: " .. text)
    end, "Available actions for " .. item:GetName())
    ```
]]
function lia.derma.requestButtons(title, buttons, callback, description)
    if IsValid(lia.gui.menuRequestButtons) then lia.gui.menuRequestButtons:Remove() end
    local buttonCount = #buttons
    local frameHeight = 200 + (buttonCount * 45)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(350, frameHeight)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("selectOption"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local descriptionLabel = vgui.Create("DLabel", frame)
    descriptionLabel:Dock(TOP)
    descriptionLabel:DockMargin(20, 40, 20, 20)
    descriptionLabel:SetText(description or "")
    descriptionLabel:SetFont("LiliaFont.17")
    descriptionLabel:SetTextColor(lia.color.theme.text or color_white)
    descriptionLabel:SetContentAlignment(5)
    descriptionLabel:SizeToContents()
    local buttonContainer = vgui.Create("Panel", frame)
    buttonContainer:Dock(FILL)
    buttonContainer:DockMargin(20, 0, 20, 60)
    local buttonPanels = {}
    for i, buttonInfo in ipairs(buttons) do
        local buttonText = ""
        local buttonCallback = nil
        local buttonIcon = nil
        if istable(buttonInfo) then
            buttonText = buttonInfo.text or buttonInfo[1] or tostring(buttonInfo)
            buttonCallback = buttonInfo.callback or buttonInfo[2]
            buttonIcon = buttonInfo.icon or buttonInfo[3]
        else
            buttonText = tostring(buttonInfo)
        end

        local buttonPanel = vgui.Create("Panel", buttonContainer)
        buttonPanel:Dock(TOP)
        buttonPanel:DockMargin(0, 5, 0, 5)
        buttonPanel:SetTall(40)
        local button = vgui.Create("liaButton", buttonPanel)
        button:Dock(FILL)
        button:DockMargin(0, 0, 0, 0)
        button:SetTxt(buttonText)
        if buttonIcon then button:SetIcon(buttonIcon) end
        button.DoClick = function()
            if buttonCallback then
                local result = buttonCallback()
                if result ~= false then frame:Remove() end
            else
                if callback then
                    local result = callback(i, buttonText)
                    if result ~= false then frame:Remove() end
                else
                    frame:Remove()
                end
            end
        end

        buttonPanels[i] = button
    end

    local closeBtn = vgui.Create("liaButton", frame)
    closeBtn:Dock(BOTTOM)
    closeBtn:DockMargin(20, 10, 20, 20)
    closeBtn:SetTall(40)
    closeBtn:SetTxt(L("close"))
    closeBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestButtons = frame
    return frame, buttonPanels
end

--[[
    Purpose:
        Creates a popup dialog with a question and multiple buttons with individual callbacks

    When Called:
        When user needs to make a choice from multiple options with custom actions

    Parameters:
        question (string) - The question text to display
        buttons (table) - Array of button definitions {text, callback} where callback is executed when button is clicked

    Returns:
        frame (Panel) - The created dialog frame

    Realm:
        Client

    Example Usage:
    ```lua
    lia.derma.requestPopupQuestion("Are you sure you want to delete this?", {
        {"Yes", function()
            print("User clicked Yes")
        end},
        {"No", function()
            print("User clicked No")
        end},
        {"Maybe", function()
            print("User clicked Maybe")
        end}
    })
    ```
]]
function lia.derma.requestPopupQuestion(question, buttons)
    if IsValid(lia.gui.menuRequestPopup) then lia.gui.menuRequestPopup:Remove() end
    local buttonCount = #buttons
    local frameHeight = 180 + (buttonCount * 45)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(400, frameHeight)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(L("question"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local questionLabel = vgui.Create("DLabel", frame)
    questionLabel:Dock(TOP)
    questionLabel:DockMargin(20, 40, 20, 20)
    questionLabel:SetText(question or L("areYouSure"))
    questionLabel:SetFont("LiliaFont.14")
    questionLabel:SetTextColor(lia.color.theme.text or color_white)
    questionLabel:SetContentAlignment(5)
    questionLabel:SizeToContents()
    local buttonContainer = vgui.Create("Panel", frame)
    buttonContainer:Dock(FILL)
    buttonContainer:DockMargin(20, 0, 20, 20)
    for _, buttonInfo in ipairs(buttons) do
        local buttonText
        local buttonCallback = nil
        if istable(buttonInfo) then
            buttonText = buttonInfo[1] or tostring(buttonInfo)
            buttonCallback = buttonInfo[2]
        else
            buttonText = tostring(buttonInfo)
        end

        local buttonPanel = vgui.Create("Panel", buttonContainer)
        buttonPanel:Dock(TOP)
        buttonPanel:DockMargin(0, 5, 0, 5)
        buttonPanel:SetTall(40)
        local button = vgui.Create("liaButton", buttonPanel)
        button:Dock(FILL)
        button:SetTxt(buttonText)
        button.DoClick = function()
            if buttonCallback and isfunction(buttonCallback) then buttonCallback() end
            frame:Remove()
        end
    end

    lia.gui.menuRequestPopup = frame
    return frame
end

timer.Simple(0, function()
    if IsValid(lia.gui.menuDermaMenu) then lia.gui.menuDermaMenu:Remove() end
    if IsValid(lia.gui.menuTextBox) then lia.gui.menuTextBox:Remove() end
    if IsValid(lia.gui.menuColorPicker) then lia.gui.menuColorPicker:Remove() end
    if IsValid(lia.gui.menu_radial) then lia.gui.menu_radial:Remove() end
    if IsValid(lia.gui.menuPlayerSelector) then lia.gui.menuPlayerSelector:Remove() end
    if IsValid(lia.gui.menuRequestDropdown) then lia.gui.menuRequestDropdown:Remove() end
    if IsValid(lia.gui.menuRequestString) then lia.gui.menuRequestString:Remove() end
    if IsValid(lia.gui.menuRequestOptions) then lia.gui.menuRequestOptions:Remove() end
    if IsValid(lia.gui.menuRequestBinary) then lia.gui.menuRequestBinary:Remove() end
    if IsValid(lia.gui.menuRequestButtons) then lia.gui.menuRequestButtons:Remove() end
    if IsValid(lia.gui.menuRequestPopup) then lia.gui.menuRequestPopup:Remove() end
    if IsValid(lia.gui.menuOpenOptions) then lia.gui.menuOpenOptions:Remove() end
    if IsValid(lia.gui.menuTableUI) then lia.gui.menuTableUI:Remove() end
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
    if IsValid(lia.gui.InteractionMenu) then lia.gui.InteractionMenu:Remove() end
    if IsValid(lia.gui.OptionsMenu) then lia.gui.OptionsMenu:Remove() end
end)
