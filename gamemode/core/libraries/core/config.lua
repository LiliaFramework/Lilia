lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
lia.config.lastSyncedValues = lia.config.lastSyncedValues or {}
local function cfgLocalizeLabel(value, ...)
    if not isstring(value) then return value end
    return lia.lang.resolve(value, ...)
end

lia.config.localizeValue = cfgLocalizeLabel
local function cfgNormalizeSelectableOption(optionEntry)
    if istable(optionEntry) then
        local rawLabel = optionEntry.rawLabel or optionEntry.label or optionEntry.name or optionEntry.text or optionEntry.value
        return {
            rawLabel = rawLabel,
            label = isstring(rawLabel) and cfgLocalizeLabel(rawLabel) or rawLabel,
            value = optionEntry.value ~= nil and optionEntry.value or rawLabel
        }
    elseif optionEntry ~= nil then
        return {
            rawLabel = optionEntry,
            label = isstring(optionEntry) and cfgLocalizeLabel(optionEntry) or optionEntry,
            value = optionEntry
        }
    end
end

local function cfgNormalizeValue(v)
    if IsColor(v) then
        return {
            r = v.r,
            g = v.g,
            b = v.b,
            a = v.a
        }
    end
    return v
end

local function cfgCoerceValue(key, value)
    local config = lia.config and lia.config.stored and lia.config.stored[key]
    if not config then return value end
    local configType = (config.data and config.data.type) or config.type
    if configType == "Generic" or isstring(config.default) then
        if value == nil then return "" end
        if isvector(value) or isangle(value) then return "" end
        if not isstring(value) then return tostring(value) end
    end

    if configType == "Color" and istable(value) then return Color(value.r, value.g, value.b, value.a) end
    return value
end

local function cfgValuesEqual(a, b)
    a = cfgNormalizeValue(a)
    b = cfgNormalizeValue(b)
    if istable(a) and istable(b) then return util.TableToJSON(a) == util.TableToJSON(b) end
    return a == b
end

function lia.config.add(key, name, value, callback, data)
    assert(isstring(key), string.format("Expected config key to be string, got %s", type(key)))
    assert(istable(data), string.format("Expected config data to be a table, got %s", type(data)))
    local t = type(value)
    local configType = t == "boolean" and "Boolean" or t == "number" and "Number" or t == "table" and (value.r and value.g and value.b and "Color" or "Table") or "Generic"
    local validTypes = {
        Boolean = true,
        Int = true,
        Float = true,
        Number = true,
        Color = true,
        Table = true,
        Generic = true
    }

    if not data.type or not validTypes[data.type] then data.type = configType end
    local oldConfig = lia.config.stored[key]
    local savedValue = (oldConfig and oldConfig.value ~= nil) and oldConfig.value or value
    if isfunction(data.options) then
        data.optionsFunc = data.options
        data.options = nil
    end

    data.rawDesc = data.rawDesc or data.desc
    data.rawCategory = data.rawCategory or data.category
    data.desc = isstring(data.desc) and cfgLocalizeLabel(data.desc) or data.desc
    data.category = isstring(data.category) and cfgLocalizeLabel(data.category) or data.category
    lia.config.stored[key] = {
        rawName = name,
        name = isstring(name) and cfgLocalizeLabel(name) or name or key,
        data = data,
        value = savedValue,
        default = value,
        rawDesc = data.rawDesc,
        desc = data.desc,
        rawCategory = data.rawCategory,
        category = data.category or "Character",
        noNetworking = data.noNetworking or false,
        callback = callback
    }
end

function lia.config.getDisplayName(key)
    local config = lia.config.stored[key]
    if not config then return key end
    local value = config.rawName or config.name or key
    return isstring(value) and cfgLocalizeLabel(value) or value
end

function lia.config.getDisplayDesc(key)
    local config = lia.config.stored[key]
    if not config then return "" end
    local value = config.rawDesc or (config.data and config.data.rawDesc) or config.desc or ""
    return isstring(value) and cfgLocalizeLabel(value) or value
end

function lia.config.getDisplayCategory(key)
    local config = lia.config.stored[key]
    if not config then return cfgLocalizeLabel("character") end
    local value = config.rawCategory or (config.data and config.data.rawCategory) or config.category or "character"
    return isstring(value) and cfgLocalizeLabel(value) or value
end

function lia.config.getOptions(key)
    local config = lia.config.stored[key]
    if not config then return {} end
    if config.data.optionsFunc then
        local success, result = pcall(config.data.optionsFunc)
        if success and istable(result) then
            local normalizedOptions = {}
            for k, v in pairs(result) do
                local normalized = cfgNormalizeSelectableOption(v)
                if normalized then normalizedOptions[k] = normalized end
            end
            return normalizedOptions
        else
            return {}
        end
    elseif istable(config.data.options) then
        local normalizedOptions = {}
        for k, v in pairs(config.data.options) do
            local normalized = cfgNormalizeSelectableOption(v)
            if normalized then normalizedOptions[k] = normalized end
        end
        return normalizedOptions
    end
    return {}
end

function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]
    if config then config.default = value end
end

function lia.config.forceSet(key, value, noSave)
    local config = lia.config.stored[key]
    if config then
        local oldValue = config.value
        config.value = value
        hook.Run("OnConfigUpdated", key, oldValue, value)
    end

    if not noSave then lia.config.save() end
end

function lia.config.set(key, value)
    local config = lia.config.stored[key]
    if config then
        value = cfgCoerceValue(key, value)
        local oldValue = config.value
        config.value = value
        hook.Run("OnConfigUpdated", key, oldValue, value)
        if SERVER then
            if not config.noNetworking then
                net.Start("liaCfgSet")
                net.WriteString(key)
                net.WriteString(tostring(lia.config.getDisplayName(key) or key))
                net.WriteType(value)
                net.Broadcast()
            end

            if config.callback then config.callback(oldValue, value) end
            lia.config.save()
        end

        if CLIENT and oldValue ~= value and IsValid(LocalPlayer()) then LocalPlayer():notifySuccess("Config '" .. tostring(lia.config.getDisplayName(key) or key) .. "' updated successfully") end
    end
end

function lia.config.get(key, default)
    local config = lia.config.stored[key]
    if config then
        if config.value ~= nil then
            if istable(config.value) and config.value.r and config.value.g and config.value.b then config.value = Color(config.value.r, config.value.g, config.value.b, config.value.a or 255) end
            return config.value
        elseif config.default ~= nil then
            return config.default
        end
    end

    if key == "Color" and CLIENT then return lia.color.getMainColor() end
    return default
end

if CLIENT then
    net.Receive("liaCfgList", function()
        local data = net.ReadTable() or {}
        for k, v in pairs(data) do
            local stored = lia.config.stored[k]
            if stored then
                stored.value = cfgCoerceValue(k, v)
            else
                lia.config.stored[k] = lia.config.stored[k] or {}
                lia.config.stored[k].value = cfgCoerceValue(k, v)
            end
        end

        hook.Run("InitializedConfig")
    end)

    net.Receive("liaCfgSet", function()
        local key = net.ReadString()
        local _ = net.ReadString()
        local value = net.ReadType()
        local stored = lia.config.stored[key]
        local oldValue = stored and stored.value
        local coerced = cfgCoerceValue(key, value)
        lia.config.stored[key] = lia.config.stored[key] or {}
        lia.config.stored[key].value = coerced
        hook.Run("OnConfigUpdated", key, oldValue, lia.config.stored[key].value)
    end)
end

if SERVER then
    function lia.config.load()
        local configData = lia.data.get("config", {})
        local existing = {}
        for cfgKey, cfgValue in pairs(configData) do
            lia.config.stored[cfgKey] = lia.config.stored[cfgKey] or {}
            cfgValue = cfgCoerceValue(cfgKey, cfgValue)
            if cfgValue == nil or cfgValue == "" then
                lia.config.stored[cfgKey].value = lia.config.stored[cfgKey].default
            else
                lia.config.stored[cfgKey].value = cfgValue
                existing[cfgKey] = true
            end
        end

        for k, v in pairs(lia.config.stored) do
            if not existing[k] then lia.config.stored[k].value = v.default end
        end

        for key, config in pairs(lia.config.stored) do
            if config.value ~= nil then
                if istable(config.value) then
                    lia.config.lastSyncedValues[key] = util.TableToJSON(config.value) and util.JSONToTable(util.TableToJSON(config.value)) or config.value
                else
                    lia.config.lastSyncedValues[key] = config.value
                end
            end
        end

        hook.Run("InitializedConfig")
    end

    function lia.config.getChangedValues(includeDefaults)
        local data = {}
        for k, v in pairs(lia.config.stored) do
            local isDifferent
            if includeDefaults or lia.config.lastSyncedValues[k] == nil then
                isDifferent = not cfgValuesEqual(v.default, v.value)
            else
                isDifferent = not cfgValuesEqual(lia.config.lastSyncedValues[k], v.value)
            end

            if isDifferent then data[k] = cfgNormalizeValue(v.value) end
        end
        return data
    end

    function lia.config.send(client)
        local data
        if client then
            data = lia.data.get("config", {})
        else
            data = lia.config.getChangedValues()
            if table.Count(data) == 0 then return end
        end

        local targets
        if IsValid(client) then
            targets = {client}
        else
            targets = player.GetHumans()
        end

        if not istable(targets) or #targets == 0 then return end
        for key, value in pairs(data) do
            if istable(value) then
                lia.config.lastSyncedValues[key] = util.TableToJSON(value) and util.JSONToTable(util.TableToJSON(value)) or value
            else
                lia.config.lastSyncedValues[key] = value
            end
        end

        net.Start("liaCfgList")
        net.WriteTable(data)
        net.Send(targets)
    end

    function lia.config.save()
        local configData = {}
        for k, v in pairs(lia.config.stored) do
            if v.value ~= nil and not cfgValuesEqual(v.value, v.default) then configData[k] = cfgNormalizeValue(v.value) end
        end

        lia.data.set("config", configData, true, true)
    end

    function lia.config.reset()
        for _, cfg in pairs(lia.config.stored) do
            local oldValue = cfg.value
            cfg.value = cfg.default
            if cfg.callback then cfg.callback(oldValue, cfg.default) end
        end

        lia.config.save()
        lia.config.send()
    end

    net.Receive("liaCfgList", function(_, client)
        if not IsValid(client) then return end
        lia.config.send(client)
    end)

    net.Receive("liaCfgSet", function(_, client)
        if not IsValid(client) then return end
        local key = net.ReadString()
        local name = net.ReadString()
        local value = net.ReadType()
        local config = lia.config.stored[key]
        if not config then return end
        value = cfgCoerceValue(key, value)
        if type(config.default) == type(value) and hook.Run("CanPlayerModifyConfig", client, key) ~= false then
            local oldValue = config.value
            lia.config.set(key, value)
            hook.Run("ConfigChanged", key, value, oldValue, client)
            client:notifySuccess(string.format("%s has set \"%s\" to %s.", client:Name(), name or config.name or key, tostring(value)))
        end
    end)
else
    hook.Add("PopulateConfigurationButtons", "liaConfigPopulate", function(pages)
        local uiColors = {
            bg = Color(5, 18, 23, 220),
            bgSoft = Color(7, 20, 25, 237),
            row = Color(10, 25, 30, 232),
            rowAlt = Color(9, 24, 29, 238),
            rowHover = Color(16, 34, 40, 235),
            selected = Color(13, 30, 35, 225),
            border = Color(45, 190, 170, 78),
            text = Color(242, 247, 247),
            muted = Color(155, 178, 179),
            dim = Color(100, 120, 122),
            accent = Color(45, 190, 170),
            accentSoft = Color(45, 190, 170, 28),
            danger = Color(215, 70, 70)
        }

        local preferredCategories = {"Core", "Gameplay", "Character", "Vehicles", "Admin", "Items", "Chat", "UI / Time", "Performance", "Fonts", "Experimental"}
        local categoryIcons = {}
        local function getAccent(alpha)
            local theme = lia.color and lia.color.theme or {}
            local color = theme.accent or theme.theme or lia.config.get("Color") or uiColors.accent
            if istable(color) and color.r and color.g and color.b then return Color(color.r, color.g, color.b, alpha or color.a or 255) end
            return Color(uiColors.accent.r, uiColors.accent.g, uiColors.accent.b, alpha or uiColors.accent.a or 255)
        end

        local function getTextColor(alpha)
            local theme = lia.color and lia.color.theme or {}
            local color = theme.text or uiColors.text
            if istable(color) and color.r and color.g and color.b then return Color(color.r, color.g, color.b, alpha or color.a or 255) end
            return Color(uiColors.text.r, uiColors.text.g, uiColors.text.b, alpha or uiColors.text.a or 255)
        end

        local function rounded(x, y, w, h, r, color)
            if lia.derma.SHAPE_IOS then
                lia.derma.rect(x, y, w, h):Rad(r or 0):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
                return
            end

            draw.RoundedBox(r or 0, x, y, w, h, color)
        end

        local function outline(x, y, w, h, color)
            if lia.derma.SHAPE_IOS then
                lia.derma.rect(x, y, w, h):Rad(6):Color(color):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
                return
            end

            surface.SetDrawColor(color)
            surface.DrawOutlinedRect(x, y, w, h)
        end

        local function tableSize(t)
            local count = 0
            for _ in pairs(t or {}) do
                count = count + 1
            end
            return count
        end

        local function sendConfigValue(key, name, value)
            net.Start("liaCfgSet")
            net.WriteString(key)
            net.WriteString(name)
            net.WriteType(value)
            net.SendToServer()
        end

        local function normalizeConfigValue(value, configType, config)
            if configType == "Number" or configType == "Int" or configType == "Float" then
                local numeric = tonumber(value)
                if numeric == nil then return nil end
                if configType == "Int" then numeric = math.floor(numeric) end
                if config.data then
                    if isnumber(config.data.min) then numeric = math.max(config.data.min, numeric) end
                    if isnumber(config.data.max) then numeric = math.min(config.data.max, numeric) end
                end
                return numeric
            end

            if configType == "Generic" then return tostring(value or "") end
            return value
        end

        local function displayValue(value)
            if IsColor(value) then return string.format("%d, %d, %d", value.r, value.g, value.b) end
            if istable(value) and value.r and value.g and value.b then return string.format("%d, %d, %d", value.r, value.g, value.b) end
            return tostring(value or "")
        end

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
                        tooltip:SetTextColor(uiColors.text)
                        function tooltip:Paint(w, h)
                            rounded(0, 0, w, h, 8, Color(7, 18, 24, 245))
                            outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 135))
                        end
                    end
                end)
            end
        end

        local function getRawCategory(config)
            return config.rawCategory or (config.data and config.data.rawCategory) or config.category or "Core"
        end

        local function getVisualCategory(key, config)
            local raw = tostring(getRawCategory(config) or "Core")
            local localized = tostring(cfgLocalizeLabel(raw) or raw)
            local lowerKey = tostring(key or ""):lower()
            local lowerCategory = localized:lower()
            if lowerCategory:find("performance", 1, true) then return "Performance" end
            if lowerCategory:find("font", 1, true) then return "Fonts" end
            if lowerCategory:find("gameplay", 1, true) then return "Gameplay" end
            if lowerCategory:find("experimental", 1, true) then return "Experimental" end
            if lowerKey:find("admin", 1, true) or lowerKey:find("staff", 1, true) or lowerKey:find("log", 1, true) or lowerKey:find("lua", 1, true) then return "Admin" end
            if lowerKey:find("vehicle", 1, true) or lowerKey:find("car", 1, true) then return "Vehicles" end
            if lowerKey:find("chat", 1, true) or lowerKey:find("ooc", 1, true) or lowerKey:find("looc", 1, true) or lowerKey:find("talk", 1, true) or lowerKey:find("whisper", 1, true) or lowerKey:find("yell", 1, true) or lowerKey:find("voice", 1, true) then return "Chat" end
            if lowerKey:find("char", 1, true) or lowerKey:find("recognition", 1, true) or lowerKey:find("fake", 1, true) or lowerKey:find("description", 1, true) or lowerKey:find("attribute", 1, true) then return "Character" end
            if lowerKey:find("item", 1, true) or lowerKey:find("ammo", 1, true) or lowerKey:find("weapon", 1, true) or lowerKey:find("equip", 1, true) or lowerKey:find("drop", 1, true) or lowerKey:find("vendor", 1, true) or lowerKey:find("money", 1, true) or lowerKey:find("currency", 1, true) or lowerKey:find("door", 1, true) or lowerKey:find("hold", 1, true) or lowerKey:find("throw", 1, true) then return "Items" end
            if lowerKey:find("time", 1, true) or lowerKey:find("timestamp", 1, true) or lowerKey:find("menu", 1, true) or lowerKey:find("hud", 1, true) or lowerKey:find("font", 1, true) or lowerKey:find("color", 1, true) or lowerKey:find("skin", 1, true) or lowerKey:find("scoreboard", 1, true) or lowerKey:find("background", 1, true) or lowerKey:find("logo", 1, true) or lowerKey:find("music", 1, true) or lowerKey:find("language", 1, true) then return "UI / Time" end
            if lowerKey:find("stamina", 1, true) or lowerKey:find("punch", 1, true) or lowerKey:find("damage", 1, true) or lowerKey:find("speed", 1, true) or lowerKey:find("spawn", 1, true) or lowerKey:find("death", 1, true) or lowerKey:find("pain", 1, true) or lowerKey:find("ragdoll", 1, true) or lowerKey:find("crosshair", 1, true) then return "Gameplay" end
            if lowerCategory == "core" or raw == "Core" then return "Core" end
            return localized ~= "" and localized or "Core"
        end

        local function sortCategories(categories)
            local sorted = {}
            local exists = {}
            for _, category in ipairs(preferredCategories) do
                if categories[category] then
                    sorted[#sorted + 1] = category
                    exists[category] = true
                end
            end

            local remaining = {}
            for category in pairs(categories) do
                if not exists[category] then remaining[#remaining + 1] = category end
            end

            table.sort(remaining, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
            for _, category in ipairs(remaining) do
                sorted[#sorted + 1] = category
            end
            return sorted
        end

        local function styleScroll(scroll)
            local bar = scroll:GetVBar()
            if not IsValid(bar) then return end
            bar:SetWide(6)
            bar.Paint = function(_, w, h) rounded(2, 0, w - 2, h, 4, Color(0, 0, 0, 70)) end
            bar.btnGrip.Paint = function(_, w, h) rounded(1, 0, w - 1, h, 4, Color(getAccent().r, getAccent().g, getAccent().b, 185)) end
            bar.btnUp.Paint = function() end
            bar.btnDown.Paint = function() end
        end

        local function makeButton(parent, text, width, primary)
            local button = parent:Add("DButton")
            button:SetText("")
            button:SetWide(width or 140)
            button:SetCursor("hand")
            button.Paint = function(s, w, h)
                local accent = getAccent(primary and 205 or 105)
                local fill = primary and Color(accent.r, accent.g, accent.b, s:IsHovered() and 230 or 190) or Color(7, 21, 28, s:IsHovered() and 235 or 190)
                rounded(0, 0, w, h, 6, fill)
                outline(0, 0, w, h, Color(accent.r, accent.g, accent.b, s:IsHovered() and 185 or 105))
                draw.SimpleText(text, "LiliaFont.18", w * 0.5, h * 0.5, getTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            return button
        end

        local function makeSection(parent, text, icon)
            local header = parent:Add("DPanel")
            header:Dock(TOP)
            header:SetTall(32)
            header:DockMargin(0, 8, 0, 0)
            header.Paint = function(_, w, h)
                local accent = getAccent()
                draw.SimpleText(string.upper(tostring(text or "")), "LiliaFont.18", 10, h * 0.52, Color(accent.r, accent.g, accent.b, 245), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                surface.SetDrawColor(accent.r, accent.g, accent.b, 165)
                surface.DrawRect(0, h - 2, w, 1)
            end
            return header
        end

        local function makeToggle(parent, key, name, value, setValue, description)
            local button = parent:Add("DButton")
            button:Dock(RIGHT)
            button:SetWide(48)
            button:DockMargin(0, 12, 14, 12)
            button:SetText("")
            button:SetCursor("hand")
            SetStyledTooltip(button, description)
            button.Paint = function(_, w, h)
                local state = tobool(value())
                local accent = getAccent()
                local bg = state and Color(accent.r, accent.g, accent.b, 218) or Color(70, 84, 89, 210)
                local knob = state and w - h + 4 or 4
                rounded(0, 0, w, h, h * 0.5, bg)
                rounded(knob, 4, h - 8, h - 8, h * 0.5, Color(235, 242, 242, 255))
            end

            button.DoClick = function() setValue(not tobool(value())) end
        end

        local function makeValueEditor(parent, key, name, config, configType, getValue, setValue, description)
            if configType == "Boolean" then
                makeToggle(parent, key, name, getValue, setValue, description)
                return
            end

            if configType == "Number" or configType == "Int" or configType == "Float" or configType == "Generic" then
                local entry = parent:Add("liaEntry")
                entry:Dock(RIGHT)
                entry:SetWidth(configType == "Generic" and 245 or 130)
                entry:DockMargin(0, 9, 14, 9)
                entry:SetValue(displayValue(getValue()))
                entry:SetFont("LiliaFont.18")
                SetStyledTooltip(entry, description)
                local function submitEntry()
                    if not IsValid(entry) then return end
                    local value = normalizeConfigValue(entry:GetValue(), configType, config)
                    if value == nil then
                        entry:SetValue(displayValue(getValue()))
                        return
                    end

                    setValue(value)
                    entry:SetValue(displayValue(value))
                end

                if entry.textEntry then
                    entry.textEntry.OnEnter = submitEntry
                    entry.textEntry.OnLoseFocus = submitEntry
                else
                    entry.OnEnter = submitEntry
                    entry.OnLoseFocus = submitEntry
                end
                return
            end

            if configType == "Color" then
                local button = parent:Add("DButton")
                button:Dock(RIGHT)
                button:SetWidth(150)
                button:DockMargin(0, 9, 14, 9)
                button:SetText("")
                button:SetCursor("hand")
                SetStyledTooltip(button, description)
                button.Paint = function(_, w, h)
                    local c = getValue()
                    if istable(c) and c.r and c.g and c.b and not IsColor(c) then c = Color(c.r, c.g, c.b, c.a or 255) end
                    if not IsColor(c) then c = color_white end
                    rounded(0, 0, w, h, 5, Color(5, 16, 22, 230))
                    outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 130))
                    rounded(8, 6, w - 16, h - 12, 4, c)
                end

                button.DoClick = function()
                    local c = getValue()
                    if not IsColor(c) and istable(c) then c = Color(c.r, c.g, c.b, c.a or 255) end
                    if not IsColor(c) then c = color_white end
                    lia.derma.requestColorPicker(function(color) setValue(color) end, c)
                end
                return
            end

            if configType == "Table" then
                local combo = parent:Add("liaComboBox")
                combo:Dock(RIGHT)
                combo:SetWidth(210)
                combo:DockMargin(0, 9, 14, 9)
                combo:SetFont("LiliaFont.18")
                SetStyledTooltip(combo, description)
                local options = lia.config.getOptions(key)
                local selectedValue = getValue()
                local selectedLabel = selectedValue
                for _, optionEntry in pairs(options) do
                    combo:AddChoice(optionEntry.label, optionEntry.value)
                    if optionEntry.value == selectedValue then selectedLabel = optionEntry.label end
                end

                combo:SetValue(tostring(selectedLabel))
                combo.OnSelect = function(_, _, _, v) setValue(v) end
            end
        end

        local function AddField(scroll, key, name, config, pendingChanges, onPendingChanged)
            local configType = config.data and config.data.type or config.type or "Generic"
            local description = tostring(lia.config.getDisplayDesc(key) or "")
            local row = scroll:Add("DPanel")
            row:Dock(TOP)
            row:SetTall(52)
            row:DockMargin(0, 0, 0, 2)
            SetStyledTooltip(row, description)
            local function currentValue()
                if pendingChanges and pendingChanges[key] ~= nil then return pendingChanges[key] end
                return lia.config.get(key, config.value)
            end

            local function setValue(value)
                if pendingChanges then
                    local original = lia.config.get(key, config.value)
                    if cfgValuesEqual(original, value) then
                        pendingChanges[key] = nil
                    else
                        pendingChanges[key] = value
                    end

                    if onPendingChanged then onPendingChanged() end
                    row:InvalidateLayout(true)
                else
                    sendConfigValue(key, name, value)
                end
            end

            row.Paint = function(s, w, h)
                local hovered = s:IsHovered()
                local changed = pendingChanges and pendingChanges[key] ~= nil
                rounded(0, 0, w, h, 0, changed and Color(getAccent().r, getAccent().g, getAccent().b, 28) or hovered and uiColors.rowHover or uiColors.row)
                surface.SetDrawColor(Color(getAccent().r, getAccent().g, getAccent().b, 78))
                surface.DrawRect(0, h - 1, w, 1)
                if changed then
                    local accent = getAccent()
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 220)
                    surface.DrawRect(0, 0, 3, h)
                end
            end

            local labels = row:Add("DPanel")
            labels:Dock(FILL)
            labels:DockMargin(14, 5, 18, 5)
            labels.Paint = function() end
            local title = labels:Add("DLabel")
            title:Dock(TOP)
            title:SetTall(21)
            title:SetText(name)
            title:SetFont("LiliaFont.18")
            title:SetTextColor(getTextColor())
            title:SetContentAlignment(4)
            SetStyledTooltip(title, description)
            local desc = labels:Add("DLabel")
            desc:Dock(FILL)
            desc:SetText(description)
            desc:SetFont("LiliaFont.16")
            desc:SetTextColor(uiColors.muted)
            desc:SetContentAlignment(4)
            desc:SetWrap(false)
            SetStyledTooltip(desc, description)
            makeValueEditor(row, key, name, config, configType, currentValue, setValue, description)
        end

        local function collectConfigItems(configs)
            local categories = {}
            local total = 0
            for key, config in pairs(configs) do
                local category = getVisualCategory(key, config)
                categories[category] = categories[category] or {}
                categories[category][#categories[category] + 1] = {
                    key = key,
                    name = tostring(lia.config.getDisplayName(key) or key),
                    desc = tostring(lia.config.getDisplayDesc(key) or ""),
                    config = config
                }

                total = total + 1
            end

            for _, items in pairs(categories) do
                table.sort(items, function(a, b) return tostring(a.name or ""):lower() < tostring(b.name or ""):lower() end)
            end
            return categories, total
        end

        local function itemMatches(item, category, filter)
            if not filter or filter == "" then return true end
            local needle = filter:lower()
            return tostring(item.name or ""):lower():find(needle, 1, true) or tostring(item.desc or ""):lower():find(needle, 1, true) or tostring(item.key or ""):lower():find(needle, 1, true) or tostring(category or ""):lower():find(needle, 1, true)
        end

        local function drawConfigPage(parent, configs, titleText, subtitleText, usePending)
            parent:Clear()
            parent:DockPadding(0, 0, 0, 0)
            local categories, total = collectConfigItems(configs)
            local sortedCategories = sortCategories(categories)
            local selectedCategory = categories.Core and "Core" or sortedCategories[1]
            local filterText = ""
            local pendingChanges = usePending and {} or nil
            local root = parent:Add("DPanel")
            root:Dock(FILL)
            root:DockMargin(0, 0, 0, 0)
            root.Paint = function(_, w, h)
                rounded(0, 0, w, h, 8, uiColors.bg)
                outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 80))
            end

            local header = root:Add("DPanel")
            header:Dock(TOP)
            header:SetTall(72)
            header:DockMargin(14, 12, 14, 0)
            header.Paint = function() end
            local title = header:Add("DLabel")
            title:Dock(TOP)
            title:SetTall(32)
            title:SetText(titleText)
            title:SetFont("LiliaFont.22")
            title:SetTextColor(getTextColor())
            title:SetContentAlignment(4)
            local subtitle = header:Add("DLabel")
            subtitle:Dock(TOP)
            subtitle:SetTall(24)
            subtitle:SetText(subtitleText)
            subtitle:SetFont("LiliaFont.18")
            subtitle:SetTextColor(uiColors.muted)
            subtitle:SetContentAlignment(4)
            local toolbar = root:Add("DPanel")
            toolbar:Dock(TOP)
            toolbar:SetTall(42)
            toolbar:DockMargin(14, 0, 14, 10)
            toolbar.Paint = function() end
            local status = toolbar:Add("DPanel")
            status:Dock(RIGHT)
            status:SetWide(usePending and 170 or 0)
            status:DockMargin(10, 3, 0, 3)
            status.Paint = function(_, w, h)
                if not usePending then return end
                local count = tableSize(pendingChanges)
                local accent = getAccent()
                rounded(0, 0, w, h, 6, Color(13, 30, 35, 225))
                outline(0, 0, w, h, Color(accent.r, accent.g, accent.b, count > 0 and 135 or 65))
                draw.SimpleText(count > 0 and "Unsaved Changes" or "No Changes", "LiliaFont.18", w * 0.5, h * 0.5, count > 0 and getTextColor() or uiColors.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            local categoryCombo = toolbar:Add("liaComboBox")
            categoryCombo:Dock(RIGHT)
            categoryCombo:SetWide(190)
            categoryCombo:DockMargin(0, 3, 0, 3)
            categoryCombo:SetFont("LiliaFont.18")
            categoryCombo:AddChoice("All Categories", "__all")
            for _, category in ipairs(sortedCategories) do
                categoryCombo:AddChoice(category, category)
            end

            categoryCombo:SetValue(selectedCategory or "All Categories")
            local searchEntry = toolbar:Add("liaEntry")
            searchEntry:Dock(FILL)
            searchEntry:DockMargin(0, 3, 10, 3)
            searchEntry:SetPlaceholderText("Search configs..." or "Search settings...")
            searchEntry:SetFont("LiliaFont.18")
            local body = root:Add("DPanel")
            body:Dock(FILL)
            body:DockMargin(14, 0, 14, usePending and 0 or 14)
            body.Paint = function() end
            local rail = body:Add("DPanel")
            rail:Dock(LEFT)
            rail:SetWide(255)
            rail:DockMargin(0, 0, 12, 0)
            rail.Paint = function(_, w, h)
                rounded(0, 0, w, h, 8, uiColors.bgSoft)
                outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 78))
            end

            local railScroll = rail:Add("liaScrollPanel")
            railScroll:Dock(FILL)
            railScroll:DockMargin(8, 8, 8, 8)
            styleScroll(railScroll)
            local scroll = body:Add("liaScrollPanel")
            scroll:Dock(FILL)
            scroll:GetCanvas():DockPadding(0, 0, 0, 0)
            styleScroll(scroll)
            local footer
            local footerStatus
            local saveButton
            local resetButton
            local refreshFooter
            local populate
            local rebuildRail
            rebuildRail = function()
                railScroll:Clear()
                local function addRailButton(label, value)
                    local button = railScroll:Add("DButton")
                    button:Dock(TOP)
                    button:SetTall(48)
                    button:DockMargin(0, 0, 0, 6)
                    button:SetText("")
                    button:SetCursor("hand")
                    button.Paint = function(s, w, h)
                        local active = selectedCategory == value or (not selectedCategory and value == nil)
                        local accent = getAccent()
                        rounded(0, 0, w, h, 5, active and Color(accent.r, accent.g, accent.b, 35) or s:IsHovered() and Color(16, 34, 40, 235) or Color(10, 25, 30, 210))
                        outline(0, 0, w, h, active and Color(accent.r, accent.g, accent.b, 160) or Color(getAccent().r, getAccent().g, getAccent().b, 62))
                        if active then
                            surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                            surface.DrawRect(0, 0, 3, h)
                        end

                        local count = value and categories[value] and #categories[value] or total
                        draw.SimpleText(label, "LiliaFont.18", 16, h * 0.38, active and getTextColor() or Color(230, 239, 239), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(count .. " settings", "LiliaFont.16", 16, h * 0.68, uiColors.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end

                    button.DoClick = function()
                        selectedCategory = value
                        if IsValid(categoryCombo) then categoryCombo:SetValue(value or "All Categories") end
                        rebuildRail()
                        populate(filterText)
                    end
                end

                addRailButton("All Settings", nil)
                for _, category in ipairs(sortedCategories) do
                    addRailButton(category, category)
                end
            end

            populate = function(filter)
                if not IsValid(scroll) then return end
                scroll:Clear()
                filterText = filter or ""
                local hasAny = false
                local categoriesToDraw = selectedCategory and {selectedCategory} or sortedCategories
                for _, category in ipairs(categoriesToDraw) do
                    local items = categories[category]
                    local visible = {}
                    if items then
                        for _, item in ipairs(items) do
                            if itemMatches(item, category, filterText) then visible[#visible + 1] = item end
                        end
                    end

                    if #visible > 0 then
                        hasAny = true
                        makeSection(scroll, category, categoryIcons[category])
                        for _, item in ipairs(visible) do
                            AddField(scroll, item.key, item.name, item.config, pendingChanges, refreshFooter)
                        end
                    end
                end

                if not hasAny then
                    local empty = scroll:Add("DPanel")
                    empty:Dock(TOP)
                    empty:SetTall(90)
                    empty.Paint = function(_, w, h)
                        rounded(0, 0, w, h, 6, Color(8, 22, 28, 185))
                        outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 78))
                        draw.SimpleText("No settings match your search.", "LiliaFont.18", w * 0.5, h * 0.5, uiColors.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end

            if usePending then
                footer = root:Add("DPanel")
                footer:Dock(BOTTOM)
                footer:SetTall(54)
                footer:DockMargin(14, 8, 14, 14)
                footer.Paint = function(_, w, h)
                    surface.SetDrawColor(Color(getAccent().r, getAccent().g, getAccent().b, 78))
                    surface.DrawRect(0, 0, w, 1)
                end

                footerStatus = footer:Add("DLabel")
                footerStatus:Dock(LEFT)
                footerStatus:SetWide(520)
                footerStatus:SetFont("LiliaFont.18")
                footerStatus:SetTextColor(uiColors.muted)
                footerStatus:SetContentAlignment(4)
                saveButton = makeButton(footer, "Save Changes", 165, true)
                saveButton:Dock(RIGHT)
                saveButton:DockMargin(8, 9, 0, 8)
                resetButton = makeButton(footer, "Reset", 135, false)
                resetButton:Dock(RIGHT)
                resetButton:DockMargin(8, 9, 0, 8)
                refreshFooter = function()
                    if not IsValid(footerStatus) then return end
                    local count = tableSize(pendingChanges)
                    footerStatus:SetText(total .. " settings    |    " .. count .. " modified    |    Changes save when you press Save Changes")
                    if IsValid(status) then status:InvalidateLayout(true) end
                    if IsValid(saveButton) then saveButton:InvalidateLayout(true) end
                    if IsValid(resetButton) then resetButton:InvalidateLayout(true) end
                end

                resetButton.DoClick = function()
                    table.Empty(pendingChanges)
                    refreshFooter()
                    populate(filterText)
                end

                saveButton.DoClick = function()
                    if tableSize(pendingChanges) <= 0 then return end
                    for key, value in pairs(pendingChanges) do
                        sendConfigValue(key, tostring(lia.config.getDisplayName(key) or key), value)
                    end

                    table.Empty(pendingChanges)
                    refreshFooter()
                    timer.Simple(0.2, function() if IsValid(parent) then populate(filterText) end end)
                end
            else
                refreshFooter = function() end
            end

            searchEntry:SetUpdateOnType(true)
            searchEntry.OnTextChanged = function(_, text) populate(text) end
            categoryCombo.OnSelect = function(_, _, _, value)
                selectedCategory = value == "__all" and nil or value
                rebuildRail()
                populate(filterText)
            end

            rebuildRail()
            populate(nil)
            refreshFooter()
        end

        if hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false then
            net.Start("liaCfgList")
            net.SendToServer()
            local uniqueTabConfigs = {}
            local regularConfigs = {}
            for k, v in pairs(lia.config.stored) do
                if istable(v) and v.data ~= nil and v.default ~= nil and v.name ~= nil then
                    if v.data.uniqueTab then
                        uniqueTabConfigs[k] = v
                    else
                        regularConfigs[k] = v
                    end
                end
            end

            local categoryPages = {}
            for key, config in pairs(uniqueTabConfigs) do
                local category = getRawCategory(config)
                categoryPages[category] = categoryPages[category] or {
                    configs = {}
                }

                table.insert(categoryPages[category].configs, {
                    key = key,
                    config = config
                })
            end

            for category, pageData in pairs(categoryPages) do
                local pageConfigs = {}
                for _, configInfo in ipairs(pageData.configs) do
                    pageConfigs[configInfo.key] = configInfo.config
                end

                pages[#pages + 1] = {
                    name = category,
                    shouldShow = function() return hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false end,
                    drawFunc = function(parent) drawConfigPage(parent, pageConfigs, tostring(cfgLocalizeLabel(category) or category), "Manage this configuration section.", false) end
                }
            end

            pages[#pages + 1] = {
                name = "Configuration",
                shouldShow = function() return hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false end,
                drawFunc = function(parent) drawConfigPage(parent, regularConfigs, "Configuration", "Manage core server settings, keybinds, options, and item configuration.", true) end
            }
        end
    end)
end

lia.config.add("MainCharacterCooldownDays", "Main Character Cooldown (Days)", 0, nil, {
    category = "Core",
    type = "Int",
    min = 0,
    max = 365,
    desc = "How many days until you can change your main character again. Set to 0 to allow changes at any time."
})

lia.config.add("MoneyModel", "Money Model", "models/props/cs_assault/Dollar.mdl", nil, {
    desc = "Defines the model used for representing money in the game.",
    category = "Core",
    type = "Generic"
})

lia.config.add("MaxMoneyEntities", "Max Money Entities", 3, nil, {
    desc = "Maximum number of money entities that can be dropped at once.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 50
})

lia.config.add("CurrencySymbol", "Currency Symbol", "", function(newVal) lia.currency.symbol = newVal end, {
    desc = "Specifies the currency symbol used in the game.",
    category = "Core",
    type = "Generic"
})

lia.config.add("CurrencySingularName", "Currency Singular Name", "dollar", function(newVal) lia.currency.singular = tostring(newVal) end, {
    desc = "Singular name of the in-game currency.",
    category = "Core",
    type = "Generic"
})

lia.config.add("CurrencyPluralName", "Currency Plural Name", "dollars", function(newVal) lia.currency.plural = tostring(newVal) end, {
    desc = "Plural name of the in-game currency.",
    category = "Core",
    type = "Generic"
})

lia.config.add("WalkSpeed", "Walk Speed", 200, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetWalkSpeed(newValue)
    end
end, {
    desc = "Controls how fast characters walk.",
    category = "Core",
    type = "Number",
    min = 50,
    max = 300
})

lia.config.add("DeathSoundEnabled", "Enable Death Sound", true, nil, {
    desc = "Enable or disable death sounds globally.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("PainSoundEnabled", "Enable Pain Sound", true, nil, {
    desc = "Enable or disable pain sounds globally.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("FallDamageEnabled", "Enable Fall Damage", true, nil, {
    desc = "Enable or disable fall damage globally.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("LimbDamage", "Limb Damage Multiplier", 0.5, nil, {
    desc = "Sets the damage multiplier for limb hits.",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 1
})

lia.config.add("DamageScale", "Global Damage Scale", 1, nil, {
    desc = "Scales all damage dealt by this multiplier.",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 5
})

lia.config.add("HeadShotDamage", "Headshot Damage Multiplier", 2, nil, {
    desc = "Sets the damage multiplier for headshots.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 10
})

lia.config.add("RunSpeed", "Run Speed", 400, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetRunSpeed(newValue)
    end
end, {
    desc = "Controls how fast characters run.",
    category = "Core",
    type = "Number",
    min = 100,
    max = 500
})

lia.config.add("MaxCharacters", "Max Characters", 5, nil, {
    desc = "Sets the maximum number of characters a player can have.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 20
})

lia.config.add("AllowPMs", "Allow Private Messages", true, nil, {
    desc = "Determines whether private messages are allowed.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("MinDescLen", "Minimum Description Length", 16, nil, {
    desc = "Minimum length required for a character's description.",
    category = "Core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("DefaultMoney", "Default Money", 0, nil, {
    desc = "Specifies the default amount of money a player starts with.",
    category = "Core",
    type = "Number",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", "Data Save Interval", 600, nil, {
    desc = "Time interval between data saves.",
    category = "Core",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", "Character Data Save Interval", 60, nil, {
    desc = "Time interval between character data saves.",
    category = "Core",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", "Respawn Time", 5, nil, {
    desc = "Time to respawn after death.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("TimeToEnterVehicle", "Time To Enter Vehicle", 1, nil, {
    desc = "Defines the time to enter vehicle.",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 30
})

lia.config.add("CarEntryDelayEnabled", "Car Entry Delay Enabled", true, nil, {
    desc = "Whether entering a vehicle requires a delay.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("MaxChatLength", "Max Chat Length", 256, nil, {
    desc = "Sets the maximum length of chat messages.",
    category = "Core",
    type = "Number",
    min = 50,
    max = 1024
})

lia.config.add("DoorsAlwaysDisabled", "Doors Always Disabled", false, nil, {
    desc = "When enabled, all doors will be disabled by default when the server loads.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("AdminConsoleNetworkLogs", "Admin Console Network Logs", true, nil, {
    desc = "Specifies if the logging system should replicate to super admins' consoles.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("CharMenuBGInputDisabled", "Character Menu Background Input Disabled", true, nil, {
    desc = "Whether background input is disabled during character menu use",
    category = "Core",
    type = "Boolean"
})

lia.config.add("AllowKeybindEditing", "Allow Keybind Editing", true, nil, {
    desc = "Allow players to edit their keybinds in the settings menu.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("CrosshairEnabled", "Enable Crosshair", false, nil, {
    desc = "Enables the crosshair.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("AutoWeaponItemGeneration", "Auto Weapon-to-Item Generation", true, nil, {
    desc = "Enables automatic conversion of dropped weapons into inventory items.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("AutoAmmoItemGeneration", "Auto Ammo Item Generation", true, nil, {
    desc = "Enables automatic conversion of ammo entities into inventory items.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("ItemsCanBeDestroyed", "Items Can Be Destroyed", true, nil, {
    desc = "Enables whether or not items can be destroyed.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("AmmoDrawEnabled", "Enable Ammo Display", true, nil, {
    desc = "Enables ammo display.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("IsVoiceEnabled", "Voice Chat Enabled", true, function(_, newValue) hook.Run("VoiceToggled", newValue) end, {
    desc = "Whether or not voice chat is enabled.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("SalaryInterval", "Salary Interval", 300, function()
    if not SERVER then return end
    timer.Simple(0.1, function() hook.Run("CreateSalaryTimers") end)
end, {
    desc = "Interval in seconds between salary payouts.",
    category = "Core",
    type = "Number",
    min = 5,
    max = 36000
})

lia.config.add("ThirdPersonEnabled", "Enable Third-Person View", true, nil, {
    desc = "Allows players to toggle third-person view on or off.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("MaxThirdPersonDistance", "Maximum Third-Person Distance", 100, nil, {
    desc = "Caps how far the third-person camera can be moved away from the character.",
    category = "Core",
    type = "Number",
    min = 0,
    max = 100
})

lia.config.add("MaxThirdPersonHorizontal", "Maximum Third-Person Horizontal Offset", 30, nil, {
    desc = "Caps how far left or right the third-person camera can be offset from the character.",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("MaxThirdPersonHeight", "Maximum Third-Person Height Offset", 30, nil, {
    desc = "Caps how high the third-person camera can be offset above the character.",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

local function getDermaSkins()
    local skins = {}
    for name in pairs(derma.GetSkinTable()) do
        table.insert(skins, name)
    end

    table.sort(skins)
    return skins
end

lia.config.add("DermaSkin", "Derma UI Skin", "Lilia Skin", function(_, newSkin) hook.Run("DermaSkinChanged", newSkin) end, {
    desc = "Select the Derma UI skin to use.",
    category = "Core",
    type = "Table",
    options = CLIENT and getDermaSkins() or {"liliaSkin"}
})

lia.config.add("Language", "Language", "English", nil, {
    desc = "Determines the language setting for the game.",
    category = "Core",
    type = "Table",
    options = lia.lang.getLanguages()
})

lia.config.add("SpawnMenuLimit", "Limit Spawn Menu Access", false, nil, {
    desc = "Determines if the spawn menu is limited to PET flag holders or staff",
    category = "Core",
    type = "Boolean"
})

lia.config.add("LogRetentionDays", "Log Retention Period", 7, nil, {
    desc = "Determines how many days of logs should be read.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 30,
})

lia.config.add("StaminaSlowdown", "Stamina Slowdown Enabled", true, nil, {
    desc = "Is Stamina Slowdown Enabled?",
    category = "Core",
    type = "Boolean",
})

lia.config.add("DefaultStamina", "Default Stamina Value", 100, nil, {
    desc = "Sets default stamina value.",
    category = "Core",
    type = "Number",
    min = 10,
    max = 1000
})

lia.config.add("JumpStaminaCost", "Jump Stamina Cost", 10, nil, {
    desc = "Stamina cost deducted when the player jumps.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 1000
})

lia.config.add("PunchStamina", "Punch Stamina", 10, nil, {
    desc = "How much stamina is consumed per punch.",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("PunchLethality", "Punch Lethality", true, nil, {
    desc = "Whether punches can kill players or just knock them out.",
    category = "Core",
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("StaminaDrain", "Stamina Drain", 1, nil, {
    desc = "The rate at which stamina drains.",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 10,
    decimals = 2
})

lia.config.add("StaminaRegeneration", "Stamina Regeneration", 1.75, nil, {
    desc = "The rate at which stamina regenerates.",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 50,
    decimals = 2
})

lia.config.add("StaminaCrouchRegeneration", "Stamina Crouch Regeneration", 2, nil, {
    desc = "The rate at which stamina regenerates while crouching.",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 50,
    decimals = 2
})

lia.config.add("logsPerPage", "Logs Per Page", 50, nil, {
    desc = "Number of log entries to display per page in the administration logs interface",
    category = "Core",
    type = "Number",
    min = 10,
    max = 1000
})

lia.config.add("PunchRagdollTime", "Punch Ragdoll Time", 25, nil, {
    desc = "Duration in seconds that players are ragdolled when punched while lethality is disabled.",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("MaxHoldWeight", "Maximum Hold Weight", 100, nil, {
    desc = "The maximum weight that a player can carry in their hands.",
    category = "Core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("ThrowForce", "Throw Force", 100, nil, {
    desc = "How hard a player can throw the item that they're holding.",
    category = "Core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("PunchPlaytime", "Punch Playtime Protection", 7200, nil, {
    desc = "Minimum playtime in seconds required to punch.",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 0,
    max = 86400
})

lia.config.add("CustomChatSound", "Custom Chat Sound", "", nil, {
    desc = "Change chat sound on message send.",
    category = "Core",
    type = "Generic",
})

lia.config.add("TalkRange", "Talk Range", 280, nil, {
    desc = "Base range for all talk-based chat modes (whisper, normal, yell).",
    category = "Core",
    type = "Number",
    min = 50,
    max = 10000
})

lia.config.add("WhisperRange", "Whisper Range", 70, nil, {
    desc = "Range at which whisper chat can be heard.",
    category = "Core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("YellRange", "Yell Range", 840, nil, {
    desc = "Range at which yell chat can be heard.",
    category = "Core",
    type = "Number",
    min = 100,
    max = 2000
})

lia.config.add("OOCLimit", "OOC Character Limit", 150, nil, {
    desc = "Limit of characters in OOC.",
    category = "Core",
    type = "Number",
    min = 25,
    max = 1000
})

lia.config.add("OOCDelay", "OOC Delay", 10, nil, {
    desc = "Set OOC text delay.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelay", "LOOC Delay", 6, nil, {
    desc = "Set LOOC text delay.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelayAdmin", "LOOC Delay for Admins", false, nil, {
    desc = "Should admins have LOOC delay.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("OOCBlocked", "The OOC is Globally Blocked!", false, nil, {
    desc = "Whether or not out-of-character chat is globally blocked.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("ChatSizeDiff", "Enable Different Chat Size", false, nil, {
    desc = "Enable different chat size.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("MusicVolume", "Music Volume", 0.25, nil, {
    desc = "The volume level for the main menu music",
    category = "Core",
    type = "Number",
    min = 0.01,
    max = 1.0
})

lia.config.add("Music", "Main Menu Music", "", nil, {
    desc = "The file path or URL for the main menu background music",
    category = "Core",
    type = "Generic"
})

lia.config.add("BackgroundURL", "Main Menu Background URL", "", nil, {
    desc = "The URL or file path for the main menu background image",
    category = "Core",
    type = "Generic"
})

lia.config.add("ServerLogo", "Server Logo", "", nil, {
    desc = "The file path or URL for the server logo displayed on the main menu and scoreboard",
    category = "Core",
    type = "Generic"
})

lia.config.add("MainMenuLogoEnabled", "Main Menu Logo Enabled", true, nil, {
    desc = "Enable or disable the server logo display on the main menu",
    category = "Core",
    type = "Boolean"
})

lia.config.add("DiscordURL", "Main Menu Discord URL", "", nil, {
    desc = "Discord server URL for the main menu",
    category = "Core",
    type = "Generic"
})

lia.config.add("Workshop", "Main Menu Workshop URL", "", nil, {
    desc = "Workshop collection URL for the main menu",
    category = "Core",
    type = "Generic"
})

lia.config.add("CharMenuBGInputDisabled", "Character Menu Background Input Disabled", true, nil, {
    desc = "Whether background input is disabled during character menu use",
    category = "Core",
    type = "Boolean"
})

lia.config.add("SwitchCooldownOnAllEntities", "Apply cooldown on all entities", false, nil, {
    desc = "If true, character switch cooldowns gets applied by all types of damage.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("OnDamageCharacterSwitchCooldownTimer", "Switch cooldown after damage", 15, nil, {
    desc = "Cooldown duration (in seconds) after taking damage to switch characters.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("CharacterSwitchCooldownTimer", "Character switch cooldown timer", 5, nil, {
    desc = "Cooldown duration (in seconds) for switching characters.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("ExplosionRagdoll", "Explosion Ragdoll on Hit", false, nil, {
    desc = "Determines whether being hit by an explosion results in ragdolling",
    category = "Core",
    type = "Boolean",
})

lia.config.add("CarRagdoll", "Car Ragdoll on Hit", false, nil, {
    desc = "Determines whether being hit by a car results in ragdolling",
    category = "Core",
    type = "Boolean",
})

lia.config.add("TimeUntilDroppedSWEPRemoved", "Time Until Dropped SWEP Removed", 15, nil, {
    desc = "Specifies the duration (in seconds) until a dropped SWEP is removed",
    category = "Core",
    type = "Number",
    min = 1,
    max = 300
})

lia.config.add("AltsDisabled", "Disable Alts", false, nil, {
    desc = "Whether or not alting is permitted",
    category = "Core",
    type = "Boolean",
})

lia.config.add("ActsActive", "Enable Acts", false, nil, {
    desc = "Determines whether acts are active",
    category = "Core",
    type = "Boolean",
})

lia.config.add("PropProtection", "Prop Protection", true, nil, {
    desc = "Enables prop crash prevention behaviors (physgun pickup/drop collision safety and freeze pass-through).",
    category = "Core",
    type = "Boolean",
})

lia.config.add("PassableOnFreeze", "Passable on Freeze", false, nil, {
    desc = "Makes it so that props frozen can be passed through when frozen",
    category = "Core",
    type = "Boolean",
})

lia.config.add("PlayerSpawnVehicleDelay", "Player Spawn Vehicle Delay", 30, nil, {
    desc = "Delay for spawning a vehicle after the previous one",
    category = "Core",
    type = "Number",
    min = 0,
    max = 300
})

lia.config.add("MouthMoveAnimation", "Mouth Move Animation", true, nil, {
    desc = "Whether or not the mouth movement animation is enabled.",
    category = "Performance",
    type = "Boolean"
})

lia.config.add("GrabEarAnimation", "Grab Ear Animation", false, nil, {
    desc = "Whether or not the grab ear animation is enabled.",
    category = "Performance",
    type = "Boolean"
})

lia.config.add("VoiceIcons", "Voice Icons", false, function(_, newValue) if SERVER then RunConsoleCommand("mp_show_voice_icons", newValue and 1 or 0) end end, {
    desc = "Whether or not the default voice icons are shown.",
    category = "Performance",
    type = "Boolean"
})

lia.config.add("DisableLuaRun", "Disable Lua Run Hooks", false, nil, {
    desc = "Whether or not Lilia should prevent lua_run hooks on maps",
    category = "Core",
    type = "Boolean",
})

lia.config.add("EquipDelay", "Equip Delay", 0, nil, {
    desc = "Time delay between equipping items.",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("UnequipDelay", "Unequip Delay", 0, nil, {
    desc = "Time delay between unequipping items.",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("DropDelay", "Drop Delay", 0, nil, {
    desc = "Time delay between dropping items.",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("DeleteDroppedItemsOnLeave", "Delete Dropped Items On Leave", false, nil, {
    desc = "When enabled, all items dropped by a player will be deleted when they disconnect.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("HUDFont", "HUD Font", "Montserrat Medium", function() if not CLIENT then return end end, {
    desc = "Font used for HUD-painted text and overlays.",
    category = "Fonts",
    type = "Table",
    options = function()
        if CLIENT then return lia.font.getAvailableFonts() end
        return {"Montserrat Medium"}
    end
})

lia.config.add("DeleteEntitiesOnLeave", "Delete Entities On Leave", true, nil, {
    desc = "When enabled, all entities created by a player (except lia_ entities) will be deleted when they disconnect.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("TakeDelay", "Take Delay", 0, nil, {
    desc = "Time delay between taking items.",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("ItemGiveSpeed", "Item Give Speed", 6, nil, {
    desc = "How fast transferring items between players via giveForward is.",
    category = "Core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("ItemGiveEnabled", "Is Item Giving Enabled", true, nil, {
    desc = "Determines if item giving via giveForward is enabled.",
    category = "Core",
    type = "Boolean",
})

lia.config.add("LoseItemsonDeathNPC", "Lose Items on NPC Death", false, nil, {
    desc = "Determine if items marked for loss are lost on death by NPCs.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathHuman", "Lose Items on Human Death", false, nil, {
    desc = "Determine if items marked for loss are lost on death by humans.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathWorld", "Lose Items on World Death", false, nil, {
    desc = "Determine if items marked for loss are lost on death by the world.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("DeathPopupEnabled", "Enable Death Popup", true, nil, {
    desc = "Enable or disable the death information popup.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("ClassDisplay", "Display Classes on Characters", true, nil, {
    desc = "Whether or not classes are displayed on characters.",
    category = "Core",
    type = "Boolean",
})

local function refreshScoreboard()
    if CLIENT and IsValid(lia.gui.score) then lia.gui.score:ApplyConfig() end
end

lia.config.add("sbWidth", "Scoreboard Width", 0.65, refreshScoreboard, {
    desc = "Scoreboard width proportion",
    category = "Core",
    type = "Number",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbHeight", "Scoreboard Height", 0.65, refreshScoreboard, {
    desc = "Scoreboard height proportion",
    category = "Core",
    type = "Number",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbDock", "Scoreboard Dock", "center", refreshScoreboard, {
    desc = "Determines where the scoreboard appears on screen",
    category = "Core",
    type = "Table",
    options = {"left", "center", "right"}
})

lia.config.add("ClassHeaders", "Class Headers", true, nil, {
    desc = "Should class headers exist?",
    category = "Core",
    type = "Boolean"
})

lia.config.add("RecognitionEnabled", "Character Recognition Enabled", true, nil, {
    desc = "Whether or not character recognition is enabled?",
    category = "Core",
    type = "Boolean"
})

lia.config.add("FakeNamesEnabled", "Fake Names Enabled", false, nil, {
    desc = "Are fake names enabled?",
    category = "Core",
    type = "Boolean"
})

lia.config.add("vendorDefaultMoney", "Default Vendor Money", 500, nil, {
    desc = "Default amount of money vendors start with",
    category = "Core",
    type = "Number",
    min = 100,
    max = 10000
})

local function getMenuTabNames()
    local defs = {}
    hook.Run("CreateMenuButtons", defs)
    local tabs = {}
    for k in pairs(defs) do
        tabs[#tabs + 1] = k
    end
    return tabs
end

lia.config.add("DefaultMenuTab", "Default Menu Tab", "You", nil, {
    desc = "Specifies which tab is opened by default when the menu is shown.",
    category = "Core",
    type = "Table",
    options = function()
        local tabs = {}
        local tabNames = CLIENT and getMenuTabNames() or {"You"}
        for _, tabName in ipairs(tabNames) do
            tabs[tostring(tabName) or tabName] = tabName
        end
        return tabs
    end
})

lia.config.add("DoorLockTime", "Door Lock Time", 0.5, nil, {
    desc = "Time delay for door lock/unlock actions",
    category = "Core",
    type = "Number",
    min = 0.05,
    max = 30.0
})

lia.config.add("DoorSellRatio", "Door Sell Ratio", 0.5, nil, {
    desc = "Percentage you can sell a door for",
    category = "Core",
    min = 0.1,
    max = 1.0
})

lia.config.add("MainMenuUseLastPos", "Use Last Position for Main Menu", true, nil, {
    desc = "Uses the character's saved last position for the main menu camera when available, then falls back to the current position for the character you are already using.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("AmericanTimeStamps", "American Timestamps", false, nil, {
    desc = "Display timestamps in 12-hour AM/PM format instead of 24-hour format.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("Color", "Accent Color", Color(0, 150, 255), nil, {
    desc = "The primary accent color used throughout the UI.",
    category = "Core",
    type = "Color"
})

lia.config.add("StaffHasGodMode", "Staff Has God Mode", true, nil, {
    desc = "Grants god mode to staff members while they are on duty.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("descriptionWidth", "Description Width", 0.5, nil, {
    desc = "Adjust the description width on the HUD",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 1.0
})
