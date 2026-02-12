--[[
    Folder: Libraries
    File: config.md
]]
--[[
    Configuration

    Comprehensive user-configurable settings management system for the Lilia framework.
]]
--[[
    Overview:
        The configuration library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.
]]
lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
lia.config._lastSyncedValues = lia.config._lastSyncedValues or {}
--[[
    Purpose:
        Register a config entry with defaults, UI metadata, and optional callback.

    When Called:
        During schema/module initialization to expose server-stored configuration.

    Parameters:
        key (string)
            Unique identifier for the config entry.
        name (string)
            Display text or localization key for UI.
        value (any)
            Default value; type inferred when data.type is omitted.
        callback (function|nil)
            Invoked server-side as callback(oldValue, newValue) after set().
        data (table)
            Fields such as type, desc, category, options/optionsFunc, noNetworking, etc.
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.config.add("MaxThirdPersonDistance", "maxThirdPersonDistance", 100, function(old, new)
            lia.option.set("thirdPersonDistance", math.min(lia.option.get("thirdPersonDistance", new), new))
        end, {category = "Lilia", type = "Int", min = 10, max = 200})
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
        Resolve a config entry's selectable options, static list or generated.

    When Called:
        Before rendering dropdown-type configs or validating submitted values.

    Parameters:
        key (string)
            Config key to resolve options for.

    Returns:
        table
            Options array or key/value table; empty when unavailable.

    Realm:
        Shared

    Example Usage:
        ```lua
        local opts = lia.config.getOptions("Theme")
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
        Override the default value for an already registered config entry.

    When Called:
        During migrations, schema overrides, or backward-compatibility fixes.

    Parameters:
        key (string)
            Config key to override.
        value (any)
            New default value.
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.config.setDefault("StartingMoney", 300)
        ```
]]
function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]
    if config then config.default = value end
end

--[[
    Purpose:
        Force-set a config value and fire update hooks without networking.

    When Called:
        Runtime adjustments (admin tools/commands) or hot reload scenarios.

    Parameters:
        key (string)
            Config key to change.
        value (any)
            Value to assign.
        noSave (boolean|nil)
            When true, skip persisting to disk.
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.config.forceSet("MaxCharacters", 10, false)
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
        Set a config value, fire update hooks, run server callbacks, network to clients, and persist.

    When Called:
        Through admin tools/commands or internal code updating configuration.

    Parameters:
        key (string)
            Config key to change.
        value (any)
            Value to assign and broadcast.
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.config.set("RunSpeed", 420)
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

        if CLIENT and oldValue ~= value then LocalPlayer():notifySuccess("Config '" .. (config.name or key) .. "' updated successfully") end
    end
end

--[[
    Purpose:
        Retrieve a config value with fallback to its stored default or a provided default.

    When Called:
        Anywhere configuration influences gameplay or UI logic.

    Parameters:
        key (string)
            Config key to read.
        default (any)
            Optional fallback when no stored value or default exists.

    Returns:
        any
            Stored value, default value, or supplied fallback.

    Realm:
        Shared

    Example Usage:
        ```lua
        local walkSpeed = lia.config.get("WalkSpeed", 200)
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
        Load config values from the database (server) or request them from the server (client).

    When Called:
        On initialization to hydrate lia.config.stored after database connectivity.

    Parameters:
        None

    Realm:
        Shared

    Example Usage:
        ```lua
        hook.Add("DatabaseConnected", "LoadLiliaConfig", lia.config.load)
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
        Collect config entries whose values differ from last synced values or their defaults.

    When Called:
        Prior to sending incremental config updates to clients.

    Parameters:
        includeDefaults (boolean|nil)
            When true, compare against defaults instead of last synced values.

    Returns:
        table
            key → value for configs that changed.

    Realm:
        Server

    Example Usage:
        ```lua
        local changed = lia.config.getChangedValues()
        if next(changed) then lia.config.send() end
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
        Check whether any config values differ from the last synced snapshot.

    When Called:
        To determine if a resync to clients is required.

    Parameters:
        None

    Returns:
        boolean
            True when at least one config value has changed.

    Realm:
        Server

    Example Usage:
        ```lua
        if lia.config.hasChanges() then lia.config.send() end
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
        Send config values to one player (full payload) or broadcast only changed values.

    When Called:
        After config changes or when a player joins the server.

    Parameters:
        client (Player|nil)
            Target player for full sync; nil broadcasts only changed values.
    Realm:
        Server

    Example Usage:
        ```lua
        hook.Add("PlayerInitialSpawn", "SyncConfig", function(ply) lia.config.send(ply) end)
        lia.config.send() -- broadcast diffs
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
        Persist all config values to the database.

    When Called:
        After changes, on shutdown, or during scheduled saves.

    Parameters:
        None
    Realm:
        Server

    Example Usage:
        ```lua
        lia.config.save()
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
        Reset all config values to defaults, then save and sync to clients.

    When Called:
        During admin resets or troubleshooting.

    Parameters:
        None
    Realm:
        Server

    Example Usage:
        ```lua
        lia.config.reset()
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

lia.config.add("MainCharacterCooldownDays", "mainCharacterCooldownDays", 0, nil, {
    category = "Core",
    type = "Int",
    min = 0,
    max = 365,
    desc = "mainCharacterCooldownDaysDesc"
})

lia.config.add("MoneyModel", "moneyModel", "models/props/cs_assault/Dollar.mdl", nil, {
    desc = "moneyModelDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("MaxMoneyEntities", "maxMoneyEntities", 3, nil, {
    desc = "maxMoneyEntitiesDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 50
})

lia.config.add("CurrencySymbol", "currencySymbol", "", function(newVal) lia.currency.symbol = newVal end, {
    desc = "currencySymbolDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("CurrencySingularName", "currencySingularName", "currencySingular", function(newVal) lia.currency.singular = L(newVal) end, {
    desc = "currencySingularNameDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("CurrencyPluralName", "currencyPluralName", "currencyPlural", function(newVal) lia.currency.plural = L(newVal) end, {
    desc = "currencyPluralNameDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("WalkSpeed", "walkSpeed", 200, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetWalkSpeed(newValue)
    end
end, {
    desc = "walkSpeedDesc",
    category = "Core",
    type = "Number",
    min = 50,
    max = 300
})

lia.config.add("DeathSoundEnabled", "enableDeathSound", true, nil, {
    desc = "enableDeathSoundDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("LimbDamage", "limbDamageMultiplier", 0.5, nil, {
    desc = "limbDamageMultiplierDesc",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 1
})

lia.config.add("DamageScale", "globalDamageScale", 1, nil, {
    desc = "globalDamageScaleDesc",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 5
})

lia.config.add("HeadShotDamage", "headshotDamageMultiplier", 2, nil, {
    desc = "headshotDamageMultiplierDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 10
})

lia.config.add("RunSpeed", "runSpeed", 400, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetRunSpeed(newValue)
    end
end, {
    desc = "runSpeedDesc",
    category = "Core",
    type = "Number",
    min = 100,
    max = 500
})

lia.config.add("WalkRatio", "walkRatio", 0.5, nil, {
    desc = "walkRatioDesc",
    category = "Core",
    type = "Number",
    min = 0.2,
    max = 1.0,
    decimals = 2
})

lia.config.add("MaxCharacters", "maxCharacters", 5, nil, {
    desc = "maxCharactersDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 20
})

lia.config.add("AllowPMs", "allowPMs", true, nil, {
    desc = "allowPMsDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("MinDescLen", "minDescriptionLength", 16, nil, {
    desc = "minDescriptionLengthDesc",
    category = "Core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("DefaultMoney", "defaultMoney", 0, nil, {
    desc = "defaultMoneyDesc",
    category = "Core",
    type = "Number",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", "dataSaveInterval", 600, nil, {
    desc = "dataSaveIntervalDesc",
    category = "Core",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", "characterDataSaveInterval", 60, nil, {
    desc = "characterDataSaveIntervalDesc",
    category = "Core",
    type = "Number",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", "respawnTime", 5, nil, {
    desc = "respawnTimeDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("TimeToEnterVehicle", "timeToEnterVehicle", 1, nil, {
    desc = "timeToEnterVehicleDesc",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 30
})

lia.config.add("CarEntryDelayEnabled", "carEntryDelayEnabled", true, nil, {
    desc = "carEntryDelayEnabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("MaxChatLength", "maxChatLength", 256, nil, {
    desc = "maxChatLengthDesc",
    category = "Core",
    type = "Number",
    min = 50,
    max = 1024
})

lia.config.add("DoorsAlwaysDisabled", "doorsAlwaysDisabled", false, nil, {
    desc = "doorsAlwaysDisabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("AdminConsoleNetworkLogs", "adminConsoleNetworkLogs", true, nil, {
    desc = "adminConsoleNetworkLogsDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("CharMenuBGInputDisabled", "charMenuBGInputDisabled", true, nil, {
    desc = "charMenuBGInputDisabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("AllowKeybindEditing", "allowKeybindEditing", true, nil, {
    desc = "allowKeybindEditingDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("CrosshairEnabled", "enableCrosshair", false, nil, {
    desc = "enableCrosshairDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("AutoWeaponItemGeneration", "autoWeaponItemGeneration", true, nil, {
    desc = "autoWeaponItemGenerationDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("AutoAmmoItemGeneration", "autoAmmoItemGeneration", true, nil, {
    desc = "autoAmmoItemGenerationDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("ItemsCanBeDestroyed", "itemsCanBeDestroyed", true, nil, {
    desc = "itemsCanBeDestroyedDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("AmmoDrawEnabled", "enableAmmoDisplay", true, nil, {
    desc = "enableAmmoDisplayDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("IsVoiceEnabled", "voiceChatEnabled", true, function(_, newValue) hook.Run("VoiceToggled", newValue) end, {
    desc = "voiceChatEnabledDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("SalaryInterval", "salaryInterval", 300, function()
    if not SERVER then return end
    timer.Simple(0.1, function() hook.Run("CreateSalaryTimers") end)
end, {
    desc = "salaryIntervalDesc",
    category = "Core",
    type = "Number",
    min = 5,
    max = 36000
})

lia.config.add("ThirdPersonEnabled", "thirdPersonEnabled", true, nil, {
    desc = "thirdPersonEnabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("MaxThirdPersonDistance", "maxThirdPersonDistance", 100, nil, {
    desc = "maxThirdPersonDistanceDesc",
    category = "Core",
    type = "Number",
    min = 0,
    max = 100
})

lia.config.add("MaxThirdPersonHorizontal", "maxThirdPersonHorizontal", 30, nil, {
    desc = "maxThirdPersonHorizontalDesc",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("MaxThirdPersonHeight", "maxThirdPersonHeight", 30, nil, {
    desc = "maxThirdPersonHeightDesc",
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

lia.config.add("DermaSkin", "dermaSkin", "Lilia Skin", function(_, newSkin) hook.Run("DermaSkinChanged", newSkin) end, {
    desc = "dermaSkinDesc",
    category = "Core",
    type = "Table",
    options = CLIENT and getDermaSkins() or {"liliaSkin"}
})

lia.config.add("Language", "language", "English", nil, {
    desc = "languageDesc",
    category = "Core",
    type = "Table",
    options = lia.lang.getLanguages()
})

lia.config.add("SpawnMenuLimit", "spawnMenuLimit", false, nil, {
    desc = "spawnMenuLimitDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("LogRetentionDays", "logRetentionPeriod", 7, nil, {
    desc = "logRetentionPeriodDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 30,
})

lia.config.add("StaminaSlowdown", "staminaSlowdownEnabled", true, nil, {
    desc = "staminaSlowdownEnabledDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("DefaultStamina", "defaultStaminaValue", 100, nil, {
    desc = "defaultStaminaValueDesc",
    category = "Core",
    type = "Number",
    min = 10,
    max = 1000
})

lia.config.add("MaxAttributePoints", "maxAttributePoints", 30, nil, {
    desc = "maxAttributePointsDesc",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("JumpStaminaCost", "jumpStaminaCost", 10, nil, {
    desc = "jumpStaminaCostDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 1000
})

lia.config.add("MaxStartingAttributes", "maxStartingAttributes", 30, nil, {
    desc = "maxStartingAttributesDesc",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("StartingAttributePoints", "startingAttributePoints", 30, nil, {
    desc = "startingAttributePointsDesc",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("PunchStamina", "punchStamina", 10, nil, {
    desc = "punchStaminaDesc",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("PunchLethality", "punchLethality", true, nil, {
    desc = "punchLethalityDesc",
    category = "Core",
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("StaminaDrain", "staminaDrain", 1, nil, {
    desc = "staminaDrainDesc",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 10,
    decimals = 2
})

lia.config.add("StaminaRegeneration", "staminaRegeneration", 1.75, nil, {
    desc = "staminaRegenerationDesc",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 50,
    decimals = 2
})

lia.config.add("StaminaCrouchRegeneration", "staminaCrouchRegeneration", 2, nil, {
    desc = "staminaCrouchRegenerationDesc",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 50,
    decimals = 2
})

lia.config.add("logsPerPage", "logsPerPage", 50, nil, {
    desc = "logsPerPageDesc",
    category = "Core",
    type = "Number",
    min = 10,
    max = 1000
})

lia.config.add("PunchRagdollTime", "punchRagdollTime", 25, nil, {
    desc = "punchRagdollTimeDesc",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("MaxHoldWeight", "maximumHoldWeight", 100, nil, {
    desc = "maximumHoldWeightDesc",
    category = "Core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("ThrowForce", "throwForce", 100, nil, {
    desc = "throwForceDesc",
    category = "Core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("PunchPlaytime", "punchPlaytimeProtection", 7200, nil, {
    desc = "punchPlaytimeProtectionDesc",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 0,
    max = 86400
})

lia.config.add("CustomChatSound", "customChatSound", "", nil, {
    desc = "customChatSoundDesc",
    category = "Core",
    type = "Generic",
})

lia.config.add("TalkRange", "talkRange", 280, nil, {
    desc = "talkRangeDesc",
    category = "Core",
    type = "Number",
    min = 50,
    max = 10000
})

lia.config.add("WhisperRange", "whisperRange", 70, nil, {
    desc = "whisperRangeDesc",
    category = "Core",
    type = "Number",
    min = 10,
    max = 500
})

lia.config.add("YellRange", "yellRange", 840, nil, {
    desc = "yellRangeDesc",
    category = "Core",
    type = "Number",
    min = 100,
    max = 2000
})

lia.config.add("OOCLimit", "oocCharacterLimit", 150, nil, {
    desc = "oocCharacterLimitDesc",
    category = "Core",
    type = "Number",
    min = 25,
    max = 1000
})

lia.config.add("OOCDelay", "oocDelayTitle", 10, nil, {
    desc = "oocDelayDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelay", "loocDelayTitle", 6, nil, {
    desc = "loocDelayDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelayAdmin", "loocDelayAdmin", false, nil, {
    desc = "loocDelayAdminDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("OOCBlocked", "oocBlocked", false, nil, {
    desc = "oocBlockedDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("ChatSizeDiff", "enableDifferentChatSize", false, nil, {
    desc = "enableDifferentChatSizeDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("MusicVolume", "mainMenuMusicVolume", 0.25, nil, {
    desc = "mainMenuMusicVolumeDesc",
    category = "Core",
    type = "Number",
    min = 0.01,
    max = 1.0
})

lia.config.add("Music", "mainMenuMusic", "", nil, {
    desc = "mainMenuMusicDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("BackgroundURL", "mainMenuBackgroundURL", "", nil, {
    desc = "mainMenuBackgroundURLDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("ServerLogo", "mainMenuCenterLogo", "", nil, {
    desc = "mainMenuCenterLogoDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("ScoreboardLogoEnabled", "scoreboardLogoEnabled", true, nil, {
    desc = "scoreboardLogoEnabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("MainMenuLogoEnabled", "mainMenuLogoEnabled", true, nil, {
    desc = "mainMenuLogoEnabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("DiscordURL", "mainMenuDiscordURL", "", nil, {
    desc = "mainMenuDiscordURLDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("Workshop", "mainMenuWorkshopURL", "", nil, {
    desc = "mainMenuWorkshopURLDesc",
    category = "Core",
    type = "Generic"
})

lia.config.add("CharMenuBGInputDisabled", "mainMenuCharBGInputDisabled", true, nil, {
    desc = "mainMenuCharBGInputDisabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("SwitchCooldownOnAllEntities", "switchCooldownOnAllEntities", false, nil, {
    desc = "switchCooldownOnAllEntitiesDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("OnDamageCharacterSwitchCooldownTimer", "onDamageCharacterSwitchCooldownTimer", 15, nil, {
    desc = "onDamageCharacterSwitchCooldownTimerDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("CharacterSwitchCooldownTimer", "characterSwitchCooldownTimer", 5, nil, {
    desc = "characterSwitchCooldownTimerDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 120
})

lia.config.add("ExplosionRagdoll", "explosionRagdoll", false, nil, {
    desc = "explosionRagdollDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("CarRagdoll", "carRagdoll", false, nil, {
    desc = "carRagdollDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("NPCsDropWeapons", "npcsDropWeapons", false, nil, {
    desc = "npcsDropWeaponsDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("TimeUntilDroppedSWEPRemoved", "timeUntilDroppedSWEPRemoved", 15, nil, {
    desc = "timeUntilDroppedSWEPRemovedDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 300
})

lia.config.add("AltsDisabled", "altsDisabled", false, nil, {
    desc = "altsDisabledDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("ActsActive", "actsActive", false, nil, {
    desc = "actsActiveDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("PropProtection", "propProtection", true, nil, {
    desc = "propProtectionDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("PassableOnFreeze", "passableOnFreeze", false, nil, {
    desc = "passableOnFreezeDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("PlayerSpawnVehicleDelay", "playerSpawnVehicleDelay", 30, nil, {
    desc = "playerSpawnVehicleDelayDesc",
    category = "Core",
    type = "Number",
    min = 0,
    max = 300
})

lia.config.add("ToolInterval", "toolInterval", 0, nil, {
    desc = "toolInterval",
    category = "Core",
    type = "Number",
    min = 0,
    max = 60
})

lia.config.add("DisableLuaRun", "disableLuaRun", false, nil, {
    desc = "disableLuaRunDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("EquipDelay", "equipDelay", 0, nil, {
    desc = "equipDelayDesc",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("UnequipDelay", "unequipDelay", 0, nil, {
    desc = "unequipDelayDesc",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("DropDelay", "dropDelay", 0, nil, {
    desc = "dropDelayDesc",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("DeleteDroppedItemsOnLeave", "deleteDroppedItemsOnLeave", false, nil, {
    desc = "deleteDroppedItemsOnLeaveDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("DeleteEntitiesOnLeave", "deleteEntitiesOnLeave", true, nil, {
    desc = "deleteEntitiesOnLeaveDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("TakeDelay", "takeDelay", 0, nil, {
    desc = "takeDelayDesc",
    category = "Core",
    type = "Number",
    min = 0,
    max = 30
})

lia.config.add("ItemGiveSpeed", "itemGiveSpeed", 6, nil, {
    desc = "itemGiveSpeedDesc",
    category = "Core",
    type = "Number",
    min = 1,
    max = 60
})

lia.config.add("ItemGiveEnabled", "itemGiveEnabled", true, nil, {
    desc = "itemGiveEnabledDesc",
    category = "Core",
    type = "Boolean",
})

lia.config.add("LoseItemsonDeathNPC", "loseItemsOnNPCDeath", false, nil, {
    desc = "loseItemsOnNPCDeathDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathHuman", "loseItemsOnHumanDeath", false, nil, {
    desc = "loseItemsOnHumanDeathDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathWorld", "loseItemsOnWorldDeath", false, nil, {
    desc = "loseItemsOnWorldDeathDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("DeathPopupEnabled", "enableDeathPopup", true, nil, {
    desc = "enableDeathPopupDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("ClassDisplay", "displayClassesOnCharacters", true, nil, {
    desc = "displayClassesOnCharactersDesc",
    category = "Core",
    type = "Boolean",
})

local function refreshScoreboard()
    if CLIENT and IsValid(lia.gui.score) and lia.gui.score.ApplyConfig then lia.gui.score:ApplyConfig() end
end

lia.config.add("sbWidth", "sbWidth", 0.65, refreshScoreboard, {
    desc = "sbWidthDesc",
    category = "Core",
    type = "Number",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbHeight", "sbHeight", 0.65, refreshScoreboard, {
    desc = "sbHeightDesc",
    category = "Core",
    type = "Number",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbDock", "sbDock", "center", refreshScoreboard, {
    desc = "sbDockDesc",
    category = "Core",
    type = "Table",
    options = {"left", "center", "right"}
})

lia.config.add("ClassHeaders", "classHeaders", true, nil, {
    desc = "classHeadersDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("UseSolidBackground", "useSolidBackground", false, nil, {
    desc = "useSolidBackgroundDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("ClassLogo", "classLogo", false, nil, {
    desc = "classLogoDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("ScoreboardBackgroundColor", "scoreboardBackgroundColor", {
    r = 255,
    g = 100,
    b = 100,
    a = 255
}, nil, {
    desc = "scoreboardBackgroundColorDesc",
    category = "Core",
    type = "Color"
})

lia.config.add("RecognitionEnabled", "recognitionEnabled", true, nil, {
    desc = "recognitionEnabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("FakeNamesEnabled", "fakeNamesEnabled", false, nil, {
    desc = "fakeNamesEnabledDesc",
    category = "Core",
    type = "Boolean"
})

lia.config.add("vendorDefaultMoney", "vendorDefaultMoney", 500, nil, {
    desc = "vendorDefaultMoneyDesc",
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

lia.config.add("DefaultMenuTab", "defaultMenuTab", "you", nil, {
    desc = "defaultMenuTabDesc",
    category = "Core",
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
    category = "Core",
    type = "Number",
    min = 0.05,
    max = 30.0
})

lia.config.add("DoorSellRatio", "doorSellRatio", 0.5, nil, {
    desc = "doorSellRatioDesc",
    category = "Core",
    type = "Number",
    min = 0.1,
    max = 1.0
})

hook.Add("PopulateConfigurationButtons", "liaConfigPopulate", function(pages)
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
        label:SetText(L(text))
        label:SetFont("LiliaFont.22")
        label:SetTextColor(lia.color.theme.text or color_white)
        label:SizeToContents()
        label:DockMargin(5, 0, 0, 0)
    end

    local function AddField(scroll, key, name, config)
        local p = scroll:Add("DPanel")
        p:Dock(TOP)
        p:SetTall(45)
        p:DockMargin(0, 0, 0, 5)
        p.Paint = function(s, w, h) lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(35, 38, 45, 180)):Shape(lia.derma.SHAPE_IOS):Draw() end
        local l = p:Add("DLabel")
        l:Dock(LEFT)
        l:DockMargin(15, 0, 0, 0)
        l:SetWidth(250)
        l:SetText(name)
        l:SetFont("LiliaFont.18")
        l:SetTextColor(lia.color.theme.text or color_white)
        l:SetContentAlignment(4)
        l:SetTooltip(config.desc or "")
        local type = config.data and config.data.type or config.type or "Generic"
        if type == "Boolean" then
            local checkbox = p:Add("liaCheckbox")
            checkbox:Dock(RIGHT)
            checkbox:DockMargin(0, 10, 15, 10)
            checkbox:SetWidth(25)
            checkbox:SetChecked(lia.config.get(key, config.value))
            checkbox.OnChange = function(s, val)
                net.Start("liaCfgSet")
                net.WriteString(key)
                net.WriteString(name)
                net.WriteType(val)
                net.SendToServer()
            end
        elseif type == "Number" or type == "Int" or type == "Float" or type == "Generic" then
            local entry = p:Add("liaEntry")
            entry:Dock(RIGHT)
            entry:SetWidth(200)
            entry:DockMargin(0, 8, 15, 8)
            entry:SetValue(tostring(lia.config.get(key, config.value)))
            entry:SetFont("LiliaFont.18")
            entry.textEntry.OnEnter = function(s)
                local value = entry:GetValue()
                local numValue = tonumber(value)
                if (type == "Number" or type == "Int" or type == "Float") and numValue ~= nil then
                    net.Start("liaCfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(numValue)
                    net.SendToServer()
                elseif type == "Generic" then
                    net.Start("liaCfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(value)
                    net.SendToServer()
                else
                    entry:SetValue(tostring(lia.config.get(key, config.value)))
                end
            end
        elseif type == "Color" then
            local button = p:Add("liaButton")
            button:Dock(RIGHT)
            button:SetWidth(200)
            button:DockMargin(0, 8, 15, 8)
            button:SetText("")
            button.Paint = function(s, w, h)
                local c = lia.config.get(key, config.value)
                if istable(c) and c.r and c.g and c.b then
                    c = Color(c.r, c.g, c.b, c.a)
                elseif not IsColor(c) then
                    c = color_white
                end

                lia.derma.rect(0, 0, w, h):Rad(6):Color(c):Shape(lia.derma.SHAPE_IOS):Draw()
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 50))
            end

            button.DoClick = function()
                local c = lia.config.get(key, config.value)
                if not IsColor(c) and istable(c) then c = Color(c.r, c.g, c.b, c.a) end
                lia.derma.requestColorPicker(function(color)
                    net.Start("liaCfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(color)
                    net.SendToServer()
                end, c)
            end
        elseif type == "Table" then
            local combo = p:Add("liaComboBox")
            combo:Dock(RIGHT)
            combo:SetWidth(200)
            combo:DockMargin(0, 8, 15, 8)
            combo:SetValue(tostring(lia.config.get(key, config.value)))
            combo:SetFont("LiliaFont.18")
            local options = lia.config.getOptions(key)
            for _, text in pairs(options) do
                combo:AddChoice(text, text)
            end

            combo.OnSelect = function(_, _, v)
                net.Start("liaCfgSet")
                net.WriteString(key)
                net.WriteString(name)
                net.WriteType(v)
                net.SendToServer()
            end
        end
    end

    if hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false then
        pages[#pages + 1] = {
            name = "categoryConfiguration",
            drawFunc = function(parent)
                net.Start("liaCfgList")
                net.SendToServer()
                parent:Clear()
                local searchEntry = parent:Add("liaEntry")
                searchEntry:Dock(TOP)
                searchEntry:SetTall(35)
                searchEntry:DockMargin(10, 10, 10, 10)
                searchEntry:SetPlaceholderText(L("searchConfigs") or "Search configurations...")
                searchEntry:SetFont("LiliaFont.18")
                local scroll = parent:Add("liaScrollPanel")
                scroll:Dock(FILL)
                scroll:GetCanvas():DockPadding(10, 10, 10, 10)
                local function populate(filter)
                    scroll:Clear()
                    filter = filter and filter:len() > 0 and filter:lower() or nil
                    local categories = {}
                    for k, v in pairs(lia.config.stored) do
                        local cat = v.category or "Core"
                        categories[cat] = categories[cat] or {}
                        table.insert(categories[cat], {
                            key = k,
                            name = v.name,
                            config = v
                        })
                    end

                    local sortedCategories = {}
                    for cat, items in pairs(categories) do
                        table.insert(sortedCategories, cat)
                    end

                    table.sort(sortedCategories)
                    for _, cat in ipairs(sortedCategories) do
                        local items = categories[cat]
                        table.sort(items, function(a, b) return a.name < b.name end)
                        local visibleItems = {}
                        for _, item in ipairs(items) do
                            if not filter or item.name:lower():find(filter, 1, true) or cat:lower():find(filter, 1, true) then table.insert(visibleItems, item) end
                        end

                        if #visibleItems > 0 then
                            AddHeader(scroll, cat)
                            for _, item in ipairs(visibleItems) do
                                AddField(scroll, item.key, item.name, item.config)
                            end
                        end
                    end
                end

                searchEntry:SetUpdateOnType(true)
                searchEntry.OnTextChanged = function(me, text) populate(text) end
                populate(nil)
            end
        }
    end
end)

lia.config.add("MainMenuUseLastPos", "mainMenuUseLastPos", true, nil, {
    desc = "mainMenuUseLastPosDesc",
    category = "Core",
    type = "Boolean"
})
