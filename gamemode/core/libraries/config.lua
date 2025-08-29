lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
function lia.config.add(key, name, value, callback, data)
    assert(isstring(key), L("configKeyString", type(key)))
    assert(istable(data), L("configDataTable", type(data)))
    local t = type(value)
    local configType = t == "boolean" and "Boolean" or t == "number" and (math.floor(value) == value and "Int" or "Float") or t == "table" and (value.r and value.g and value.b and "Color" or "Table") or "Generic"
    local validTypes = {
        Boolean = true,
        Int = true,
        Float = true,
        Color = true,
        Table = true,
        Generic = true
    }

    if not data.type or not validTypes[data.type] then
        print(L("configMissingType", key, configType))
        data.type = configType
    end

    if (data.type == "Int" or data.type == "Float") and (data.min == nil or data.max == nil) then
        local missing = data.min == nil and data.max == nil and "min and max" or data.min == nil and "min" or "max"
        print(L("configNeedsMinMax", key, data.type, missing))
    end

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
            print("Warning: Config options function for '" .. key .. "' failed or returned invalid result")
            return {}
        end
    elseif istable(config.data.options) then
        return config.data.options
    end
    return {}
end

function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]
    if config then config.default = value end
end

function lia.config.forceSet(key, value, noSave)
    local config = lia.config.stored[key]
    if config then config.value = value end
    if not noSave then lia.config.save() end
end

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
    function lia.config.getChangedValues()
        local data = {}
        for k, v in pairs(lia.config.stored) do
            if v.default ~= v.value then data[k] = v.value end
        end
        return data
    end

    function lia.config.send(client)
        net.Start("cfgList")
        net.WriteTable(lia.config.getChangedValues())
        if client then
            net.Send(client)
        else
            net.Broadcast()
        end
    end

    function lia.config.save()
        local changed = lia.config.getChangedValues()
        local rows = {}
        for k, v in pairs(changed) do
            rows[#rows + 1] = {
                key = k,
                value = {v},
            }
        end

        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local queries = {"DELETE FROM lia_config WHERE schema = " .. lia.db.convertDataType(gamemode)}
        for _, row in ipairs(rows) do
            queries[#queries + 1] = "INSERT INTO lia_config (schema,key,value) VALUES (" .. lia.db.convertDataType(gamemode) .. ", " .. lia.db.convertDataType(row.key) .. ", " .. lia.db.convertDataType(row.value) .. ")"
        end

        lia.db.transaction(queries)
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
end

lia.config.add("MoneyModel", "moneyModel", "models/props_lab/box01a.mdl", nil, {
    desc = "moneyModelDesc",
    category = "money",
    type = "Generic"
})

lia.config.add("MoneyLimit", "moneyLimit", 0, nil, {
    desc = "moneyLimitDesc",
    category = "money",
    type = "Int",
    min = 0,
    max = 1000000
})

lia.config.add("MaxMoneyEntities", "maxMoneyEntities", 3, nil, {
    desc = "maxMoneyEntitiesDesc",
    category = "money",
    type = "Int",
    min = 1,
    max = 50
})

lia.config.add("CurrencySymbol", "currencySymbol", "", function(newVal) lia.currency.symbol = newVal end, {
    desc = "currencySymbolDesc",
    category = "money",
    type = "Generic"
})

lia.config.add("PKWorld", "pkWorld", false, nil, {
    desc = "pkWorldDesc",
    category = "character",
    type = "Boolean"
})

lia.config.add("CurrencySingularName", "currencySingularName", "currencySingular", function(newVal) lia.currency.singular = L(newVal) end, {
    desc = "currencySingularNameDesc",
    category = "money",
    type = "Generic"
})

lia.config.add("CurrencyPluralName", "currencyPluralName", "currencyPlural", function(newVal) lia.currency.plural = L(newVal) end, {
    desc = "currencyPluralNameDesc",
    category = "money",
    type = "Generic"
})

lia.config.add("WalkSpeed", "walkSpeed", 130, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetWalkSpeed(newValue)
    end
end, {
    desc = "walkSpeedDesc",
    category = "character",
    type = "Int",
    min = 50,
    max = 300
})

lia.config.add("RunSpeed", "runSpeed", 275, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetRunSpeed(newValue)
    end
end, {
    desc = "runSpeedDesc",
    category = "character",
    type = "Int",
    min = 100,
    max = 500
})

lia.config.add("WalkRatio", "walkRatio", 0.5, nil, {
    desc = "walkRatioDesc",
    category = "character",
    type = "Float",
    min = 0.2,
    max = 1.0,
    decimals = 2
})

lia.config.add("AllowExistNames", "allowDuplicateNames", true, nil, {
    desc = "allowDuplicateNamesDesc",
    category = "character",
    type = "Boolean"
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
    category = "character",
    type = "Int",
    min = 1,
    max = 20
})

lia.config.add("AllowPMs", "allowPMs", true, nil, {
    desc = "allowPMsDesc",
    category = "categoryChat",
    type = "Boolean"
})

lia.config.add("MinDescLen", "minDescriptionLength", 16, nil, {
    desc = "minDescriptionLengthDesc",
    category = "character",
    type = "Int",
    min = 10,
    max = 500
})

lia.config.add("SaveInterval", "saveInterval", 300, nil, {
    desc = "saveIntervalDesc",
    category = "character",
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("DefMoney", "defaultMoney", 0, nil, {
    desc = "defaultMoneyDesc",
    category = "character",
    type = "Int",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", "dataSaveInterval", 600, nil, {
    desc = "dataSaveIntervalDesc",
    category = "categoryData",
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", "characterDataSaveInterval", 300, nil, {
    desc = "characterDataSaveIntervalDesc",
    category = "categoryData",
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", "respawnTime", 5, nil, {
    desc = "respawnTimeDesc",
    category = "death",
    type = "Float",
    min = 0.5,
    max = 60
})

lia.config.add("TimeToEnterVehicle", "timeToEnterVehicle", 1, nil, {
    desc = "timeToEnterVehicleDesc",
    category = "categoryQualityOfLife",
    type = "Float",
    min = 0.1,
    max = 30
})

lia.config.add("CarEntryDelayEnabled", "carEntryDelayEnabled", true, nil, {
    desc = "carEntryDelayEnabledDesc",
    category = "categoryTimers",
    type = "Boolean"
})

lia.config.add("MaxChatLength", "maxChatLength", 256, nil, {
    desc = "maxChatLengthDesc",
    category = "categoryVisuals",
    type = "Int",
    min = 50,
    max = 1024
})

lia.config.add("SchemaYear", "schemaYear", 2025, nil, {
    desc = "schemaYearDesc",
    category = "categoryGeneral",
    type = "Int",
    min = 0,
    max = 999999
})

lia.config.add("DoorsAlwaysDisabled", "doorsAlwaysDisabled", false, nil, {
    desc = "doorsAlwaysDisabledDesc",
    category = "Doors",
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
    category = "categoryLogging",
    type = "Boolean"
})

lia.config.add("Color", "themeColor", {
    r = 37,
    g = 116,
    b = 108
}, nil, {
    desc = "themeColorDesc",
    category = "categoryVisuals",
    type = "Color"
})

lia.config.add("CharMenuBGInputDisabled", "charMenuBGInputDisabled", true, nil, {
    desc = "charMenuBGInputDisabledDesc",
    category = "mainMenu",
    type = "Boolean"
})

lia.config.add("AllowKeybindEditing", "allowKeybindEditing", true, nil, {
    desc = "allowKeybindEditingDesc",
    category = "categoryGeneral",
    type = "Boolean"
})

lia.config.add("CrosshairEnabled", "enableCrosshair", false, nil, {
    desc = "enableCrosshairDesc",
    category = "categoryVisuals",
    type = "Boolean",
})

lia.config.add("BarsDisabled", "disableBars", false, nil, {
    desc = "disableBarsDesc",
    category = "categoryVisuals",
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

lia.config.add("AmmoDrawEnabled", "enableAmmoDisplay", true, nil, {
    desc = "enableAmmoDisplayDesc",
    category = "categoryVisuals",
    type = "Boolean",
})

lia.config.add("IsVoiceEnabled", "voiceChatEnabled", true, function(_, newValue) hook.Run("VoiceToggled", newValue) end, {
    desc = "voiceChatEnabledDesc",
    category = "categoryGeneral",
    type = "Boolean",
})

lia.config.add("SalaryInterval", "salaryInterval", 300, function()
    for _, client in player.Iterator() do
        hook.Run("CreateSalaryTimer", client)
    end
end, {
    desc = "salaryIntervalDesc",
    category = "categorySalary",
    type = "Float",
    min = 60,
    max = 3600
})

lia.config.add("SalaryThreshold", "salaryThreshold", 0, nil, {
    desc = "salaryThresholdDesc",
    category = "categorySalary",
    type = "Int",
    min = 0,
    max = 100000
})

lia.config.add("ThirdPersonEnabled", "thirdPersonEnabled", true, nil, {
    desc = "thirdPersonEnabledDesc",
    category = "categoryThirdPerson",
    type = "Boolean"
})

lia.config.add("MaxThirdPersonDistance", "maxThirdPersonDistance", 100, nil, {
    desc = "maxThirdPersonDistanceDesc",
    category = "categoryThirdPerson",
    type = "Int",
    min = 25,
    max = 200
})

lia.config.add("WallPeek", "wallPeek", true, nil, {
    desc = "wallPeekDesc",
    category = "categoryRendering",
    type = "Boolean",
})

lia.config.add("MaxThirdPersonHorizontal", "maxThirdPersonHorizontal", 30, nil, {
    desc = "maxThirdPersonHorizontalDesc",
    category = "categoryThirdPerson",
    type = "Int",
    min = 5,
    max = 100
})

lia.config.add("MaxThirdPersonHeight", "maxThirdPersonHeight", 30, nil, {
    desc = "maxThirdPersonHeightDesc",
    category = "categoryThirdPerson",
    type = "Int",
    min = 5,
    max = 100
})

lia.config.add("MaxViewDistance", "maxViewDistance", 32768, nil, {
    desc = "maxViewDistanceDesc",
    category = "categoryQualityOfLife",
    type = "Int",
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
    category = "categoryVisuals",
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
    category = "categorySpawnGeneral",
    type = "Boolean"
})

lia.config.add("LogRetentionDays", "logRetentionPeriod", 7, nil, {
    desc = "logRetentionPeriodDesc",
    category = "categoryLogging",
    type = "Int",
    min = 1,
    max = 30,
})

lia.config.add("MaxLogLines", "maximumLogLines", 1000, nil, {
    desc = "maximumLogLinesDesc",
    category = "categoryLogging",
    type = "Int",
    min = 100,
    max = 1000000,
})

lia.config.add("StaminaBlur", "staminaBlurEnabled", true, nil, {
    desc = "staminaBlurEnabledDesc",
    category = "attributes",
    type = "Boolean",
})

lia.config.add("StaminaSlowdown", "staminaSlowdownEnabled", true, nil, {
    desc = "staminaSlowdownEnabledDesc",
    category = "attributes",
    type = "Boolean",
})

lia.config.add("DefaultStamina", "defaultStaminaValue", 100, nil, {
    desc = "defaultStaminaValueDesc",
    category = "attributes",
    type = "Int",
    min = 10,
    max = 1000
})

lia.config.add("MaxAttributePoints", "maxAttributePoints", 30, nil, {
    desc = "maxAttributePointsDesc",
    category = "attributes",
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("JumpStaminaCost", "jumpStaminaCost", 10, nil, {
    desc = "jumpStaminaCostDesc",
    category = "attributes",
    type = "Int",
    min = 1,
    max = 1000
})

lia.config.add("MaxStartingAttributes", "maxStartingAttributes", 30, nil, {
    desc = "maxStartingAttributesDesc",
    category = "attributes",
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("StartingAttributePoints", "startingAttributePoints", 30, nil, {
    desc = "startingAttributePointsDesc",
    category = "attributes",
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("PunchStamina", "punchStamina", 10, nil, {
    desc = "punchStaminaDesc",
    category = "attributes",
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("MaxHoldWeight", "maximumHoldWeight", 100, nil, {
    desc = "maximumHoldWeightDesc",
    category = "categoryGeneral",
    type = "Int",
    min = 10,
    max = 500
})

lia.config.add("ThrowForce", "throwForce", 100, nil, {
    desc = "throwForceDesc",
    category = "categoryGeneral",
    type = "Int",
    min = 10,
    max = 500
})

lia.config.add("AllowPush", "allowPush", true, nil, {
    desc = "allowPushDesc",
    category = "categoryGeneral",
    type = "Boolean",
})

lia.config.add("PunchPlaytime", "punchPlaytimeProtection", 7200, nil, {
    desc = "punchPlaytimeProtectionDesc",
    category = "categoryGeneral",
    isGlobal = true,
    type = "Int",
    min = 0,
    max = 86400
})

lia.config.add("CustomChatSound", "customChatSound", "", nil, {
    desc = "customChatSoundDesc",
    category = "categoryChat",
    type = "Generic",
})

lia.config.add("ChatColor", "chatColor", {
    r = 255,
    g = 239,
    b = 150,
    a = 255
}, nil, {
    desc = "chatColorDesc",
    category = "categoryChat",
    type = "Color",
})

lia.config.add("ChatRange", "chatRange", 280, nil, {
    desc = "chatRangeDesc",
    category = "categoryChat",
    type = "Int",
    min = 50,
    max = 10000
})

lia.config.add("OOCLimit", "oocCharacterLimit", 150, nil, {
    desc = "oocCharacterLimitDesc",
    category = "categoryChat",
    type = "Int",
    min = 25,
    max = 1000
})

lia.config.add("ChatListenColor", "chatListenColor", {
    r = 168,
    g = 240,
    b = 170,
    a = 255
}, nil, {
    desc = "chatListenColorDesc",
    category = "categoryChat",
    type = "Color",
})

lia.config.add("OOCDelay", "oocDelayTitle", 10, nil, {
    desc = "oocDelayDesc",
    category = "categoryChat",
    type = "Float",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelay", "loocDelayTitle", 6, nil, {
    desc = "loocDelayDesc",
    category = "categoryChat",
    type = "Float",
    min = 1,
    max = 60
})

lia.config.add("LOOCDelayAdmin", "loocDelayAdmin", false, nil, {
    desc = "loocDelayAdminDesc",
    category = "categoryChat",
    type = "Boolean",
})

lia.config.add("ChatSizeDiff", "enableDifferentChatSize", false, nil, {
    desc = "enableDifferentChatSizeDesc",
    category = "categoryChat",
    type = "Boolean",
})

lia.config.add("MusicVolume", "mainMenuMusicVolume", 0.25, nil, {
    desc = "mainMenuMusicVolumeDesc",
    category = "mainMenu",
    type = "Float",
    min = 0.01,
    max = 1.0
})

lia.config.add("Music", "mainMenuMusic", "", nil, {
    desc = "mainMenuMusicDesc",
    category = "mainMenu",
    type = "Generic"
})

lia.config.add("BackgroundURL", "mainMenuBackgroundURL", "", nil, {
    desc = "mainMenuBackgroundURLDesc",
    category = "mainMenu",
    type = "Generic"
})

lia.config.add("CenterLogo", "mainMenuCenterLogo", "", nil, {
    desc = "mainMenuCenterLogoDesc",
    category = "mainMenu",
    type = "Generic"
})

lia.config.add("DiscordURL", "mainMenuDiscordURL", "", nil, {
    desc = "mainMenuDiscordURLDesc",
    category = "mainMenu",
    type = "Generic"
})

lia.config.add("Workshop", "mainMenuWorkshopURL", "", nil, {
    desc = "mainMenuWorkshopURLDesc",
    category = "mainMenu",
    type = "Generic"
})

lia.config.add("CharMenuBGInputDisabled", "mainMenuCharBGInputDisabled", true, nil, {
    desc = "mainMenuCharBGInputDisabledDesc",
    category = "mainMenu",
    type = "Boolean"
})

lia.config.add("SwitchCooldownOnAllEntities", "switchCooldownOnAllEntities", false, nil, {
    desc = "switchCooldownOnAllEntitiesDesc",
    category = "character",
    type = "Boolean",
})

lia.config.add("OnDamageCharacterSwitchCooldownTimer", "onDamageCharacterSwitchCooldownTimer", 15, nil, {
    desc = "onDamageCharacterSwitchCooldownTimerDesc",
    category = "character",
    type = "Float",
    min = 1,
    max = 120
})

lia.config.add("CharacterSwitchCooldownTimer", "characterSwitchCooldownTimer", 5, nil, {
    desc = "characterSwitchCooldownTimerDesc",
    category = "character",
    type = "Float",
    min = 1,
    max = 120
})

lia.config.add("ExplosionRagdoll", "explosionRagdoll", false, nil, {
    desc = "explosionRagdollDesc",
    category = "categoryQualityOfLife",
    type = "Boolean",
})

lia.config.add("CarRagdoll", "carRagdoll", false, nil, {
    desc = "carRagdollDesc",
    category = "categoryQualityOfLife",
    type = "Boolean",
})

lia.config.add("NPCsDropWeapons", "npcsDropWeapons", false, nil, {
    desc = "npcsDropWeaponsDesc",
    category = "categoryQualityOfLife",
    type = "Boolean",
})

lia.config.add("TimeUntilDroppedSWEPRemoved", "timeUntilDroppedSWEPRemoved", 15, nil, {
    desc = "timeUntilDroppedSWEPRemovedDesc",
    category = "protection",
    type = "Float",
    min = 1,
    max = 300
})

lia.config.add("AltsDisabled", "altsDisabled", false, nil, {
    desc = "altsDisabledDesc",
    category = "protection",
    type = "Boolean",
})

lia.config.add("ActsActive", "actsActive", false, nil, {
    desc = "actsActiveDesc",
    category = "protection",
    type = "Boolean",
})

lia.config.add("PropProtection", "propProtection", true, nil, {
    desc = "propProtectionDesc",
    category = "protection",
    type = "Boolean",
})

lia.config.add("PassableOnFreeze", "passableOnFreeze", false, nil, {
    desc = "passableOnFreezeDesc",
    category = "protection",
    type = "Boolean",
})

lia.config.add("PlayerSpawnVehicleDelay", "playerSpawnVehicleDelay", 30, nil, {
    desc = "playerSpawnVehicleDelayDesc",
    category = "protection",
    type = "Float",
    min = 0,
    max = 300
})

lia.config.add("ToolInterval", "toolInterval", 0, nil, {
    desc = "toolInterval",
    category = "protection",
    type = "Float",
    min = 0,
    max = 60
})

lia.config.add("DisableLuaRun", "disableLuaRun", false, nil, {
    desc = "disableLuaRunDesc",
    category = "protection",
    type = "Boolean",
})

lia.config.add("EquipDelay", "equipDelay", 0, nil, {
    desc = "equipDelayDesc",
    category = "items",
    type = "Float",
    min = 0,
    max = 30
})

lia.config.add("UnequipDelay", "unequipDelay", 0, nil, {
    desc = "unequipDelayDesc",
    category = "items",
    type = "Float",
    min = 0,
    max = 30
})

lia.config.add("DropDelay", "dropDelay", 0, nil, {
    desc = "dropDelayDesc",
    category = "items",
    type = "Float",
    min = 0,
    max = 30
})

lia.config.add("TakeDelay", "takeDelay", 0, nil, {
    desc = "takeDelayDesc",
    category = "items",
    type = "Float",
    min = 0,
    max = 30
})

lia.config.add("ItemGiveSpeed", "itemGiveSpeed", 6, nil, {
    desc = "itemGiveSpeedDesc",
    category = "items",
    type = "Int",
    min = 1,
    max = 60
})

lia.config.add("ItemGiveEnabled", "itemGiveEnabled", true, nil, {
    desc = "itemGiveEnabledDesc",
    category = "items",
    type = "Boolean",
})

lia.config.add("DisableCheaterActions", "disableCheaterActions", true, nil, {
    desc = "disableCheaterActionsDesc",
    category = "protection",
    type = "Boolean",
})

lia.config.add("LoseItemsonDeathNPC", "loseItemsOnNPCDeath", false, nil, {
    desc = "loseItemsOnNPCDeathDesc",
    category = "death",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathHuman", "loseItemsOnHumanDeath", false, nil, {
    desc = "loseItemsOnHumanDeathDesc",
    category = "death",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathWorld", "loseItemsOnWorldDeath", false, nil, {
    desc = "loseItemsOnWorldDeathDesc",
    category = "death",
    type = "Boolean"
})

lia.config.add("DeathPopupEnabled", "enableDeathPopup", true, nil, {
    desc = "enableDeathPopupDesc",
    category = "death",
    type = "Boolean"
})

lia.config.add("StaffHasGodMode", "staffGodMode", true, nil, {
    desc = "staffGodModeDesc",
    category = "categoryStaffSettings",
    type = "Boolean"
})

lia.config.add("ClassDisplay", "displayClassesOnCharacters", true, nil, {
    desc = "displayClassesOnCharactersDesc",
    category = "character",
    type = "Boolean",
})

local function refreshScoreboard()
    if CLIENT and lia.gui and IsValid(lia.gui.score) and lia.gui.score.ApplyConfig then lia.gui.score:ApplyConfig() end
end

lia.config.add("sbWidth", "sbWidth", 0.65, refreshScoreboard, {
    desc = "sbWidthDesc",
    category = "scoreboard",
    type = "Float",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbHeight", "sbHeight", 0.65, refreshScoreboard, {
    desc = "sbHeightDesc",
    category = "scoreboard",
    type = "Float",
    min = 0.2,
    max = 1.0
})

lia.config.add("sbDock", "sbDock", "center", refreshScoreboard, {
    desc = "sbDockDesc",
    category = "scoreboard",
    type = "Table",
    options = {"left", "center", "right"}
})

lia.config.add("ClassHeaders", "classHeaders", true, nil, {
    desc = "classHeadersDesc",
    category = "scoreboard",
    type = "Boolean"
})

lia.config.add("UseSolidBackground", "useSolidBackground", false, nil, {
    desc = "useSolidBackgroundDesc",
    category = "scoreboard",
    type = "Boolean"
})

lia.config.add("ClassLogo", "classLogo", false, nil, {
    desc = "classLogoDesc",
    category = "scoreboard",
    type = "Boolean"
})

lia.config.add("ScoreboardBackgroundColor", "scoreboardBackgroundColor", {
    r = 255,
    g = 100,
    b = 100,
    a = 255
}, nil, {
    desc = "scoreboardBackgroundColorDesc",
    category = "scoreboard",
    type = "Color"
})

lia.config.add("RecognitionEnabled", "recognitionEnabled", true, nil, {
    desc = "recognitionEnabledDesc",
    category = "recognition",
    type = "Boolean"
})

lia.config.add("FakeNamesEnabled", "fakeNamesEnabled", false, nil, {
    desc = "fakeNamesEnabledDesc",
    category = "recognition",
    type = "Boolean"
})

lia.config.add("vendorDefaultMoney", "vendorDefaultMoney", 500, nil, {
    desc = "vendorDefaultMoneyDesc",
    category = "vendor",
    type = "Int",
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
    category = "categoryMenu",
    type = "Table",
    options = CLIENT and getMenuTabNames() or {"you"}
})

lia.config.add("DoorLockTime", "doorLockTime", 0.5, nil, {
    desc = "doorLockTimeDesc",
    category = "moduleDoorsName",
    type = "Float",
    min = 0.05,
    max = 30.0
})

lia.config.add("DoorSellRatio", "doorSellRatio", 0.5, nil, {
    desc = "doorSellRatioDesc",
    category = "moduleDoorsName",
    type = "Float",
    min = 0.1,
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
                local ic = v and "lilia/checkbox.png" or "lilia/unchecked.png"
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

            for _, o in ipairs(lia.config.getOptions(key)) do
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
                local cat = opt.category or L("misc")
                local ln, ld = n:lower(), d:lower()
                local lk, lc = k:lower(), cat:lower()
                if filter == "" or ln:find(filter, 1, true) or ld:find(filter, 1, true) or lk:find(filter, 1, true) or lc:find(filter, 1, true) then
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
            name = "categoryConfiguration",
            drawFunc = function(parent) buildConfiguration(parent) end
        }
    end
end)