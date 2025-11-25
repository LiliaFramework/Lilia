--[[
    Configuration Library

    Comprehensive user-configurable settings management system for the Lilia framework.
]]
--[[
    Overview:
        The configuration library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.
]]
local GM = GM or GAMEMODE
lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
lia.config._lastSyncedValues = lia.config._lastSyncedValues or {}
--[[
    Purpose:
        Adds a new configuration option to the system with specified properties and validation

    When Called:
        During gamemode initialization, module loading, or when registering new config options

    Parameters:
        key (string)
            Unique identifier for the configuration option
        name (string)
            Display name for the configuration option
        value (any)
            Default value for the configuration option
        callback (function, optional)
            Function to call when the option value changes
        data (table)
            Configuration metadata including type, description, category, and constraints

    Returns:
        nil

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a basic boolean configuration
        lia.config.add("EnableFeature", "Enable Feature", true, nil, {
            desc      = "Enable or disable this feature",
            category  = "categoryGeneral",
            type      = "Boolean"
        })
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add configuration with callback and constraints
        lia.config.add("WalkSpeed", "Walk Speed", 130, function(_, newValue)
            for _, client in player.Iterator() do
                client:SetWalkSpeed(newValue)
            end
        end, {
            desc      = "Player walking speed",
            category  = "categoryCharacter",
            type      = "Int",
            min       = 50,
            max       = 300
        })
        ```

    High Complexity:
        ```lua
        -- High: Add configuration with dynamic options and complex validation
        lia.config.add("Language", "Language", "English", nil, {
            desc      = "Select your preferred language",
            category  = "categoryGeneral",
            type      = "Table",
            options   = function()
                local languages = {}
                for code, data in pairs(lia.lang.getLanguages()) do
                    languages[data.name] = code
                end
                return languages
            end
        })
        ```
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
    local savedValue = oldConfig and oldConfig.value or value
    if istable(data.options) then
        for k, v in pairs(data.options) do
            if isstring(v) then data.options[k] = L(v) end
        end
    elseif isfunction(data.options) then
        data.optionsFunc = data.options
        data.options = nil
    end

    data.desc = isstring(data.desc) and L(data.desc) or data.desc
    data.category = isstring(data.category) and L(data.category) or data.category
    lia.config.stored[key] = {
        name = isstring(name) and L(name) or name or key,
        data = data,
        value = savedValue,
        default = value,
        desc = data.desc,
        category = data.category or L("character"),
        noNetworking = data.noNetworking or false,
        callback = callback
    }
end

--[[
    Purpose:
        Retrieves the available options for a configuration setting, supporting both static and dynamic option lists

    When Called:
        When building UI elements for configuration options, particularly dropdown menus and selection lists

    Parameters:
        key (string)
            The configuration key to get options for

    Returns:
        table - Array of available options for the configuration

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get static options for a configuration
        local options = lia.config.getOptions("DermaSkin")
        for _, option in ipairs(options) do
            print("Available skin:", option)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Use options in UI creation
        local combo = vgui.Create("liaComboBox")
        local options = lia.config.getOptions("Language")
        for _, text in pairs(options) do
            combo:AddChoice(text, text)
        end
        ```

    High Complexity:
        ```lua
        -- High: Dynamic options with validation and filtering
        local function createDynamicOptions()
            local options = lia.config.getOptions("DefaultMenuTab")
            local filteredOptions = {}
            for key, value in pairs(options) do
                if IsValid(value) and value:IsVisible() then
                    filteredOptions[key] = value
                end
            end
            return filteredOptions
        end
        ```
]]
function lia.config.getOptions(key)
    local config = lia.config.stored[key]
    if not config then return {} end
    if config.data.optionsFunc then
        local success, result = pcall(config.data.optionsFunc)
        if success and istable(result) then
            for k, v in pairs(result) do
                if isstring(v) then result[k] = L(v) end
            end
            return result
        else
            return {}
        end
    elseif istable(config.data.options) then
        return config.data.options
    end
    return {}
end

--[[
    Purpose:
        Updates the default value for an existing configuration option without changing the current value

    When Called:
        During configuration updates, module reloads, or when default values need to be changed

    Parameters:
        key (string)
            The configuration key to update the default for
        value (any)
            The new default value to set

    Returns:
        nil

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Update default value for a configuration
        lia.config.setDefault("MaxCharacters", 10)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Update default based on server conditions
        local maxChars = SERVER and 5 or 3
        lia.config.setDefault("MaxCharacters", maxChars)
        ```

    High Complexity:
        ```lua
        -- High: Update multiple defaults based on module availability
        local function updateModuleDefaults()
            local defaults = {
                MaxCharacters = lia.module.get("characters") and 5 or 1,
                AllowPMs      = lia.module.get("chatbox") and true or false,
                WalkSpeed     = lia.module.get("attributes") and 130 or 100
            }
            for key, value in pairs(defaults) do
                lia.config.setDefault(key, value)
            end
        end
        ```
]]
function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]
    if config then config.default = value end
end

--[[
    Purpose:
        Forces a configuration value to be set immediately without triggering networking or callbacks, with optional save control

    When Called:
        During initialization, module loading, or when bypassing normal configuration update mechanisms

    Parameters:
        key (string)
            The configuration key to set
        value (any)
            The value to set
        noSave (boolean, optional)
            If true, prevents automatic saving of the configuration

    Returns:
        nil

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Force set a configuration value
        lia.config.forceSet("WalkSpeed", 150)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Force set without saving for temporary changes
        lia.config.forceSet("DebugMode", true, true)
        -- Do some debug operations
        lia.config.forceSet("DebugMode", false, true)
        ```

    High Complexity:
        ```lua
        -- High: Bulk force set with conditional saving
        local function applyModuleConfigs(moduleName, configs, saveAfter)
            for key, value in pairs(configs) do
                lia.config.forceSet(key, value, not saveAfter)
            end
            if saveAfter then
                lia.config.save()
            end
        end
        ```
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
        Sets a configuration value with full networking, callback execution, and automatic saving on server

    When Called:
        When users change configuration values through UI, commands, or programmatic updates

    Parameters:
        key (string)
            The configuration key to set
        value (any)
            The value to set

    Returns:
        nil

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set a configuration value
        lia.config.set("WalkSpeed", 150)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set configuration with validation
        local function setConfigWithValidation(key, value, min, max)
            if isnumber(value) and value >= min and value <= max then
                lia.config.set(key, value)
            else
                print("Invalid value for " .. key)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch configuration updates with rollback
        local function batchConfigUpdate(updates)
            local originalValues = {}
            for key, value in pairs(updates) do
                originalValues[key] = lia.config.get(key)
                lia.config.set(key, value)
            end

            return function()
                for key, value in pairs(originalValues) do
                    lia.config.set(key, value)
                end
            end
        end
        ```
]]
function lia.config.set(key, value)
    local config = lia.config.stored[key]
    if config then
        local oldValue = config.value
        config.value = value
        hook.Run("OnConfigUpdated", key, oldValue, value)
        if SERVER then
            if not config.noNetworking then
                net.Start("liaCfgSet")
                net.WriteString(key)
                net.WriteType(value)
                net.Broadcast()
            end

            if config.callback then config.callback(oldValue, value) end
            lia.config.save()
        end
    end
end

--[[
    Purpose:
        Retrieves the current value of a configuration option with fallback to default values

    When Called:
        When reading configuration values for gameplay logic, UI updates, or module functionality

    Parameters:
        key (string)
            The configuration key to retrieve
        default (any, optional)
            Fallback value if configuration doesn't exist

    Returns:
        any - The current configuration value, default value, or provided fallback

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get a configuration value
        local walkSpeed = lia.config.get("WalkSpeed")
        player:SetWalkSpeed(walkSpeed)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get configuration with validation and fallback
        local function getConfigValue(key, expectedType, fallback)
            local value = lia.config.get(key, fallback)
            if type(value) == expectedType then
                return value
            else
                return fallback
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Get multiple configurations with type checking and validation
        local function getPlayerSettings()
            local settings = {}
            local configs = {
                walkSpeed = {"WalkSpeed", "number", 130},
                runSpeed  = {"RunSpeed", "number", 275},
                maxChars  = {"MaxCharacters", "number", 5}
            }

            for setting, data in pairs(configs) do
                local key, expectedType, fallback = data[1], data[2], data[3]
                local value = lia.config.get(key, fallback)
                settings[setting] = type(value) == expectedType and value or fallback
            end

            return settings
        end
        ```
]]
function lia.config.get(key, default)
    local config = lia.config.stored[key]
    if config then
        if config.value ~= nil then
            if istable(config.value) and config.value.r and config.value.g and config.value.b then config.value = Color(config.value.r, config.value.g, config.value.b) end
            return config.value
        elseif config.default ~= nil then
            return config.default
        end
    end

    if key == "Color" and CLIENT then return lia.color.getMainColor() end
    return default
end

--[[
    Purpose:
        Loads configuration values from the database on server or requests them from server on client

    When Called:
        During gamemode initialization, after database connection, or when configuration needs to be refreshed

    Parameters:
        None

    Returns:
        nil

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Load configurations during initialization
        lia.config.load()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Load configurations with callback
        lia.config.load()
        hook.Add("InitializedConfig", "MyModule", function()
            print("Configurations loaded successfully")
            -- Initialize module with loaded configs
        end)
        ```

    High Complexity:
        ```lua
        -- High: Load configurations with error handling and fallback
        local function loadConfigWithFallback()
            local success = pcall(lia.config.load)
            if not success then
                print("Failed to load configurations, using defaults")
                -- Apply default configurations
                for key, config in pairs(lia.config.stored) do
                    config.value = config.default
                end
            end
        end
        ```
]]
function lia.config.load()
    if SERVER then
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        lia.db.select({"key", "value"}, "config", "schema = " .. lia.db.convertDataType(gamemode)):next(function(res)
            local rows = res.results or {}
            local existing = {}
            for _, row in ipairs(rows) do
                local decoded = util.JSONToTable(row.value)
                lia.config.stored[row.key] = lia.config.stored[row.key] or {}
                local value = decoded and decoded[1]
                if value == nil or value == "" then
                    lia.config.stored[row.key].value = lia.config.stored[row.key].default
                else
                    lia.config.stored[row.key].value = value
                    existing[row.key] = true
                end
            end

            local inserts = {}
            for k, v in pairs(lia.config.stored) do
                if not existing[k] then
                    lia.config.stored[k].value = v.default
                    inserts[#inserts + 1] = {
                        schema = gamemode,
                        key = k,
                        value = {v.default}
                    }
                end
            end

            local finalize = function()
                for key, config in pairs(lia.config.stored) do
                    if config.value ~= nil then
                        if istable(config.value) then
                            lia.config._lastSyncedValues[key] = util.TableToJSON(config.value) and util.JSONToTable(util.TableToJSON(config.value)) or config.value
                        else
                            lia.config._lastSyncedValues[key] = config.value
                        end
                    end
                end

                hook.Run("InitializedConfig")
            end

            if #inserts > 0 then
                local ops = {}
                for _, row in ipairs(inserts) do
                    ops[#ops + 1] = lia.db.upsert(row, "config")
                end

                deferred.all(ops):next(finalize, finalize)
            else
                finalize()
            end
        end)
    else
        net.Start("liaCfgList")
        net.SendToServer()
    end
end

if SERVER then
    --[[
        Purpose:
            Retrieves all configuration values that differ from their default values for efficient synchronization

        When Called:
            Before sending configurations to clients or when preparing configuration data for export

        Parameters:
            None

        Returns:
            table - Dictionary of changed configuration keys and their current values

        Realm:
            Server

        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Get all changed values
            local changed = lia.config.getChangedValues()
            print("Changed configurations:", table.Count(changed))
            ```

    Medium Complexity:
            ```lua
            -- Medium: Send only changed configurations to specific client
            local function sendConfigToClient(client)
                local changed = lia.config.getChangedValues()
                if table.Count(changed) > 0 then
                    net.Start("liaCfgList")
                    net.WriteTable(changed)
                    net.Send(client)
                end
            end
            ```

    High Complexity:
            ```lua
            -- High: Export changed configurations with filtering and validation
            local function exportChangedConfigs(filterFunc)
                local changed = lia.config.getChangedValues()
                local filtered = {}

                for key, value in pairs(changed) do
                    local config = lia.config.stored[key]
                    if config and (not filterFunc or filterFunc(key, value, config)) then
                        filtered[key] = {
                            value    = value,
                            name     = config.name,
                            category = config.category,
                            type     = config.data.type
                        }
                    end
                end

                return filtered
            end
            ```
    ]]
    function lia.config.getChangedValues(includeDefaults)
        local data = {}
        for k, v in pairs(lia.config.stored) do
            local isDifferent
            if includeDefaults or lia.config._lastSyncedValues[k] == nil then
                if istable(v.default) and istable(v.value) then
                    isDifferent = util.TableToJSON(v.default) ~= util.TableToJSON(v.value)
                else
                    isDifferent = v.default ~= v.value
                end
            else
                local lastSynced = lia.config._lastSyncedValues[k]
                if istable(lastSynced) and istable(v.value) then
                    isDifferent = util.TableToJSON(lastSynced) ~= util.TableToJSON(v.value)
                else
                    isDifferent = lastSynced ~= v.value
                end
            end

            if isDifferent then data[k] = v.value end
        end
        return data
    end

    --[[
        Purpose:
            Checks if there are any configuration changes that need to be synced to clients

        When Called:
            Before syncing configurations to determine if a sync is necessary

        Parameters:
            None

        Returns:
            boolean - True if there are changed values that differ from defaults

        Realm:
            Server

        Example Usage:
            ```lua
            if lia.config.hasChanges() then
                lia.config.send()
            end
            ```
    ]]
    function lia.config.hasChanges()
        if table.Count(lia.config._lastSyncedValues) == 0 and table.Count(lia.config.stored) > 0 then
            for key, config in pairs(lia.config.stored) do
                if config.value ~= nil then
                    if istable(config.value) then
                        lia.config._lastSyncedValues[key] = util.TableToJSON(config.value) and util.JSONToTable(util.TableToJSON(config.value)) or config.value
                    else
                        lia.config._lastSyncedValues[key] = config.value
                    end
                end
            end
        end

        local changed = lia.config.getChangedValues()
        local count = table.Count(changed)
        return count > 0
    end

    --[[
        Purpose:
            Sends configuration data to clients with intelligent batching and rate limiting for large datasets

        When Called:
            When a client connects, when configurations change, or when manually syncing configurations

        Parameters:
            client (Player, optional)
                Specific client to send to, or nil to send to all clients

        Returns:
            nil

        Realm:
            Server

        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Send configurations to all clients
            lia.config.send()
            ```

    Medium Complexity:
            ```lua
            -- Medium: Send configurations to specific client on connect
            hook.Add("PlayerInitialSpawn", "SendConfigs", function(client)
                timer.Simple(1, function()
                    if IsValid(client) then
                        lia.config.send(client)
                    end
                end)
            end)
            ```

    High Complexity:
            ```lua
            -- High: Send configurations with priority and filtering
            local function sendConfigsWithPriority(priority, filterFunc)
                local changed = lia.config.getChangedValues()
                local filtered = {}

                for key, value in pairs(changed) do
                    local config = lia.config.stored[key]
                    if config and (not filterFunc or filterFunc(key, value, config)) then
                        if config.data.priority == priority then
                            filtered[key] = value
                        end
                    end
                end

                if table.Count(filtered) > 0 then
                    net.Start("liaCfgList")
                    net.WriteTable(filtered)
                    net.Broadcast()
                end
            end
            ```
    ]]
    function lia.config.send(client)
        local data
        if client then
            data = {}
            for k, v in pairs(lia.config.stored) do
                if v.value ~= nil then data[k] = v.value end
            end
        else
            data = lia.config.getChangedValues()
            if table.Count(data) == 0 then return end
        end

        local function getTargets()
            if IsValid(client) then return {client} end
            return player.GetHumans()
        end

        local targets = getTargets()
        if not istable(targets) or #targets == 0 then return end
        for key, value in pairs(data) do
            if istable(value) then
                lia.config._lastSyncedValues[key] = util.TableToJSON(value) and util.JSONToTable(util.TableToJSON(value)) or value
            else
                lia.config._lastSyncedValues[key] = value
            end
        end

        local batchSize = 5
        local baseDelayPerBatch = 0.05
        local function sendTableStaggered(tbl, startDelay)
            local delay = startDelay or 0
            for i = 1, #targets, batchSize do
                local batch = {}
                for j = i, math.min(i + batchSize - 1, #targets) do
                    batch[#batch + 1] = targets[j]
                end

                timer.Simple(delay, function()
                    for _, ply in ipairs(batch) do
                        if IsValid(ply) then
                            net.Start("liaCfgList")
                            net.WriteTable(tbl)
                            net.Send(ply)
                        end
                    end
                end)

                delay = delay + baseDelayPerBatch
            end
        end

        if not client and table.Count(data) > 50 then
            local chunks = {}
            local chunkSize = 25
            local currentChunk = {}
            for key, value in pairs(data) do
                currentChunk[key] = value
                if table.Count(currentChunk) >= chunkSize then
                    table.insert(chunks, currentChunk)
                    currentChunk = {}
                end
            end

            if table.Count(currentChunk) > 0 then table.insert(chunks, currentChunk) end
            for i, chunk in ipairs(chunks) do
                local startDelay = (i - 1) * 0.15
                sendTableStaggered(chunk, startDelay)
            end
        else
            sendTableStaggered(data, 0)
        end
    end

    --[[
        Purpose:
            Saves all changed configuration values to the database using transaction-based operations

        When Called:
            When configuration values change, during server shutdown, or when manually saving configurations

        Parameters:
            None

        Returns:
            nil

        Realm:
            Server

        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Save all configurations
            lia.config.save()
            ```

    Medium Complexity:
            ```lua
            -- Medium: Save configurations with error handling
            local function saveConfigsSafely()
                local success, err = pcall(lia.config.save)
                if not success then
                    print("Failed to save configurations:", err)
                    -- Implement fallback or retry logic
                end
            end
            ```

    High Complexity:
            ```lua
            -- High: Save configurations with backup and validation
            local function saveConfigsWithBackup()
                local changed = lia.config.getChangedValues()
                if table.Count(changed) == 0 then return end

                -- Create backup
                local backup = util.TableToJSON(changed)
                file.Write("config_backup_" .. os.time() .. ".json", backup)

                -- Save with validation
                local success, err = pcall(lia.config.save)
                if not success then
                    print("Save failed, restoring from backup")
                    -- Restore from backup logic
                end
            end
            ```
    ]]
    function lia.config.save()
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local rows = {}
        for k, v in pairs(lia.config.stored) do
            if v.value ~= nil then
                rows[#rows + 1] = {
                    schema = gamemode,
                    key = k,
                    value = {v.value},
                }
            end
        end

        local ops = {}
        for _, row in ipairs(rows) do
            ops[#ops + 1] = lia.db.upsert(row, "config")
        end

        if #ops > 0 then deferred.all(ops) end
    end

    --[[
        Purpose:
            Resets all configuration values to their default values and synchronizes changes to clients

        When Called:
            When resetting server configurations, during maintenance, or when reverting to defaults

        Parameters:
            None

        Returns:
            nil

        Realm:
            Server

        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Reset all configurations to defaults
            lia.config.reset()
            ```

    Medium Complexity:
            ```lua
            -- Medium: Reset configurations with confirmation
            local function resetConfigsWithConfirmation()
                print("Resetting all configurations to defaults...")
                lia.config.reset()
                print("Configuration reset complete")
            end
            ```

    High Complexity:
            ```lua
            -- High: Reset configurations with selective restoration and logging
            local function resetConfigsSelectively(keepConfigs)
                local originalValues = {}

                -- Store current values for configs to keep
                for _, key in ipairs(keepConfigs) do
                    originalValues[key] = lia.config.get(key)
                end

                -- Reset all configurations
                lia.config.reset()

                -- Restore selected configurations
                for key, value in pairs(originalValues) do
                    lia.config.set(key, value)
                end

                print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
            end
            ```
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
end

lia.config.add("MoneyModel", "moneyModel", "models/props/cs_office/money.mdl", nil, {
    desc = "moneyModelDesc",
    category = "categoryCharacter",
    type = "Generic"
})

lia.config.add("MaxMoneyEntities", "maxMoneyEntities", 3, nil, {
    desc = "maxMoneyEntitiesDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 1,
    max = 50
})

lia.config.add("CurrencySymbol", "currencySymbol", "", function(newVal) lia.currency.symbol = newVal end, {
    desc = "currencySymbolDesc",
    category = "categoryCharacter",
    type = "Generic"
})

lia.config.add("PKWorld", "pkWorld", false, nil, {
    desc = "pkWorldDesc",
    category = "categoryCharacter",
    type = "Boolean"
})

lia.config.add("CurrencySingularName", "currencySingularName", "currencySingular", function(newVal) lia.currency.singular = L(newVal) end, {
    desc = "currencySingularNameDesc",
    category = "categoryCharacter",
    type = "Generic"
})

lia.config.add("CurrencyPluralName", "currencyPluralName", "currencyPlural", function(newVal) lia.currency.plural = L(newVal) end, {
    desc = "currencyPluralNameDesc",
    category = "categoryCharacter",
    type = "Generic"
})

lia.config.add("WalkSpeed", "walkSpeed", 130, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetWalkSpeed(newValue)
    end
end, {
    desc = "walkSpeedDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 50,
    max = 300
})

lia.config.add("DeathSoundEnabled", "enableDeathSound", true, nil, {
    desc = "enableDeathSoundDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("LimbDamage", "limbDamageMultiplier", 0.5, nil, {
    desc = "limbDamageMultiplierDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0.1,
    max = 1
})

lia.config.add("DamageScale", "globalDamageScale", 1, nil, {
    desc = "globalDamageScaleDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0.1,
    max = 5
})

lia.config.add("HeadShotDamage", "headshotDamageMultiplier", 2, nil, {
    desc = "headshotDamageMultiplierDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 1,
    max = 10
})

lia.config.add("RunSpeed", "runSpeed", 275, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetRunSpeed(newValue)
    end
end, {
    desc = "runSpeedDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 100,
    max = 500
})

lia.config.add("WalkRatio", "walkRatio", 0.5, nil, {
    desc = "walkRatioDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 0.2,
    max = 1.0,
    decimals = 2
})

lia.config.add("WhitelistEnabled", "whitelistEnabled", false, nil, {
    desc = "whitelistEnabledDesc",
    category = "categoryServer",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = false,
    type = "Boolean"
})

lia.config.add("BlacklistedEnabled", "blacklistEnabled", false, nil, {
    desc = "blacklistEnabledDesc",
    category = "categoryServer",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = false,
    type = "Boolean"
})

lia.config.add("MaxCharacters", "maxCharacters", 5, nil, {
    desc = "maxCharactersDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 1,
    max = 20
})

lia.config.add("AllowPMs", "allowPMs", true, nil, {
    desc = "allowPMsDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("MinDescLen", "minDescriptionLength", 16, nil, {
    desc = "minDescriptionLengthDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("SaveInterval", "saveInterval", 300, nil, {
    desc = "saveIntervalDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("DefaultMoney", "defaultMoney", 0, nil, {
    desc = "defaultMoneyDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", "dataSaveInterval", 600, nil, {
    desc = "dataSaveIntervalDesc",
    category = "categoryServer",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", "characterDataSaveInterval", 60, nil, {
    desc = "characterDataSaveIntervalDesc",
    category = "categoryServer",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", "respawnTime", 5, nil, {
    desc = "respawnTimeDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("TimeToEnterVehicle", "timeToEnterVehicle", 1, nil, {
    desc = "timeToEnterVehicleDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0.1,
    max = 30
})

lia.config.add("CarEntryDelayEnabled", "carEntryDelayEnabled", true, nil, {
    desc = "carEntryDelayEnabledDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("MaxChatLength", "maxChatLength", 256, nil, {
    desc = "maxChatLengthDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 50,
    max = 1024
})

lia.config.add("SchemaYear", "schemaYear", 2025, nil, {
    desc = "schemaYearDesc",
    category = "categoryGeneral",
    type = "Number",
    min = 0,
    max = 999999
})

lia.config.add("DoorsAlwaysDisabled", "doorsAlwaysDisabled", false, nil, {
    desc = "doorsAlwaysDisabledDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("AmericanDates", "americanDates", true, nil, {
    desc = "americanDatesDesc",
    category = "categoryGeneral",
    type = "Boolean"
})

lia.config.add("AmericanTimeStamp", "americanTimeStamp", true, nil, {
    desc = "americanTimeStampDesc",
    category = "categoryGeneral",
    type = "Boolean"
})

lia.config.add("AdminConsoleNetworkLogs", "adminConsoleNetworkLogs", true, nil, {
    desc = "adminConsoleNetworkLogsDesc",
    category = "categoryServer",
    type = "Boolean"
})

lia.config.add("CharMenuBGInputDisabled", "charMenuBGInputDisabled", true, nil, {
    desc = "charMenuBGInputDisabledDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("AllowKeybindEditing", "allowKeybindEditing", true, nil, {
    desc = "allowKeybindEditingDesc",
    category = "categoryGeneral",
    type = "Boolean"
})

lia.config.add("CrosshairEnabled", "enableCrosshair", false, nil, {
    desc = "enableCrosshairDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("BarsDisabled", "disableBars", false, nil, {
    desc = "disableBarsDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("AutoWeaponItemGeneration", "autoWeaponItemGeneration", true, nil, {
    desc = "autoWeaponItemGenerationDesc",
    category = "categoryGeneral",
    type = "Boolean",
})

lia.config.add("AutoAmmoItemGeneration", "autoAmmoItemGeneration", true, nil, {
    desc = "autoAmmoItemGenerationDesc",
    category = "categoryGeneral",
    type = "Boolean",
})

lia.config.add("ItemsCanBeDestroyed", "itemsCanBeDestroyed", true, nil, {
    desc = "itemsCanBeDestroyedDesc",
    category = "categoryGeneral",
    type = "Boolean",
})

lia.config.add("AmmoDrawEnabled", "enableAmmoDisplay", true, nil, {
    desc = "enableAmmoDisplayDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("IsVoiceEnabled", "voiceChatEnabled", true, function(_, newValue) hook.Run("VoiceToggled", newValue) end, {
    desc = "voiceChatEnabledDesc",
    category = "categoryGeneral",
    type = "Boolean",
})

lia.config.add("SalaryInterval", "salaryInterval", 300, function()
    if not SERVER then return end
    timer.Simple(0.1, function() GM:CreateSalaryTimers() end)
end, {
    desc = "salaryIntervalDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 5,
    max = 36000
})

lia.config.add("ThirdPersonEnabled", "thirdPersonEnabled", true, nil, {
    desc = "thirdPersonEnabledDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("MaxThirdPersonDistance", "maxThirdPersonDistance", 100, nil, {
    desc = "maxThirdPersonDistanceDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 25,
    max = 200
})

lia.config.add("MaxThirdPersonHorizontal", "maxThirdPersonHorizontal", 90, nil, {
    desc = "maxThirdPersonHorizontalDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 5,
    max = 100
})

lia.config.add("MaxThirdPersonHeight", "maxThirdPersonHeight", 90, nil, {
    desc = "maxThirdPersonHeightDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 5,
    max = 100
})

lia.config.add("MaxViewDistance", "maxViewDistance", 32768, nil, {
    desc = "maxViewDistanceDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 500,
    max = 32768,
})

local function getDermaSkins()
    local skins = {}
    for name in pairs(derma.GetSkinTable()) do
        table.insert(skins, name)
    end

    table.sort(skins)
    return skins
end

lia.config.add("DermaSkin", "dermaSkin", "Lilia Skin", function(_, newSkin) hook.Run("DermaSkinChanged", newSkin) end, {
    desc = "dermaSkinDesc",
    category = "categoryGameplay",
    type = "Table",
    options = CLIENT and getDermaSkins() or {"liliaSkin"}
})

lia.config.add("Language", "language", "English", nil, {
    desc = "languageDesc",
    category = "categoryGeneral",
    type = "Table",
    options = lia.lang.getLanguages()
})

lia.config.add("SpawnMenuLimit", "spawnMenuLimit", false, nil, {
    desc = "spawnMenuLimitDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("LogRetentionDays", "logRetentionPeriod", 7, nil, {
    desc = "logRetentionPeriodDesc",
    category = "categoryServer",
    type = "Number",
    min = 1,
    max = 30,
})

lia.config.add("MaxLogLines", "maximumLogLines", 1000, nil, {
    desc = "maximumLogLinesDesc",
    category = "categoryServer",
    type = "Number",
    min = 100,
    max = 1000000,
})

lia.config.add("StaminaSlowdown", "staminaSlowdownEnabled", true, nil, {
    desc = "staminaSlowdownEnabledDesc",
    category = "categoryCharacter",
    type = "Boolean",
})

lia.config.add("DefaultStamina", "defaultStaminaValue", 100, nil, {
    desc = "defaultStaminaValueDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 10,
    max = 1000
})

lia.config.add("MaxAttributePoints", "maxAttributePoints", 30, nil, {
    desc = "maxAttributePointsDesc",
    category = "categoryCharacter",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("JumpStaminaCost", "jumpStaminaCost", 10, nil, {
    desc = "jumpStaminaCostDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 1,
    max = 1000
})

lia.config.add("MaxStartingAttributes", "maxStartingAttributes", 30, nil, {
    desc = "maxStartingAttributesDesc",
    category = "categoryCharacter",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("StartingAttributePoints", "startingAttributePoints", 30, nil, {
    desc = "startingAttributePointsDesc",
    category = "categoryCharacter",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("PunchStamina", "punchStamina", 10, nil, {
    desc = "punchStaminaDesc",
    category = "categoryCharacter",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("PunchLethality", "punchLethality", true, nil, {
    desc = "punchLethalityDesc",
    category = "categoryCharacter",
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("StaminaDrain", "staminaDrain", 1, nil, {
    desc = "staminaDrainDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 0.1,
    max = 10,
    decimals = 2
})

lia.config.add("StaminaRegeneration", "staminaRegeneration", 5, nil, {
    desc = "staminaRegenerationDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 0.1,
    max = 50,
    decimals = 2
})

lia.config.add("StaminaCrouchRegeneration", "staminaCrouchRegeneration", 8, nil, {
    desc = "staminaCrouchRegenerationDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 0.1,
    max = 50,
    decimals = 2
})

lia.config.add("logsPerPage", "logsPerPage", 50, nil, {
    desc = "logsPerPageDesc",
    category = "categoryServer",
    type = "Number",
    min = 10,
    max = 200
})

lia.config.add("PunchRagdollTime", "punchRagdollTime", 25, nil, {
    desc = "punchRagdollTimeDesc",
    category = "categoryCharacter",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("MaxHoldWeight", "maximumHoldWeight", 100, nil, {
    desc = "maximumHoldWeightDesc",
    category = "categoryGeneral",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("ThrowForce", "throwForce", 100, nil, {
    desc = "throwForceDesc",
    category = "categoryGeneral",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("PunchPlaytime", "punchPlaytimeProtection", 7200, nil, {
    desc = "punchPlaytimeProtectionDesc",
    category = "categoryGeneral",
    isGlobal = true,
    type = "Number",
    min = 0,
    max = 86400
})

lia.config.add("CustomChatSound", "customChatSound", "", nil, {
    desc = "customChatSoundDesc",
    category = "categoryInterface",
    type = "Generic",
})

lia.config.add("TalkRange", "talkRange", 280, nil, {
    desc = "talkRangeDesc",
    category = "categoryInterface",
    type = "Number",
    min = 50,
    max = 10000
})

lia.config.add("WhisperRange", "whisperRange", 70, nil, {
    desc = "whisperRangeDesc",
    category = "categoryInterface",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("YellRange", "yellRange", 840, nil, {
    desc = "yellRangeDesc",
    category = "categoryInterface",
    type = "Number",
    min = 100,
    max = 2000
})

lia.config.add("OOCLimit", "oocCharacterLimit", 150, nil, {
    desc = "oocCharacterLimitDesc",
    category = "categoryInterface",
    type = "Number",
    min = 25,
    max = 1000
})

lia.config.add("OOCDelay", "oocDelayTitle", 10, nil, {
    desc = "oocDelayDesc",
    category = "categoryInterface",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelay", "loocDelayTitle", 6, nil, {
    desc = "loocDelayDesc",
    category = "categoryInterface",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelayAdmin", "loocDelayAdmin", false, nil, {
    desc = "loocDelayAdminDesc",
    category = "categoryInterface",
    type = "Boolean",
})

lia.config.add("ChatSizeDiff", "enableDifferentChatSize", false, nil, {
    desc = "enableDifferentChatSizeDesc",
    category = "categoryInterface",
    type = "Boolean",
})

lia.config.add("MusicVolume", "mainMenuMusicVolume", 0.25, nil, {
    desc = "mainMenuMusicVolumeDesc",
    category = "categoryInterface",
    type = "Number",
    min = 0.01,
    max = 1.0
})

lia.config.add("Music", "mainMenuMusic", "", nil, {
    desc = "mainMenuMusicDesc",
    category = "categoryInterface",
    type = "Generic"
})

lia.config.add("BackgroundURL", "mainMenuBackgroundURL", "", nil, {
    desc = "mainMenuBackgroundURLDesc",
    category = "categoryInterface",
    type = "Generic"
})

lia.config.add("ServerLogo", "mainMenuCenterLogo", "", nil, {
    desc = "mainMenuCenterLogoDesc",
    category = "categoryInterface",
    type = "Generic"
})

lia.config.add("ScoreboardLogoEnabled", "scoreboardLogoEnabled", true, nil, {
    desc = "scoreboardLogoEnabledDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("MainMenuLogoEnabled", "mainMenuLogoEnabled", true, nil, {
    desc = "mainMenuLogoEnabledDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("DiscordURL", "mainMenuDiscordURL", "", nil, {
    desc = "mainMenuDiscordURLDesc",
    category = "categoryInterface",
    type = "Generic"
})

lia.config.add("Workshop", "mainMenuWorkshopURL", "", nil, {
    desc = "mainMenuWorkshopURLDesc",
    category = "categoryInterface",
    type = "Generic"
})

lia.config.add("CharMenuBGInputDisabled", "mainMenuCharBGInputDisabled", true, nil, {
    desc = "mainMenuCharBGInputDisabledDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("SwitchCooldownOnAllEntities", "switchCooldownOnAllEntities", false, nil, {
    desc = "switchCooldownOnAllEntitiesDesc",
    category = "categoryCharacter",
    type = "Boolean",
})

lia.config.add("OnDamageCharacterSwitchCooldownTimer", "onDamageCharacterSwitchCooldownTimer", 15, nil, {
    desc = "onDamageCharacterSwitchCooldownTimerDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("CharacterSwitchCooldownTimer", "characterSwitchCooldownTimer", 5, nil, {
    desc = "characterSwitchCooldownTimerDesc",
    category = "categoryCharacter",
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("ExplosionRagdoll", "explosionRagdoll", false, nil, {
    desc = "explosionRagdollDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("CarRagdoll", "carRagdoll", false, nil, {
    desc = "carRagdollDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("NPCsDropWeapons", "npcsDropWeapons", false, nil, {
    desc = "npcsDropWeaponsDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("TimeUntilDroppedSWEPRemoved", "timeUntilDroppedSWEPRemoved", 15, nil, {
    desc = "timeUntilDroppedSWEPRemovedDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 1,
    max = 300
})

lia.config.add("AltsDisabled", "altsDisabled", false, nil, {
    desc = "altsDisabledDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("ActsActive", "actsActive", false, nil, {
    desc = "actsActiveDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("PropProtection", "propProtection", true, nil, {
    desc = "propProtectionDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("PassableOnFreeze", "passableOnFreeze", false, nil, {
    desc = "passableOnFreezeDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("PlayerSpawnVehicleDelay", "playerSpawnVehicleDelay", 30, nil, {
    desc = "playerSpawnVehicleDelayDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0,
    max = 300
})

lia.config.add("ToolInterval", "toolInterval", 0, nil, {
    desc = "toolInterval",
    category = "categoryGameplay",
    type = "Number",
    min = 0,
    max = 60
})

lia.config.add("DisableLuaRun", "disableLuaRun", false, nil, {
    desc = "disableLuaRunDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("EquipDelay", "equipDelay", 0, nil, {
    desc = "equipDelayDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("UnequipDelay", "unequipDelay", 0, nil, {
    desc = "unequipDelayDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("DropDelay", "dropDelay", 0, nil, {
    desc = "dropDelayDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("DeleteDroppedItemsOnLeave", "deleteDroppedItemsOnLeave", false, nil, {
    desc = "deleteDroppedItemsOnLeaveDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("DeleteEntitiesOnLeave", "deleteEntitiesOnLeave", true, nil, {
    desc = "deleteEntitiesOnLeaveDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("TakeDelay", "takeDelay", 0, nil, {
    desc = "takeDelayDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("ItemGiveSpeed", "itemGiveSpeed", 6, nil, {
    desc = "itemGiveSpeedDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("ItemGiveEnabled", "itemGiveEnabled", true, nil, {
    desc = "itemGiveEnabledDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("DisableCheaterActions", "disableCheaterActions", true, nil, {
    desc = "disableCheaterActionsDesc",
    category = "categoryGameplay",
    type = "Boolean",
})

lia.config.add("LoseItemsonDeathNPC", "loseItemsOnNPCDeath", false, nil, {
    desc = "loseItemsOnNPCDeathDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathHuman", "loseItemsOnHumanDeath", false, nil, {
    desc = "loseItemsOnHumanDeathDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathWorld", "loseItemsOnWorldDeath", false, nil, {
    desc = "loseItemsOnWorldDeathDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("DeathPopupEnabled", "enableDeathPopup", true, nil, {
    desc = "enableDeathPopupDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("StaffHasGodMode", "staffGodMode", true, nil, {
    desc = "staffGodModeDesc",
    category = "categoryServer",
    type = "Boolean"
})

lia.config.add("RagdollDamageTransfer", "ragdollDamageTransfer", true, nil, {
    desc = "ragdollDamageTransferDesc",
    category = "categoryGameplay",
    type = "Boolean"
})

lia.config.add("ClassDisplay", "displayClassesOnCharacters", true, nil, {
    desc = "displayClassesOnCharactersDesc",
    category = "categoryCharacter",
    type = "Boolean",
})

local function refreshScoreboard()
    if CLIENT and lia.gui and IsValid(lia.gui.score) and lia.gui.score.ApplyConfig then lia.gui.score:ApplyConfig() end
end

lia.config.add("sbWidth", "sbWidth", 0.65, refreshScoreboard, {
    desc = "sbWidthDesc",
    category = "categoryInterface",
    type = "Number",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbHeight", "sbHeight", 0.65, refreshScoreboard, {
    desc = "sbHeightDesc",
    category = "categoryInterface",
    type = "Number",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbDock", "sbDock", "center", refreshScoreboard, {
    desc = "sbDockDesc",
    category = "categoryInterface",
    type = "Table",
    options = {"left", "center", "right"}
})

lia.config.add("ClassHeaders", "classHeaders", true, nil, {
    desc = "classHeadersDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("UseSolidBackground", "useSolidBackground", false, nil, {
    desc = "useSolidBackgroundDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("ClassLogo", "classLogo", false, nil, {
    desc = "classLogoDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("ScoreboardBackgroundColor", "scoreboardBackgroundColor", {
    r = 255,
    g = 100,
    b = 100,
    a = 255
}, nil, {
    desc = "scoreboardBackgroundColorDesc",
    category = "categoryInterface",
    type = "Color"
})

lia.config.add("RecognitionEnabled", "recognitionEnabled", true, nil, {
    desc = "recognitionEnabledDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("FakeNamesEnabled", "fakeNamesEnabled", false, nil, {
    desc = "fakeNamesEnabledDesc",
    category = "categoryInterface",
    type = "Boolean"
})

lia.config.add("vendorDefaultMoney", "vendorDefaultMoney", 500, nil, {
    desc = "vendorDefaultMoneyDesc",
    category = "categoryCharacter",
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

lia.config.add("DefaultMenuTab", "defaultMenuTab", "you", nil, {
    desc = "defaultMenuTabDesc",
    category = "categoryInterface",
    type = "Table",
    options = function()
        local tabs = {}
        local tabNames = CLIENT and getMenuTabNames() or {"you"}
        for _, tabName in ipairs(tabNames) do
            tabs[L(tabName) or tabName] = tabName
        end
        return tabs
    end
})

lia.config.add("DoorLockTime", "doorLockTime", 0.5, nil, {
    desc = "doorLockTimeDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0.05,
    max = 30.0
})

lia.config.add("DoorSellRatio", "doorSellRatio", 0.5, nil, {
    desc = "doorSellRatioDesc",
    category = "categoryGameplay",
    type = "Number",
    min = 0.1,
    max = 1.0
})

hook.Add("PopulateConfigurationButtons", "liaConfigPopulate", function(pages)
    local ConfigFormatting = {
        Number = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(config.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local entry = vgui.Create("liaEntry", panel)
            if IsValid(entry) then
                entry:Dock(TOP)
                entry:SetTall(60)
                entry:DockMargin(300, 10, 300, 0)
                entry:SetValue(tostring(lia.config.get(key, config.value)))
                entry:SetFont("LiliaFont.36")
                entry.textEntry.OnEnter = function()
                    local value = entry:GetValue()
                    local numValue = tonumber(value)
                    if numValue ~= nil then
                        net.Start("liaCfgSet")
                        net.WriteString(key)
                        net.WriteString(name)
                        net.WriteType(numValue)
                        net.SendToServer()
                    else
                        entry:SetValue(tostring(lia.config.get(key, config.value)))
                    end
                end
            end
            return container
        end,
        Generic = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(config.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local entry = vgui.Create("liaEntry", panel)
            if IsValid(entry) then
                entry:Dock(TOP)
                entry:SetTall(60)
                entry:DockMargin(300, 10, 300, 0)
                entry:SetValue(tostring(lia.config.get(key, config.value)))
                entry:SetFont("LiliaFont.36")
                entry.textEntry.OnEnter = function()
                    local value = entry:GetValue()
                    if value ~= "" then
                        net.Start("liaCfgSet")
                        net.WriteString(key)
                        net.WriteString(name)
                        net.WriteType(value)
                        net.SendToServer()
                    end
                end
            end
            return container
        end,
        Boolean = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(config.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local checkbox = vgui.Create("liaCheckbox", panel)
            if IsValid(checkbox) then
                checkbox:Dock(TOP)
                checkbox:SetTall(160)
                checkbox:DockMargin(10, 25, 10, 15)
                checkbox:SetChecked(lia.config.get(key, config.value))
                checkbox.OnChange = function(_, state)
                    local t = "ConfigChange_" .. key .. "_" .. os.time()
                    timer.Create(t, 0.5, 1, function()
                        net.Start("liaCfgSet")
                        net.WriteString(key)
                        net.WriteString(name)
                        net.WriteType(state)
                        net.SendToServer()
                    end)
                end
            end
            return container
        end,
        Color = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(config.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local button = vgui.Create("liaButton", panel)
            if IsValid(button) then
                button:Dock(TOP)
                button:DockMargin(300, 10, 300, 0)
                button:SetTall(60)
                button:SetTxt("")
                button.Paint = function(_, w, h)
                    local c = lia.config.get(key, config.value)
                    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
                    lia.derma.rect(0, 0, w, h):Rad(16):Color(c):Shape(lia.derma.SHAPE_IOS):Draw()
                    draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, 50))
                end

                button.DoClick = function()
                    lia.derma.requestColorPicker(function(color)
                        local t = "ConfigChange_" .. key .. "_" .. os.time()
                        timer.Create(t, 0.5, 1, function()
                            net.Start("liaCfgSet")
                            net.WriteString(key)
                            net.WriteString(name)
                            net.WriteType(color)
                            net.SendToServer()
                        end)
                    end, lia.config.get(key, config.value))
                end
            end
            return container
        end,
        Table = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(config.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local combo = vgui.Create("liaComboBox", panel)
            if IsValid(combo) then
                combo:Dock(TOP)
                combo:SetTall(60)
                combo:DockMargin(300, 20, 300, 0)
                combo:SetValue(tostring(lia.config.get(key, config.value)))
                combo:SetFont("LiliaFont.18")
                local options = lia.config.getOptions(key)
                for _, text in pairs(options) do
                    combo:AddChoice(text, text)
                end

                combo:FinishAddingOptions()
                combo:PostInit()
                combo.OnSelect = function(_, _, v)
                    net.Start("liaCfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(v)
                    net.SendToServer()
                end
            end
            return container
        end
    }

    ConfigFormatting.Int = function(key, name, config, parent) return ConfigFormatting.Number(key, name, config, parent) end
    ConfigFormatting.Float = function(key, name, config, parent) return ConfigFormatting.Number(key, name, config, parent) end
    local function buildConfiguration(parent)
        parent:Clear()
        local tabs = parent:Add("liaTabs")
        tabs:Dock(FILL)
        local allCategoryItems = {}
        local function populate()
            if tabs.tabs then
                for i = #tabs.tabs, 1, -1 do
                    tabs:CloseTab(i)
                end
            end

            local categories = {}
            local keys = {}
            for k in pairs(lia.config.stored) do
                keys[#keys + 1] = k
            end

            table.sort(keys, function(a, b)
                local configA = lia.config.stored[a]
                local configB = lia.config.stored[b]
                if not configA then
                    lia.error(L("configWithKey") .. "\"" .. tostring(a) .. "\" not found in stored configs")
                    return false
                end

                if not configB then
                    lia.error(L("configWithKey") .. "\"" .. tostring(b) .. "\" not found in stored configs")
                    return true
                end

                local nameA = tostring(configA.name or a)
                local nameB = tostring(configB.name or b)
                return nameA < nameB
            end)

            for _, k in ipairs(keys) do
                local opt = lia.config.stored[k]
                if not opt then
                    lia.error(L("configWithKey") .. "\"" .. tostring(k) .. "\" is missing from stored configs")
                else
                    local n = tostring(opt.name or "")
                    local cat = tostring(opt.category or L("misc"))
                    categories[cat] = categories[cat] or {}
                    categories[cat][#categories[cat] + 1] = {
                        key = k,
                        name = n,
                        config = opt,
                        elemType = opt.data and opt.data.type or "Generic"
                    }
                end
            end

            local categoryNames = {}
            for name in pairs(categories) do
                categoryNames[#categoryNames + 1] = name
            end

            table.sort(categoryNames)
            allCategoryItems = categories
            local function populateCategoryTab(categoryName, scrollPanel, searchFilter)
                local canvas = scrollPanel:GetCanvas()
                canvas:Clear()
                canvas:DockPadding(10, 10, 10, 10)
                local items = allCategoryItems[categoryName] or {}
                local filteredItems = {}
                searchFilter = tostring(searchFilter or "")
                if searchFilter ~= "" then
                    local filterLower = searchFilter:lower()
                    for _, it in ipairs(items) do
                        local n = tostring(it.name or "")
                        local d = tostring(it.config.desc or "")
                        local k = tostring(it.key or "")
                        local ln, ld, lk = n:lower(), d:lower(), k:lower()
                        if ln:find(filterLower, 1, true) or ld:find(filterLower, 1, true) or lk:find(filterLower, 1, true) then filteredItems[#filteredItems + 1] = it end
                    end
                else
                    filteredItems = items
                end

                for _, it in ipairs(filteredItems) do
                    local el = ConfigFormatting[it.elemType](it.key, it.name, it.config, canvas)
                    el:Dock(TOP)
                    el:DockMargin(10, 10, 10, 0)
                    el.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(50, 50, 60, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
                end

                -- Force layout update
                scrollPanel:InvalidateLayout(true)
            end

            for _, categoryName in ipairs(categoryNames) do
                local categoryContainer = vgui.Create("DPanel")
                categoryContainer:Dock(FILL)
                categoryContainer.Paint = function() end
                local searchBar = vgui.Create("liaEntry", categoryContainer)
                searchBar:Dock(TOP)
                searchBar:DockMargin(10, 10, 10, 10)
                searchBar:SetTall(40)
                searchBar:SetFont("LiliaFont.18")
                searchBar:SetPlaceholderText(L("searchConfigs") or "Search configs...")
                searchBar:SetTextColor(Color(200, 200, 200))
                local scrollPanel = vgui.Create("liaScrollPanel", categoryContainer)
                scrollPanel:Dock(FILL)
                scrollPanel:InvalidateLayout(true)
                if not IsValid(scrollPanel.VBar) then scrollPanel:PerformLayout() end
                categoryContainer.searchBar = searchBar
                categoryContainer.scrollPanel = scrollPanel
                categoryContainer.categoryName = categoryName
                searchBar.OnTextChanged = function(_, value)
                    populateCategoryTab(categoryName, scrollPanel, value or "")
                end

                populateCategoryTab(categoryName, scrollPanel, "")
                tabs:AddTab(categoryName, categoryContainer)
            end
        end

        populate()
    end

    if hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false then
        pages[#pages + 1] = {
            name = "categoryConfiguration",
            drawFunc = function(parent) buildConfiguration(parent) end
        }
    end
end)
