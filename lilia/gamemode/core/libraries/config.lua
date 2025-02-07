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
        category = category or L("character"),
        noNetworking = data.noNetworking or false,
        callback = callback
    }
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
        local data = lia.data.get("config", nil, false, true)
        if data then
            for k, v in pairs(data) do
                lia.config.stored[k] = lia.config.stored[k] or {}
                lia.config.stored[k].value = v
            end
        end
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
        local data = {}
        for k, v in pairs(lia.config.getChangedValues()) do
            data[k] = v
        end

        lia.data.set("config", data, false, true)
    end
end

lia.config.add("MoneyModel", L("money_model"), "models/props_lab/box01a.mdl", nil, {
    desc = L("money_model_desc"),
    category = L("money_category"),
    noNetworking = false,
    schemaOnly = false,
    type = "Generic"
})

lia.config.add("MoneyLimit", L("money_limit"), 0, nil, {
    desc = L("money_limit_desc"),
    category = L("money_category"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 0,
    max = 1000000
})

lia.config.add("CurrencySymbol", L("currency_symbol"), "$", nil, {
    desc = L("currency_symbol_desc"),
    category = L("money_category"),
    noNetworking = false,
    schemaOnly = false,
    type = "Generic"
})

lia.config.add("CurrencySingularName", L("currency_singular_name"), "Dollar", nil, {
    desc = L("currency_singular_name_desc"),
    category = L("money_category"),
    noNetworking = false,
    schemaOnly = false,
    type = "Generic"
})

lia.config.add("CurrencyPluralName", L("currency_plural_name"), "Dollars", nil, {
    desc = L("currency_plural_name_desc"),
    category = L("money_category"),
    noNetworking = false,
    schemaOnly = false,
    type = "Generic"
})

lia.config.add("invW", L("inventory_width"), 6, nil, {
    desc = L("inventory_width_desc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 1,
    max = 20
})

lia.config.add("invH", L("inventory_height"), 4, nil, {
    desc = L("inventory_height_desc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 1,
    max = 20
})

lia.config.add("WalkSpeed", L("walkSpeed"), 130, function(newValue)
    for _, client in ipairs(player.GetAll()) do
        if IsValid(client) then client:SetWalkSpeed(newValue) end
    end
end, {
    desc = L("walkSpeedDesc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 50,
    max = 300
})

lia.config.add("RunSpeed", L("runSpeed"), 235, function(newValue)
    for _, client in ipairs(player.GetAll()) do
        if IsValid(client) then client:SetRunSpeed(newValue) end
    end
end, {
    desc = L("runSpeedDesc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 100,
    max = 500
})

lia.config.add("WalkRatio", L("walk_ratio"), 0.5, nil, {
    desc = L("walk_ratio_desc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Float",
    min = 0.1,
    max = 1.0,
    decimals = 2
})

lia.config.add("AllowExistNames", L("allow_duplicate_names"), true, nil, {
    desc = L("allow_duplicate_names_desc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})

lia.config.add("MaxCharacters", L("max_characters"), 5, nil, {
    desc = L("max_characters_desc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 1,
    max = 10
})

lia.config.add("MinDescLen", L("min_desc_length"), 16, nil, {
    desc = L("min_desc_length_desc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 10,
    max = 500
})

lia.config.add("SaveInterval", L("save_interval"), 300, nil, {
    desc = L("save_interval_desc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("DefMoney", L("default_money"), 0, nil, {
    desc = L("default_money_desc"),
    category = L("character"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", L("data_save_interval"), 600, nil, {
    desc = L("data_save_interval_desc"),
    category = L("data"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", L("character_data_save_interval"), 300, nil, {
    desc = L("character_data_save_interval_desc"),
    category = L("data"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", L("spawn_time"), 5, nil, {
    desc = L("spawn_time_desc"),
    category = L("death"),
    noNetworking = false,
    schemaOnly = false,
    type = "Float",
    min = 1,
    max = 60
})

lia.config.add("Font", L("font"), "Arial", function(newValue) hook.Run("LoadFonts", newValue) end, {
    desc = L("fontDesc"),
    category = L("visuals"),
    noNetworking = false,
    schemaOnly = false,
    type = "Generic"
})

lia.config.add("GenericFont", L("generic_font"), "Segoe UI", nil, {
    desc = L("generic_font_desc"),
    category = L("visuals"),
    noNetworking = false,
    schemaOnly = false,
    type = "Generic"
})

lia.config.add("MaxChatLength", L("max_chat_length"), 256, nil, {
    desc = L("max_chat_length_desc"),
    category = L("visuals"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 50,
    max = 1024
})

lia.config.add("SchemaYear", L("schema_year"), 2025, nil, {
    desc = L("schema_year_desc"),
    category = L("server"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 0,
    max = 999999
})

lia.config.add("AmericanDates", L("american_dates"), true, nil, {
    desc = L("american_dates_desc"),
    category = L("server"),
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})

lia.config.add("AmericanTimeStamp", L("american_timestamp"), true, nil, {
    desc = L("american_timestamp_desc"),
    category = L("server"),
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})

lia.config.add("AdminConsoleNetworkLogs", L("admin_console_network_logs"), false, nil, {
    desc = L("admin_console_network_logs_desc"),
    category = L("staff"),
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})

lia.config.add("Color", L("theme_color"), {
    r = 37,
    g = 116,
    b = 108
}, nil, {
    desc = L("theme_color_desc"),
    category = L("visuals"),
    noNetworking = false,
    schemaOnly = false,
    type = "Color"
})

lia.config.add("AutoDownloadWorkshop", L("auto_download_workshop"), true, nil, {
    desc = L("auto_download_workshop_desc"),
    category = L("server"),
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})