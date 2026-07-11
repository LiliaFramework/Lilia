--[[
    Folder: Developer - Libraries
    File: lia.option.md
]]
--[[
    Option

    Option helpers for Lilia user settings, including registration, lookup, localization, persistence, and configuration menu display.
]]
--[[
    Overview:
        The option library centralizes user-facing settings under `lia.option`. It stores registered option metadata and values, infers option types from defaults, localizes labels, descriptions, categories, and selectable values, persists option values to `data/lilia/options.json`, and builds the configuration menu page used to edit registered options.
]]
--[[
    Hooks:
        OptionAdded(string key, table option)

    Purpose:
        Runs after an option is registered with `lia.option.add`.

    Category:
        Options

    Parameters:
        key (string)
            The unique option identifier.

        option (table)
            The stored option data table created for the key.

    Example Usage:
        ```lua
        hook.Add("OptionAdded", "liaExampleOptionAdded", function(key, option)
            print("[MyModule] handled OptionAdded")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        OptionChanged(string key, any oldValue, any newValue)

    Purpose:
        Runs after `lia.option.set` changes a registered option value.

    Category:
        Options

    Parameters:
        key (string)
            The unique option identifier.

        oldValue (any)
            The value before the change.

        newValue (any)
            The value after the change.

    Example Usage:
        ```lua
        hook.Add("OptionChanged", "liaExampleOptionChanged", function(key, oldValue, newValue)
            print("[MyModule] handled OptionChanged")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        OptionReceived(Player|nil client, string key, any value)

    Purpose:
        Runs on the server when a changed option is marked for networking.

    Category:
        Options

    Parameters:
        client (Player|nil)
            The player associated with the networked option change, or nil when triggered directly by `lia.option.set`.

        key (string)
            The unique option identifier.

        value (any)
            The networked option value.

    Example Usage:
        ```lua
        hook.Add("OptionReceived", "liaExampleOptionReceived", function(client, key, value)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled OptionReceived for %s", client:Name()))
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        InitializedOptions()

    Purpose:
        Runs after saved option values are loaded, or after defaults are initialized and saved when no option file exists.

    Category:
        Options

    Example Usage:
        ```lua
        hook.Add("InitializedOptions", "liaExampleInitializedOptions", function()
            print("[MyModule] handled InitializedOptions")
        end)
        ```

    Realm:
        Shared
]]
lia.option = lia.option or {}
lia.option.stored = lia.option.stored or {}
local function localizeMenuLabel(value, ...)
    if not isstring(value) then return value end
    local resolved = lia.lang.resolveToken(value, ...)
    if resolved ~= value then return resolved end
    return L(value, ...)
end

--[[
    Purpose:
        Localizes an option or menu label value.

    Parameters:
        value (any)
            The value to localize. Non-string values are returned unchanged.

        ... (any)
            Optional arguments forwarded to the language lookup.

    Returns:
        any
            The localized string when a string token is provided, otherwise the original value.

    Example Usage:
        ```lua
        local label = lia.option.localizeValue("@core")
        ```

    Realm:
        Shared
]]
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
        Registers an option and stores its display metadata, default value, callback, type information, and configuration data.

    Parameters:
        key (string)
            The unique option identifier.

        name (string)
            The display name or language token for the option.

        desc (string)
            The display description or language token for the option.

        default (any)
            The default value used when no saved value exists.

        callback (function|nil)
            Optional function called with the old and new values when the option changes.

        data (table)
            Option metadata such as category, type, min, max, decimals, options, visible, shouldNetwork, and isQuick.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.option.add("exampleOption", "@exampleOption", "@exampleOptionDesc", true, nil, {
            category = "@core",
            type = "Boolean"
        })
        ```

    Realm:
        Shared
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
        Returns the localized display name for a registered option.

    Parameters:
        key (string)
            The unique option identifier.

    Returns:
        string
            The localized option display name, or the key when the option is not registered.

    Example Usage:
        ```lua
        local name = lia.option.getDisplayName("descriptionWidth")
        ```

    Realm:
        Shared
]]
function lia.option.getDisplayName(key)
    local option = lia.option.stored[key]
    if not option then return key end
    local value = option.rawName or option.name or key
    return isstring(value) and localizeMenuLabel(value) or value
end

--[[
    Purpose:
        Returns the localized display description for a registered option.

    Parameters:
        key (string)
            The unique option identifier.

    Returns:
        string
            The localized option description, or an empty string when the option is not registered.

    Example Usage:
        ```lua
        local desc = lia.option.getDisplayDesc("descriptionWidth")
        ```

    Realm:
        Shared
]]
function lia.option.getDisplayDesc(key)
    local option = lia.option.stored[key]
    if not option then return "" end
    local value = option.rawDesc or option.desc or ""
    return isstring(value) and localizeMenuLabel(value) or value
end

--[[
    Purpose:
        Returns the localized display category for a registered option.

    Parameters:
        key (string)
            The unique option identifier.

    Returns:
        string
            The localized option category, or the localized misc category when none is set.

    Example Usage:
        ```lua
        local category = lia.option.getDisplayCategory("descriptionWidth")
        ```

    Realm:
        Shared
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
        Returns normalized and localized selectable values for a registered table option.

    Parameters:
        key (string)
            The unique option identifier.

    Returns:
        table
            A table of selectable option entries containing label, rawLabel, and value fields.

    Example Usage:
        ```lua
        local options = lia.option.getOptions("weaponSelectorPosition")
        ```

    Realm:
        Shared
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
        Updates a registered option value, runs its callback, emits option change hooks, and saves option values.

    Parameters:
        key (string)
            The unique option identifier.

        value (any)
            The new option value.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.option.set("drawItemHoverInfo", false)
        ```

    Realm:
        Shared
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
        Returns the current value for a registered option.

    Parameters:
        key (string)
            The unique option identifier.

        default (any)
            Fallback value returned when the option is not registered and has no stored default.

    Returns:
        any
            The current option value, the registered default value, or the provided fallback default.

    Example Usage:
        ```lua
        local enabled = lia.option.get("drawItemHoverInfo", true)
        ```

    Realm:
        Shared
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
        Saves all registered option values to `data/lilia/options.json`.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.option.save()
        ```

    Realm:
        Shared
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
        Loads saved option values from `data/lilia/options.json`, or initializes and saves defaults when no option file exists.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.option.load()
        ```

    Realm:
        Shared
]]
function lia.option.load()
    local path = "lilia/options.json"
    local data = file.Read(path, "DATA")
    local saved = data and util.JSONToTable(data) or nil
    for _, option in pairs(lia.option.stored) do
        option.value = option.default
    end

    if istable(saved) then
        for k, v in pairs(saved) do
            if lia.option.stored[k] then lia.option.stored[k].value = v end
        end
    else
        lia.option.save()
    end

    for _, option in pairs(lia.option.stored) do
        if option.callback then option.callback(option.value, option.value) end
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
        l:Dock(FILL)
        l:DockMargin(15, 8, 15, 8)
        l:SetText(name)
        l:SetFont("LiliaFont.18")
        l:SetTextColor(lia.color.theme.text or color_white)
        l:SetWrap(true)
        l:SetAutoStretchVertical(true)
        l:SetContentAlignment(7)
        SetStyledTooltip(l, description)
        local control
        local function updateRowHeight()
            if not IsValid(p) or not IsValid(l) then return end
            local minHeight = 45
            local labelHeight = select(2, l:GetContentSize())
            local controlHeight = IsValid(control) and control:GetTall() + 16 or minHeight
            p:SetTall(math.max(minHeight, labelHeight + 16, controlHeight))
        end

        p.PerformLayout = function(_, w, h)
            if IsValid(l) then
                local controlWidth = IsValid(control) and control:GetWide() + 30 or 30
                l:SetWide(math.max(120, w - controlWidth))
                l:InvalidateLayout(true)
            end

            updateRowHeight()
        end

        local optionType = option.type or "Generic"
        if optionType == "Boolean" then
            local checkbox = p:Add("liaCheckbox")
            checkbox:Dock(RIGHT)
            checkbox:DockMargin(0, 10, 15, 10)
            checkbox:SetWidth(25)
            checkbox:SetChecked(lia.option.get(key, option.value))
            SetStyledTooltip(checkbox, description)
            checkbox.OnChange = function(s, val) lia.option.set(key, val) end
            control = checkbox
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

            control = entry
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

            control = button
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
            control = combo
        end

        timer.Simple(0, function() if IsValid(p) then p:InvalidateLayout(true) end end)
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

lia.option.add("drawPlayerHoverInfo", "@drawPlayerHoverInfo", "@drawPlayerHoverInfoDesc", true, nil, {
    category = "@core",
    isQuick = true,
})

lia.option.add("drawItemHoverInfo", "@drawItemHoverInfo", "@drawItemHoverInfoDesc", true, nil, {
    category = "@core",
    isQuick = true,
})

lia.option.add("drawEntityHoverInfo", "@drawEntityHoverInfo", "@drawEntityHoverInfoDesc", true, nil, {
    category = "@core",
    isQuick = true,
})

lia.option.add("drawDevelopmentHUD", "@drawDevelopmentHUD", "@drawDevelopmentHUDDesc", true, nil, {
    category = "@categoryHUD",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local hasDevelopmentHUD = ply:hasPrivilege("developmentHUD")
        local hasStaffHUD = ply:hasPrivilege("staffHUD")
        local permission = hasDevelopmentHUD or hasStaffHUD
        return permission
    end
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
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espPlayers", "@espPlayers", "@espPlayersDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espItems", "@espItems", "@espItemsDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espEntities", "@espEntities", "@espEntitiesDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espUnconfiguredDoors", "@espUnconfiguredDoors", "@espUnconfiguredDoorsDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
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
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
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
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
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
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espConfiguredDoors", "@espConfiguredDoors", "@espConfiguredDoorsDesc", false, nil, {
    category = "@categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
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
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
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
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
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

lia.option.add("realisticViewEnabled", "@realisticViewEnabled", "@realisticViewEnabledDesc", false, nil, {
    category = "@categoryCamera",
    type = "Boolean",
    isQuick = true
})

lia.option.add("freelookEnabled", "@freelookEnabled", "@freelookEnabledDesc", true, nil, {
    category = "@categoryCamera",
    type = "Boolean",
    isQuick = true
})

lia.option.add("freelookLimitVertical", "@freelookLimitVertical", "@freelookLimitVerticalDesc", 65, nil, {
    category = "@categoryCamera",
    type = "Int",
    min = 30,
    max = 90
})

lia.option.add("freelookLimitHorizontal", "@freelookLimitHorizontal", "@freelookLimitHorizontalDesc", 90, nil, {
    category = "@categoryCamera",
    type = "Int",
    min = 60,
    max = 120
})

lia.option.add("freelookSmoothness", "@freelookSmoothness", "@freelookSmoothnessDesc", 1, nil, {
    category = "@categoryCamera",
    type = "Float",
    min = 0.1,
    max = 2,
    decimals = 2
})

lia.option.add("freelookBlockADS", "@freelookBlockADS", "@freelookBlockADSDesc", true, nil, {
    category = "@categoryCamera",
    type = "Boolean"
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
