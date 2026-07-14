--[[
    Folder: Developer - Libraries
    File: lia.config.md
]]
--[[
    Configuration

    Configuration helpers for registering, retrieving, localizing, synchronizing, saving, and editing Lilia configuration values.
]]
--[[
    Overview:
        The configuration library centralizes runtime settings under `lia.config`. It stores registered configuration definitions, preserves defaults, localizes names, descriptions, categories, and selectable options, coerces networked values into the expected types, synchronizes changed server values to clients, persists non-default values, and builds the client configuration menu.
]]
--[[
    Hooks:
        InitializedConfig()

    Purpose:
        Runs after configuration values have been loaded on the server or received by the client.

    Category:
        Configuration

    Example Usage:
        ```lua
        hook.Add("InitializedConfig", "liaExampleInitializedConfig", function()
            print("[MyModule] handled InitializedConfig")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        OnConfigUpdated(string key, any oldValue, any newValue)

    Purpose:
        Runs whenever a configuration value is updated locally through `lia.config.set`, `lia.config.forceSet`, or a networked configuration update.

    Category:
        Configuration

    Parameters:
        key (string)
            The configuration key that changed.

        oldValue (any)
            The previous value for the configuration key.

        newValue (any)
            The new value for the configuration key.

    Example Usage:
        ```lua
        hook.Add("OnConfigUpdated", "liaExampleOnConfigUpdated", function(key, oldValue, newValue)
            print("[MyModule] handled OnConfigUpdated")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        CanPlayerModifyConfig(Player client, string key)

    Purpose:
        Allows plugins or modules to control whether a player may view or modify configuration values.

    Category:
        Configuration

    Parameters:
        client (Player)
            The player attempting to access or modify configuration values.

        key (string)
            The configuration key being modified. This argument is only provided during a configuration change.

    Example Usage:
        ```lua
        hook.Add("CanPlayerModifyConfig", "liaExampleCanPlayerModifyConfig", function(client, key)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return false to block access or modification. Return nil or true to allow it.

    Realm:
        Shared
]]
--[[
    Hooks:
        ConfigChanged(string key, any newValue, any oldValue, Player client)

    Purpose:
        Runs on the server after a player successfully changes a configuration value.

    Category:
        Configuration

    Parameters:
        key (string)
            The configuration key that changed.

        newValue (any)
            The new value assigned to the configuration key.

        oldValue (any)
            The previous value for the configuration key.

        client (Player)
            The player who changed the configuration value.

    Example Usage:
        ```lua
        hook.Add("ConfigChanged", "liaExampleConfigChanged", function(key, newValue, oldValue, client)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled ConfigChanged for %s", client:Name()))
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        VoiceToggled(boolean enabled)

    Purpose:
        Runs when the `IsVoiceEnabled` configuration value changes.

    Category:
        Configuration

    Parameters:
        enabled (boolean)
            True when voice chat is enabled, false when it is disabled.

    Example Usage:
        ```lua
        hook.Add("VoiceToggled", "liaExampleVoiceToggled", function(enabled)
            print("[MyModule] handled VoiceToggled")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        CreateSalaryTimers()

    Purpose:
        Runs shortly after the `SalaryInterval` configuration value changes so salary timers can be rebuilt.

    Category:
        Configuration

    Example Usage:
        ```lua
        hook.Add("CreateSalaryTimers", "liaExampleCreateSalaryTimers", function()
            print("[MyModule] handled CreateSalaryTimers")
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        DermaSkinChanged(string skin)

    Purpose:
        Runs when the `DermaSkin` configuration value changes.

    Category:
        Configuration

    Parameters:
        skin (string)
            The selected Derma skin name.

    Example Usage:
        ```lua
        hook.Add("DermaSkinChanged", "liaExampleDermaSkinChanged", function(skin)
            print("[MyModule] handled DermaSkinChanged")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        CreateMenuButtons(table tabs)

    Purpose:
        Allows menu tabs to be collected for the `DefaultMenuTab` configuration option.

    Category:
        Configuration

    Parameters:
        tabs (table)
            A table that should be populated with menu tab definitions.

    Example Usage:
        ```lua
        hook.Add("CreateMenuButtons", "liaExampleCreateMenuButtons", function(tabs)
            print("[MyModule] handled CreateMenuButtons")
        end)
        ```

    Realm:
        Client
]]
lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
lia.config.lastSyncedValues = lia.config.lastSyncedValues or {}
local function cfgLocalizeLabel(value, ...)
    if not isstring(value) then return value end
    local resolved = lia.lang.resolveToken(value, ...)
    if resolved ~= value then return resolved end
    return L(value, ...)
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

--[[
    Purpose:
        Registers a configuration entry and stores its metadata, default value, current value, localization data, optional callback, and UI behavior.

    Parameters:
        key (string)
            The unique configuration key.

        name (string)
            The display name or localization token shown for the configuration.

        value (any)
            The default value for the configuration.

        callback (function|nil)
            Optional function called with the old value and new value when the configuration is changed through `lia.config.set` or reset on the server.

        data (table)
            Configuration metadata, including fields such as type, desc, category, min, max, decimals, options, optionsFunc, noNetworking, isGlobal, and uniqueTab.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.config.add("ExampleEnabled", "@exampleEnabled", true, nil, {
            desc = "@exampleEnabledDesc",
            category = "@core",
            type = "Boolean"
        })
        ```

    Realm:
        Shared
]]
function lia.config.add(key, name, value, callback, data)
    assert(isstring(key), L("configKeyString", type(key)))
    assert(istable(data), L("configDataTable", type(data)))
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
        category = data.category or L("character"),
        noNetworking = data.noNetworking or false,
        callback = callback
    }
end

--[[
    Purpose:
        Returns the localized display name for a registered configuration key.

    Parameters:
        key (string)
            The configuration key whose display name should be returned.

    Returns:
        string|any
            The localized display name when available, or the key when the configuration is not registered.

    Example Usage:
        ```lua
        print(lia.config.getDisplayName("WalkSpeed"))
        ```

    Realm:
        Shared
]]
function lia.config.getDisplayName(key)
    local config = lia.config.stored[key]
    if not config then return key end
    local value = config.rawName or config.name or key
    return isstring(value) and cfgLocalizeLabel(value) or value
end

--[[
    Purpose:
        Returns the localized description for a registered configuration key.

    Parameters:
        key (string)
            The configuration key whose description should be returned.

    Returns:
        string|any
            The localized description when available, or an empty string when the configuration is not registered.

    Example Usage:
        ```lua
        print(lia.config.getDisplayDesc("WalkSpeed"))
        ```

    Realm:
        Shared
]]
function lia.config.getDisplayDesc(key)
    local config = lia.config.stored[key]
    if not config then return "" end
    local value = config.rawDesc or (config.data and config.data.rawDesc) or config.desc or ""
    return isstring(value) and cfgLocalizeLabel(value) or value
end

--[[
    Purpose:
        Returns the localized category for a registered configuration key.

    Parameters:
        key (string)
            The configuration key whose category should be returned.

    Returns:
        string|any
            The localized category when available, or the localized character category when the configuration is not registered.

    Example Usage:
        ```lua
        print(lia.config.getDisplayCategory("WalkSpeed"))
        ```

    Realm:
        Shared
]]
function lia.config.getDisplayCategory(key)
    local config = lia.config.stored[key]
    if not config then return cfgLocalizeLabel("character") end
    local value = config.rawCategory or (config.data and config.data.rawCategory) or config.category or "character"
    return isstring(value) and cfgLocalizeLabel(value) or value
end

--[[
    Purpose:
        Returns normalized selectable options for a registered table-based configuration.

    Parameters:
        key (string)
            The configuration key whose options should be returned.

    Returns:
        table
            A table of normalized option entries containing rawLabel, localized label, and value fields. Returns an empty table when no options are available.

    Example Usage:
        ```lua
        for _, option in pairs(lia.config.getOptions("Language")) do
            print(option.label, option.value)
        end
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Updates the default value for a registered configuration key.

    Parameters:
        key (string)
            The configuration key whose default value should be changed.

        value (any)
            The new default value.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.config.setDefault("WalkSpeed", 200)
        ```

    Realm:
        Shared
]]
function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]
    if config then config.default = value end
end

--[[
    Purpose:
        Directly changes a registered configuration value, runs the update hook, and optionally saves the configuration without type coercion, networking, or callbacks.

    Parameters:
        key (string)
            The configuration key to change.

        value (any)
            The value to assign.

        noSave (boolean|nil)
            When true, prevents the configuration from being saved after the value is changed.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.config.forceSet("WalkSpeed", 250, true)
        ```

    Realm:
        Shared
]]
function lia.config.forceSet(key, value, noSave)
    local config = lia.config.stored[key]
    if config then
        local oldValue = config.value
        config.value = value
        hook.Run("OnConfigUpdated", key, oldValue, value)
    end

    if not noSave then lia.config.save() end
end

--[[
    Purpose:
        Changes a registered configuration value, coerces it to the expected type, runs update hooks, broadcasts the value from the server when networking is enabled, calls the configuration callback, and saves the configuration.

    Parameters:
        key (string)
            The configuration key to change.

        value (any)
            The value to assign.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.config.set("WalkSpeed", 250)
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Returns the current value for a registered configuration key, falling back to its default value or the provided fallback.

    Parameters:
        key (string)
            The configuration key to read.

        default (any)
            Optional fallback value returned when the configuration key is not registered or has no stored value.

    Returns:
        any
            The current configuration value, its default value, the special client color fallback for `Color`, or the provided fallback.

    Example Usage:
        ```lua
        local walkSpeed = lia.config.get("WalkSpeed", 200)
        ```

    Realm:
        Shared
]]
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
    --[[
        Purpose:
            Loads saved configuration values from data storage, applies defaults for missing values, updates the last-synced value cache, and runs the initialization hook.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.config.load()
            ```

        Realm:
            Server
    ]]
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

    --[[
        Purpose:
            Builds a table of configuration values that differ from their defaults or from the last values synchronized to clients.

        Parameters:
            includeDefaults (boolean|nil)
                When true, compares each current value against its default instead of the last synchronized value.

        Returns:
            table
                A table of changed configuration keys and normalized values.

        Example Usage:
            ```lua
            local changes = lia.config.getChangedValues()
            ```

        Realm:
            Server
    ]]
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

    --[[
        Purpose:
            Sends configuration data to one client or broadcasts changed configuration values to all human players.

        Parameters:
            client (Player|nil)
                Optional player who should receive the full saved configuration table. When omitted, changed values are sent to all human players.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.config.send(client)
            lia.config.send()
            ```

        Realm:
            Server
    ]]
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

    --[[
        Purpose:
            Persists all registered configuration values that differ from their defaults.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.config.save()
            ```

        Realm:
            Server
    ]]
    function lia.config.save()
        local configData = {}
        for k, v in pairs(lia.config.stored) do
            if v.value ~= nil and not cfgValuesEqual(v.value, v.default) then configData[k] = cfgNormalizeValue(v.value) end
        end

        lia.data.set("config", configData, true, true)
    end

    --[[
        Purpose:
            Resets every registered configuration value to its default, runs configuration callbacks, saves the new state, and synchronizes clients.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.config.reset()
            ```

        Realm:
            Server
    ]]
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
            lia.log.add(client, "configChange", name or config.name or key, oldValue, value)
            hook.Run("ConfigChanged", key, value, oldValue, client)
            client:notifySuccessLocalized("cfgSet", client:Name(), name or config.name or key, tostring(value))
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
            local color = theme.accent or theme.theme or lia.config and lia.config.get and lia.config.get("Color") or uiColors.accent
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
            if lia.derma and lia.derma.rect and lia.derma.SHAPE_IOS then
                lia.derma.rect(x, y, w, h):Rad(r or 0):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
                return
            end

            draw.RoundedBox(r or 0, x, y, w, h, color)
        end

        local function outline(x, y, w, h, color)
            if lia.derma and lia.derma.rect and lia.derma.SHAPE_IOS then
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
            if lowerCategory == "core" or raw == "@core" then return "Core" end
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
            searchEntry:SetPlaceholderText(L("searchConfigs") or "Search settings...")
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
                name = "configuration",
                shouldShow = function() return hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false end,
                drawFunc = function(parent) drawConfigPage(parent, regularConfigs, "Configuration", "Manage core server settings, keybinds, options, and item configuration.", true) end
            }
        end
    end)
end

lia.config.add("MainCharacterCooldownDays", "@mainCharacterCooldownDays", 0, nil, {
    category = "@core",
    type = "Int",
    min = 0,
    max = 365,
    desc = "@mainCharacterCooldownDaysDesc"
})

lia.config.add("MoneyModel", "@moneyModel", "models/props/cs_assault/Dollar.mdl", nil, {
    desc = "@moneyModelDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("MaxMoneyEntities", "@maxMoneyEntities", 3, nil, {
    desc = "@maxMoneyEntitiesDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 50
})

lia.config.add("CurrencySymbol", "@currencySymbol", "", function(newVal) lia.currency.symbol = newVal end, {
    desc = "@currencySymbolDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("CurrencySingularName", "@currencySingularName", L("currencySingular"), function(newVal) lia.currency.singular = L(newVal) end, {
    desc = "@currencySingularNameDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("CurrencyPluralName", "@currencyPluralName", L("currencyPlural"), function(newVal) lia.currency.plural = L(newVal) end, {
    desc = "@currencyPluralNameDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("WalkSpeed", "@walkSpeed", 200, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetWalkSpeed(newValue)
    end
end, {
    desc = "@walkSpeedDesc",
    category = "@core",
    type = "Number",
    min = 50,
    max = 300
})

lia.config.add("DeathSoundEnabled", "@enableDeathSound", true, nil, {
    desc = "@enableDeathSoundDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("PainSoundEnabled", "@enablePainSound", true, nil, {
    desc = "@enablePainSoundDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("FallDamageEnabled", "@fallDamageEnabled", true, nil, {
    desc = "@fallDamageEnabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("LimbDamage", "@limbDamageMultiplier", 0.5, nil, {
    desc = "@limbDamageMultiplierDesc",
    category = "@core",
    type = "Number",
    min = 0.1,
    max = 1
})

lia.config.add("DamageScale", "@globalDamageScale", 1, nil, {
    desc = "@globalDamageScaleDesc",
    category = "@core",
    type = "Number",
    min = 0.1,
    max = 5
})

lia.config.add("HeadShotDamage", "@headshotDamageMultiplier", 2, nil, {
    desc = "@headshotDamageMultiplierDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 10
})

lia.config.add("RunSpeed", "@runSpeed", 400, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetRunSpeed(newValue)
    end
end, {
    desc = "@runSpeedDesc",
    category = "@core",
    type = "Number",
    min = 100,
    max = 500
})

lia.config.add("MaxCharacters", "@maxCharacters", 5, nil, {
    desc = "@maxCharactersDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 20
})

lia.config.add("AllowPMs", "@allowPMs", true, nil, {
    desc = "@allowPMsDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("MinDescLen", "@minDescriptionLength", 16, nil, {
    desc = "@minDescriptionLengthDesc",
    category = "@core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("DefaultMoney", "@defaultMoney", 0, nil, {
    desc = "@defaultMoneyDesc",
    category = "@core",
    type = "Number",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", "@dataSaveInterval", 600, nil, {
    desc = "@dataSaveIntervalDesc",
    category = "@core",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", "@characterDataSaveInterval", 60, nil, {
    desc = "@characterDataSaveIntervalDesc",
    category = "@core",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", "@respawnTime", 5, nil, {
    desc = "@respawnTimeDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("TimeToEnterVehicle", "@timeToEnterVehicle", 1, nil, {
    desc = "@timeToEnterVehicleDesc",
    category = "@core",
    type = "Number",
    min = 0.1,
    max = 30
})

lia.config.add("CarEntryDelayEnabled", "@carEntryDelayEnabled", true, nil, {
    desc = "@carEntryDelayEnabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("MaxChatLength", "@maxChatLength", 256, nil, {
    desc = "@maxChatLengthDesc",
    category = "@core",
    type = "Number",
    min = 50,
    max = 1024
})

lia.config.add("DoorsAlwaysDisabled", "@doorsAlwaysDisabled", false, nil, {
    desc = "@doorsAlwaysDisabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("AdminConsoleNetworkLogs", "@adminConsoleNetworkLogs", true, nil, {
    desc = "@adminConsoleNetworkLogsDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("CharMenuBGInputDisabled", "@charMenuBGInputDisabled", true, nil, {
    desc = "@charMenuBGInputDisabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("AllowKeybindEditing", "@allowKeybindEditing", true, nil, {
    desc = "@allowKeybindEditingDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("CrosshairEnabled", "@enableCrosshair", false, nil, {
    desc = "@enableCrosshairDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("AutoWeaponItemGeneration", "@autoWeaponItemGeneration", true, nil, {
    desc = "@autoWeaponItemGenerationDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("AutoAmmoItemGeneration", "@autoAmmoItemGeneration", true, nil, {
    desc = "@autoAmmoItemGenerationDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("ItemsCanBeDestroyed", "@itemsCanBeDestroyed", true, nil, {
    desc = "@itemsCanBeDestroyedDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("AmmoDrawEnabled", "@enableAmmoDisplay", true, nil, {
    desc = "@enableAmmoDisplayDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("IsVoiceEnabled", "@voiceChatEnabled", true, function(_, newValue) hook.Run("VoiceToggled", newValue) end, {
    desc = "@voiceChatEnabledDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("SalaryInterval", "@salaryInterval", 300, function()
    if not SERVER then return end
    timer.Simple(0.1, function() hook.Run("CreateSalaryTimers") end)
end, {
    desc = "@salaryIntervalDesc",
    category = "@core",
    type = "Number",
    min = 5,
    max = 36000
})

lia.config.add("ThirdPersonEnabled", "@thirdPersonEnabled", true, nil, {
    desc = "@thirdPersonEnabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("MaxThirdPersonDistance", "@maxThirdPersonDistance", 100, nil, {
    desc = "@maxThirdPersonDistanceDesc",
    category = "@core",
    type = "Number",
    min = 0,
    max = 100
})

lia.config.add("MaxThirdPersonHorizontal", "@maxThirdPersonHorizontal", 30, nil, {
    desc = "@maxThirdPersonHorizontalDesc",
    category = "@core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("MaxThirdPersonHeight", "@maxThirdPersonHeight", 30, nil, {
    desc = "@maxThirdPersonHeightDesc",
    category = "@core",
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

lia.config.add("DermaSkin", "@dermaSkin", "Lilia Skin", function(_, newSkin) hook.Run("DermaSkinChanged", newSkin) end, {
    desc = "@dermaSkinDesc",
    category = "@core",
    type = "Table",
    options = CLIENT and getDermaSkins() or {"liliaSkin"}
})

lia.config.add("Language", "@language", "English", nil, {
    desc = "@languageDesc",
    category = "@core",
    type = "Table",
    options = lia.lang.getLanguages()
})

lia.config.add("SpawnMenuLimit", "@spawnMenuLimit", false, nil, {
    desc = "@spawnMenuLimitDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("LogRetentionDays", "@logRetentionPeriod", 7, nil, {
    desc = "@logRetentionPeriodDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 30,
})

lia.config.add("StaminaSlowdown", "@staminaSlowdownEnabled", true, nil, {
    desc = "@staminaSlowdownEnabledDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("DefaultStamina", "@defaultStaminaValue", 100, nil, {
    desc = "@defaultStaminaValueDesc",
    category = "@core",
    type = "Number",
    min = 10,
    max = 1000
})

lia.config.add("MaxAttributePoints", "@maxAttributePoints", 30, nil, {
    desc = "@maxAttributePointsDesc",
    category = "@core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("JumpStaminaCost", "@jumpStaminaCost", 10, nil, {
    desc = "@jumpStaminaCostDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 1000
})

lia.config.add("MaxStartingAttributes", "@maxStartingAttributes", 30, nil, {
    desc = "@maxStartingAttributesDesc",
    category = "@core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("StartingAttributePoints", "@startingAttributePoints", 30, nil, {
    desc = "@startingAttributePointsDesc",
    category = "@core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("PunchStamina", "@punchStamina", 10, nil, {
    desc = "@punchStaminaDesc",
    category = "@core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("PunchLethality", "@punchLethality", true, nil, {
    desc = "@punchLethalityDesc",
    category = "@core",
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("StaminaDrain", "@staminaDrain", 1, nil, {
    desc = "@staminaDrainDesc",
    category = "@core",
    type = "Number",
    min = 0.1,
    max = 10,
    decimals = 2
})

lia.config.add("StaminaRegeneration", "@staminaRegeneration", 1.75, nil, {
    desc = "@staminaRegenerationDesc",
    category = "@core",
    type = "Number",
    min = 0.1,
    max = 50,
    decimals = 2
})

lia.config.add("StaminaCrouchRegeneration", "@staminaCrouchRegeneration", 2, nil, {
    desc = "@staminaCrouchRegenerationDesc",
    category = "@core",
    type = "Number",
    min = 0.1,
    max = 50,
    decimals = 2
})

lia.config.add("logsPerPage", "@logsPerPage", 50, nil, {
    desc = "@logsPerPageDesc",
    category = "@core",
    type = "Number",
    min = 10,
    max = 1000
})

lia.config.add("PunchRagdollTime", "@punchRagdollTime", 25, nil, {
    desc = "@punchRagdollTimeDesc",
    category = "@core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("MaxHoldWeight", "@maximumHoldWeight", 100, nil, {
    desc = "@maximumHoldWeightDesc",
    category = "@core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("ThrowForce", "@throwForce", 100, nil, {
    desc = "@throwForceDesc",
    category = "@core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("PunchPlaytime", "@punchPlaytimeProtection", 7200, nil, {
    desc = "@punchPlaytimeProtectionDesc",
    category = "@core",
    isGlobal = true,
    type = "Number",
    min = 0,
    max = 86400
})

lia.config.add("CustomChatSound", "@customChatSound", "", nil, {
    desc = "@customChatSoundDesc",
    category = "@core",
    type = "Generic",
})

lia.config.add("TalkRange", "@talkRange", 280, nil, {
    desc = "@talkRangeDesc",
    category = "@core",
    type = "Number",
    min = 50,
    max = 10000
})

lia.config.add("WhisperRange", "@whisperRange", 70, nil, {
    desc = "@whisperRangeDesc",
    category = "@core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("YellRange", "@yellRange", 840, nil, {
    desc = "@yellRangeDesc",
    category = "@core",
    type = "Number",
    min = 100,
    max = 2000
})

lia.config.add("OOCLimit", "@oocCharacterLimit", 150, nil, {
    desc = "@oocCharacterLimitDesc",
    category = "@core",
    type = "Number",
    min = 25,
    max = 1000
})

lia.config.add("OOCDelay", "@oocDelayTitle", 10, nil, {
    desc = "@oocDelayDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelay", "@loocDelayTitle", 6, nil, {
    desc = "@loocDelayDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelayAdmin", "@loocDelayAdmin", false, nil, {
    desc = "@loocDelayAdminDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("OOCBlocked", "@oocBlocked", false, nil, {
    desc = "@oocBlockedDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("ChatSizeDiff", "@enableDifferentChatSize", false, nil, {
    desc = "@enableDifferentChatSizeDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("MusicVolume", "@mainMenuMusicVolume", 0.25, nil, {
    desc = "@mainMenuMusicVolumeDesc",
    category = "@core",
    type = "Number",
    min = 0.01,
    max = 1.0
})

lia.config.add("Music", "@mainMenuMusic", "", nil, {
    desc = "@mainMenuMusicDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("BackgroundURL", "@mainMenuBackgroundURL", "", nil, {
    desc = "@mainMenuBackgroundURLDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("ServerLogo", "@mainMenuCenterLogo", "", nil, {
    desc = "@mainMenuCenterLogoDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("MainMenuLogoEnabled", "@mainMenuLogoEnabled", true, nil, {
    desc = "@mainMenuLogoEnabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("DiscordURL", "@mainMenuDiscordURL", "", nil, {
    desc = "@mainMenuDiscordURLDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("Workshop", "@mainMenuWorkshopURL", "", nil, {
    desc = "@mainMenuWorkshopURLDesc",
    category = "@core",
    type = "Generic"
})

lia.config.add("CharMenuBGInputDisabled", "@charMenuBGInputDisabled", true, nil, {
    desc = "@charMenuBGInputDisabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("SwitchCooldownOnAllEntities", "@switchCooldownOnAllEntities", false, nil, {
    desc = "@switchCooldownOnAllEntitiesDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("OnDamageCharacterSwitchCooldownTimer", "@onDamageCharacterSwitchCooldownTimer", 15, nil, {
    desc = "@onDamageCharacterSwitchCooldownTimerDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("CharacterSwitchCooldownTimer", "@characterSwitchCooldownTimer", 5, nil, {
    desc = "@characterSwitchCooldownTimerDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("ExplosionRagdoll", "@explosionRagdoll", false, nil, {
    desc = "@explosionRagdollDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("CarRagdoll", "@carRagdoll", false, nil, {
    desc = "@carRagdollDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("TimeUntilDroppedSWEPRemoved", "@timeUntilDroppedSWEPRemoved", 15, nil, {
    desc = "@timeUntilDroppedSWEPRemovedDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 300
})

lia.config.add("AltsDisabled", "@altsDisabled", false, nil, {
    desc = "@altsDisabledDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("ActsActive", "@actsActive", false, nil, {
    desc = "@actsActiveDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("PropProtection", "@propProtection", true, nil, {
    desc = "@propProtectionDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("PassableOnFreeze", "@passableOnFreeze", false, nil, {
    desc = "@passableOnFreezeDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("PlayerSpawnVehicleDelay", "@playerSpawnVehicleDelay", 30, nil, {
    desc = "@playerSpawnVehicleDelayDesc",
    category = "@core",
    type = "Number",
    min = 0,
    max = 300
})

lia.config.add("MouthMoveAnimation", "@mouthMoveAnimation", true, nil, {
    desc = "@mouthMoveAnimationDesc",
    category = "Performance",
    type = "Boolean"
})

lia.config.add("GrabEarAnimation", "@grabEarAnimation", false, nil, {
    desc = "@grabEarAnimationDesc",
    category = "Performance",
    type = "Boolean"
})

lia.config.add("VoiceIcons", "@voiceIcons", false, function(_, newValue) if SERVER then RunConsoleCommand("mp_show_voice_icons", newValue and 1 or 0) end end, {
    desc = "@voiceIconsDesc",
    category = "Performance",
    type = "Boolean"
})

lia.config.add("DisableLuaRun", "@disableLuaRun", false, nil, {
    desc = "@disableLuaRunDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("EquipDelay", "@equipDelay", 0, nil, {
    desc = "@equipDelayDesc",
    category = "@core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("UnequipDelay", "@unequipDelay", 0, nil, {
    desc = "@unequipDelayDesc",
    category = "@core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("DropDelay", "@dropDelay", 0, nil, {
    desc = "@dropDelayDesc",
    category = "@core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("DeleteDroppedItemsOnLeave", "@deleteDroppedItemsOnLeave", false, nil, {
    desc = "@deleteDroppedItemsOnLeaveDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("HUDFont", "@hudFont", "Montserrat Medium", function() if not CLIENT then return end end, {
    desc = "@hudFontDesc",
    category = "fonts",
    type = "Table",
    options = function()
        if CLIENT and lia.font and isfunction(lia.font.getAvailableFonts) then return lia.font.getAvailableFonts() end
        return {"Montserrat Medium"}
    end
})

lia.config.add("BodyGrouperModel", "@bodyGrouperModel", "models/props_c17/FurnitureDresser001a.mdl", nil, {
    desc = "@bodyGrouperModelDesc",
    category = "@gameplay",
    type = "Generic"
})

lia.config.add("ModelTweakerModel", "@wardrobeModel", "models/props_c17/FurnitureDresser001a.mdl", nil, {
    desc = "@wardrobeModelDesc",
    category = "@gameplay",
    type = "Generic"
})

lia.config.add("WardrobeEnableFactionModels", "@enableFactionModels", true, nil, {
    desc = "@enableFactionModelsDesc",
    category = "@gameplay",
    type = "Boolean"
})

lia.config.add("WardrobeEnableClassModels", "@enableClassModels", true, nil, {
    desc = "@enableClassModelsDesc",
    category = "@gameplay",
    type = "Boolean"
})

lia.config.add("DeleteEntitiesOnLeave", "@deleteEntitiesOnLeave", true, nil, {
    desc = "@deleteEntitiesOnLeaveDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("TakeDelay", "@takeDelay", 0, nil, {
    desc = "@takeDelayDesc",
    category = "@core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("ItemGiveSpeed", "@itemGiveSpeed", 6, nil, {
    desc = "@itemGiveSpeedDesc",
    category = "@core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("ItemGiveEnabled", "@itemGiveEnabled", true, nil, {
    desc = "@itemGiveEnabledDesc",
    category = "@core",
    type = "Boolean",
})

lia.config.add("LoseItemsonDeathNPC", "@loseItemsOnNPCDeath", false, nil, {
    desc = "@loseItemsOnNPCDeathDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathHuman", "@loseItemsOnHumanDeath", false, nil, {
    desc = "@loseItemsOnHumanDeathDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathWorld", "@loseItemsOnWorldDeath", false, nil, {
    desc = "@loseItemsOnWorldDeathDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("DeathPopupEnabled", "@enableDeathPopup", true, nil, {
    desc = "@enableDeathPopupDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("ClassDisplay", "@displayClassesOnCharacters", true, nil, {
    desc = "@displayClassesOnCharactersDesc",
    category = "@core",
    type = "Boolean",
})

local function refreshScoreboard()
    if CLIENT and IsValid(lia.gui.score) and lia.gui.score.ApplyConfig then lia.gui.score:ApplyConfig() end
end

lia.config.add("sbWidth", "@sbWidth", 0.65, refreshScoreboard, {
    desc = "@sbWidthDesc",
    category = "@core",
    type = "Number",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbHeight", "@sbHeight", 0.65, refreshScoreboard, {
    desc = "@sbHeightDesc",
    category = "@core",
    type = "Number",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbDock", "@sbDock", "center", refreshScoreboard, {
    desc = "@sbDockDesc",
    category = "@core",
    type = "Table",
    options = {"left", "center", "right"}
})

lia.config.add("ClassHeaders", "@classHeaders", true, nil, {
    desc = "@classHeadersDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("RecognitionEnabled", "@recognitionEnabled", true, nil, {
    desc = "@recognitionEnabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("FakeNamesEnabled", "@fakeNamesEnabled", false, nil, {
    desc = "@fakeNamesEnabledDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("vendorDefaultMoney", "@vendorDefaultMoney", 500, nil, {
    desc = "@vendorDefaultMoneyDesc",
    category = "@core",
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

lia.config.add("DefaultMenuTab", "@defaultMenuTab", "@you", nil, {
    desc = "@defaultMenuTabDesc",
    category = "@core",
    type = "Table",
    options = function()
        local tabs = {}
        local tabNames = CLIENT and getMenuTabNames() or {"@you"}
        for _, tabName in ipairs(tabNames) do
            tabs[L(tabName) or tabName] = tabName
        end
        return tabs
    end
})

lia.config.add("DoorLockTime", "@doorLockTime", 0.5, nil, {
    desc = "@doorLockTimeDesc",
    category = "@core",
    type = "Number",
    min = 0.05,
    max = 30.0
})

lia.config.add("DoorSellRatio", "@doorSellRatio", 0.5, nil, {
    desc = "@doorSellRatioDesc",
    category = "@core",
    min = 0.1,
    max = 1.0
})

lia.config.add("MainMenuUseLastPos", "@mainMenuUseLastPos", true, nil, {
    desc = "@mainMenuUseLastPosDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("AmericanTimeStamps", "@americanTimeStamps", false, nil, {
    desc = "@americanTimeStampsDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("Color", "@color", Color(0, 150, 255), nil, {
    desc = "@colorDesc",
    category = "@core",
    type = "Color"
})

lia.config.add("StaffHasGodMode", "@staffHasGodMode", true, nil, {
    desc = "@staffHasGodModeDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("descriptionWidth", "@descriptionWidth", 0.5, nil, {
    desc = "@descriptionWidthDesc",
    category = "@core",
    type = "Number",
    min = 0.1,
    max = 1.0
})

lia.config.add("maxAttributes", "@maxAttributes", 100, nil, {
    desc = "@maxAttributesDesc",
    category = "@core",
    type = "Int",
    min = 1,
    max = 1000
})
