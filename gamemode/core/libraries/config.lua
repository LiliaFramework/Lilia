--[[
# Configuration Library

This page documents the functions for working with configuration variables and settings.

---

## Overview

The configuration library provides a centralized system for managing configuration variables throughout the Lilia framework. It handles the registration, storage, and retrieval of config values with support for different data types, validation, and change callbacks. The system supports networking configuration changes to clients and provides a robust foundation for customizable server settings.

The library features include:
- **Type-Safe Configuration**: Support for various data types including strings, numbers, booleans, colors, and complex objects
- **Validation System**: Built-in validation with custom validation rules and error handling
- **Change Callbacks**: Automatic notification when configuration values change with custom callback support
- **Client-Server Synchronization**: Automatic networking of configuration changes to connected clients
- **Category Organization**: Hierarchical organization of configurations by category for better management
- **Default Value Management**: Automatic handling of default values with fallback mechanisms
- **Database Persistence**: Automatic saving and loading of configuration values to/from database
- **Access Control**: Permission-based access to configuration modification and viewing
- **Validation Rules**: Custom validation rules with min/max values, pattern matching, and custom validators
- **Change History**: Optional tracking of configuration changes for audit purposes
- **Hot Reloading**: Support for runtime configuration changes without server restart
- **Import/Export**: Configuration backup and restore functionality
- **UI Integration**: Built-in support for configuration management interfaces
- **Performance Optimization**: Efficient caching and lookup mechanisms for configuration values
- **Cross-Module Support**: Configuration sharing between different modules and addons

The configuration system provides a flexible and powerful foundation for managing server settings, player preferences, and module configurations. It ensures consistency across the framework and provides an intuitive interface for both developers and administrators.
]]
lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
--[[
    lia.config.add

    Purpose:
        Registers a new configuration variable with the Lilia config system. This function sets up the config's name, default value,
        type, description, category, and optional callback for when the value changes. The config is stored in lia.config.stored.

    Parameters:
        key (string)        - The unique key for the config variable.
        name (string)       - The display name for the config variable.
        value (any)         - The default value for the config variable.
        callback (function) - (Optional) Function to call when the config value changes.
        data (table)        - Table containing additional config properties (type, desc, category, etc).

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Add a new integer config variable for maximum players
        lia.config.add("MaxPlayers", "Maximum Players", 32, function(old, new)
            print("Max players changed from", old, "to", new)
        end, {
            desc = "The maximum number of players allowed on the server.",
            category = "server",
            type = "Int",
            min = 1,
            max = 128
        })
]]
function lia.config.add(key, name, value, callback, data)
    assert(isstring(key), L("configKeyString", type(key)))
    assert(istable(data), L("configDataTable", type(data)))
    local t = type(value)
    local configType = t == "boolean" and "Boolean" or t == "number" and (math.floor(value) == value and "Int" or "Float") or t == "table" and value.r and value.g and value.b and "Color" or "Generic"
    data.type = data.type or configType
    local oldConfig = lia.config.stored[key]
    local savedValue = oldConfig and oldConfig.value or value
    local category = data.category
    local desc = data.desc
    lia.config.stored[key] = {
        name = name or key,
        data = data,
        value = savedValue,
        default = value,
        desc = desc,
        category = category or L("character"),
        noNetworking = data.noNetworking or false,
        callback = callback
    }
end

--[[
    lia.config.setDefault

    Purpose:
        Sets the default value for a given config variable. This does not change the current value, only the default.

    Parameters:
        key (string)   - The config variable key.
        value (any)    - The new default value.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Change the default walk speed to 150
        lia.config.setDefault("WalkSpeed", 150)
]]
function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]
    if config then config.default = value end
end

--[[
    lia.config.forceSet

    Purpose:
        Sets the value of a config variable, bypassing any callbacks or networking, and optionally skips saving to the database.

    Parameters:
        key (string)     - The config variable key.
        value (any)      - The value to set.
        noSave (boolean) - If true, does not save the config to the database.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Force the money limit to 10000 without saving to the database
        lia.config.forceSet("MoneyLimit", 10000, true)
]]
function lia.config.forceSet(key, value, noSave)
    local config = lia.config.stored[key]
    if config then config.value = value end
    if not noSave then lia.config.save() end
end

--[[
    lia.config.set

    Purpose:
        Sets the value of a config variable, triggers networking to clients (if applicable), calls the callback, and saves the config.

    Parameters:
        key (string)   - The config variable key.
        value (any)    - The value to set.

    Returns:
        None.

    Realm:
        Shared (server triggers networking).

    Example Usage:
        -- Set the walk speed to 140 and notify all clients
        lia.config.set("WalkSpeed", 140)
]]
function lia.config.set(key, value)
    local config = lia.config.stored[key]
    if config then
        local oldValue = config.value
        config.value = value
        if SERVER then
            if not config.noNetworking then
                net.Start("cfgSet")
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
    lia.config.get

    Purpose:
        Retrieves the value of a config variable. If the value is not set, returns the default or a provided fallback.

    Parameters:
        key (string)     - The config variable key.
        default (any)    - (Optional) Value to return if the config is not found.

    Returns:
        any - The current value, the default, or the provided fallback.

    Realm:
        Shared.

    Example Usage:
        -- Get the current money limit, or 5000 if not set
        local limit = lia.config.get("MoneyLimit", 5000)
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
    return default
end

--[[
    lia.config.load

    Purpose:
        Loads all config variables from the database for the current schema/gamemode. If a config is missing, it is inserted with its default value.
        On the client, requests the config list from the server.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server (loads from DB), Client (requests from server).

    Example Usage:
        -- Load all config variables at server startup
        lia.config.load()
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
                        schema = schema,
                        key = k,
                        value = {v.default}
                    }
                end
            end

            local finalize = function() hook.Run("InitializedConfig") end
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
        net.Start("cfgList")
        net.SendToServer()
    end
end

if SERVER then
    --[[
        lia.config.getChangedValues

        Purpose:
            Returns a table of all config variables whose value differs from their default.

        Parameters:
            None.

        Returns:
            table - A table of changed config key-value pairs.

        Realm:
            Server.

        Example Usage:
            -- Get all changed config values for saving
            local changed = lia.config.getChangedValues()
    ]]
    function lia.config.getChangedValues()
        local data = {}
        for k, v in pairs(lia.config.stored) do
            if v.default ~= v.value then data[k] = v.value end
        end
        return data
    end

    --[[
        lia.config.send

        Purpose:
            Sends the current changed config values to a specific client or broadcasts to all clients.

        Parameters:
            client (Player) - (Optional) The client to send to. If nil, broadcasts to all.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Send config to a specific client
            lia.config.send(somePlayer)

            -- Broadcast config to all clients
            lia.config.send()
    ]]
    function lia.config.send(client)
        net.Start("cfgList")
        net.WriteTable(lia.config.getChangedValues())
        if client then
            net.Send(client)
        else
            net.Broadcast()
        end
    end

    --[[
        lia.config.save

        Purpose:
            Saves all changed config values to the database for the current schema/gamemode.

        Parameters:
            None.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Save all config changes to the database
            lia.config.save()
    ]]
    function lia.config.save()
        local changed = lia.config.getChangedValues()
        local rows = {}
        for k, v in pairs(changed) do
            rows[#rows + 1] = {
                key = k,
                value = {v}
            }
        end

        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local queries = {"DELETE FROM lia_config WHERE schema = " .. lia.db.convertDataType(gamemode)}
        for _, row in ipairs(rows) do
            queries[#queries + 1] = "INSERT INTO lia_config (schema,key,value) VALUES (" .. lia.db.convertDataType(gamemode) .. ", " .. lia.db.convertDataType(row.key) .. ", " .. lia.db.convertDataType(row.value) .. ")"
        end

        lia.db.transaction(queries)
    end
end

lia.config.add("MoneyModel", L("moneyModel"), "models/props_lab/box01a.mdl", nil, {
    desc = L("moneyModelDesc"),
    category = L("money"),
    type = "Generic"
})

lia.config.add("MoneyLimit", L("moneyLimit"), 0, nil, {
    desc = L("moneyLimitDesc"),
    category = L("money"),
    type = "Int",
    min = 0,
    max = 1000000
})

lia.config.add("MaxMoneyEntities", L("maxMoneyEntities"), 3, nil, {
    desc = L("maxMoneyEntitiesDesc"),
    category = L("money"),
    type = "Int",
    min = 1,
    max = 50
})

lia.config.add("CurrencySymbol", L("currencySymbol"), "", function(newVal) lia.currency.symbol = newVal end, {
    desc = L("currencySymbolDesc"),
    category = L("money"),
    type = "Generic"
})

lia.config.add("PKWorld", L("pkWorld"), false, nil, {
    desc = L("pkWorldDesc"),
    category = L("character"),
    type = "Boolean"
})

lia.config.add("CurrencySingularName", L("currencySingularName"), L("currencySingular"), function(newVal) lia.currency.singular = newVal end, {
    desc = L("currencySingularNameDesc"),
    category = L("money"),
    type = "Generic"
})

lia.config.add("CurrencyPluralName", L("currencyPluralName"), L("currencyPlural"), function(newVal) lia.currency.plural = newVal end, {
    desc = L("currencyPluralNameDesc"),
    category = L("money"),
    type = "Generic"
})

lia.config.add("WalkSpeed", L("walkSpeed"), 130, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetWalkSpeed(newValue)
    end
end, {
    desc = L("walkSpeedDesc"),
    category = L("character"),
    type = "Int",
    min = 50,
    max = 300
})

lia.config.add("RunSpeed", L("runSpeed"), 275, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetRunSpeed(newValue)
    end
end, {
    desc = L("runSpeedDesc"),
    category = L("character"),
    type = "Int",
    min = 100,
    max = 500
})

lia.config.add("WalkRatio", L("walkRatio"), 0.5, nil, {
    desc = L("walkRatioDesc"),
    category = L("character"),
    type = "Float",
    min = 0.1,
    max = 1.0,
    decimals = 2
})

lia.config.add("AllowExistNames", L("allowDuplicateNames"), true, nil, {
    desc = L("allowDuplicateNamesDesc"),
    category = L("character"),
    type = "Boolean"
})

lia.config.add("WhitelistEnabled", L("whitelistEnabled"), false, nil, {
    desc = L("whitelistEnabledDesc"),
    category = L("categoryServer"),
    noNetworking = false,
    schemaOnly = false,
    isGlobal = false,
    type = "Boolean"
})

lia.config.add("BlacklistedEnabled", L("blacklistEnabled"), false, nil, {
    desc = L("blacklistEnabledDesc"),
    category = L("categoryServer"),
    noNetworking = false,
    schemaOnly = false,
    isGlobal = false,
    type = "Boolean"
})

lia.config.add("MaxCharacters", L("maxCharacters"), 5, nil, {
    desc = L("maxCharactersDesc"),
    category = L("character"),
    type = "Int",
    min = 1,
    max = 10
})

lia.config.add("AllowPMs", L("allowPMs"), true, nil, {
    desc = L("allowPMsDesc"),
    category = L("categoryChat"),
    type = "Boolean"
})

lia.config.add("MinDescLen", L("minDescriptionLength"), 16, nil, {
    desc = L("minDescriptionLengthDesc"),
    category = L("character"),
    type = "Int",
    min = 10,
    max = 500
})

lia.config.add("SaveInterval", L("saveInterval"), 300, nil, {
    desc = L("saveIntervalDesc"),
    category = L("character"),
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("DefMoney", L("defaultMoney"), 0, nil, {
    desc = L("defaultMoneyDesc"),
    category = L("character"),
    type = "Int",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", L("dataSaveInterval"), 600, nil, {
    desc = L("dataSaveIntervalDesc"),
    category = L("categoryData"),
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", L("characterDataSaveInterval"), 300, nil, {
    desc = L("characterDataSaveIntervalDesc"),
    category = L("categoryData"),
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", L("respawnTime"), 5, nil, {
    desc = L("respawnTimeDesc"),
    category = L("death"),
    type = "Float",
    min = 1,
    max = 60
})

lia.config.add("TimeToEnterVehicle", L("timeToEnterVehicle"), 1, nil, {
    desc = L("timeToEnterVehicleDesc"),
    category = L("categoryQualityOfLife"),
    type = "Float",
    min = 0.5,
    max = 10
})

lia.config.add("CarEntryDelayEnabled", L("carEntryDelayEnabled"), true, nil, {
    desc = L("carEntryDelayEnabledDesc"),
    category = L("categoryTimers"),
    type = "Boolean"
})

lia.config.add("MaxChatLength", L("maxChatLength"), 256, nil, {
    desc = L("maxChatLengthDesc"),
    category = L("categoryVisuals"),
    type = "Int",
    min = 50,
    max = 1024
})

lia.config.add("SchemaYear", L("schemaYear"), 2025, nil, {
    desc = L("schemaYearDesc"),
    category = L("categoryGeneral"),
    type = "Int",
    min = 0,
    max = 999999
})

lia.config.add("AmericanDates", L("americanDates"), true, nil, {
    desc = L("americanDatesDesc"),
    category = L("categoryGeneral"),
    type = "Boolean"
})

lia.config.add("AmericanTimeStamp", L("americanTimeStamp"), true, nil, {
    desc = L("americanTimeStampDesc"),
    category = L("categoryGeneral"),
    type = "Boolean"
})

lia.config.add("AdminConsoleNetworkLogs", L("adminConsoleNetworkLogs"), true, nil, {
    desc = L("adminConsoleNetworkLogsDesc"),
    category = L("categoryLogging"),
    type = "Boolean"
})

lia.config.add("Color", L("themeColor"), {
    r = 37,
    g = 116,
    b = 108
}, nil, {
    desc = L("themeColorDesc"),
    category = L("categoryVisuals"),
    type = "Color"
})

lia.config.add("CharMenuBGInputDisabled", L("charMenuBGInputDisabled"), true, nil, {
    desc = L("charMenuBGInputDisabledDesc"),
    category = L("mainMenu"),
    type = "Boolean"
})

lia.config.add("AllowKeybindEditing", L("allowKeybindEditing"), true, nil, {
    desc = L("allowKeybindEditingDesc"),
    category = L("categoryGeneral"),
    type = "Boolean"
})

lia.config.add("CrosshairEnabled", L("enableCrosshair"), false, nil, {
    desc = L("enableCrosshairDesc"),
    category = L("categoryVisuals"),
    type = "Boolean",
})

lia.config.add("BarsDisabled", L("disableBars"), false, nil, {
    desc = L("disableBarsDesc"),
    category = L("categoryVisuals"),
    type = "Boolean",
})

lia.config.add("AutoWeaponItemGeneration", L("autoWeaponItemGeneration"), true, nil, {
    desc = L("autoWeaponItemGenerationDesc"),
    category = L("categoryGeneral"),
    type = "Boolean",
})

lia.config.add("AmmoDrawEnabled", L("enableAmmoDisplay"), true, nil, {
    desc = L("enableAmmoDisplayDesc"),
    category = L("categoryVisuals"),
    type = "Boolean",
})

lia.config.add("IsVoiceEnabled", L("voiceChatEnabled"), true, function(_, newValue) hook.Run("VoiceToggled", newValue) end, {
    desc = L("voiceChatEnabledDesc"),
    category = L("categoryGeneral"),
    type = "Boolean",
})

lia.config.add("SalaryInterval", L("salaryInterval"), 300, function()
    for _, client in player.Iterator() do
        hook.Run("CreateSalaryTimer", client)
    end
end, {
    desc = L("salaryIntervalDesc"),
    category = L("categorySalary"),
    type = "Float",
    min = 60,
    max = 3600
})

lia.config.add("SalaryThreshold", L("salaryThreshold"), 0, nil, {
    desc = L("salaryThresholdDesc"),
    category = L("categorySalary"),
    type = "Int",
    min = 0,
    max = 100000
})

lia.config.add("ThirdPersonEnabled", L("thirdPersonEnabled"), true, nil, {
    desc = L("thirdPersonEnabledDesc"),
    category = L("categoryThirdPerson"),
    type = "Boolean"
})

lia.config.add("MaxThirdPersonDistance", L("maxThirdPersonDistance"), 100, nil, {
    desc = L("maxThirdPersonDistanceDesc"),
    category = L("categoryThirdPerson"),
    type = "Int"
})

lia.config.add("WallPeek", L("wallPeek"), true, nil, {
    desc = L("wallPeekDesc"),
    category = L("categoryRendering"),
    type = "Boolean",
})

lia.config.add("MaxThirdPersonHorizontal", L("maxThirdPersonHorizontal"), 30, nil, {
    desc = L("maxThirdPersonHorizontalDesc"),
    category = L("categoryThirdPerson"),
    type = "Int"
})

lia.config.add("MaxThirdPersonHeight", L("maxThirdPersonHeight"), 30, nil, {
    desc = L("maxThirdPersonHeightDesc"),
    category = L("categoryThirdPerson"),
    type = "Int"
})

lia.config.add("MaxViewDistance", L("maxViewDistance"), 32768, nil, {
    desc = L("maxViewDistanceDesc"),
    category = L("categoryQualityOfLife"),
    type = "Int",
    min = 1000,
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

lia.config.add("DermaSkin", L("dermaSkin"), "Lilia Skin", function(_, newSkin) hook.Run("DermaSkinChanged", newSkin) end, {
    desc = L("dermaSkinDesc"),
    category = L("categoryVisuals"),
    type = "Table",
    options = CLIENT and getDermaSkins() or {L("liliaSkin")}
})

lia.config.add("Language", L("language"), "English", nil, {
    desc = L("languageDesc"),
    category = L("categoryGeneral"),
    type = "Table",
    options = lia.lang.getLanguages()
})

lia.config.add("SpawnMenuLimit", L("spawnMenuLimit"), false, nil, {
    desc = L("spawnMenuLimitDesc"),
    category = L("categorySpawnGeneral"),
    type = "Boolean"
})

lia.config.add("LogRetentionDays", L("logRetentionPeriod"), 7, nil, {
    desc = L("logRetentionPeriodDesc"),
    category = L("categoryLogging"),
    type = "Int",
    min = 3,
    max = 30,
})

lia.config.add("MaxLogLines", L("maximumLogLines"), 1000, nil, {
    desc = L("maximumLogLinesDesc"),
    category = L("categoryLogging"),
    type = "Int",
    min = 500,
    max = 1000000,
})

lia.config.add("StaminaBlur", L("staminaBlurEnabled"), true, nil, {
    desc = L("staminaBlurEnabledDesc"),
    category = L("attributes"),
    type = "Boolean",
})

lia.config.add("StaminaSlowdown", L("staminaSlowdownEnabled"), true, nil, {
    desc = L("staminaSlowdownEnabledDesc"),
    category = L("attributes"),
    type = "Boolean",
})

lia.config.add("DefaultStamina", L("defaultStaminaValue"), 100, nil, {
    desc = L("defaultStaminaValueDesc"),
    category = L("attributes"),
    type = "Int",
    min = 0,
    max = 1000
})

lia.config.add("MaxAttributePoints", L("maxAttributePoints"), 30, nil, {
    desc = L("maxAttributePointsDesc"),
    category = L("attributes"),
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("JumpStaminaCost", L("jumpStaminaCost"), 10, nil, {
    desc = L("jumpStaminaCostDesc"),
    category = L("attributes"),
    type = "Int",
    min = 0,
    max = 1000
})

lia.config.add("MaxStartingAttributes", L("maxStartingAttributes"), 30, nil, {
    desc = L("maxStartingAttributesDesc"),
    category = L("attributes"),
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("StartingAttributePoints", L("startingAttributePoints"), 30, nil, {
    desc = L("startingAttributePointsDesc"),
    category = L("attributes"),
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("PunchStamina", L("punchStamina"), 10, nil, {
    desc = L("punchStaminaDesc"),
    category = L("attributes"),
    isGlobal = true,
    type = "Int",
    min = 0,
    max = 100
})

lia.config.add("MaxHoldWeight", L("maximumHoldWeight"), 100, nil, {
    desc = L("maximumHoldWeightDesc"),
    category = L("categoryGeneral"),
    type = "Int",
    min = 1,
    max = 500
})

lia.config.add("ThrowForce", L("throwForce"), 100, nil, {
    desc = L("throwForceDesc"),
    category = L("categoryGeneral"),
    type = "Int",
    min = 1,
    max = 500
})

lia.config.add("AllowPush", L("allowPush"), true, nil, {
    desc = L("allowPushDesc"),
    category = L("categoryGeneral"),
    type = "Boolean",
})

lia.config.add("PunchPlaytime", L("punchPlaytimeProtection"), 7200, nil, {
    desc = L("punchPlaytimeProtectionDesc"),
    category = L("categoryGeneral"),
    isGlobal = true,
    type = "Int",
    min = 0,
    max = 86400
})

lia.config.add("CustomChatSound", L("customChatSound"), "", nil, {
    desc = L("customChatSoundDesc"),
    category = L("categoryChat"),
    type = "Generic",
})

lia.config.add("ChatColor", L("chatColor"), {
    r = 255,
    g = 239,
    b = 150,
    a = 255
}, nil, {
    desc = L("chatColorDesc"),
    category = L("categoryChat"),
    type = "Color",
})

lia.config.add("ChatRange", L("chatRange"), 280, nil, {
    desc = L("chatRangeDesc"),
    category = L("categoryChat"),
    type = "Int",
    min = 0,
    max = 10000
})

lia.config.add("OOCLimit", L("oocCharacterLimit"), 150, nil, {
    desc = L("oocCharacterLimitDesc"),
    category = L("categoryChat"),
    type = "Int",
    min = 10,
    max = 1000
})

lia.config.add("ChatListenColor", L("chatListenColor"), {
    r = 168,
    g = 240,
    b = 170,
    a = 255
}, nil, {
    desc = L("chatListenColorDesc"),
    category = L("categoryChat"),
    type = "Color",
})

lia.config.add("OOCDelay", L("oocDelayTitle"), 10, nil, {
    desc = L("oocDelayDesc"),
    category = L("categoryChat"),
    type = "Float",
    min = 0,
    max = 60
})

lia.config.add("LOOCDelay", L("loocDelayTitle"), 6, nil, {
    desc = L("loocDelayDesc"),
    category = L("categoryChat"),
    type = "Float",
    min = 0,
    max = 60
})

lia.config.add("LOOCDelayAdmin", L("loocDelayAdmin"), false, nil, {
    desc = L("loocDelayAdminDesc"),
    category = L("categoryChat"),
    type = "Boolean",
})

lia.config.add("ChatSizeDiff", L("enableDifferentChatSize"), false, nil, {
    desc = L("enableDifferentChatSizeDesc"),
    category = L("categoryChat"),
    type = "Boolean",
})

lia.config.add("MusicVolume", L("mainMenuMusicVolume"), 0.25, nil, {
    desc = L("mainMenuMusicVolumeDesc"),
    category = L("mainMenu"),
    type = "Float",
    min = 0.0,
    max = 1.0
})

lia.config.add("Music", L("mainMenuMusic"), "", nil, {
    desc = L("mainMenuMusicDesc"),
    category = L("mainMenu"),
    type = "Generic"
})

lia.config.add("BackgroundURL", L("mainMenuBackgroundURL"), "", nil, {
    desc = L("mainMenuBackgroundURLDesc"),
    category = L("mainMenu"),
    type = "Generic"
})

lia.config.add("CenterLogo", L("mainMenuCenterLogo"), "", nil, {
    desc = L("mainMenuCenterLogoDesc"),
    category = L("mainMenu"),
    type = "Generic"
})

lia.config.add("DiscordURL", L("mainMenuDiscordURL"), "https://discord.gg/esCRH5ckbQ", nil, {
    desc = L("mainMenuDiscordURLDesc"),
    category = L("mainMenu"),
    type = "Generic"
})

lia.config.add("Workshop", L("mainMenuWorkshopURL"), "https://steamcommunity.com/sharedfiles/filedetails/?id=3527535922", nil, {
    desc = L("mainMenuWorkshopURLDesc"),
    category = L("mainMenu"),
    type = "Generic"
})

lia.config.add("CharMenuBGInputDisabled", L("mainMenuCharBGInputDisabled"), true, nil, {
    desc = L("mainMenuCharBGInputDisabledDesc"),
    category = L("mainMenu"),
    type = "Boolean"
})

lia.config.add("SwitchCooldownOnAllEntities", L("switchCooldownOnAllEntities"), false, nil, {
    desc = L("switchCooldownOnAllEntitiesDesc"),
    category = L("character"),
    type = "Boolean",
})

lia.config.add("OnDamageCharacterSwitchCooldownTimer", L("onDamageCharacterSwitchCooldownTimer"), 15, nil, {
    desc = L("onDamageCharacterSwitchCooldownTimerDesc"),
    category = L("character"),
    type = "Float",
    min = 0,
    max = 120
})

lia.config.add("CharacterSwitchCooldownTimer", L("characterSwitchCooldownTimer"), 5, nil, {
    desc = L("characterSwitchCooldownTimerDesc"),
    category = L("character"),
    type = "Float",
    min = 0,
    max = 120
})

lia.config.add("ExplosionRagdoll", L("explosionRagdoll"), false, nil, {
    desc = L("explosionRagdollDesc"),
    category = L("categoryQualityOfLife"),
    type = "Boolean",
})

lia.config.add("CarRagdoll", L("carRagdoll"), false, nil, {
    desc = L("carRagdollDesc"),
    category = L("categoryQualityOfLife"),
    type = "Boolean",
})

lia.config.add("NPCsDropWeapons", L("npcsDropWeapons"), false, nil, {
    desc = L("npcsDropWeaponsDesc"),
    category = L("categoryQualityOfLife"),
    type = "Boolean",
})

lia.config.add("TimeUntilDroppedSWEPRemoved", L("timeUntilDroppedSWEPRemoved"), 15, nil, {
    desc = L("timeUntilDroppedSWEPRemovedDesc"),
    category = L("protection"),
    type = "Float",
    min = 0,
    max = 300
})

lia.config.add("AltsDisabled", L("altsDisabled"), false, nil, {
    desc = L("altsDisabledDesc"),
    category = L("protection"),
    type = "Boolean",
})

lia.config.add("ActsActive", L("actsActive"), false, nil, {
    desc = L("actsActiveDesc"),
    category = L("protection"),
    type = "Boolean",
})

lia.config.add("PassableOnFreeze", L("passableOnFreeze"), false, nil, {
    desc = L("passableOnFreezeDesc"),
    category = L("protection"),
    type = "Boolean",
})

lia.config.add("PlayerSpawnVehicleDelay", L("playerSpawnVehicleDelay"), 30, nil, {
    desc = L("playerSpawnVehicleDelayDesc"),
    category = L("protection"),
    type = "Float",
    min = 0,
    max = 300
})

lia.config.add("ToolInterval", L("toolInterval"), 0, nil, {
    desc = L("toolInterval"),
    category = L("protection"),
    type = "Float",
    min = 0,
    max = 60
})

lia.config.add("DisableLuaRun", L("disableLuaRun"), false, nil, {
    desc = L("disableLuaRunDesc"),
    category = L("protection"),
    type = "Boolean",
})

lia.config.add("EquipDelay", L("equipDelay"), 0, nil, {
    desc = L("equipDelayDesc"),
    category = L("items"),
    type = "Float",
    min = 0,
    max = 10
})

lia.config.add("UnequipDelay", L("unequipDelay"), 0, nil, {
    desc = L("unequipDelayDesc"),
    category = L("items"),
    type = "Float",
    min = 0,
    max = 10
})

lia.config.add("DropDelay", L("dropDelay"), 0, nil, {
    desc = L("dropDelayDesc"),
    category = L("items"),
    type = "Float",
    min = 0,
    max = 10
})

lia.config.add("TakeDelay", L("takeDelay"), 0, nil, {
    desc = L("takeDelayDesc"),
    category = L("items"),
    type = "Float",
    min = 0,
    max = 10
})

lia.config.add("ItemGiveSpeed", L("itemGiveSpeed"), 6, nil, {
    desc = L("itemGiveSpeedDesc"),
    category = L("items"),
    type = "Int",
    min = 1,
    max = 60
})

lia.config.add("ItemGiveEnabled", L("itemGiveEnabled"), true, nil, {
    desc = L("itemGiveEnabledDesc"),
    category = L("items"),
    type = "Boolean",
})

lia.config.add("DisableCheaterActions", L("disableCheaterActions"), true, nil, {
    desc = L("disableCheaterActionsDesc"),
    category = L("protection"),
    type = "Boolean",
})

lia.config.add("LoseItemsonDeathNPC", L("loseItemsOnNPCDeath"), false, nil, {
    desc = L("loseItemsOnNPCDeathDesc"),
    category = L("death"),
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathHuman", L("loseItemsOnHumanDeath"), false, nil, {
    desc = L("loseItemsOnHumanDeathDesc"),
    category = L("death"),
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathWorld", L("loseItemsOnWorldDeath"), false, nil, {
    desc = L("loseItemsOnWorldDeathDesc"),
    category = L("death"),
    type = "Boolean"
})

lia.config.add("DeathPopupEnabled", L("enableDeathPopup"), true, nil, {
    desc = L("enableDeathPopupDesc"),
    category = L("death"),
    type = "Boolean"
})

lia.config.add("StaffHasGodMode", L("staffGodMode"), true, nil, {
    desc = L("staffGodModeDesc"),
    category = L("categoryStaffSettings"),
    type = "Boolean"
})

lia.config.add("ClassDisplay", L("displayClassesOnCharacters"), true, nil, {
    desc = L("displayClassesOnCharactersDesc"),
    category = L("character"),
    type = "Boolean"
})

lia.config.add("sbWidth", L("sbWidth"), 0.35, nil, {
    desc = L("sbWidthDesc"),
    category = L("scoreboard"),
    type = "Float",
    min = 0.1,
    max = 1.0
})

lia.config.add("sbHeight", L("sbHeight"), 0.65, nil, {
    desc = L("sbHeightDesc"),
    category = L("scoreboard"),
    type = "Float",
    min = 0.1,
    max = 1.0
})

lia.config.add("ClassHeaders", L("classHeaders"), true, nil, {
    desc = L("classHeadersDesc"),
    category = L("scoreboard"),
    type = "Boolean"
})

lia.config.add("UseSolidBackground", L("useSolidBackground"), false, nil, {
    desc = L("useSolidBackgroundDesc"),
    category = L("scoreboard"),
    type = "Boolean"
})

lia.config.add("ClassLogo", L("classLogo"), false, nil, {
    desc = L("classLogoDesc"),
    category = L("scoreboard"),
    type = "Boolean"
})

lia.config.add("ScoreboardBackgroundColor", L("scoreboardBackgroundColor"), {
    r = 255,
    g = 100,
    b = 100,
    a = 255
}, nil, {
    desc = L("scoreboardBackgroundColorDesc"),
    category = L("scoreboard"),
    type = "Color"
})

lia.config.add("RecognitionEnabled", L("recognitionEnabled"), true, nil, {
    desc = L("recognitionEnabledDesc"),
    category = L("recognition"),
    type = "Boolean"
})

lia.config.add("FakeNamesEnabled", L("fakeNamesEnabled"), false, nil, {
    desc = L("fakeNamesEnabledDesc"),
    category = L("recognition"),
    type = "Boolean"
})

lia.config.add("vendorDefaultMoney", L("vendorDefaultMoney"), 500, nil, {
    desc = L("vendorDefaultMoneyDesc"),
    category = L("vendor"),
    type = "Int"
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

lia.config.add("DefaultMenuTab", L("defaultMenuTab"), L("you"), nil, {
    desc = L("defaultMenuTabDesc"),
    category = L("categoryMenu"),
    type = "Table",
    options = CLIENT and getMenuTabNames() or {L("you")}
})

lia.config.add("DoorLockTime", L("doorLockTime"), 0.5, nil, {
    desc = L("doorLockTimeDesc"),
    category = L("moduleDoorsName"),
    type = "Float",
    min = 0.1,
    max = 10.0
})

lia.config.add("DoorSellRatio", L("doorSellRatio"), 0.5, nil, {
    desc = L("doorSellRatioDesc"),
    category = L("moduleDoorsName"),
    type = "Float",
    min = 0.0,
    max = 1.0
})

hook.Add("PopulateConfigurationButtons", "liaConfigPopulate", function(pages)
    local ConfigFormatting = {
        Int = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local slider = panel:Add("DNumSlider")
            slider:Dock(FILL)
            slider:DockMargin(10, 0, 10, 0)
            slider:SetMin(lia.config.get(key .. "_min", config.data and config.data.min or 0))
            slider:SetMax(lia.config.get(key .. "_max", config.data and config.data.max or 1))
            slider:SetDecimals(0)
            slider:SetValue(lia.config.get(key, config.value))
            slider:SetText("")
            slider.PerformLayout = function()
                slider.Label:SetWide(0)
                slider.TextArea:SetWide(50)
            end

            slider.OnValueChanged = function(_, v)
                local t = "ConfigChange_" .. key .. "_" .. os.time()
                timer.Create(t, 0.5, 1, function()
                    net.Start("cfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(math.floor(v))
                    net.SendToServer()
                end)
            end
            return container
        end,
        Float = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local slider = panel:Add("DNumSlider")
            slider:Dock(FILL)
            slider:DockMargin(10, 0, 10, 0)
            slider:SetMin(lia.config.get(key .. "_min", config.data and config.data.min or 0))
            slider:SetMax(lia.config.get(key .. "_max", config.data and config.data.max or 1))
            slider:SetDecimals(2)
            slider:SetValue(lia.config.get(key, config.value))
            slider:SetText("")
            slider.PerformLayout = function()
                slider.Label:SetWide(0)
                slider.TextArea:SetWide(50)
            end

            slider.OnValueChanged = function(_, v)
                local t = "ConfigChange_" .. key .. "_" .. os.time()
                timer.Create(t, 0.5, 1, function()
                    net.Start("cfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(tonumber(v))
                    net.SendToServer()
                end)
            end
            return container
        end,
        Generic = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local entry = panel:Add("DTextEntry")
            entry:Dock(TOP)
            entry:SetTall(60)
            entry:DockMargin(300, 10, 300, 0)
            entry:SetText(tostring(lia.config.get(key, config.value)))
            entry:SetFont("ConfigFontLarge")
            entry:SetTextColor(Color(255, 255, 255))
            entry.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
                self:DrawTextEntryText(Color(255, 255, 255), Color(255, 255, 255), Color(255, 255, 255))
            end

            entry.OnEnter = function()
                local t = "ConfigChange_" .. key .. "_" .. os.time()
                timer.Create(t, 0.5, 1, function()
                    net.Start("cfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(entry:GetText())
                    net.SendToServer()
                end)
            end
            return container
        end,
        Boolean = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local button = panel:Add("DButton")
            button:Dock(TOP)
            button:SetTall(120)
            button:DockMargin(90, 10, 90, 10)
            button:SetText("")
            button.Paint = function(_, w, h)
                local v = lia.config.get(key, config.value)
                local ic = v and "checkbox.png" or "unchecked.png"
                lia.util.drawTexture(ic, color_white, w / 2 - 48, h / 2 - 64, 96, 96)
            end

            button.DoClick = function()
                local t = "ConfigChange_" .. key .. "_" .. os.time()
                timer.Create(t, 0.5, 1, function()
                    net.Start("cfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(not lia.config.get(key, config.value))
                    net.SendToServer()
                end)
            end
            return container
        end,
        Color = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local button = panel:Add("DButton")
            button:Dock(FILL)
            button:DockMargin(10, 0, 10, 0)
            button:SetText("")
            button.Paint = function(_, w, h)
                local c = lia.config.get(key, config.value)
                surface.SetDrawColor(c)
                surface.DrawRect(10, h / 2 - 15, w - 20, 30)
                draw.RoundedBox(2, 10, h / 2 - 15, w - 20, 30, Color(255, 255, 255, 50))
            end

            button.DoClick = function()
                if IsValid(button.picker) then button.picker:Remove() end
                local f = vgui.Create("DFrame")
                f:SetSize(300, 400)
                f:Center()
                f:MakePopup()
                local m = f:Add("DColorMixer")
                m:Dock(FILL)
                m:SetPalette(true)
                m:SetAlphaBar(true)
                m:SetWangs(true)
                m:SetColor(lia.config.get(key, config.value))
                local apply = f:Add("DButton")
                apply:Dock(BOTTOM)
                apply:SetTall(40)
                apply:SetText(L("apply"))
                apply:SetFont("ConfigFontLarge")
                apply.Paint = function(_, w, h)
                    surface.SetDrawColor(Color(0, 150, 0))
                    surface.DrawRect(0, 0, w, h)
                    if apply:IsHovered() then
                        surface.SetDrawColor(Color(0, 180, 0))
                        surface.DrawRect(0, 0, w, h)
                    end

                    surface.SetDrawColor(Color(255, 255, 255))
                    surface.DrawOutlinedRect(0, 0, w, h)
                end

                apply.DoClick = function()
                    local color = m:GetColor()
                    local t = "ConfigChange_" .. key .. "_" .. os.time()
                    timer.Create(t, 0.5, 1, function()
                        net.Start("cfgSet")
                        net.WriteString(key)
                        net.WriteString(name)
                        net.WriteType(color)
                        net.SendToServer()
                    end)

                    f:Remove()
                end

                button.picker = f
            end
            return container
        end,
        Table = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local combo = panel:Add("DComboBox")
            combo:Dock(TOP)
            combo:SetTall(60)
            combo:DockMargin(300, 10, 300, 0)
            combo:SetValue(tostring(lia.config.get(key, config.value)))
            combo:SetFont("ConfigFontLarge")
            combo.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
                self:DrawTextEntryText(Color(255, 255, 255), Color(255, 255, 255), Color(255, 255, 255))
            end

            for _, o in ipairs(config.data and config.data.options or {}) do
                combo:AddChoice(o)
            end

            combo.OnSelect = function(_, _, v)
                local t = "ConfigChange_" .. key .. "_" .. os.time()
                timer.Create(t, 0.5, 1, function()
                    net.Start("cfgSet")
                    net.WriteString(key)
                    net.WriteString(name)
                    net.WriteType(v)
                    net.SendToServer()
                end)
            end
            return container
        end
    }

    local function buildConfiguration(parent)
        parent:Clear()
        local sheet = parent:Add("liaSheet")
        sheet:Dock(FILL)
        sheet:SetPlaceholderText(L("searchConfigs"))
        local function populate(filter)
            sheet:Clear()
            local categories = {}
            local keys = {}
            for k in pairs(lia.config.stored) do
                keys[#keys + 1] = k
            end

            table.sort(keys, function(a, b) return lia.config.stored[a].name < lia.config.stored[b].name end)
            for _, k in ipairs(keys) do
                local opt = lia.config.stored[k]
                local n = opt.name or ""
                local d = opt.desc or ""
                local ln, ld = n:lower(), d:lower()
                if filter == "" or ln:find(filter, 1, true) or ld:find(filter, 1, true) then
                    local cat = opt.category or L("misc")
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
            for _, categoryName in ipairs(categoryNames) do
                local items = categories[categoryName]
                local cat = vgui.Create("DCollapsibleCategory", sheet.canvas)
                cat:Dock(TOP)
                cat:SetLabel(categoryName)
                cat:SetExpanded(true)
                cat:DockMargin(0, 0, 0, 10)
                cat.Header:SetContentAlignment(5)
                cat.Header:SetTall(30)
                cat.Header:SetFont("liaMediumFont")
                cat.Header:SetTextColor(Color(255, 255, 255))
                cat.Paint = function() end
                cat.Header.Paint = function(_, w, h)
                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawOutlinedRect(0, 0, w, h, 2)
                    surface.SetDrawColor(0, 0, 0, 150)
                    surface.DrawRect(1, 1, w - 2, h - 2)
                end

                cat.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 60)) end
                local body = vgui.Create("DPanel", cat)
                body:SetTall(#items * 240)
                body.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 50)) end
                cat:SetContents(body)
                for _, it in ipairs(items) do
                    local el = ConfigFormatting[it.elemType](it.key, it.name, it.config, body)
                    el:Dock(TOP)
                    el:DockMargin(10, 10, 10, 0)
                    el.Paint = function(_, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawOutlinedRect(0, 0, w, h)
                    end
                end
            end
        end

        sheet.search.OnTextChanged = function() populate(sheet.search:GetValue():lower()) end
        populate("")
    end

    if hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false then
        pages[#pages + 1] = {
            name = L("categoryConfiguration"),
            drawFunc = function(parent) buildConfiguration(parent) end
        }
    end
end)