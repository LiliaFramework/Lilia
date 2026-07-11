--[[
    Folder: Developer - Libraries
    File: lia.flag.md
]]
--[[
    Flags

    Flag helpers for registering character permission flags, storing flag metadata, reapplying flag callbacks on player spawn, and displaying available flags in the character information menu.
]]
--[[
    Overview:
        The flag library centralizes shared flag registration under `lia.flag`. Registered flags are stored in `lia.flag.list` with an optional localized description and callback. On the server, player spawn handling reapplies callbacks for each unique flag the player has. On the client, the information menu displays all registered flags and indicates whether the local character currently has each one.
]]
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--[[
    Purpose:
        Registers a character permission flag with an optional localized description and optional callback.

    Parameters:
        flag (string)
            The single-character flag identifier to register.

        desc (string|nil)
            The language token or description for the flag. When provided, it is resolved through lia.lang.resolveToken before being stored.

        callback (function|nil)
            Optional function called when the flag is applied or removed by flag handling code. The callback receives the player and a boolean indicating whether the flag is being given.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.flag.add("p", "@flagPhysgun", function(client, isGiven)
            if isGiven then
                client:Give("weapon_physgun")
            else
                client:StripWeapon("weapon_physgun")
            end
        end)
        ```

    Realm:
        Shared
]]
function lia.flag.add(flag, desc, callback)
    if lia.flag.list[flag] then return end
    lia.flag.list[flag] = {
        desc = desc and lia.lang.resolveToken(desc) or desc,
        callback = callback
    }
end

if SERVER then
    --[[
    Purpose:
        Reapplies registered flag callbacks for every unique flag the player has when spawn handling runs.

    Parameters:
        client (Player)
            The player whose current flags should be processed.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.flag.onSpawn(client)
        ```

    Realm:
        Server
]]
    function lia.flag.onSpawn(client)
        local flags = client:getFlags()
        local processed = {}
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not processed[flag] then
                processed[flag] = true
                local info = lia.flag.list[flag]
                if info and info.callback then info.callback(client, true) end
            end
        end
    end
end

lia.flag.add("C", "@flagSpawnVehicles")
lia.flag.add("z", "@flagSpawnSweps")
lia.flag.add("E", "@flagSpawnSents")
lia.flag.add("L", "@flagSpawnEffects")
lia.flag.add("r", "@flagSpawnRagdolls")
lia.flag.add("e", "@flagSpawnProps")
lia.flag.add("n", "@flagSpawnNpcs")
lia.flag.add("Z", "@flagInviteToYourFaction")
lia.flag.add("X", "@flagInviteToYourClass")
lia.flag.add("F", "@flagViewFactionRoster")
lia.flag.add("p", "@flagPhysgun", function(client, isGiven)
    if isGiven then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    else
        client:StripWeapon("weapon_physgun")
    end
end)

lia.flag.add("t", "@flagToolgun", function(client, isGiven)
    if isGiven then
        client:Give("gmod_tool")
        client:SelectWeapon("gmod_tool")
    else
        client:StripWeapon("gmod_tool")
    end
end)

if CLIENT then
    local function getFlagThemeColors()
        local theme = lia.color and lia.color.theme or {}
        local accent = theme.accent or theme.theme
        if not IsColor(accent) and lia.config and lia.config.get then accent = lia.config.get("Color") end
        if not IsColor(accent) then accent = Color(45, 190, 170) end
        local textColor = theme.text
        if not IsColor(textColor) then textColor = Color(225, 238, 238) end
        return accent, textColor
    end

    local function drawFlagPanel(x, y, w, h, radius, color, outline)
        draw.RoundedBox(radius, x, y, w, h, color)
        if outline then
            surface.SetDrawColor(outline)
            surface.DrawOutlinedRect(x, y, w, h, 1)
        end
    end

    local function createFlagButton(parent, label, accented, callback)
        local button = parent:Add("DButton")
        button:SetText("")
        button.Paint = function(self, w, h)
            local accent, textColor = getFlagThemeColors()
            local hovered = self:IsHovered() and self:IsEnabled()
            local background
            local outline
            if accented then
                background = Color(accent.r, accent.g, accent.b, hovered and 32 or 16)
                outline = Color(accent.r, accent.g, accent.b, hovered and 185 or 120)
            else
                background = hovered and Color(255, 255, 255, 10) or Color(4, 17, 22, 210)
                outline = Color(160, 190, 192, hovered and 90 or 48)
            end

            if not self:IsEnabled() then
                background = Color(255, 255, 255, 5)
                outline = Color(255, 255, 255, 22)
            end

            drawFlagPanel(0, 0, w, h, 5, background, outline)
            local color = self:IsEnabled() and (accented and accent or textColor) or Color(115, 135, 136)
            draw.SimpleText(label, "LiliaFont.17", w * 0.5, h * 0.5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        button.DoClick = function(self)
            if not self:IsEnabled() then return end
            lia.websound.playButtonSound()
            callback()
        end
        return button
    end

    local function addFlagInfoRow(parent, label, valueFunc, valueColorFunc)
        local row = parent:Add("DPanel")
        row:Dock(TOP)
        row:SetTall(46)
        row.Paint = function(_, w, h)
            surface.SetDrawColor(130, 160, 162, 35)
            surface.DrawRect(0, h - 1, w, 1)
            draw.SimpleText(label, "LiliaFont.16", 14, h * 0.5, Color(165, 187, 188), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local value = isfunction(valueFunc) and valueFunc() or valueFunc or ""
            local color = isfunction(valueColorFunc) and valueColorFunc() or valueColorFunc or Color(224, 235, 235)
            draw.SimpleText(value, "LiliaFont.16", w - 14, h * 0.5, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        return row
    end

    hook.Add("CreateInformationButtons", "liaInformationFlagsUnified", function(pages)
        table.insert(pages, {
            name = "charFlagsTitle",
            shouldShow = function() return true end,
            drawFunc = function(parent)
                parent:Clear()
                local client = LocalPlayer()
                local root = parent:Add("DPanel")
                root:Dock(FILL)
                root.Paint = function() end
                local listPanel = root:Add("DPanel")
                listPanel:Dock(LEFT)
                listPanel:SetWide(math.Clamp(ScrW() * 0.245, 360, 440))
                listPanel:DockMargin(0, 0, 12, 0)
                listPanel:DockPadding(12, 12, 12, 12)
                listPanel.Paint = function(_, w, h)
                    local accent = getFlagThemeColors()
                    drawFlagPanel(0, 0, w, h, 7, Color(5, 18, 23, 215), Color(accent.r, accent.g, accent.b, 58))
                end

                local detailPanel = root:Add("DPanel")
                detailPanel:Dock(FILL)
                detailPanel.Paint = function() end
                local controls = listPanel:Add("DPanel")
                controls:Dock(TOP)
                controls:SetTall(46)
                controls:DockMargin(0, 0, 0, 12)
                controls.Paint = function() end
                local filterMode = "all"
                local filterLabels = {
                    all = "All Flags",
                    granted = "Granted",
                    missing = "Not Granted"
                }

                local filterButton = controls:Add("DButton")
                filterButton:Dock(RIGHT)
                filterButton:SetWide(142)
                filterButton:DockMargin(8, 0, 0, 0)
                filterButton:SetText("")
                filterButton.Paint = function(self, w, h)
                    local accent = getFlagThemeColors()
                    local hovered = self:IsHovered()
                    drawFlagPanel(0, 0, w, h, 5, hovered and Color(255, 255, 255, 8) or Color(6, 20, 26, 225), Color(accent.r, accent.g, accent.b, hovered and 95 or 60))
                    draw.SimpleText(filterLabels[filterMode], "LiliaFont.16", 12, h * 0.5, Color(215, 229, 229), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText("▼", "LiliaFont.15", w - 16, h * 0.5, Color(175, 197, 198), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local searchPanel = controls:Add("DPanel")
                searchPanel:Dock(FILL)
                searchPanel:DockPadding(12, 0, 8, 0)
                searchPanel.Paint = function(_, w, h)
                    local accent = getFlagThemeColors()
                    drawFlagPanel(0, 0, w, h, 5, Color(6, 20, 26, 225), Color(accent.r, accent.g, accent.b, 60))
                end

                local searchEntry = searchPanel:Add("DTextEntry")
                searchEntry:Dock(FILL)
                searchEntry:SetFont("LiliaFont.16")
                searchEntry:SetTextColor(Color(225, 236, 236))
                searchEntry:SetCursorColor(getFlagThemeColors())
                searchEntry:SetPlaceholderText(L("searchFlags"))
                searchEntry:SetDrawBackground(false)
                searchEntry:SetPaintBackground(false)
                searchEntry:SetPaintBorderEnabled(false)
                local sectionLabel = listPanel:Add("DLabel")
                sectionLabel:Dock(TOP)
                sectionLabel:SetTall(34)
                sectionLabel:SetText("CHARACTER FLAGS")
                sectionLabel:SetFont("LiliaFont.17")
                sectionLabel:SetTextColor(getFlagThemeColors())
                sectionLabel:SetContentAlignment(4)
                local countLabel = listPanel:Add("DLabel")
                countLabel:Dock(BOTTOM)
                countLabel:SetTall(28)
                countLabel:SetFont("LiliaFont.15")
                countLabel:SetTextColor(Color(145, 169, 170))
                countLabel:SetContentAlignment(4)
                local listScroll = listPanel:Add("liaScrollPanel")
                listScroll:Dock(FILL)
                listScroll.Paint = function() end
                local listCanvas = listScroll:GetCanvas()
                if IsValid(listCanvas) then
                    listCanvas:DockPadding(0, 0, 4, 0)
                    listCanvas.Paint = function() end
                else
                    listCanvas = listScroll
                end

                local records = {}
                local selectedRecord
                local selectedCard
                local applyFilters
                local function hasFlag(record)
                    local char = client:getChar()
                    return char and char:hasFlags(record.name) or false
                end

                local function updateCount()
                    local visible = 0
                    for _, record in ipairs(records) do
                        if IsValid(record.card) and record.card:IsVisible() then visible = visible + 1 end
                    end

                    countLabel:SetText(string.format("%d %s", visible, visible == 1 and "flag" or "flags"))
                end

                local function matchesFilter(record)
                    local granted = hasFlag(record)
                    if filterMode == "granted" then return granted end
                    if filterMode == "missing" then return not granted end
                    return true
                end

                local function rebuildDetail(record)
                    selectedRecord = record
                    detailPanel:Clear()
                    local accent, textColor = getFlagThemeColors()
                    local header = detailPanel:Add("DPanel")
                    header:Dock(TOP)
                    header:SetTall(140)
                    header:DockMargin(0, 0, 0, 12)
                    header.Paint = function(_, w, h)
                        drawFlagPanel(0, 0, w, h, 7, Color(5, 18, 23, 218), Color(accent.r, accent.g, accent.b, 58))
                        draw.SimpleText(L("flag") .. " '" .. record.name .. "'", "LiliaFont.26", 28, 24, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        draw.SimpleText(record.description ~= "" and record.description or "No description available.", "LiliaFont.16", 28, 60, Color(165, 187, 188), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        local granted = hasFlag(record)
                        local statusColor = granted and Color(60, 225, 160) or Color(180, 195, 196)
                        draw.SimpleText(granted and "GRANTED" or "NOT GRANTED", "LiliaFont.16", 28, 102, statusColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end

                    local copyButton = createFlagButton(header, "COPY FLAG", false, function() SetClipboardText(record.name) end)
                    copyButton:SetSize(150, 42)
                    header.PerformLayout = function(_, w) copyButton:SetPos(w - 166, 49) end
                    local scroll = detailPanel:Add("liaScrollPanel")
                    scroll:Dock(FILL)
                    scroll.Paint = function() end
                    local canvas = scroll:GetCanvas()
                    if IsValid(canvas) then
                        canvas:DockPadding(0, 0, 4, 0)
                        canvas.Paint = function() end
                    else
                        canvas = scroll
                    end

                    local infoSection = canvas:Add("DPanel")
                    infoSection:Dock(TOP)
                    infoSection:DockMargin(0, 0, 0, 12)
                    infoSection:DockPadding(14, 48, 14, 14)
                    infoSection.Paint = function(_, w, h)
                        drawFlagPanel(0, 0, w, h, 7, Color(5, 18, 23, 205), Color(accent.r, accent.g, accent.b, 52))
                        draw.SimpleText("FLAG INFORMATION", "LiliaFont.17", 14, 16, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
                        surface.DrawRect(14, 39, w - 28, 1)
                    end

                    addFlagInfoRow(infoSection, "Identifier", record.name)
                    addFlagInfoRow(infoSection, "Status", function() return hasFlag(record) and "Granted" or "Not Granted" end, function() return hasFlag(record) and Color(60, 225, 160) or Color(180, 195, 196) end)
                    addFlagInfoRow(infoSection, "Character", function()
                        local char = client:getChar()
                        return char and tostring(char:getName() or L("unknown")) or L("none")
                    end)

                    infoSection.PerformLayout = function(self) self:SetTall(48 + 46 * 3 + 14) end
                    local descriptionSection = canvas:Add("DPanel")
                    descriptionSection:Dock(TOP)
                    descriptionSection:SetTall(170)
                    descriptionSection:DockMargin(0, 0, 0, 12)
                    descriptionSection:DockPadding(14, 50, 14, 14)
                    descriptionSection.Paint = function(_, w, h)
                        drawFlagPanel(0, 0, w, h, 7, Color(5, 18, 23, 205), Color(accent.r, accent.g, accent.b, 52))
                        draw.SimpleText("DESCRIPTION", "LiliaFont.17", 14, 16, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
                        surface.DrawRect(14, 39, w - 28, 1)
                    end

                    local description = descriptionSection:Add("DLabel")
                    description:Dock(FILL)
                    description:SetWrap(true)
                    description:SetAutoStretchVertical(true)
                    description:SetFont("LiliaFont.17")
                    description:SetTextColor(Color(205, 220, 220))
                    description:SetText(record.description ~= "" and record.description or "No description available.")
                    description:SetContentAlignment(7)
                end

                local function selectRecord(record)
                    if selectedRecord == record then
                        rebuildDetail(record)
                        return
                    end

                    if IsValid(selectedCard) then selectedCard.selected = false end
                    selectedRecord = record
                    selectedCard = record.card
                    if IsValid(selectedCard) then selectedCard.selected = true end
                    rebuildDetail(record)
                end

                for flagName, flagData in SortedPairs(lia.flag.list) do
                    if not isnumber(flagName) then
                        local record = {
                            name = tostring(flagName),
                            description = tostring(flagData.desc or "")
                        }

                        record.searchText = (record.name .. " " .. record.description):lower()
                        local card = listCanvas:Add("DButton")
                        card:Dock(TOP)
                        card:SetTall(82)
                        card:DockMargin(0, 0, 0, 8)
                        card:SetText("")
                        card.selected = false
                        card.Paint = function(self, w, h)
                            local cardAccent = getFlagThemeColors()
                            local active = self.selected
                            local hovered = self:IsHovered()
                            local background = active and Color(cardAccent.r, cardAccent.g, cardAccent.b, 18) or hovered and Color(255, 255, 255, 7) or Color(6, 20, 25, 205)
                            local outline = active and Color(cardAccent.r, cardAccent.g, cardAccent.b, 125) or Color(cardAccent.r, cardAccent.g, cardAccent.b, 42)
                            drawFlagPanel(0, 0, w, h, 5, background, outline)
                            if active then
                                surface.SetDrawColor(cardAccent.r, cardAccent.g, cardAccent.b, 235)
                                surface.DrawRect(0, 8, 3, h - 16)
                            end

                            draw.SimpleText(L("flag") .. " '" .. record.name .. "'", "LiliaFont.18", 16, 17, active and Color(245, 249, 249) or Color(220, 231, 231), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            draw.SimpleText(record.description, "LiliaFont.15", 16, 48, Color(145, 169, 170), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            local granted = hasFlag(record)
                            local statusColor = granted and Color(60, 225, 160) or Color(150, 170, 170)
                            draw.SimpleText(granted and "GRANTED" or "NOT GRANTED", "LiliaFont.14", w - 14, h * 0.5, statusColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        end

                        card.DoClick = function()
                            lia.websound.playButtonSound()
                            selectRecord(record)
                        end

                        record.card = card
                        records[#records + 1] = record
                    end
                end

                applyFilters = function()
                    local query = string.Trim(searchEntry:GetValue() or ""):lower()
                    for _, record in ipairs(records) do
                        local visible = matchesFilter(record) and (query == "" or record.searchText:find(query, 1, true) ~= nil)
                        if IsValid(record.card) then record.card:SetVisible(visible) end
                    end

                    if IsValid(listCanvas) then listCanvas:InvalidateLayout(true) end
                    updateCount()
                end

                filterButton.DoClick = function()
                    lia.websound.playButtonSound()
                    local menu = DermaMenu()
                    menu:AddOption("All Flags", function()
                        filterMode = "all"
                        applyFilters()
                    end)

                    menu:AddOption("Granted", function()
                        filterMode = "granted"
                        applyFilters()
                    end)

                    menu:AddOption("Not Granted", function()
                        filterMode = "missing"
                        applyFilters()
                    end)

                    menu:Open()
                end

                if #records == 0 then
                    countLabel:SetText("0 flags")
                    local empty = listCanvas:Add("DLabel")
                    empty:Dock(TOP)
                    empty:SetTall(80)
                    empty:SetText("No flags available.")
                    empty:SetContentAlignment(5)
                    empty:SetTextColor(Color(150, 170, 170))
                    empty:SetFont("LiliaFont.18")
                    detailPanel.Paint = function(_, w, h)
                        local accent = getFlagThemeColors()
                        drawFlagPanel(0, 0, w, h, 7, Color(5, 18, 23, 190), Color(accent.r, accent.g, accent.b, 45))
                        draw.SimpleText("No flags available.", "LiliaFont.20", w * 0.5, h * 0.5, Color(150, 170, 170), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    return
                end

                searchEntry.OnChange = applyFilters
                selectRecord(records[1])
                applyFilters()
                parent.refreshFlags = function()
                    if not IsValid(parent) then return end
                    applyFilters()
                    if selectedRecord then rebuildDetail(selectedRecord) end
                end
            end,
            onSelect = function(panel) if panel.refreshFlags then panel.refreshFlags() end end
        })
    end)
end
