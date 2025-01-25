lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
function lia.config.add(key, name, value, callback, data)
    assert(isstring(key), "Expected config key to be string, got " .. type(key))
    assert(istable(data), "Expected config data to be a table, got " .. type(data))
    local t = type(value)
    local configType = t == "boolean" and "Boolean" or (t == "number" and (math.floor(value) == value and "Int" or "Float")) or (t == "table" and value.r and value.g and value.b and "Color") or "Generic"
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
        category = category or "General",
        noNetworking = data.noNetworking or false,
        global = not (data.schemaOnly or false),
        callback = callback
    }

    if data.isGlobal then lia.config[key] = lia.config.get(key, value) end
end

function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]
    if config then
        config.default = value
        if config.global then lia.config[key] = lia.config.get(key, value) end
    end
end

function lia.config.forceSet(key, value, noSave)
    local config = lia.config.stored[key]
    if config then
        config.value = value
        if config.global then lia.config[key] = value end
    end

    if noSave then lia.config.save() end
end

function lia.config.set(key, value)
    local config = lia.config.stored[key]
    if config then
        local oldValue = config.value
        config.value = value
        if config.global then lia.config[key] = value end
        if SERVER then
            if not config.noNetworking then netstream.Start(nil, "cfgSet", key, value) end
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
        local globals = lia.data.get("config", nil, true, true)
        local data = lia.data.get("config", nil, false, true)
        if globals then
            for k, v in pairs(globals) do
                lia.config.stored[k] = lia.config.stored[k] or {}
                lia.config.stored[k].value = v
            end
        end

        if data then
            for k, v in pairs(data) do
                lia.config.stored[k] = lia.config.stored[k] or {}
                lia.config.stored[k].value = v
            end
        end
    end

    for k, config in pairs(lia.config.stored) do
        if config.global then lia.config[k] = lia.config.get(k, config.default) end
    end

    hook.Run("InitializedConfig")
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
        netstream.Start(client, "cfgList", lia.config.getChangedValues())
    end

    function lia.config.save()
        local globals = {}
        local data = {}
        for k, v in pairs(lia.config.getChangedValues()) do
            if lia.config.stored[k].global then
                globals[k] = v
            else
                data[k] = v
            end
        end

        lia.data.set("config", globals, true, true)
        lia.data.set("config", data, false, true)
    end
end

lia.config.add("MoneyModel", "Money Model", "models/props_lab/box01a.mdl", nil, {
    desc = "Defines the model used for representing money in the game.",
    category = "Money",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Generic"
})

lia.config.add("MoneyLimit", "Money Limit", 0, nil, {
    desc = "Sets the limit of money a player can have [0 for infinite].",
    category = "Money",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 0,
    max = 1000000
})

lia.config.add("DefaultVendorMoney", "Default Vendor Money", 500, nil, {
    desc = "Sets the default amount of money a vendor starts with.",
    category = "Money",
    type = "Int",
    min = 0,
    max = 100000
})

lia.config.add("CurrencySymbol", "Currency Symbol", "$", nil, {
    desc = "Specifies the currency symbol used in the game.",
    category = "Money",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Generic"
})

lia.config.add("CurrencySingularName", "Currency Singular Name", "Dollar", nil, {
    desc = "Singular name of the in-game currency.",
    category = "Money",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Generic"
})

lia.config.add("CurrencyPluralName", "Currency Plural Name", "Dollars", nil, {
    desc = "Plural name of the in-game currency.",
    category = "Money",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Generic"
})

lia.config.add("invW", "Inventory Width", 6, nil, {
    desc = "Defines the width of the default inventory.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 20
})

lia.config.add("invH", "Inventory Height", 4, nil, {
    desc = "Defines the height of the default inventory.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 20
})

lia.config.add("WalkSpeed", "Walk Speed", 130, nil, {
    desc = "Controls how fast characters walk.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 50,
    max = 300
})

lia.config.add("RunSpeed", "Run Speed", 235, nil, {
    desc = "Controls how fast characters run.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 100,
    max = 500
})

lia.config.add("WalkRatio", "Walk Ratio", 0.5, nil, {
    desc = "Defines the walk speed ratio when holding the Alt key.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Float",
    min = 0.1,
    max = 1.0,
    decimals = 2
})

lia.config.add("AllowExistNames", "Allow Duplicate Names", true, nil, {
    desc = "Determines whether duplicate character names are allowed.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("MaxCharacters", "Max Characters", 5, nil, {
    desc = "Sets the maximum number of characters a player can have.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 10
})

lia.config.add("MinDescLen", "Minimum Description Length", 16, nil, {
    desc = "Minimum length required for a character's description.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 10,
    max = 500
})

lia.config.add("SaveInterval", "Save Interval", 300, nil, {
    desc = "Interval for character saves in seconds.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("DefMoney", "Default Money", 0, nil, {
    desc = "Specifies the default amount of money a player starts with.",
    category = "Character",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", "Data Save Interval", 600, nil, {
    desc = "Time interval between data saves.",
    category = "Data",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", "Character Data Save Interval", 300, nil, {
    desc = "Time interval between character data saves.",
    category = "Data",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", "Respawn Time", 5, nil, {
    desc = "Time to respawn after death.",
    category = "Death",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Float",
    min = 1,
    max = 60
})

lia.config.add("TimeToEnterVehicle", "Vehicle Entry Time", 1, nil, {
    desc = "Time [in seconds] required to enter a vehicle.",
    category = "Quality of Life",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Float",
    min = 0.5,
    max = 10
})

lia.config.add("CarEntryDelayEnabled", "Car Entry Delay Enabled", true, nil, {
    desc = "Determines if the car entry delay is applicable.",
    category = "Timers",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("Font", "Font", "Arial", nil, {
    desc = "Specifies the core font used for UI elements.",
    category = "Visuals",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Generic"
})

lia.config.add("GenericFont", "Generic Font", "Segoe UI", nil, {
    desc = "Specifies the secondary font used for UI elements.",
    category = "Visuals",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Generic"
})

lia.config.add("MaxChatLength", "Max Chat Length", 256, nil, {
    desc = "Sets the maximum length of chat messages.",
    category = "Visuals",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 50,
    max = 1024
})

lia.config.add("GamemodeName", "Gamemode Name", "A Lilia Gamemode", nil, {
    desc = "The gamemode that the server is running.",
    category = "Server",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Generic"
})

lia.config.add("SchemaYear", "Schema Year", 2025, nil, {
    desc = "Year of the gamemode's schema.",
    category = "Server",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Int",
    min = 0,
    max = 999999
})

lia.config.add("AmericanDates", "American Dates", true, nil, {
    desc = "Determines whether to use the American date format.",
    category = "Server",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("AmericanTimeStamp", "American Timestamp", true, nil, {
    desc = "Determines whether to use the American timestamp format.",
    category = "Server",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("AdminConsoleNetworkLogs", "Admin Console Network Logs", false, nil, {
    desc = "Specifies if the logging system should replicate to admins' consoles.",
    category = "Staff",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Boolean"
})

lia.config.add("ThemeColor", "Theme Color", {
    r = 37,
    g = 116,
    b = 108
}, nil, {
    desc = "Sets the theme color used throughout the gamemode.",
    category = "Visuals",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Color"
})
