--[[
    Folder: Libraries
    File: option.md
]]
--[[
    Option

    User-configurable settings management system for the Lilia framework.
]]
--[[
    Overview:
        The option library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.
]]
lia.option = lia.option or {}
lia.option.stored = lia.option.stored or {}
local function localizeMenuLabel(value, ...)
    if not isstring(value) then return value end
    local resolved = lia.lang.resolveToken(value, ...)
    if resolved ~= value then return resolved end
    return L(value, ...)
end

lia.option.localizeValue = localizeMenuLabel
local function normalizeSelectableOption(optionEntry)
    if istable(optionEntry) then
        local rawLabel = optionEntry.rawLabel or optionEntry.label or optionEntry.name or optionEntry.text or optionEntry.value
        return {
            rawLabel = rawLabel,
            label = rawLabel,
            value = optionEntry.value ~= nil and optionEntry.value or rawLabel
        }
    elseif isstring(optionEntry) then
        return {
            rawLabel = optionEntry,
            label = optionEntry,
            value = optionEntry
        }
    end
end

local function localizeSelectableOption(optionEntry)
    if not istable(optionEntry) then return optionEntry end
    local rawLabel = optionEntry.rawLabel or optionEntry.label
    return {
        rawLabel = rawLabel,
        label = isstring(rawLabel) and localizeMenuLabel(rawLabel) or rawLabel,
        value = optionEntry.value
    }
end

local function getSelectableOptionLabel(options, selectedValue)
    for _, optionEntry in pairs(options or {}) do
        if istable(optionEntry) then
            if optionEntry.value == selectedValue then return optionEntry.label end
            if isstring(optionEntry.value) and isstring(selectedValue) and optionEntry.value:lower() == selectedValue:lower() then return optionEntry.label end
        end
    end
    return selectedValue
end

--[[
    Purpose:
        Register a configurable option with defaults, callbacks, and metadata.

    When Called:
        During initialization to expose settings to the config UI/system.

    Parameters:
        key (string)
            Option identifier to resolve choices for.
        name (string)
            Display name or localization key.
        desc (string)
            Description or localization key.
        default (any)
            Default value; determines inferred type.
        callback (function|nil)
            function(old, new) invoked on change.
        data (table)
            Extra fields: category, min/max, options, visible, shouldNetwork, isQuick, type, etc.
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.option.add("hudScale", "HUD Scale", "Scale HUD elements", 1.0, function(old, new)
            hook.Run("HUDScaleChanged", old, new)
        end, {
            category = "@core",
            min = 0.5,
            max = 1.5,
            decimals = 2,
            isQuick = true
        })
        ```
]]
function lia.option.add(key, name, desc, default, callback, data)
    assert(isstring(key), L("optionKeyString", type(key)))
    assert(isstring(name), L("optionNameString", type(name)))
    assert(istable(data), L("optionDataTable", type(data)))
    local t = type(default)
    local optionType = t == "boolean" and "Boolean" or t == "number" and (math.floor(default) == default and "Int" or "Float") or t == "table" and default.r and default.g and default.b and "Color" or "Generic"
    if optionType == "Int" or optionType == "Float" then
        data.min = data.min or optionType == "Int" and math.floor(default / 2) or default / 2
        data.max = data.max or optionType == "Int" and math.floor(default * 2) or default * 2
    end

    if data.type then optionType = data.type end
    local old = lia.option.stored[key]
    local value = (old and old.value ~= nil) and old.value or default
    if istable(data.options) then
        for k, v in pairs(data.options) do
            local normalized = normalizeSelectableOption(v)
            if normalized then data.options[k] = normalized end
        end
    elseif isfunction(data.options) then
        data.optionsFunc = data.options
        data.options = nil
    end

    data.rawCategory = data.rawCategory or data.category
    data.category = isstring(data.category) and localizeMenuLabel(data.category) or data.category
    lia.option.stored[key] = {
        rawName = name,
        name = isstring(name) and localizeMenuLabel(name) or name,
        rawDesc = desc,
        desc = isstring(desc) and localizeMenuLabel(desc) or desc,
        data = data,
        value = value,
        default = default,
        callback = callback,
        type = optionType,
        visible = data.visible,
        shouldNetwork = data.shouldNetwork,
        isQuick = data.isQuick
    }

    hook.Run("OptionAdded", key, lia.option.stored[key])
end

--[[
    Purpose:
        Retrieve the localized display name of an option entry.

    When Called:
        When rendering option entries in the config UI or sorting them by name.

    Parameters:
        key (string)
            The option key to look up.

    Returns:
        string
            Localized display name, or the raw key if the entry does not exist.

    Realm:
        Shared

    Example Usage:
        ```lua
            local name = lia.option.getDisplayName("BarsAlwaysVisible")
            lia.debug("Option name:", name)
        ```
]]
function lia.option.getDisplayName(key)
    local option = lia.option.stored[key]
    if not option then return key end
    local value = option.rawName or option.name or key
    return isstring(value) and localizeMenuLabel(value) or value
end

--[[
    Purpose:
        Retrieve the localized description of an option entry.

    When Called:
        When populating tooltips or description labels in the options UI.

    Parameters:
        key (string)
            The option key to look up.

    Returns:
        string
            Localized description string, or an empty string if none exists.

    Realm:
        Shared

    Example Usage:
        ```lua
            local desc = lia.option.getDisplayDesc("BarsAlwaysVisible")
            lia.debug("Option description:", desc)
        ```
]]
function lia.option.getDisplayDesc(key)
    local option = lia.option.stored[key]
    if not option then return "" end
    local value = option.rawDesc or option.desc or ""
    return isstring(value) and localizeMenuLabel(value) or value
end

--[[
    Purpose:
        Retrieve the localized category of an option entry for grouping in the UI.

    When Called:
        When building the options UI to sort entries into category sections.

    Parameters:
        key (string)
            The option key to look up.

    Returns:
        string
            Localized category name, or "misc" as the default fallback.

    Realm:
        Shared

    Example Usage:
        ```lua
            local cat = lia.option.getDisplayCategory("BarsAlwaysVisible")
            lia.debug("Option category:", cat)
        ```
]]
function lia.option.getDisplayCategory(key)
    local option = lia.option.stored[key]
    if not option then return localizeMenuLabel("misc") end
    local data = option.data or {}
    local value = data.rawCategory or data.category or "misc"
    return isstring(value) and localizeMenuLabel(value) or value
end

--[[
    Purpose:
        Resolve option choices (static or generated) for dropdowns.

    When Called:
        By the config UI before rendering a Table option.

    Parameters:
        key (string)

    Returns:
        table
            Array/map of options.

    Realm:
        Shared

    Example Usage:
        ```lua
        local list = lia.option.getOptions("weaponSelectorPosition")
        for _, opt in pairs(list) do lia.debug("Choice:", opt) end
        ```
]]
function lia.option.getOptions(key)
    local option = lia.option.stored[key]
    if not option then return {} end
    if option.data.optionsFunc then
        local success, result = pcall(option.data.optionsFunc)
        if success and istable(result) then
            local normalizedOptions = {}
            for k, v in pairs(result) do
                local normalized = normalizeSelectableOption(v)
                if normalized then normalizedOptions[k] = localizeSelectableOption(normalized) end
            end
            return normalizedOptions
        else
            return {}
        end
    elseif istable(option.data.options) then
        local normalizedOptions = {}
        for k, v in pairs(option.data.options) do
            local normalized = normalizeSelectableOption(v)
            if normalized then normalizedOptions[k] = localizeSelectableOption(normalized) end
        end
        return normalizedOptions
    end
    return {}
end

--[[
    Purpose:
        Set an option value, run callbacks/hooks, persist and optionally network it.

    When Called:
        From UI interactions or programmatic changes.

    Parameters:
        key (string)
        value (any)
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.option.set("BarsAlwaysVisible", true)
        ```
]]
function lia.option.set(key, value)
    local opt = lia.option.stored[key]
    if not opt then return end
    local old = opt.value
    opt.value = value
    if opt.callback then opt.callback(old, value) end
    hook.Run("OptionChanged", key, old, value)
    lia.option.save()
    if opt.shouldNetwork and SERVER then hook.Run("OptionReceived", nil, key, value) end
end

--[[
    Purpose:
        Retrieve an option value with fallback to default or provided default.

    When Called:
        Anywhere an option influences behavior or UI.

    Parameters:
        key (string)
        default (any)

    Returns:
        any

    Realm:
        Shared

    Example Usage:
        ```lua
        local showTime = lia.option.get("ChatShowTime", false)
        ```
]]
function lia.option.get(key, default)
    local opt = lia.option.stored[key]
    if opt then
        if opt.value ~= nil then return opt.value end
        if opt.default ~= nil then return opt.default end
    end
    return default
end

--[[
    Purpose:
        Persist option values to disk (data/lilia/options.json).

    When Called:
        After option changes; auto-called by lia.option.set.

    Parameters:
        None
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.option.save()
        ```
]]
function lia.option.save()
    local path = "lilia/options.json"
    local out = {}
    for k, v in pairs(lia.option.stored) do
        if v.value ~= nil then out[k] = v.value end
    end

    local json = util.TableToJSON(out, true)
    if json then file.Write(path, json) end
end

--[[
    Purpose:
        Load option values from disk or initialize defaults when missing.

    When Called:
        On client init or config menu load.

    Parameters:
        None
    Realm:
        Shared

    Example Usage:
        ```lua
        hook.Add("Initialize", "LoadLiliaOptions", lia.option.load)
        ```
]]
function lia.option.load()
    local path = "lilia/options.json"
    local data = file.Read(path, "DATA")
    if data then
        local saved = util.JSONToTable(data)
        if saved then
            for k, v in pairs(saved) do
                if lia.option.stored[k] then lia.option.stored[k].value = v end
            end
        end
    else
        for _, option in pairs(lia.option.stored) do
            if option.default ~= nil then option.value = option.default end
        end

        local out = {}
        for k, v in pairs(lia.option.stored) do
            if v.value ~= nil then out[k] = v.value end
        end

        local json = util.TableToJSON(out, true)
        if json then file.Write(path, json) end
    end

    hook.Run("InitializedOptions")
end

hook.Add("PopulateConfigurationButtons", "liaOptionsPopulate", function(pages)
    local function SetStyledTooltip(panel, text)
        if not text or text == "" then return end
        panel:SetTooltip(text)
        local oldSetTooltip = panel.SetTooltip
        function panel:SetTooltip(tooltipText)
            oldSetTooltip(self, tooltipText)
            timer.Simple(0, function()
                if not IsValid(self) then return end
                local tooltip = vgui.GetTooltipPanel()
                if IsValid(tooltip) and not tooltip.LiliaStyled then
                    tooltip.LiliaStyled = true
                    function tooltip:Paint(w, h)
                        local bgColor = Color(25, 28, 35, 250)
                        lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
                    end
                end
            end)
        end
    end

    local function AddHeader(scroll, text)
        local header = scroll:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(35)
        header:DockMargin(0, 5, 0, 5)
        header.Paint = function(me, w, h)
            local accent = lia.color.theme.accent or lia.config.get("Color") or Color(0, 150, 255)
            surface.SetDrawColor(accent)
            surface.DrawRect(0, h - 2, w, 2)
        end

        local label = header:Add("DLabel")
        label:Dock(LEFT)
        label:SetText(localizeMenuLabel(text))
        label:SetFont("LiliaFont.22")
        label:SetTextColor(lia.color.theme.text or color_white)
        label:SizeToContents()
        label:DockMargin(5, 0, 0, 0)
    end

    local function AddField(scroll, key, name, option)
        local p = scroll:Add("DPanel")
        p:Dock(TOP)
        p:SetTall(45)
        p:DockMargin(0, 0, 0, 5)
        p.Paint = function(s, w, h) lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(35, 38, 45, 180)):Shape(lia.derma.SHAPE_IOS):Draw() end
        local description = lia.option.getDisplayDesc(key)
        SetStyledTooltip(p, description)
        local l = p:Add("DLabel")
        l:Dock(LEFT)
        l:DockMargin(15, 0, 0, 0)
        l:SetWidth(250)
        l:SetText(name)
        l:SetFont("LiliaFont.18")
        l:SetTextColor(lia.color.theme.text or color_white)
        l:SetContentAlignment(4)
        SetStyledTooltip(l, description)
        local optionType = option.type or "Generic"
        if optionType == "Boolean" then
            local checkbox = p:Add("liaCheckbox")
            checkbox:Dock(RIGHT)
            checkbox:DockMargin(0, 10, 15, 10)
            checkbox:SetWidth(25)
            checkbox:SetChecked(lia.option.get(key, option.value))
            SetStyledTooltip(checkbox, description)
            checkbox.OnChange = function(s, val) lia.option.set(key, val) end
        elseif optionType == "Int" or optionType == "Float" or optionType == "Number" or optionType == "Generic" then
            local entry = p:Add("liaEntry")
            entry:Dock(RIGHT)
            entry:SetWidth(200)
            entry:DockMargin(0, 8, 15, 8)
            entry:SetValue(tostring(lia.option.get(key, option.value)))
            entry:SetFont("LiliaFont.18")
            SetStyledTooltip(entry, description)
            entry.textEntry.OnEnter = function(s)
                local value = entry:GetValue()
                local numValue = tonumber(value)
                if (optionType == "Int" or optionType == "Float" or optionType == "Number") and numValue ~= nil then
                    if optionType == "Int" then numValue = math.Round(numValue) end
                    lia.option.set(key, numValue)
                elseif optionType == "Generic" then
                    lia.option.set(key, value)
                else
                    entry:SetValue(tostring(lia.option.get(key, option.value)))
                end
            end
        elseif optionType == "Color" then
            local button = p:Add("liaButton")
            button:Dock(RIGHT)
            button:SetWidth(200)
            button:DockMargin(0, 8, 15, 8)
            button:SetText("")
            SetStyledTooltip(button, description)
            button.Paint = function(s, w, h)
                local c = lia.option.get(key, option.value)
                if istable(c) and c.r and c.g and c.b then
                    c = Color(c.r, c.g, c.b, c.a)
                elseif not IsColor(c) then
                    c = color_white
                end

                lia.derma.rect(0, 0, w, h):Rad(6):Color(c):Shape(lia.derma.SHAPE_IOS):Draw()
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 50))
            end

            button.DoClick = function()
                local c = lia.option.get(key, option.value)
                if not IsColor(c) and istable(c) then c = Color(c.r, c.g, c.b, c.a) end
                lia.derma.requestColorPicker(function(color) lia.option.set(key, color) end, c)
            end
        elseif optionType == "Table" then
            local combo = p:Add("liaComboBox")
            combo:Dock(RIGHT)
            combo:SetWidth(200)
            combo:DockMargin(0, 8, 15, 8)
            combo:SetFont("LiliaFont.18")
            SetStyledTooltip(combo, description)
            local options = lia.option.getOptions(key)
            local selectedValue = lia.option.get(key, option.value)
            combo:SetValue(tostring(getSelectableOptionLabel(options, selectedValue)))
            for _, optionEntry in pairs(options) do
                combo:AddChoice(optionEntry.label, optionEntry.value)
            end

            combo.OnSelect = function(_, _, v) lia.option.set(key, v) end
        end
    end

    pages[#pages + 1] = {
        name = "options",
        shouldShow = function() return true end,
        drawFunc = function(parent)
            parent:Clear()
            local searchEntry = parent:Add("liaEntry")
            searchEntry:Dock(TOP)
            searchEntry:SetTall(35)
            searchEntry:DockMargin(10, 10, 10, 10)
            searchEntry:SetPlaceholderText(L("searchOptions"))
            searchEntry:SetFont("LiliaFont.18")
            local scroll = parent:Add("liaScrollPanel")
            scroll:Dock(FILL)
            scroll:GetCanvas():DockPadding(10, 10, 10, 10)
            local function populate(filter)
                scroll:Clear()
                filter = filter and filter:len() > 0 and filter:lower() or nil
                local categories = {}
                local keys = {}
                for k in pairs(lia.option.stored) do
                    keys[#keys + 1] = k
                end

                table.sort(keys, function(a, b)
                    local aName = tostring(lia.option.getDisplayName(a) or a):lower()
                    local bName = tostring(lia.option.getDisplayName(b) or b):lower()
                    return aName < bName
                end)

                for _, k in ipairs(keys) do
                    local opt = lia.option.stored[k]
                    if not opt.visible or isfunction(opt.visible) and opt.visible() then
                        local data = opt.data or {}
                        local cat = data.rawCategory or data.category or "misc"
                        categories[cat] = categories[cat] or {}
                        table.insert(categories[cat], {
                            key = k,
                            name = lia.option.getDisplayName(k),
                            desc = lia.option.getDisplayDesc(k),
                            option = opt
                        })
                    end
                end

                local sortedCategories = {}
                for cat in pairs(categories) do
                    table.insert(sortedCategories, cat)
                end

                table.sort(sortedCategories, function(a, b)
                    local aName = tostring(localizeMenuLabel(a)):lower()
                    local bName = tostring(localizeMenuLabel(b)):lower()
                    return aName < bName
                end)

                for _, cat in ipairs(sortedCategories) do
                    local items = categories[cat]
                    table.sort(items, function(a, b) return tostring(a.name or ""):lower() < tostring(b.name or ""):lower() end)
                    local visibleItems = {}
                    local localizedCategory = tostring(localizeMenuLabel(cat))
                    for _, item in ipairs(items) do
                        local localizedName = tostring(item.name or ""):lower()
                        local localizedDesc = tostring(item.desc or ""):lower()
                        if not filter or localizedName:find(filter, 1, true) or localizedDesc:find(filter, 1, true) or localizedCategory:lower():find(filter, 1, true) then table.insert(visibleItems, item) end
                    end

                    if #visibleItems > 0 then
                        AddHeader(scroll, localizedCategory)
                        for _, item in ipairs(visibleItems) do
                            AddField(scroll, item.key, item.name, item.option)
                        end
                    end
                end
            end

            searchEntry:SetUpdateOnType(true)
            searchEntry.OnTextChanged = function(me, text) populate(text) end
            populate(nil)
        end
    }
end)

lia.option.add("descriptionWidth", "@descriptionWidth", "@descriptionWidthDesc", 0.5, nil, {
    category = "@core",
    min = 0.1,
    max = 1,
    decimals = 2
})

lia.option.add("invertWeaponScroll", "@invertWeaponScroll", "@invertWeaponScrollDesc", false, nil, {
    category = "@core",
    isQuick = true,
})

lia.option.add("espEnabled", "@espEnabled", "@espEnabledDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espPlayers", "@espPlayers", "@espPlayersDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espItems", "@espItems", "@espItemsDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espEntities", "@espEntities", "@espEntitiesDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espUnconfiguredDoors", "@espUnconfiguredDoors", "@espUnconfiguredDoorsDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espItemsColor", "@espItemsColor", "@espItemsColorDesc", {
    r = 0,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "@categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espEntitiesColor", "@espEntitiesColor", "@espEntitiesColorDesc", {
    r = 255,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "@categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espUnconfiguredDoorsColor", "@espUnconfiguredDoorsColor", "@espUnconfiguredDoorsColorDesc", {
    r = 255,
    g = 0,
    b = 255,
    a = 255
}, nil, {
    category = "@categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espConfiguredDoors", "@espConfiguredDoors", "@espConfiguredDoorsDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espConfiguredDoorsColor", "@espConfiguredDoorsColor", "@espConfiguredDoorsColorDesc", {
    r = 0,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "@categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espPlayersColor", "@espPlayersColor", "@espPlayersColorDesc", {
    r = 0,
    g = 0,
    b = 255,
    a = 255
}, nil, {
    category = "@categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("BarsAlwaysVisible", "@barsAlwaysVisible", "@barsAlwaysVisibleDesc", false, nil, {
    category = "@core",
    isQuick = true,
})

lia.option.add("thirdPersonEnabled", "@thirdPersonEnabled", "@thirdPersonEnabledDesc", false, function(_, newValue) hook.Run("ThirdPersonToggled", newValue) end, {
    category = "@categoryThirdPerson",
    isQuick = true,
})

lia.option.add("thirdPersonClassicMode", "@thirdPersonClassicMode", "@thirdPersonClassicModeDesc", false, nil, {
    category = "@categoryThirdPerson",
    isQuick = true,
})

lia.option.add("thirdPersonHeight", "@thirdPersonHeight", "@thirdPersonHeightDesc", 10, nil, {
    category = "@categoryThirdPerson",
    min = 0,
    isQuick = true,
    max = lia.config.get("MaxThirdPersonHeight", 30),
})

lia.option.add("thirdPersonHorizontal", "@thirdPersonHorizontal", "@thirdPersonHorizontalDesc", 0, nil, {
    category = "@categoryThirdPerson",
    min = -lia.config.get("MaxThirdPersonHorizontal", 30),
    isQuick = true,
    max = lia.config.get("MaxThirdPersonHorizontal", 30),
})

lia.option.add("thirdPersonDistance", "@thirdPersonDistance", "@thirdPersonDistanceDesc", 50, nil, {
    category = "@categoryThirdPerson",
    min = 0,
    isQuick = true,
    max = lia.config.get("MaxThirdPersonDistance", 100),
})

lia.option.add("ChatShowTime", "@chatShowTime", "@chatShowTimeDesc", false, nil, {
    category = "@core",
    type = "Boolean"
})

lia.option.add("shadows", "@optionShadows", "@optionShadowsDesc", false, function(_, value) RunConsoleCommand("r_shadows", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("dynamicLighting", "@optionDynamicLighting", "@optionDynamicLightingDesc", false, function(_, value) RunConsoleCommand("r_dynamic", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("eyeMovement", "@optionEyeMovement", "@optionEyeMovementDesc", false, function(_, value) RunConsoleCommand("r_eyemove", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("facialExpressions", "@optionFacialExpressions", "@optionFacialExpressionsDesc", false, function(_, value) RunConsoleCommand("r_flex", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("antiAliasing", "@optionAntiAliasing", "@optionAntiAliasingDesc", false, function(_, value) RunConsoleCommand("mat_antialias", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("hdrLighting", "@optionHDRLighting", "@optionHDRLightingDesc", false, function(_, value) RunConsoleCommand("mat_hdr_level", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("motionBlur", "@optionMotionBlur", "@optionMotionBlurDesc", false, function(_, value) RunConsoleCommand("mat_motion_blur_enabled", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("waterReflections", "@optionWaterReflections", "@optionWaterReflectionsDesc", false, function(_, value) RunConsoleCommand("r_waterdrawreflection", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("gameMonitors", "@optionGameMonitors", "@optionGameMonitorsDesc", false, function(_, value) RunConsoleCommand("cl_drawmonitors", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("alienGibs", "@optionAlienGibs", "@optionAlienGibsDesc", false, function(_, value) RunConsoleCommand("violence_agibs", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("humanGibs", "@optionHumanGibs", "@optionHumanGibsDesc", false, function(_, value) RunConsoleCommand("violence_hgibs", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("waterSplashes", "@optionWaterSplashes", "@optionWaterSplashesDesc", false, function(_, value) RunConsoleCommand("cl_show_splashes", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("shellEjection", "@optionShellEjection", "@optionShellEjectionDesc", false, function(_, value) RunConsoleCommand("cl_ejectbrass", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("sprayLifetime", "@optionSprayLifetime", "@optionSprayLifetimeDesc", 1, function(_, value) RunConsoleCommand("r_spray_lifetime", tostring(value)) end, {
    min = 0,
    max = 300,
    category = "@categoryPerformance",
    type = "Int"
})

lia.option.add("modelDecals", "@optionModelDecals", "@optionModelDecalsDesc", true, function(_, value) RunConsoleCommand("r_drawmodeldecals", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("multiplayerDecals", "@optionMultiplayerDecals", "@optionMultiplayerDecalsDesc", 1, function(_, value) RunConsoleCommand("mp_decals", tostring(value)) end, {
    min = 0,
    max = 50,
    category = "@categoryPerformance",
    type = "Int"
})

lia.option.add("detailFadeDistance", "@optionDetailFadeDistance", "@optionDetailFadeDistanceDesc", 800, function(_, value) RunConsoleCommand("cl_detailfade", tostring(value)) end, {
    min = 400,
    max = 2000,
    category = "@categoryPerformance",
    type = "Int"
})

lia.option.add("detailDistance", "@optionDetailDistance", "@optionDetailDistanceDesc", 0, function(_, value) RunConsoleCommand("cl_detaildist", tostring(value)) end, {
    min = 0,
    max = 1200,
    category = "@categoryPerformance",
    type = "Int"
})

lia.option.add("networkSmoothing", "@optionNetworkSmoothing", "@optionNetworkSmoothingDesc", false, function(_, value) RunConsoleCommand("cl_smooth", value and "1" or "0") end, {
    category = "@categoryPerformance",
    type = "Boolean"
})

lia.option.add("smoothingTime", "@optionSmoothingTime", "@optionSmoothingTimeDesc", 0.05, function(_, value) RunConsoleCommand("cl_smoothtime", tostring(value)) end, {
    min = 0.01,
    max = 0.2,
    decimals = 2,
    category = "@categoryPerformance",
    type = "Float"
})

lia.option.add("voiceRange", "@voiceRange", "@voiceRangeDesc", false, nil, {
    category = "@core",
    isQuick = true,
    type = "Boolean"
})

lia.option.add("weaponSelectorPosition", "@weaponSelectorPosition", "@weaponSelectorPositionDesc", "left", nil, {
    category = "@core",
    type = "Table",
    options = {
        {
            label = "@left",
            value = "left"
        },
        {
            label = "@right",
            value = "right"
        },
        {
            label = "@center",
            value = "center"
        }
    }
})
