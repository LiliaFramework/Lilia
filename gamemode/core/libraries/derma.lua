--[[
    Folder: Libraries
    File: derma.md
]]
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
        Opens a fresh `liaDermaMenu` at the current cursor position and tracks it in `lia.gui.menuDermaMenu`.

    When Called:
        Use when you need a standard context menu for interaction options and want any previous one closed first.

    Parameters:
        None

    Returns:
        Panel
            The newly created `liaDermaMenu` panel.

    Realm:
        Client

    Example Usage:
        ```lua
            local menu = lia.derma.dermaMenu()
            menu:AddOption("Say hi", function() chat.AddText("hi") end)
            menu:Open()
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
        Builds and shows the configurable options/interaction menu, filtering and categorising provided options before rendering buttons.

    When Called:
        Use when presenting interaction, action, or custom options to the player, optionally tied to a targeted entity and network message.

    Parameters:
        rawOptions (table)
            Option definitions keyed by id or stored in an array; entries can include `type`, `range`, `target`, `shouldShow`, `callback`, and `onSelect`.
        config (table)
            Optional settings such as `mode` ("interaction", "action", or "custom"), `entity`, `netMsg`, `preFiltered`, `registryKey`, sizing fields, and behaviour toggles like `closeOnSelect`.

    Returns:
        Panel|nil
            The created frame when options are available; otherwise nil.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.optionsMenu({
                greet = {type = "action", callback = function(client) chat.AddText(client, " waves") end}
            }, {mode = "action"})
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
    if mode == "interaction" or mode == "action" then return lia.derma.interactionTooltip(rawOptions, config) end
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
            if option.type == "interaction" and lia.playerinteract then
                local maxRange = option.range and math.min(option.range, 100) or 100
                if lia.playerinteract.isWithinRange(client, ent, maxRange) then
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
            local minHeight = ScrH() * 0.25
            local maxHeight = ScrH() * 0.75
            frameH = math.max(minHeight, math.min(totalHeight, maxHeight))
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
        Creates and displays a tooltip-style interaction menu similar to magic/item tooltips, with enhanced visual effects and modern styling.

    When Called:
        Automatically called when opening player interaction (TAB) or personal actions (G) menus to provide a polished tooltip interface.

    Parameters:
        rawOptions (table)
            Raw interaction/action options data from playerinteract system.
        config (table)
            Configuration options including:
            - mode (string): "interaction", "action", or "custom"
            - entity (Entity): Target entity for interactions
            - title (string): Menu title override
            - closeKey (number): Key code to close menu
            - netMsg (string): Network message for server communication
            - preFiltered (boolean): Whether options are already filtered
            - emitHooks (boolean): Whether to trigger interaction hooks
            - registryKey (string): Key for GUI registry
            - autoCloseDelay (number): Auto-close timeout in seconds

    Returns:
        Panel|nil
            The created tooltip panel, or nil if no valid options.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Automatically called by lia.playerinteract.openMenu()
            -- Can also be called directly:
            local tooltip = lia.derma.interactionTooltip(interactions, {
                mode = "interaction",
                title = "Player Interactions",
                entity = targetPlayer
            })
        ```
]]
function lia.derma.interactionTooltip(rawOptions, config)
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
            if option.type == "interaction" and lia.playerinteract then
                local maxRange = option.range and math.min(option.range, 100) or 100
                if lia.playerinteract.isWithinRange(client, ent, maxRange) then
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

    local maxWidth = 350
    local lineHeight = 20
    local padding = 16
    local iconSize = 32
    local titleHeight = 28
    local sectionSpacing = 8
    local contentHeight = titleHeight + sectionSpacing
    local currentCategory = nil
    for _, entry in ipairs(optionsList) do
        if entry.isCategory then
            if currentCategory then contentHeight = contentHeight + sectionSpacing end
            contentHeight = contentHeight + 24
            currentCategory = entry.name
        else
            contentHeight = contentHeight + lineHeight + 2
        end
    end

    local tooltipWidth = maxWidth
    local tooltipHeight = math.min(contentHeight + padding * 2, ScrH() * 0.7)
    local screenW, screenH = ScrW(), ScrH()
    local tooltipX = screenW - tooltipWidth - 20
    local tooltipY = math.max(80, (screenH - tooltipHeight) / 2)
    local tooltip = vgui.Create("DPanel")
    tooltip:SetSize(tooltipWidth, tooltipHeight)
    tooltip:SetPos(tooltipX, tooltipY)
    tooltip:MakePopup()
    tooltip:SetDrawOnTop(true)
    tooltip:SetZPos(10000)
    tooltip:SetAlpha(0)
    tooltip:AlphaTo(255, 0.1)
    function tooltip:Paint(w, h)
        local radius = 8
        local accent = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme or Color(100, 150, 200)
        local background = lia.color.theme.background_alpha or lia.color.theme.background or Color(40, 40, 40, 240)
        lia.derma.rect(0, 0, w, h):Rad(radius):Color(lia.color.theme.window_shadow or Color(0, 0, 0, 50)):Shadow(8, 12):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.util.drawBlurAt(tooltipX, tooltipY, w, h)
        lia.derma.rect(0, 0, w, h):Rad(radius):Color(background):Draw()
        surface.SetDrawColor(accent.r, accent.g, accent.b, accent.a or 255)
        surface.DrawRect(0, 0, w, 3)
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

        surface.SetFont("LiliaFont.18")
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(padding, padding - 2)
        surface.DrawText(titleText)
    end

    if emitHooks then hook.Run("InteractionMenuOpened", tooltip) end
    local oldOnRemove = tooltip.OnRemove
    function tooltip:OnRemove()
        if oldOnRemove then oldOnRemove(self) end
        if emitHooks then hook.Run("InteractionMenuClosed") end
        if registryKey and lia.gui[registryKey] == self then lia.gui[registryKey] = nil end
    end

    local closeKey = config.closeKey
    if closeKey then
        function tooltip:Think()
            if not input.IsKeyDown(closeKey) then self:Remove() end
        end
    end

    local timerName = config.timerName or (mode ~= "custom" and "InteractionTooltip_Frame_Timer" or "OptionsTooltip_Frame_Timer")
    local autoCloseDelay = config.autoCloseDelay
    if autoCloseDelay == nil then autoCloseDelay = 30 end
    if timerName and autoCloseDelay and autoCloseDelay > 0 then
        timer.Remove(timerName)
        timer.Create(timerName, autoCloseDelay, 1, function() if IsValid(tooltip) then tooltip:Remove() end end)
    end

    local scroll = tooltip:Add("liaScrollPanel")
    scroll:SetPos(0, titleHeight + padding)
    scroll:SetSize(tooltipWidth, tooltipHeight - titleHeight - padding * 2)
    local layout = vgui.Create("DListLayout", scroll)
    layout:Dock(FILL)
    currentCategory = nil
    for _, entry in ipairs(optionsList) do
        if entry.isCategory then
            if currentCategory then
                local spacer = vgui.Create("DPanel", layout)
                spacer:SetTall(sectionSpacing)
                spacer:SetPaintBackground(false)
                layout:Add(spacer)
            end

            local categoryPanel = vgui.Create("DPanel", layout)
            categoryPanel:SetTall(20)
            categoryPanel:Dock(TOP)
            categoryPanel:DockMargin(padding, 0, padding, 4)
            categoryPanel:SetPaintBackground(false)
            function categoryPanel:Paint(w, h)
                local theme = lia.color.theme
                local categoryColor = entry.color or (theme and theme.category_accent or Color(100, 150, 200, 255))
                local textColor = theme and theme.category_text or theme and theme.text or color_white
                local lineColor = theme and theme.category_line or Color(255, 255, 255, 20)
                surface.SetDrawColor(categoryColor.r, categoryColor.g, categoryColor.b, 100)
                surface.DrawRect(0, h - 1, w, 1)
                local displayText = entry.name or ""
                if L then
                    local localized = L(displayText)
                    if localized and localized ~= "" then displayText = localized end
                end

                surface.SetFont("LiliaFont.16")
                surface.SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 255)
                surface.SetTextPos(0, 0)
                surface.DrawText(displayText)
                surface.SetDrawColor(lineColor.r, lineColor.g, lineColor.b, lineColor.a or 255)
                surface.DrawRect(0, h - 2, w, 1)
            end

            layout:Add(categoryPanel)
            currentCategory = entry.name
        else
            local btn = vgui.Create("DButton", layout)
            btn:SetTall(lineHeight)
            btn:Dock(TOP)
            btn:DockMargin(padding + iconSize + 8, 0, padding, 2)
            btn:SetText("")
            btn:SetPaintBackground(false)
            btn:SetCursor("hand")
            local displayText = entry.label or entry.id or ""
            if entry.opt and entry.opt.localized ~= false and L then
                local localized = L(displayText)
                if localized and localized ~= "" then displayText = localized end
            end

            function btn:Paint(w, h)
                local isHovered = self:IsHovered()
                if isHovered then
                    surface.SetDrawColor(255, 255, 255, 20)
                    surface.DrawRect(0, 0, w, h)
                end

                surface.SetFont("LiliaFont.16")
                local textColor = entry.opt and entry.opt.textColor or color_white
                if isHovered then textColor = Color(200, 220, 255, 255) end
                surface.SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 255)
                surface.SetTextPos(0, 2)
                surface.DrawText(displayText)
            end

            local iconMat = entry.opt and entry.opt.icon
            if iconMat then
                function btn:PaintOver(w, h)
                    surface.SetDrawColor(255, 255, 255, 200)
                    surface.SetMaterial(iconMat)
                    surface.DrawTexturedRect(-iconSize - 8, (h - iconSize) / 2, iconSize, iconSize)
                end
            end

            btn.DoClick = function()
                tooltip:AlphaTo(0, 0.1, 0, function() if IsValid(tooltip) then tooltip:Remove() end end)
                local optionData = entry.opt or {}
                local callback = optionData.callback or optionData.onRun
                if callback and not optionData.serverOnly then
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
                        callback(client, ent, entry, tooltip)
                        return
                    end

                    if istable(passContext) then
                        callback(unpack(passContext))
                        return
                    end

                    callback()
                end

                local messageName = optionData.serverOnly and (optionData.netMessage or netMsg) or nil
                if messageName then
                    net.Start(messageName)
                    net.WriteString(optionData.networkID or entry.id)
                    net.WriteBool(mode == "interaction")
                    net.WriteEntity(IsValid(ent) and ent or Entity(0))
                    if isfunction(optionData.writePayload) then optionData.writePayload() end
                    net.SendToServer()
                end

                if isfunction(optionData.onSelect) then optionData.onSelect(client, ent, entry, tooltip) end
            end

            local description = entry.opt and (entry.opt.description or entry.opt.desc)
            if isstring(description) and description ~= "" then
                if entry.opt.localizedDescription ~= false and L then description = L(description) end
                btn:SetTooltip(description)
            end

            layout:Add(btn)
        end
    end

    if registryKey then lia.gui[registryKey] = tooltip end
    return tooltip
end

--[[
    Purpose:
        Displays a modal color picker window that lets the user pick a hue and saturation/value, then returns the chosen color.

    When Called:
        Use when you need the player to choose a color for a UI element or configuration field.

    Parameters:
        func (function)
            Callback invoked with the selected Color when the user confirms.
        colorStandard (Color)
            Optional starting color; defaults to white.

    Returns:
        nil
            Operates through UI side effects and the supplied callback.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.requestColorPicker(function(col) print("Picked", col) end, Color(0, 200, 255))
        ```
]]
function lia.derma.requestColorPicker(func, colorStandard)
    if IsValid(lia.gui.menuColorPicker) then lia.gui.menuColorPicker:Remove() end
    local selected_color = colorStandard or Color(255, 255, 255)
    local hue = 0
    local saturation = 1
    local value = 1
    if colorStandard then
        local r, g, b = colorStandard.r / 255, colorStandard.g / 255, colorStandard.b / 255
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
        Spawns a radial selection menu using `liaRadialPanel` and stores the reference on `lia.gui.menu_radial`.

    When Called:
        Use for quick circular option pickers, such as pie-menu interactions.

    Parameters:
        options (table)
            Table passed directly to `liaRadialPanel:Init`, defining each radial entry.

    Returns:
        Panel
            The created `liaRadialPanel` instance.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.radialMenu({{label = "Yes", callback = function() print("yes") end}})
        ```
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
        Opens a player selector window listing all connected players and runs a callback when one is chosen.

    When Called:
        Use when an action needs the user to target a specific player from the current server list.

    Parameters:
        doClick (function)
            Called with the selected player entity after the user clicks a card.

    Returns:
        Panel
            The created selector frame stored on `lia.gui.menuPlayerSelector`.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.requestPlayerSelector(function(pl) chat.AddText("Selected ", pl:Name()) end)
        ```
]]
function lia.derma.requestPlayerSelector(doClick)
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
                doClick(pl)
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
local SHADERS_GMA = [========[R01BRAOHS2tdVNwrAMQWx2gAAAAAAFJORFhfMTc1Nzg3Nzk1NgAAdW5rbm93bgABAAAAAQAAAHNoYWRlcnMvZnhjLzE3NTc4Nzc5NTZfcm5keF9yb3VuZGVkX2JsdXJfcHMzMC52Y3MAUAUAAAAAAAAAAAAAAgAAAHNoYWRlcnMvZnhjLzE3NTc4Nzc5NTZfcm5keF9yb3VuZGVkX3BzMzAudmNzADQEAAAAAAAAAAAAAAMAAABzaGFkZXJzL2Z4Yy8xNzU3ODc3OTU2X3JuZHhfc2hhZG93c19ibHVyX3BzMzAudmNzADYFAAAAAAAAAAAAAAQAAABzaGFkZXJzL2Z4Yy8xNzU3ODc3OTU2X3JuZHhfc2hhZG93c19wczMwLnZjcwDeAwAAAAAAAAAAAAAFAAAAc2hhZGVycy9meGMvMTc1Nzg3Nzk1Nl9ybmR4X3ZlcnRleF92czMwLnZjcwAeAQAAAAAAAAAAAAAAAAAABgAAAAEAAAABAAAAAAAAAAAAAAACAAAAHUcBbAAAAAAwAAAA/////1AFAAAAAAAAGAUAQExaTUG0DgAABwUAAF0AAAABAABoqV8kgL/sqj/+eCjfxRdm72ukxxrZJOmY5BiSff6UK8jKnQg0wmy60gGA6OIVrm+AZ/lvb8Ywy3K8LU+BJPZn395onULJrRD4M/GDQNqeVSGshmtApEeReU+ZTtlBcM3KgMP5kNHFcYeMjOP18v1rXRkhTnsRXCivQkjpG0AzOenhnTzSeUk0VRjyYUnN3TMr2QcLKyqCwWb6m/Fs7nXcrvFthAwSs0ciBXYmrkwlQ310qhdU+A7QyOJg9+a4osRtdsSFsU0kDnqfMCg3LJ/xPGbKLgrBp9Gp9WHeJZlAkxwGefkRNGJxCIQHLe/mMKU3/zoj0lpzNB+tDMSouHs1pc4Tao0Vnw7+gilRptrVd106Cc9HdUId8tlzu3EUSh75xRLQ/LkyqbgLeHg6VjD9cWcx8Fdq1e3Icg6ut5v0rg30grbcJQU4teRPS4Wf5+1qeYTID52pLXIKqTBQGZtYOuSjbA8roO5AKZw7hBirqZ8H4WC7dSmHudrAvjtPeVPjOpABK3Q+N+KPu97KER7zTZMx9Uwmtb5yXpTSpKsuRX03kZxlL1bi4l8GF/2zPP1barOH4ZWuC4c+l/N+/naMPMfTau5LXAMg0FTc23AFYG1D0/BRWSIueZ8BeyFkoOL12W2I9Kvoga0GYSKR9rSnQdG9RkIFf0UXv8PYoESenIWvFLY7dFuzqNeJUXT4U0KKswIb5OLisV5vjTS/KZCkvZxgj6YVYOev8K2SUAd7wC2lrE6hJxdRxFSfnnlebSIjW7dIP3JJATeZBVJGQdPY7YTxKYISudydzgEjEeBGo8XP+7zuiF/53LicBsZu2m/gaEQ6RBGWkv5kMZTWRe1TS1xzLlxZCMSHRniAHZBA6+Xu7b5C5+vVYxG1/Uo7AXzUYRkaX076jIFYdhH5jiUl3kDFW80VAbJya5jVQPX6H0osnxcyY9Tqya7iENMj19Nf8NIXXsq31uSew+ev7LIyrqiGgDQc50KDmu7VTELYGEfVZmFjuPoOpNxzd3sGvn+tULFd8pEOTjzZNJIxmcVUGS8OTkRZa/0ntBj80P6HZzT3XJkv5Trc1zmAf0ee+mRuMXLO4o4wkkwvt2/JmeMRdGptSXBh015K/iwDqknZvuNbCwI7ILoeHP0S78lC3o6nQpe/96CeVmEPwXvbqbMly76i4z7ELTbbMHxCG4S0UjKUtB1R41Z4uDEEds624Zy8LnwjnJ6nJqEiEZy68bDShzBg8VoGqnl5/NFMBrTNpHdZ73euE2Fxm4tMBxDBOexUPSP5D2qcg73zMVTuCIE4i4blFWIwDdoPNG3SHQNLgZ+DLkLmgAlf3syt2myk5t2rTrqoYiw6Ow1EDNENSACJK+bu4IqiEFz7FEhJkq2G9tM+RZ4OHIqSikUymqgNIC5k+Se/4sk3gjKnqdW8UjO1f5CQNk8Z1kAAeIdFM67xRTGafWAbjIpA7f2bvMMPDtkHEAGXcC2RLd4ZcWRV79g8txCT8HjMBlzJA1S+2Kwsbws1SX+aIa/rm55ONmwVmaVcPWp6yf4xQ+hvBn2rZry1XVH+cCiXSN+DjgUpc9nL+QcwRixWTt1SHTTmbEkY2sZwfYT889oXKgTEpx8/qhVFQQYiS2FbhkeBXnxSXArAfnR6Pm4RmKhxw3Lvgjf4Eo4aSb2f4CEUlJVDjIeDeumTv/9OzAfoRZXEIDuXWcEZ4VoTdAAA/////wYAAAABAAAAAQAAAAAAAAAAAAAAAgAAAC+rzZYAAAAAMAAAAP////80BAAAAAAAAPwDAEBMWk1BgAoAAOsDAABdAAAAAQAAaJxe2IK/7KknxcSXK86dhEFS5n0YZtr4ZBTKG6WPr92ZGhquZzTIAKwwliLKh/wHyv7F/aVS8kpvJo5JPXNZPgXTFX/r2QzKEbGTOLiSpZb0yRzahJKiusbwU71tIeclNnMc/99W3WWjJetsaZ+WtSVKSPK1gik1voA3BrTI/PRBgTM4UIhTe2kkA8iMqPHiXR2hcqYwuuWgpVPHQXAVTuZnx9Zxn7bIpbv064K2rh42q3/XhlqkGkdjxR91QiiLMG9Chi6pQUshsjfAtQOYMGq/uDdmEXd3u6d7fVl4c4khoVbbs2840Tl3f+HX6kaJop667+ZhIxCIkHfBTkrJVyGuzpHDwvLTlI5u9FFg5v5w3m6nvQDpubo8iNPkx7pjnYOAApaD8p7PB42hx7Z/zDRIokdXY5O20wkNlzug1BHGm3HZuO0jXQsDIlSsiFurNm3N8maWhjLOKVcjm6y0TUPSQwTk/XUHjT/sj0X7Rq1sTXMCPdkV17lw+p6UozRKJJpxjouFdqyLH9BgT+fPSp2sWHjdy0kfhm8Sz94+HMWo5RtnOIfBws69zzbIFHJu70Jt32rZA6N5YM3No0C65Mi+FMX6HIqCu/DXXoGuKzxyBcnxURaE7ICSKx+A5aLOTWg+60yTxguXcqAx/RGYRJzv/6UDfEMoTjfRPz6a8TdPpNg2OxDLbzsu3SzLEwbPJMLSHS+ZuZ3QGew39UBbHHnxsyv3o3ft+zZ4/D8l/IIc0Ra0JFwgPkQQNl7gxpW0LFsfPjW7IobAXwqtczEM5HdClLhNE6YcRzQmtugRzHHrYnSOKpcf3mwr2AxTwpqtEw198bpfhpM1PQxKmSCJtzhuZz9atBHdInc/GhB2PlaDBm71z4I4T0EaDqgfp4WCmoolhi4Z4kJ9sWZ505wJxIOczgalRbgnERpjYFhSVUxmSs4yhEXijcptcncWvN87f0peWcxvWRFtiLdbxi33jFb8qklA7UnSp6cN0jz8Prs7QDJxAIUMN7WWnUSrJsHC1JEr+Z8WVMJGMYfLOVeRSCgu1BMHgvd7r9keQBsbMpUjIKBY9qeOqyZxyEu3HIWurvGd5r5mw8VE6J3kDUTxc4PRETqcyCIj52ys7wexeU3c/MSu6/UG0zFwJpJRzbTAhFWD9CamRx9SA8BrD7TtdErPhcc/L5diqGfBvN3WZv4Bp7rQHr4lfO2KUkxqq/8tVe7z+EpHN4WGYPS2k4Imc7PqUk5mNzk4jJ4YnWENas9Qz5JkNOZCJxSilqhDy4KqjHkiBCNmUJvWLy5XGu6TnwK4XJ9kCuA7EAOiM+H6uB8uxDTWt5CzuQD/////BgAAAAEAAAABAAAAAAAAAAAAAAACAAAA5CvzcQAAAAAwAAAA/////zYFAAAAAAAA/gQAQExaTUEgDgAA7QQAAF0AAAABAABohF/3ANos8ikRxPcBjHHEdepXp59WPT3vqirl6vheC7siJXviLHTHGaBqsjjm8uLG5Ve4w16rPpO+g1UZp520DHb0HpjYXJSk0M5IFR3Z3LJ6CXR6tPtNlqpMD8ZAKDdvjwcIwfPX2C0FiL5+eD32kebgYrV8PQnqCCxXZiN+/fwfAX0dF/AhVpUarBAj7DQRYywlck3WHyM09yjgwHsv5JdVZ+yabdwWo7K9bIQZkzVC4wJbWodKY9XjuDKoe7X6nat7dsjajdvnb8b5dWXoFBIwIuv4w+98OvjAM8uZqF4CbCoEBV/r7nqxx2RYsv+CYtPIPYAu6d7gK4BsVxy6kZRrI54N0cWF63nYa93Ce6GrkCPKg0p1QJMfe4/roFMA2GOp/7wkY2j3b+KwvFJh4vX2vsMdDL0oZ3MOhA5P+7nGrJECft7fEI7H9ykxU3jwbCyKfbBtPK6WSqWKiunXV2cHqBe9tNysHz0zGyIftTRZK8DXWdxswDEgAKhjqD+DIYey23RiC1HQX4oUMtadmoZ7QN9YcyhPnJQOPxMmKmtk7+DW6lBK92Ikyyr/lrZv+CR6c/Dhxr52JvtZLwWYv4bja08Ks6ZhHk9j9laSsMrN/q1XMbMtiAYleup8IXxgJgVYorVQBn/zcaRx0HTm7txKdNgWe4DyzrkqT7uYWTNNwLFmwKhiLd2RCGR4vwZ+nQsSS443H/TgPROTccB4WxTSBuSIRQVotQAUpJGTEmro0vsCEqoDkQxCuuHz7kWdWzXp5HQlwb2qlWYbd27nObHO1uUKJ9FpOkTInUPdWZ7I6Y3kcnGC5X2KabIzOPOh0GirJYmNpybhJrpLBRzQHvxV3AD0w3qP0Od67MrhZnv1wn3LDy8iroHOR58ab1jZ0xCGH9Qwo1EXtTuMUhyCi4riP5SiHFGRXXaOl32lW+rCoUi3QFm3wpoJ6N0kjQwAeUqHneaOjD3uyihFQrG6RC4VeVQLRwhW5kJIx9qXQBguOS4u1/hUlW+HfD3BwpdrvOBaICxBGNkAuju8+ah3vPyvESXbQZaDAhg7dfxnNOB951z/ftzEt489RsAZXz646GLTJGyLD25rLOhFRrn3LsVHgkQyD9YADf+fvwDYg9QHWCmhkgEluRTsiYcO87vMuma3+3++u3NmsSEPdDpYON6/EY4OE6WktRPDS19FflOA/aHh/GnrsQ7bJ7jYmV+d1R+3oXBMq+GIAkD3D/O22HroGKkoYC6tUQf1wMCmZ/mj+ihc6mtoV1KdVDLYWatmlR4U8avkG5RFI4vAs/7z0c34UDoutvoIwWrRG+rYQ1ALHp4+Nlquu3rhltrYk6n2gzSpnEjozJoJ+TGs4bttDCqggliwUCnHsDeRM8+wiGLEoo/ib+otxzTiRue28334DMQw3ec2PfzbLMnB5AYB8cw78oaIzkbRob5H+tsE0QFOwumh3nnyjOq1QuIIwJRCTs/wz+dhUJU7yKiMBfdYqJIa+tomn+Biaexl/d98Onnn+Aoguen1I29+DRkG7fvom2rHpXAOXH41W/cvczU0jwYabtKkdvA43c97oDu2rcegTlxpza4C4v/HquZa3nJ27UlYI89jM73vOSWcOfaRSoeEGXuwxgWGnGMaC1OKGrcp7+HsAUTec3yFir5DQWGN3ImkF17dOoXXAP////8GAAAAAQAAAAEAAAAAAAAAAAAAAAIAAABJTIjdAAAAADAAAAD/////3gMAAAAAAACmAwBATFpNQUAJAACVAwAAXQAAAAEAAGiMXviDP+ypJ8XER2Obf/Gub4RtwST2I5aFElPLRnYyBGKzzWHS3j92PM7OOrjSszB3wZMwdm0ahxEzeRRdNzXWcyklmZpnZnyTRC1yzISeAfbjOOXNofxCuF8x+RimSjb0+CE9pgV8Fgs6Nza/MSog2twkgUxmn0aoky4CECmnsEJJcQ66Ump+4tkbY284nKlxFxhT5k59LWkOwjOaFUysSXLX5R+gwJC82uA54PE1GidvXhqA/AkjGjcz0crb5k/rsqQ77T/wZsFhxana52fesSgZCV6fvqoGjkzqZnmsJVRGQcSPS2LBaJLIc+OOk8ZbDiGqBn5Xsxb9J31v/qjpov8yGxRyHi4yXRCCjE2QeaMeDtDSLxCXdTCYhjFtCJZytirhuAigToCAO1qMzZy4fREQYWlH0l8lEp13GryblNQkYNdwjgxZlwnavBf/O9G5hNH10VgiONbDa++CPCMStyDovKk1rOP6F3++I9wOyI5nnzYDxWd1Zo9j549iEsN8JbdhcD1JQUI/mt0N21t/FFJ5IWnChz3s/CmajA6AhG7xEXPc9SdqDDRegPwDBdktJSHOEpSmZOkeizeev4Emz0y76UP6oREqOSa8w9o2cgcxiPlbWqcQzIYb3D/WbwiYYexKjJM2Wszl2l401eHQLrduaUc5oYBufGT+do+LUUbxPvl1XwMIH6KyrwKFwHv2KsWRtCjNWB75xugj5FJcE1L1g2J2YUXkqFNuZveahmgjJ4KjyETVWv7DBlj6/GD5vJzEeIICH+mrkgKArOgHcEeMbNzGIUhAwY4wwMjxdMrUpwUwwKkmfx6L1eNjiqWrrholmk8qUGFN5IJMIvCAKUHujMSaqnCMO/7jvlWeWy5nsejSnWBNii/+YQJAxMBcUKmeSC54PzInKQxWTPygv1hxoD60xjr7B403/1ym7C0JKZEMrkLpB2dQ/9MrXqWH5jnpQuNd7GZ/wFYNMBQHQlODNaeWwPRJ8qbUlcgkeqWRC5/zhJ1H03Lb9hhGPTew9EHrKcDpUJvRQcJD2S5QMJ8wqbS6fODbJJxWCK6TU30bHf25JKqxv/S6sCAtPh7L/LypsErbO2f8sril+ZYtOWOdYJldzYzK79DNl453VbFjBfqlla+E74sKEC29OoaGAzIb+dFd8Ozl2fi1iB5tzXwwbauu9M0uKGvtZgQu2Zsx53qVwM7rC4TFKYfxEf7cAP////8GAAAAAQAAAAEAAAAAAAAAAAAAAAIAAAB3Q0KZAAAAADAAAAD/////HgEAAAAAAADmAABATFpNQWQBAADVAAAAXQAAAAEAAGiVXdSHP+xjGaphZkpGU+Usm+MtQUH83EbXXMjgea+yS5+C8AjZsriU7FrSa/C3QwfnfNO2E25hgUTRGIDQmsxKx7Q+ggw5O2Hyu6lPnEYPfqt3jvm3cjj6Z1X02PoibeZEF4V28Or5mSkKcqgZk6cbnqeeVgnqfAvD/O3uLu+nT7VAOydRrNBSD1yQVTBZUZtIJLmvDuIE27Eo7GuwHoYCUrVUwgW6q0SbikkxwEeOthaz5bMITbOd2JgjhkHkQV22VJTNinlRW2ADS1E/dJnyAAD/////AAAAAA==]========]
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
        Draws a rounded rectangle using the shader-based derma pipeline with the same radius on every corner.

    When Called:
        Use when rendering a simple rounded box with optional shape or blur flags.

    Parameters:
        radius (number)
            Corner radius to apply to all corners.
        x (number)
            X position of the box.
        y (number)
            Y position of the box.
        w (number)
            Width of the box.
        h (number)
            Height of the box.
        col (Color|nil)
            Fill color; defaults to solid white if omitted.
        flags (number|nil)
            Optional bitmask using `lia.derma` flag constants (shape, blur, corner suppression).

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.draw(8, 10, 10, 140, 48, Color(30, 30, 30, 220))
        ```
]]
function lia.derma.draw(radius, x, y, w, h, col, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius)
end

--[[
    Purpose:
        Draws only the outline of a rounded rectangle with configurable thickness.

    When Called:
        Use when you need a stroked rounded box while leaving the interior transparent.

    Parameters:
        radius (number)
            Corner radius for all corners.
        x (number)
            X position of the outline.
        y (number)
            Y position of the outline.
        w (number)
            Width of the outline box.
        h (number)
            Height of the outline box.
        col (Color|nil)
            Outline color; defaults to white when nil.
        thickness (number|nil)
            Outline thickness in pixels; defaults to 1.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawOutlined(10, 20, 20, 180, 60, lia.color.theme.text, 2)
        ```
]]
function lia.derma.drawOutlined(radius, x, y, w, h, col, thickness, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius, nil, thickness or 1)
end

--[[
    Purpose:
        Draws a rounded rectangle filled with the provided texture.

    When Called:
        Use when you need a textured rounded box instead of a solid color.

    Parameters:
        radius (number)
            Corner radius for all corners.
        x (number)
            X position.
        y (number)
            Y position.
        w (number)
            Width.
        h (number)
            Height.
        col (Color|nil)
            Modulation color for the texture; defaults to white.
        texture (ITexture)
            Texture handle to apply to the rectangle.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            local tex = Material("vgui/gradient-u"):GetTexture("$basetexture")
            lia.derma.drawTexture(6, 50, 50, 128, 64, color_white, tex)
        ```
]]
function lia.derma.drawTexture(radius, x, y, w, h, col, texture, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius, texture)
end

--[[
    Purpose:
        Convenience wrapper that draws a rounded rectangle using the base texture from a material.

    When Called:
        Use when you have an `IMaterial` and want its base texture applied to a rounded box.

    Parameters:
        radius (number)
            Corner radius for all corners.
        x (number)
            X position.
        y (number)
            Y position.
        w (number)
            Width.
        h (number)
            Height.
        col (Color|nil)
            Color modulation for the material.
        mat (IMaterial)
            Material whose base texture will be drawn.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawMaterial(6, 80, 80, 100, 40, color_white, Material("vgui/gradient-d"))
        ```
]]
function lia.derma.drawMaterial(radius, x, y, w, h, col, mat, flags)
    local tex = mat:GetTexture("$basetexture")
    if tex then return lia.derma.drawTexture(radius, x, y, w, h, col, tex, flags) end
end

--[[
    Purpose:
        Draws a filled circle using the rounded rectangle shader configured for circular output.

    When Called:
        Use when you need a smooth circle without manually handling radii or shapes.

    Parameters:
        x (number)
            Center X position.
        y (number)
            Center Y position.
        radius (number)
            Circle diameter; internally halved for corner radii.
        col (Color|nil)
            Fill color; defaults to white.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawCircle(100, 100, 48, Color(200, 80, 80, 255))
        ```
]]
function lia.derma.drawCircle(x, y, radius, col, flags)
    return lia.derma.draw(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, (flags or 0) + SHAPE_CIRCLE)
end

--[[
    Purpose:
        Draws only the outline of a circle with configurable thickness.

    When Called:
        Use for circular strokes such as selection rings or markers.

    Parameters:
        x (number)
            Center X position.
        y (number)
            Center Y position.
        radius (number)
            Circle diameter.
        col (Color|nil)
            Outline color.
        thickness (number|nil)
            Outline thickness; defaults to 1.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawCircleOutlined(200, 120, 40, lia.color.theme.accent, 2)
        ```
]]
function lia.derma.drawCircleOutlined(x, y, radius, col, thickness, flags)
    return lia.derma.drawOutlined(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, thickness, (flags or 0) + SHAPE_CIRCLE)
end

--[[
    Purpose:
        Draws a textured circle using a supplied texture handle.

    When Called:
        Use when you want a circular render that uses a specific texture rather than a solid color.

    Parameters:
        x (number)
            Center X position.
        y (number)
            Center Y position.
        radius (number)
            Circle diameter.
        col (Color|nil)
            Color modulation for the texture.
        texture (ITexture)
            Texture handle to apply.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawCircleTexture(64, 64, 32, color_white, Material("icon16/star.png"):GetTexture("$basetexture"))
        ```
]]
function lia.derma.drawCircleTexture(x, y, radius, col, texture, flags)
    return lia.derma.drawTexture(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, texture, (flags or 0) + SHAPE_CIRCLE)
end

--[[
    Purpose:
        Draws a textured circle using the base texture from an `IMaterial`.

    When Called:
        Use when you have a material and need to render its base texture within a circular mask.

    Parameters:
        x (number)
            Center X position.
        y (number)
            Center Y position.
        radius (number)
            Circle diameter.
        col (Color|nil)
            Color modulation for the material.
        mat (IMaterial)
            Material whose base texture will be drawn.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawCircleMaterial(48, 48, 28, color_white, Material("vgui/gradient-l"))
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
        Renders a blurred rounded shape using the blur shader while respecting per-corner radii and optional outline thickness.

    When Called:
        Use to blur a rectangular region (or other supported shapes) without drawing a solid fill.

    Parameters:
        x (number)
            X position of the blurred region.
        y (number)
            Y position of the blurred region.
        w (number)
            Width of the blurred region.
        h (number)
            Height of the blurred region.
        flags (number|nil)
            Bitmask using `lia.derma` flags to control shape, blur, and disabled corners.
        tl (number|nil)
            Top-left radius override.
        tr (number|nil)
            Top-right radius override.
        bl (number|nil)
            Bottom-left radius override.
        br (number|nil)
            Bottom-right radius override.
        thickness (number|nil)
            Optional outline thickness for partial arcs.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawBlur(0, 0, 220, 80, lia.derma.BLUR, 12, 12, 12, 12)
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
        Draws a configurable drop shadow behind a rounded shape, optionally using blur and manual color control.

    When Called:
        Use when you want a soft shadow around a shape with fine control over radii, spread, intensity, and flags.

    Parameters:
        x (number)
            X position of the shape casting the shadow.
        y (number)
            Y position of the shape casting the shadow.
        w (number)
            Width of the shape.
        h (number)
            Height of the shape.
        col (Color|nil|boolean)
            Shadow color; pass `false` to skip color modulation.
        flags (number|nil)
            Bitmask using `lia.derma` flags (shape, blur, corner suppression).
        tl (number|nil)
            Top-left radius override.
        tr (number|nil)
            Top-right radius override.
        bl (number|nil)
            Bottom-left radius override.
        br (number|nil)
            Bottom-right radius override.
        spread (number|nil)
            Pixel spread of the shadow; defaults to 30.
        intensity (number|nil)
            Shadow alpha scaling; defaults to `spread * 1.2`.
        thickness (number|nil)
            Optional outline thickness when rendering arcs.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawShadowsEx(40, 40, 200, 80, Color(0, 0, 0, 180), nil, 12, 12, 12, 12, 26, 32)
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
        Convenience wrapper to draw a drop shadow with the same radius on every corner.

    When Called:
        Use when you need a uniform-radius shadow without manually specifying each corner.

    Parameters:
        radius (number)
            Radius applied to all corners.
        x (number)
            X position.
        y (number)
            Y position.
        w (number)
            Width.
        h (number)
            Height.
        col (Color|nil)
            Shadow color.
        spread (number|nil)
            Pixel spread of the shadow.
        intensity (number|nil)
            Shadow alpha scaling.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawShadows(10, 60, 60, 180, 70, Color(0, 0, 0, 150))
        ```
]]
function lia.derma.drawShadows(radius, x, y, w, h, col, spread, intensity, flags)
    return lia.derma.drawShadowsEx(x, y, w, h, col, flags, radius, radius, radius, radius, spread, intensity)
end

--[[
    Purpose:
        Convenience wrapper that draws only the shadow outline for a uniform-radius shape.

    When Called:
        Use when you need a stroked shadow ring around a rounded box.

    Parameters:
        radius (number)
            Radius applied to all corners.
        x (number)
            X position.
        y (number)
            Y position.
        w (number)
            Width.
        h (number)
            Height.
        col (Color|nil)
            Shadow color.
        thickness (number|nil)
            Outline thickness for the shadow.
        spread (number|nil)
            Pixel spread of the shadow.
        intensity (number|nil)
            Shadow alpha scaling.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawShadowsOutlined(12, 40, 40, 160, 60, Color(0, 0, 0, 180), 2)
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
        Starts a chainable rectangle draw builder using the derma shader helpers.

    When Called:
        Use when you want to configure a rectangle (radius, color, outline, blur, etc.) through a fluent API before drawing.

    Parameters:
        x (number)
            X position of the rectangle.
        y (number)
            Y position of the rectangle.
        w (number)
            Width of the rectangle.
        h (number)
            Height of the rectangle.

    Returns:
        table
            Chainable rectangle builder supporting methods like `:Rad`, `:Color`, `:Outline`, and `:Draw`.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.rect(12, 12, 220, 80):Rad(10):Color(Color(40, 40, 40, 220)):Shadow():Draw()
        ```
]]
function lia.derma.rect(x, y, w, h)
    return lia.derma.Types.Rect(x, y, w, h)
end

--[[
    Purpose:
        Starts a chainable circle draw builder using the derma shader helpers.

    When Called:
        Use when you want to configure a circle (color, outline, blur, etc.) before drawing it.

    Parameters:
        x (number)
            Center X position.
        y (number)
            Center Y position.
        r (number)
            Circle diameter.

    Returns:
        table
            Chainable circle builder supporting methods like `:Color`, `:Outline`, `:Shadow`, and `:Draw`.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.circle(100, 100, 50):Color(lia.color.theme.accent):Outline(2):Draw()
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
--[[
    Purpose:
        Sets or clears a specific drawing flag on a bitmask using a flag value or named constant.

    When Called:
        Use when toggling derma drawing flags such as shapes or corner suppression.

    Parameters:
        flags (number)
            Current flag bitmask.
        flag (number|string)
            Flag value or key in `lia.derma` (e.g., "BLUR").
        bool (boolean)
            Whether to enable (`true`) or disable (`false`) the flag.

    Returns:
        number
            Updated flag bitmask.

    Realm:
        Client

    Example Usage:
        ```lua
            flags = lia.derma.setFlag(flags, "BLUR", true)
        ```
]]
function lia.derma.setFlag(flags, flag, bool)
    flag = lia.derma[flag] or flag
    if tobool(bool) then
        return bit.bor(flags, flag)
    else
        return bit.band(flags, bit.bnot(flag))
    end
end

--[[
    Purpose:
        Updates the default shape flag used by the draw helpers (rectangles and circles) when no explicit flag is provided.

    When Called:
        Use to globally change the base rounding style (e.g., figma, iOS, circle) for subsequent draw calls.

    Parameters:
        shape (number)
            Shape flag constant such as `lia.derma.SHAPE_FIGMA`; defaults to `SHAPE_FIGMA` when nil.

    Returns:
        nil
            Updates internal default state.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.setDefaultShape(lia.derma.SHAPE_IOS)
        ```
]]
function lia.derma.setDefaultShape(shape)
    defaultShape = shape or SHAPE_FIGMA
    defaultDrawFlags = defaultShape
end

--[[
    Purpose:
        Draws text with a single offset shadow before the main text for lightweight legibility.

    When Called:
        Use when you need a subtle shadow behind text without a full outline.

    Parameters:
        text (string)
            Text to draw.
        font (string)
            Font name.
        x (number)
            X position.
        y (number)
            Y position.
        colortext (Color)
            Foreground text color.
        colorshadow (Color)
            Shadow color.
        dist (number)
            Pixel offset for both X and Y shadow directions.
        xalign (number)
            Horizontal alignment (`TEXT_ALIGN_*`).
        yalign (number)
            Vertical alignment (`TEXT_ALIGN_*`).

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.shadowText("Hello", "LiliaFont.18", 200, 100, color_white, Color(0, 0, 0, 180), 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
        Draws text with a configurable outline by repeatedly rendering offset copies around the glyphs.

    When Called:
        Use when you need high-contrast text that stays legible on varied backgrounds.

    Parameters:
        text (string)
            Text to draw.
        font (string)
            Font name.
        x (number)
            X position.
        y (number)
            Y position.
        colour (Color)
            Main text color.
        xalign (number)
            Horizontal alignment (`TEXT_ALIGN_*`).
        outlinewidth (number)
            Total outline thickness in pixels.
        outlinecolour (Color)
            Color applied to the outline renders.

    Returns:
        number
            The value returned by `draw.DrawText` for the final text render.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawTextOutlined("Warning", "LiliaFont.16", 50, 50, color_white, TEXT_ALIGN_LEFT, 2, Color(0, 0, 0, 200))
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
        Draws a speech-bubble style tooltip with a triangular pointer and centered label.

    When Called:
        Use for lightweight tooltip rendering when you need a callout pointing to a position.

    Parameters:
        x (number)
            Left position of the bubble.
        y (number)
            Top position of the bubble.
        w (number)
            Bubble width.
        h (number)
            Bubble height including pointer.
        text (string)
            Text to display inside the bubble.
        font (string)
            Font used for the text.
        textCol (Color)
            Color of the label text.
        outlineCol (Color)
            Color used to draw the bubble outline/fill.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawTip(300, 200, 160, 60, "Hint", "LiliaFont.16", color_white, Color(20, 20, 20, 220))
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
        Draws text with a subtle shadow using `draw.TextShadow`, defaulting to common derma font and colors.

    When Called:
        Use when rendering HUD/UI text that benefits from a small shadow for readability.

    Parameters:
        text (string)
            Text to render.
        x (number)
            X position.
        y (number)
            Y position.
        color (Color|nil)
            Text color; defaults to white.
        alignX (number|nil)
            Horizontal alignment (`TEXT_ALIGN_*`), defaults to left.
        alignY (number|nil)
            Vertical alignment (`TEXT_ALIGN_*`), defaults to top.
        font (string|nil)
            Font name; defaults to `LiliaFont.16`.
        alpha (number|nil)
            Shadow alpha override; defaults to 57.5% of text alpha.

    Returns:
        number
            Width returned by `draw.TextShadow`.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawText("Objective updated", 20, 20, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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

--[[
    Purpose:
        Renders a configurable blurred box with optional border and draws one or more text lines inside it.

    When Called:
        Use for notification overlays, labels, or caption boxes that need automatic sizing and padding.

    Parameters:
        text (string|table)
            Single string or table of lines to display.
        x (number)
            Reference X coordinate.
        y (number)
            Reference Y coordinate.
        options (table|nil)
            Customisation table supporting `font`, `textColor`, `backgroundColor`, `borderColor`, `borderRadius`, `borderThickness`, `padding`, `blur`, `textAlignX`, `textAlignY`, `autoSize`, `width`, `height`, and `lineSpacing`.

    Returns:
        number, number
            The final box width and height.

    Realm:
        Client

    Example Usage:
        ```lua
            local w, h = lia.derma.drawBoxWithText("Saved", ScrW() * 0.5, 120, {textAlignX = TEXT_ALIGN_CENTER})
        ```
]]
local drawBoxOverlaps = {}
local drawBoxFrame = 0
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
    local overlapMargin = options.overlapMargin or 8
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

    if drawBoxFrame ~= FrameNumber() then
        drawBoxOverlaps = {}
        drawBoxFrame = FrameNumber()
    end

    local screenW, screenH = ScrW(), ScrH()
    local function intersects(cx, cy)
        for _, rect in ipairs(drawBoxOverlaps) do
            if cx < rect.x + rect.w + overlapMargin and cx + boxWidth + overlapMargin > rect.x and cy < rect.y + rect.h + overlapMargin and cy + boxHeight + overlapMargin > rect.y then return rect end
        end
    end

    boxX = math.Clamp(boxX, 0, screenW - boxWidth)
    boxY = math.Clamp(boxY, 0, screenH - boxHeight)
    local overlap = intersects(boxX, boxY)
    local attempts = 0
    while overlap and attempts < 8 do
        local down = overlap.y + overlap.h + overlapMargin
        local up = overlap.y - boxHeight - overlapMargin
        local nextY
        if down + boxHeight <= screenH then
            nextY = down
        else
            nextY = math.max(0, up)
        end

        boxY = math.Clamp(nextY, 0, screenH - boxHeight)
        overlap = intersects(boxX, boxY)
        attempts = attempts + 1
    end

    local shadow = options.shadow or {
        enabled = false
    }

    if shadow.enabled then lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Rad(borderRadius):Color(shadow.color or Color(0, 0, 0, 50)):Shadow(shadow.offsetX or 8, shadow.offsetY or 12):Shape(lia.derma.SHAPE_IOS):Draw() end
    if blur.enabled then lia.util.drawBlurAt(boxX, boxY, boxWidth, boxHeight, blur.amount, blur.passes, blur.alpha) end
    lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(backgroundColor):Rad(borderRadius):Draw()
    if borderThickness > 0 then lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(borderColor):Rad(borderRadius):Outline(borderThickness):Draw() end
    local accentBorder = options.accentBorder or {
        enabled = false
    }

    if accentBorder.enabled then
        surface.SetDrawColor((accentBorder.color or lia.color.theme.theme):Unpack())
        surface.DrawRect(boxX, boxY, boxWidth, accentBorder.height or 2)
    end

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

    drawBoxOverlaps[#drawBoxOverlaps + 1] = {
        x = boxX,
        y = boxY,
        w = boxWidth,
        h = boxHeight
    }
    return boxWidth, boxHeight
end

--[[
    Purpose:
        Draws a textured rectangle using either a supplied material or a material path.

    When Called:
        Use when you need to render a texture/material directly without rounded corners.

    Parameters:
        material (IMaterial|string)
            Material instance or path to the material.
        color (Color|nil)
            Color modulation for the draw; defaults to white.
        x (number)
            X position.
        y (number)
            Y position.
        w (number)
            Width.
        h (number)
            Height.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawSurfaceTexture("vgui/gradient-l", color_white, 10, 10, 64, 64)
        ```
]]
function lia.derma.drawSurfaceTexture(material, color, x, y, w, h)
    surface.SetDrawColor(color or Color(255, 255, 255))
    if isstring(material) then
        surface.SetMaterial(lia.util.getMaterial(material))
    else
        surface.SetMaterial(material)
    end

    surface.DrawTexturedRect(x, y, w, h)
end

--[[
    Purpose:
        Calls a named skin function on the panel's active skin (or the default skin) with the provided arguments.

    When Called:
        Use to defer drawing or layout to the current Derma skin implementation.

    Parameters:
        name (string)
            Skin function name to invoke.
        panel (Panel|nil)
            Target panel whose skin should be used; falls back to the default skin.
        a, b, c, d, e, f, g (any)
            Optional arguments forwarded to the skin function.

    Returns:
        any
            Whatever the skin function returns, or nil if unavailable.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.skinFunc("PaintButton", someButton, w, h)
        ```
]]
function lia.derma.skinFunc(name, panel, a, b, c, d, e, f, g)
    local skin = ispanel(panel) and IsValid(panel) and panel:GetSkin() or derma.GetDefaultSkin()
    if not skin then return end
    local func = skin[name]
    if not func then return end
    return func(skin, panel, a, b, c, d, e, f, g)
end

--[[
    Purpose:
        Smoothly moves a value toward a target using an exponential approach based on delta time.

    When Called:
        Use for UI animations or interpolations that should ease toward a target without overshoot.

    Parameters:
        current (number)
            Current value.
        target (number)
            Desired target value.
        speed (number)
            Exponential speed factor.
        dt (number)
            Frame delta time.

    Returns:
        number
            The updated value after applying the exponential approach.

    Realm:
        Client

    Example Usage:
        ```lua
            scale = lia.derma.approachExp(scale, 1, 4, FrameTime())
        ```
]]
function lia.derma.approachExp(current, target, speed, dt)
    local t = 1 - math.exp(-speed * dt)
    return current + (target - current) * t
end

--[[
    Purpose:
        Returns a cubic ease-out interpolation for values between 0 and 1.

    When Called:
        Use for easing animations that should start quickly and slow toward the end.

    Parameters:
        t (number)
            Normalized time between 0 and 1.

    Returns:
        number
            Eased value.

    Realm:
        Client

    Example Usage:
        ```lua
            local eased = lia.derma.easeOutCubic(progress)
        ```
]]
function lia.derma.easeOutCubic(t)
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

--[[
    Purpose:
        Returns a cubic ease-in/ease-out interpolation for values between 0 and 1.

    When Called:
        Use when you want acceleration at the start and deceleration at the end of an animation.

    Parameters:
        t (number)
            Normalized time between 0 and 1.

    Returns:
        number
            Eased value.

    Realm:
        Client

    Example Usage:
        ```lua
            local eased = lia.derma.easeInOutCubic(progress)
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
        Animates a panel from a scaled, transparent state to a target size/position with exponential easing and optional callback.

    When Called:
        Use to show panels with a smooth pop-in animation that scales and fades into place.

    Parameters:
        panel (Panel)
            Panel to animate.
        targetWidth (number)
            Final width.
        targetHeight (number)
            Final height.
        duration (number|nil)
            Time in seconds for the size/position animation; defaults to 0.18s.
        alphaDuration (number|nil)
            Time in seconds for the fade animation; defaults to the duration.
        callback (function|nil)
            Called once the animation finishes.
        scaleFactor (number|nil)
            Starting scale factor relative to the final size; defaults to 0.8.

    Returns:
        nil
            Mutates the panel in-place and assigns a Think hook.

    Realm:
        Client

    Example Usage:
        ```lua
            local pnl = vgui.Create("DPanel")
            pnl:SetPos(100, 100)
            lia.derma.animateAppearance(pnl, 300, 200, 0.2, nil, function() pnl:SetMouseInputEnabled(true) end)
        ```
]]
function lia.derma.animateAppearance(panel, targetWidth, targetHeight, duration, alphaDuration, callback, scaleFactor)
    scaleFactor = scaleFactor or 0.8
    if not IsValid(panel) then return end
    duration = (duration and duration > 0) and duration or 0.18
    alphaDuration = (alphaDuration and alphaDuration > 0) and alphaDuration or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or duration
    local targetX, targetY = panel:GetPos()
    local initialW = targetWidth * (scaleFactor and scaleFactor or scaleFactor)
    local initialH = targetHeight * (scaleFactor and scaleFactor or scaleFactor)
    local initialX = targetX + (targetWidth - initialW) / 2
    local initialY = targetY + (targetHeight - initialH) / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2
    panel:SetSize(initialW, initialH)
    panel:SetPos(initialX, initialY)
    panel:SetAlpha(0)
    local curW, curH = initialW, initialH
    local curX, curY = initialX, initialY
    local curA = 0
    local eps = 0.5
    local alpha_eps = 1
    local speedSize = 3 / math.max(0.0001, duration)
    local speedAlpha = 3 / math.max(0.0001, alphaDuration)
    panel.Think = function()
        if not IsValid(panel) then return end
        local dt = FrameTime()
        curW = lia.derma.approachExp(curW, targetWidth, speedSize, dt)
        curH = lia.derma.approachExp(curH, targetHeight, speedSize, dt)
        curX = lia.derma.approachExp(curX, targetX, speedSize, dt)
        curY = lia.derma.approachExp(curY, targetY, speedSize, dt)
        curA = lia.derma.approachExp(curA, 255, speedAlpha, dt)
        panel:SetSize(curW, curH)
        panel:SetPos(curX, curY)
        panel:SetAlpha(math.floor(curA + 0.5))
        local doneSize = math.abs(curW - targetWidth) <= eps and math.abs(curH - targetHeight) <= eps <= eps
        local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
        local doneAlpha = math.abs(curA - 255) <= alpha_eps
        if doneSize and donePos and doneAlpha then
            panel:SetSize(targetWidth, targetHeight)
            panel:SetPos(targetX, targetY)
            panel:SetAlpha(255)
            panel.Think = nil
            if callback then callback(panel) end
        end
    end
end

--[[
    Purpose:
        Repositions a panel so it remains within the visible screen area with a small padding.

    When Called:
        Use after moving or resizing a popup to prevent it from clipping off-screen.

    Parameters:
        panel (Panel)
            Panel to clamp.

    Returns:
        nil
            Mutates the panel position in-place.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.clampMenuPosition(myPanel)
        ```
]]
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

--[[
    Purpose:
        Draws a rectangular gradient using common VGUI gradient materials and optional rounding.

    When Called:
        Use when you need a directional gradient fill without creating custom materials.

    Parameters:
        x (number)
            X position.
        y (number)
            Y position.
        w (number)
            Width.
        h (number)
            Height.
        direction (number)
            Gradient index (1 = up, 2 = down, 3 = left, 4 = right).
        colorShadow (Color)
            Color modulation for the gradient texture.
        radius (number|nil)
            Corner radius; defaults to 0.
        flags (number|nil)
            Optional bitmask using `lia.derma` flags.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawGradient(0, 0, 200, 40, 2, Color(0, 0, 0, 180), 6)
        ```
]]
function lia.derma.drawGradient(x, y, w, h, direction, colorShadow, radius, flags)
    local listGradients = {Material("vgui/gradient_up"), Material("vgui/gradient_down"), Material("vgui/gradient-l"), Material("vgui/gradient-r")}
    radius = radius and radius or 0
    lia.derma.drawMaterial(radius, x, y, w, h, colorShadow, listGradients[direction], flags)
end

--[[
    Purpose:
        Splits text into lines that fit within a maximum width using the specified font.

    When Called:
        Use before rendering multi-line text to avoid manual word wrapping.

    Parameters:
        text (string)
            Text to wrap.
        width (number)
            Maximum line width in pixels.
        font (string|nil)
            Font to measure with; defaults to `LiliaFont.16`.

    Returns:
        table, number
            A table of wrapped lines and the widest measured width.

    Realm:
        Client

    Example Usage:
        ```lua
            local lines, maxW = lia.derma.wrapText("Hello world", 180, "LiliaFont.16")
        ```
]]
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
        Applies a screen-space blur behind the given panel by repeatedly sampling the blur material.

    When Called:
        Use when you want a translucent blurred background behind a Derma panel.

    Parameters:
        panel (Panel)
            Panel whose bounds define the blur area.
        amount (number|nil)
            Blur strength multiplier; defaults to 5.
        passes (number|nil)
            Number of blur passes; defaults to 0.2 steps up to 1.
        alpha (number|nil)
            Alpha applied to the blur draw; defaults to 255.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawBlur(myPanel, 4, 1, 200)
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

--[[
    Purpose:
        Draws a blur behind a panel and overlays a dark tint to emphasize foreground elements.

    When Called:
        Use for modal backdrops or to dim the UI behind dialogs.

    Parameters:
        panel (Panel)
            Panel whose bounds define the blur and tint area.
        amount (number|nil)
            Blur strength; defaults to 6.
        passes (number|nil)
            Number of blur passes; defaults to 5.
        alpha (number|nil)
            Alpha applied to the blur draw; defaults to 255.
        darkAlpha (number|nil)
            Alpha of the dark overlay; defaults to 220.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawBlackBlur(myPanel, 8, 4, 255, 180)
        ```
]]
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
        Applies a blur effect to a specific screen-space rectangle defined by coordinates and size.

    When Called:
        Use to blur a custom area of the screen that is not tied to a panel.

    Parameters:
        x (number)
            X position of the blur rectangle.
        y (number)
            Y position of the blur rectangle.
        w (number)
            Width of the blur rectangle.
        h (number)
            Height of the blur rectangle.
        amount (number|nil)
            Blur strength; defaults to 5.
        passes (number|nil)
            Number of blur passes; defaults to 0.2 steps up to 1.
        alpha (number|nil)
            Alpha applied to the blur draw; defaults to 255.

    Returns:
        nil
            Draws directly to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.drawBlurAt(100, 100, 200, 120, 6, 1, 180)
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
        Builds a dynamic argument entry form with typed controls and validates input before submission.

    When Called:
        Use when a command or action requires the player to supply multiple typed arguments.

    Parameters:
        title (string|nil)
            Title text key; defaults to `"enterArguments"`.
        argTypes (table)
            Ordered list or map describing fields; entries can be `"string"`, `"boolean"`, `"number"/"int"`, `"table"` (dropdown), or `"player"`, optionally with data and default values.
        onSubmit (function|nil)
            Callback receiving `(true, resultsTable)` on submit or `(false)` on cancel.
        defaults (table|nil)
            Default values keyed by field name.

    Returns:
        nil
            Operates through UI side effects and the provided callback.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.createTableUI("Players", {
                {name = "name", field = "name"},
                {name = "steamid", field = "steamid"}
            }, playerRows)
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

--[[
    Purpose:
        Builds a full-screen table UI with optional context actions, populating rows from provided data and column definitions.

    When Called:
        Use when you need to display tabular data (e.g., admin lists) with right-click options and copy support.

    Parameters:
        title (string|nil)
            Title text key; defaults to localized table list title.
        columns (table)
            Array of column definitions `{name = <lang key>, field = <data key>, width = <optional>}`.
        data (table)
            Array of row tables keyed by column fields.
        options (table|nil)
            Optional array of context menu option tables with `name`, `net`, and optional `ExtraFields`.
        charID (number|nil)
            Character identifier forwarded to network options.

    Returns:
        Panel, Panel
            The created frame and the underlying `DListView`.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.createTableUI("Players", {
                {name = "name", field = "name"},
                {name = "steamid", field = "steamid"}
            }, playerRows)
        ```
]]
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

--[[
    Purpose:
        Opens a compact options window from either a keyed table or an array of `{name, callback}` entries.

    When Called:
        Use for lightweight choice prompts where each option triggers a callback and then closes the window.

    Parameters:
        title (string|nil)
            Localized title text key; defaults to `"options"`.
        options (table)
            Either an array of option tables `{name=<text>, callback=<fn>}` or a map of `name -> callback`.

    Returns:
        Panel
            The created options frame.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.openOptionsMenu("Actions", {
                {name = "Heal", callback = function() net.Start("Heal") net.SendToServer() end}
            })
        ```
]]
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
        Draws floating text above an entity with distance-based fade and easing, caching per-entity scales.

    When Called:
        Use to display labels or names above entities that appear when nearby.

    Parameters:
        ent (Entity)
            Target entity to label.
        text (string)
            Text to display.
        posY (number|nil)
            Vertical offset for the text; defaults to 0.
        alphaOverride (number|nil)
            Optional alpha multiplier or raw alpha value.

    Returns:
        nil
            Draws directly to the screen and tracks internal fade state.

    Realm:
        Client

    Example Usage:
        ```lua
            hook.Add("PostDrawTranslucentRenderables", "DrawNames", function()
                for _, ent in ipairs(ents.FindByClass("npc_*")) do
                    lia.derma.drawEntText(ent, ent:GetClass(), 0)
                end
            end)
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
        Shows a modal dropdown prompt and returns the selected entry through a callback.

    When Called:
        Use when you need the player to choose a single option from a list with optional default selection.

    Parameters:
        title (string|nil)
            Title text key; defaults to `"selectOption"`.
        options (table)
            Array of options, either strings or `{text, data}` tables.
        callback (function|nil)
            Invoked with `selectedText` and optional `selectedData`, or `false` if cancelled.
        defaultValue (any|table|nil)
            Optional default selection value or `{text, data}` pair.

    Returns:
        Panel
            The created dropdown frame.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.requestDropdown("Choose color", {"Red", "Green", "Blue"}, function(choice) print("Picked", choice) end)
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
        Prompts the user for a single line of text with an optional description and default value.

    When Called:
        Use for simple text input such as renaming or entering custom values.

    Parameters:
        title (string|nil)
            Title text key; defaults to `"enterText"`.
        description (string|nil)
            Helper text displayed above the entry field.
        callback (function|nil)
            Invoked with the entered string, or `false` when cancelled.
        defaultValue (any|nil)
            Pre-filled value for the input field.
        maxLength (number|nil)
            Optional character limit.

    Returns:
        Panel
            The created input frame.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.requestString("Rename", "Enter a new name:", function(val) if val then print("New name", val) end end, "Default")
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
        Presents multiple selectable options, supporting dropdowns and checkboxes, and returns the chosen set.

    When Called:
        Use for multi-field configuration prompts where each option can be a boolean or a list of choices.

    Parameters:
        title (string|nil)
            Title text key; defaults to `"selectOptions"`.
        options (table)
            Array where each entry is either a value or `{display, data}` table; tables create dropdowns, values create checkboxes.
        callback (function|nil)
            Invoked with a table of selected values or `false` when cancelled.
        defaults (table|nil)
            Default selections; for dropdowns this can map option names to selected values.

    Returns:
        Panel
            The created options frame.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.requestOptions("Permissions", {{"Rank", {"User", "Admin"}}, "CanKick"}, function(result) PrintTable(result) end)
        ```
]]
function lia.derma.requestOptions(title, options, callback, defaults)
    defaults = defaults or {}
    if IsValid(lia.gui.menuRequestOptions) then lia.gui.menuRequestOptions:Remove() end
    local count = table.Count(options)
    local frameW, frameH = 600, math.min(350 + count * 100, ScrH() * 0.5)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("selectOptions"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local scrollPanel = vgui.Create("liaScrollPanel", frame)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(10, 40, 10, 10)
    local controls = {}
    if istable(options) then
        for _, option in ipairs(options) do
            local optionName, optionData
            if istable(option) then
                optionName = option[1] or tostring(option[2])
                optionData = option[2]
            else
                optionName = tostring(option)
                optionData = option
            end

            local panel = vgui.Create("DPanel", scrollPanel)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 10)
            panel:SetTall(90)
            panel.Paint = nil
            local label = vgui.Create("DLabel", panel)
            label:SetFont("LiliaFont.20")
            label:SetText(optionName)
            label:SizeToContents()
            local textW = select(1, surface.GetTextSize(optionName))
            local ctrl
            if istable(optionData) then
                ctrl = vgui.Create("liaComboBox", panel)
                local defaultChoiceIndex
                for idx, v in ipairs(optionData) do
                    if istable(v) then
                        ctrl:AddChoice(v[1], v[2])
                        if defaults[optionName] ~= nil and (v[2] == defaults[optionName] or v[1] == defaults[optionName]) then defaultChoiceIndex = idx end
                    else
                        ctrl:AddChoice(tostring(v))
                        if defaults[optionName] ~= nil and v == defaults[optionName] then defaultChoiceIndex = idx end
                    end
                end

                if defaultChoiceIndex then ctrl:ChooseOptionID(defaultChoiceIndex) end
                ctrl:FinishAddingOptions()
                ctrl:PostInit()
            else
                ctrl = vgui.Create("liaCheckbox", panel)
                ctrl:SetChecked(defaults and table.HasValue(defaults, optionData))
            end

            panel.PerformLayout = function(_, w, h)
                local ctrlH, ctrlW
                if ctrl:GetName() == "liaCheckbox" then
                    ctrlH, ctrlW = 22, 60
                else
                    ctrlH, ctrlW = 60, w * 0.85
                end

                local ctrlX = (w - ctrlW) / 2
                ctrl:SetPos(ctrlX, (h - ctrlH) / 2 + 6)
                ctrl:SetSize(ctrlW, ctrlH)
                label:SetPos((w - textW) / 2, (h - ctrlH) / 2 - 18)
            end

            controls[optionName] = {
                ctrl = ctrl,
                data = optionData
            }
        end
    end

    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(15, 15, 15, 15)
    buttonPanel:SetTall(90)
    buttonPanel.Paint = nil
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(LEFT)
    submitBtn:DockMargin(0, 0, 15, 0)
    submitBtn:SetWide(270)
    submitBtn:SetTxt(L("submit"))
    submitBtn.DoClick = function()
        local selectedOptions = {}
        for optionName, controlInfo in pairs(controls) do
            local ctrl = controlInfo.ctrl
            if ctrl:GetName() == "liaCheckbox" then
                if ctrl:GetChecked() then table.insert(selectedOptions, controlInfo.data) end
            elseif ctrl:GetName() == "liaComboBox" then
                local selectedText, selectedData = ctrl:GetSelected()
                if selectedData then
                    selectedOptions[optionName] = selectedData
                else
                    selectedOptions[optionName] = selectedText
                end
            end
        end

        if callback then callback(selectedOptions) end
        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(RIGHT)
    cancelBtn:SetWide(270)
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
        Displays a yes/no style modal dialog with customizable labels and forwards the response.

    When Called:
        Use when you need explicit confirmation from the player before executing an action.

    Parameters:
        title (string|nil)
            Title text key; defaults to `"question"`.
        question (string|nil)
            Prompt text; defaults to `"areYouSure"`.
        callback (function|nil)
            Invoked with `true` for yes, `false` for no.
        yesText (string|nil)
            Custom text for the affirmative button; defaults to `"yes"`.
        noText (string|nil)
            Custom text for the negative button; defaults to `"no"`.

    Returns:
        Panel
            The created dialog frame.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.requestBinaryQuestion("Confirm", "Delete item?", function(ok) if ok then print("Deleted") end end)
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
        Creates a dialog with a list of custom buttons and optional description, forwarding clicks to provided callbacks.

    When Called:
        Use for multi-action prompts where each button can perform custom logic and optionally prevent auto-close by returning false.

    Parameters:
        title (string|nil)
            Title text key; defaults to `"selectOption"`.
        buttons (table)
            Array of button definitions; each can be a string or a table with `text`, `callback`, and optional `icon`.
        callback (function|nil)
            Fallback invoked with `(index, buttonText)` when a button lacks its own callback; returning false keeps the dialog open.
        description (string|nil)
            Optional descriptive text shown above the buttons.

    Returns:
        Panel, table
            The created frame and a table of created button panels.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.requestButtons("Choose action", {"Heal", "Damage"}, function(_, text) print("Pressed", text) end, "Pick an effect:")
        ```
]]
function lia.derma.requestButtons(title, buttons, callback, description)
    if IsValid(lia.gui.menuRequestButtons) then lia.gui.menuRequestButtons:Remove() end
    local buttonCount = #buttons
    local frameHeight = 260 + (buttonCount * 45)
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
        Shows a small popup question with custom buttons, closing automatically unless a button callback prevents it.

    When Called:
        Use for quick confirmation prompts that need more than a binary choice.

    Parameters:
        question (string|nil)
            Prompt text; defaults to `"areYouSure"`.
        buttons (table)
            Array of button definitions; each can be a string or `{text, callback}` table.

    Returns:
        Panel
            The created popup frame.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.derma.requestPopupQuestion("Teleport where?", {{"City", function() net.Start("tp_city") net.SendToServer() end}, "Cancel"})
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
