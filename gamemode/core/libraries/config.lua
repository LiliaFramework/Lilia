lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
lia.config.isConverting = lia.config.isConverting or false
function lia.config.add(key, name, value, callback, data)
    assert(isstring(key), "Expected config key to be string, got " .. type(key))
    assert(istable(data), "Expected config data to be a table, got " .. type(data))
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
        lia.db.waitForTablesToLoad():next(function()
            local schema = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
            lia.db.select({"_key", "_value"}, "config", "_schema = " .. lia.db.convertDataType(schema)):next(function(res)
                local rows = res.results or {}
                local existing = {}
                if #rows == 0 then
                    local legacy = lia.data.get("config", nil)
                    if legacy then
                        for k, v in pairs(legacy) do
                            lia.config.stored[k] = lia.config.stored[k] or {}
                            lia.config.stored[k].value = v
                            existing[k] = true
                        end

                        lia.config.convertToDatabase(true, legacy)
                    end
                else
                    for _, row in ipairs(rows) do
                        local decoded = util.JSONToTable(row._value)
                        lia.config.stored[row._key] = lia.config.stored[row._key] or {}
                        lia.config.stored[row._key].value = decoded and decoded[1]
                        existing[row._key] = true
                    end
                end

                local inserts = {}
                for k, v in pairs(lia.config.stored) do
                    if not existing[k] then
                        inserts[#inserts + 1] = {
                            _schema = schema,
                            _key = k,
                            _value = {v.default}
                        }
                    end
                end

                local finalize = function() hook.Run("InitializedConfig") end
                if #inserts > 0 then
                    lia.db.bulkInsert("config", inserts):next(finalize)
                else
                    finalize()
                end
            end)
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
                _key = k,
                _value = {v}
            }
        end

        lia.db.waitForTablesToLoad():next(function()
            local schema = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
            local queries = {"DELETE FROM lia_config WHERE _schema = " .. lia.db.convertDataType(schema)}
            for _, row in ipairs(rows) do
                queries[#queries + 1] = "INSERT INTO lia_config (_schema,_key,_value) VALUES (" .. lia.db.convertDataType(schema) .. ", " .. lia.db.convertDataType(row._key) .. ", " .. lia.db.convertDataType(row._value) .. ")"
            end

            lia.db.transaction(queries)
        end)
    end

    function lia.config.convertToDatabase(changeMap, data)
        if lia.config.isConverting then return end
        lia.config.isConverting = true
        lia.bootstrap("Database", L("convertConfigToDatabase"))
        data = data or lia.data.get("config", nil) or {}
        local entryCount = table.Count(data)
        local schema = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local queries = {"DELETE FROM lia_config WHERE _schema = " .. lia.db.convertDataType(schema)}
        for k, v in pairs(data) do
            lia.config.stored[k] = lia.config.stored[k] or {}
            lia.config.stored[k].value = v
            queries[#queries + 1] = "INSERT INTO lia_config (_schema,_key,_value) VALUES (" .. lia.db.convertDataType(schema) .. ", " .. lia.db.convertDataType(k) .. ", " .. lia.db.convertDataType({v}) .. ")"
        end

        lia.db.waitForTablesToLoad():next(function()
            lia.db.transaction(queries):next(function()
                lia.config.isConverting = false
                lia.bootstrap("Database", L("convertConfigToDatabaseDone", entryCount))
                file.Delete("lilia/config.txt")
                if changeMap then game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n") end
            end)
        end)
    end
end

local function countLegacyConfigEntries()
    local data = lia.data.get("config", nil) or {}
    local total = istable(data) and table.Count(data) or 0
    return total, total
end

concommand.Add("lia_config_legacy_count", function(ply)
    if IsValid(ply) then return end
    local ported, total = countLegacyConfigEntries()
    print("[Lilia] " .. L("liaConfigLegacyCount", total, ported))
end)

lia.config.add("MoneyModel", "Money Model", "models/props_lab/box01a.mdl", nil, {
    desc = "Defines the model used for representing money in the game.",
    category = "Money",
    type = "Generic"
})

lia.config.add("MoneyLimit", "Money Limit", 0, nil, {
    desc = "Sets the limit of money a player can have [0 for infinite].",
    category = "Money",
    type = "Int",
    min = 0,
    max = 1000000
})

lia.config.add("CurrencySymbol", "Currency Symbol", "", function(newVal) lia.currency.symbol = newVal end, {
    desc = "Specifies the currency symbol used in the game.",
    category = "Money",
    type = "Generic"
})

lia.config.add("PKWorld", "PK World Deaths Count", false, nil, {
    desc = "When marked for Perma Kill, does world deaths count as perma killing?",
    category = "Character",
    type = "Boolean"
})

lia.config.add("CurrencySingularName", "Currency Singular Name", "Dollar", function(newVal) lia.currency.singular = newVal end, {
    desc = "Singular name of the in-game currency.",
    category = "Money",
    type = "Generic"
})

lia.config.add("CurrencyPluralName", "Currency Plural Name", "Dollars", function(newVal) lia.currency.plural = newVal end, {
    desc = "Plural name of the in-game currency.",
    category = "Money",
    type = "Generic"
})

lia.config.add("WalkSpeed", "Walk Speed", 130, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetWalkSpeed(newValue)
    end
end, {
    desc = "Controls how fast characters walk.",
    category = "Character",
    type = "Int",
    min = 50,
    max = 300
})

lia.config.add("RunSpeed", "Run Speed", 275, function(_, newValue)
    for _, client in player.Iterator() do
        client:SetRunSpeed(newValue)
    end
end, {
    desc = "Controls how fast characters run.",
    category = "Character",
    type = "Int",
    min = 100,
    max = 500
})

lia.config.add("WalkRatio", "Walk Ratio", 0.5, nil, {
    desc = "Defines the walk speed ratio when holding the Alt key.",
    category = "Character",
    type = "Float",
    min = 0.1,
    max = 1.0,
    decimals = 2
})

lia.config.add("AllowExistNames", "Allow Duplicate Names", true, nil, {
    desc = "Determines whether duplicate character names are allowed.",
    category = "Character",
    type = "Boolean"
})

lia.config.add("MaxCharacters", "Max Characters", 5, nil, {
    desc = "Sets the maximum number of characters a player can have.",
    category = "Character",
    type = "Int",
    min = 1,
    max = 10
})

lia.config.add("AllowPMs", "Allow Private Messages", true, nil, {
    desc = "Determines whether private messages are allowed.",
    category = "Chat",
    type = "Boolean"
})

lia.config.add("MinDescLen", "Minimum Description Length", 16, nil, {
    desc = "Minimum length required for a character's description.",
    category = "Character",
    type = "Int",
    min = 10,
    max = 500
})

lia.config.add("SaveInterval", "Save Interval", 300, nil, {
    desc = "Interval for character saves in seconds.",
    category = "Character",
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("DefMoney", "Default Money", 0, nil, {
    desc = "Specifies the default amount of money a player starts with.",
    category = "Character",
    type = "Int",
    min = 0,
    max = 10000
})

lia.config.add("DataSaveInterval", "Data Save Interval", 600, nil, {
    desc = "Time interval between data saves.",
    category = "Data",
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("CharacterDataSaveInterval", "Character Data Save Interval", 300, nil, {
    desc = "Time interval between character data saves.",
    category = "Data",
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("SpawnTime", "Respawn Time", 5, nil, {
    desc = "Time to respawn after death.",
    category = "Death",
    type = "Float",
    min = 1,
    max = 60
})

lia.config.add("TimeToEnterVehicle", "Vehicle Entry Time", 1, nil, {
    desc = "Time [in seconds] required to enter a vehicle.",
    category = "Quality of Life",
    type = "Float",
    min = 0.5,
    max = 10
})

lia.config.add("CarEntryDelayEnabled", "Car Entry Delay Enabled", true, nil, {
    desc = "Determines if the car entry delay is applicable.",
    category = "Timers",
    type = "Boolean"
})

lia.config.add("MaxChatLength", "Max Chat Length", 256, nil, {
    desc = "Sets the maximum length of chat messages.",
    category = "Visuals",
    type = "Int",
    min = 50,
    max = 1024
})

lia.config.add("SchemaYear", "Schema Year", 2025, nil, {
    desc = "Year of the gamemode's schema.",
    category = "General",
    type = "Int",
    min = 0,
    max = 999999
})

lia.config.add("AmericanDates", "American Dates", true, nil, {
    desc = "Determines whether to use the American date format.",
    category = "General",
    type = "Boolean"
})

lia.config.add("AmericanTimeStamp", "American Timestamp", true, nil, {
    desc = "Determines whether to use the American timestamp format.",
    category = "General",
    type = "Boolean"
})

lia.config.add("AdminConsoleNetworkLogs", "Admin Console Network Logs", true, nil, {
    desc = "Specifies if the logging system should replicate to super admins' consoles.",
    category = "Staff",
    type = "Boolean"
})

lia.config.add("Color", "Theme Color", {
    r = 37,
    g = 116,
    b = 108
}, nil, {
    desc = "Sets the theme color used throughout the gamemode.",
    category = "Visuals",
    type = "Color"
})

lia.config.add("CharMenuBGInputDisabled", "Character Menu BG Input Disabled", true, nil, {
    desc = "Whether background input is disabled durinag character menu use",
    category = "Main Menu",
    type = "Boolean"
})

lia.config.add("AllowKeybindEditing", "Allow Keybind Editing", true, nil, {
    desc = "Whether keybind editing is allowed",
    category = "General",
    type = "Boolean"
})

lia.config.add("CrosshairEnabled", "Enable Crosshair", false, nil, {
    desc = "Enables the crosshair",
    category = "Visuals",
    type = "Boolean"
})

lia.config.add("BarsDisabled", "Disable Bars", false, nil, {
    desc = "Disables bars",
    category = "Visuals",
    type = "Boolean"
})

lia.config.add("AutoWeaponItemGeneration", "Auto Weapon-to-Item Generation", true, nil, {
    desc = "Enables automatic conversion of dropped weapons into inventory items",
    category = "General",
    type = "Boolean"
})

lia.config.add("AmmoDrawEnabled", "Enable Ammo Display", true, nil, {
    desc = "Enables ammo display",
    category = "Visuals",
    type = "Boolean"
})

lia.config.add("IsVoiceEnabled", "Voice Chat Enabled", true, function(_, newValue) hook.Run("VoiceToggled", newValue) end, {
    desc = "Whether or not voice chat is enabled",
    category = "General",
    type = "Boolean"
})

lia.config.add("SalaryInterval", "Salary Interval", 300, function()
    for _, client in player.Iterator() do
        hook.Run("CreateSalaryTimer", client)
    end
end, {
    desc = "Interval in seconds between salary payouts.",
    category = "Salary",
    type = "Float",
    min = 60,
    max = 3600
})

lia.config.add("SalaryThreshold", "Salary Threshold", 0, nil, {
    desc = "Money threshold above which salaries will not be given.",
    category = "Salary",
    type = "Int",
    min = 0,
    max = 100000
})

lia.config.add("ThirdPersonEnabled", "Enable Third-Person View", true, nil, {
    desc = "Allows players to toggle third-person view on or off.",
    category = "Third Person",
    type = "Boolean"
})

lia.config.add("MaxThirdPersonDistance", "Maximum Third-Person Distance", 100, nil, {
    desc = "The maximum allowable camera distance in third-person view.",
    category = "Third Person",
    type = "Int"
})

lia.config.add("WallPeek", "Wall Peek", true, nil, {
    desc = "Limits third‑person wall peeking by hiding players outside view or obstructed.",
    category = "Rendering",
    type = "Boolean"
})

lia.config.add("MaxThirdPersonHorizontal", "Maximum Third-Person Horizontal Offset", 30, nil, {
    desc = "The maximum allowable horizontal offset for third-person view.",
    category = "Third Person",
    type = "Int"
})

lia.config.add("MaxThirdPersonHeight", "Maximum Third-Person Height Offset", 30, nil, {
    desc = "The maximum allowable vertical offset for third-person view.",
    category = "Third Person",
    type = "Int"
})

lia.config.add("MaxViewDistance", "Maximum View Distance", 5000, nil, {
    desc = "The maximum distance (in units) at which players are visible.",
    category = "Quality of Life",
    type = "Int",
    min = 1000,
    max = 5000,
})

lia.config.add("AutoDownloadWorkshop", "Auto Download Workshop Content", true, nil, {
    desc = "Automatically download both collection and module-defined WorkshopContent.",
    category = "Workshop",
    type = "Boolean"
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
    desc = "Select the Derma UI skin to use",
    category = "Visuals",
    type = "Table",
    options = CLIENT and getDermaSkins() or {"Lilia Skin"}
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
                    local t = "ConfigChange_" .. key .. "_" .. os.time()
                    timer.Create(t, 0.5, 1, function()
                        net.Start("cfgSet")
                        net.WriteString(key)
                        net.WriteString(name)
                        net.WriteType(m:GetColor())
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
        local search = vgui.Create("DTextEntry", parent)
        search:Dock(TOP)
        search:SetTall(30)
        search:DockMargin(5, 5, 5, 5)
        search:SetPlaceholderText(L("searchConfigs"))
        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:Dock(FILL)
        local function populate(filter)
            scroll:Clear()
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
                    local cat = opt.category or "Miscellaneous"
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
                local cat = vgui.Create("DCollapsibleCategory", scroll)
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

        search.OnTextChanged = function() populate(search:GetValue():lower()) end
        populate("")
    end

    if hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false then
        pages[#pages + 1] = {
            name = "Configuration",
            drawFunc = function(parent) buildConfiguration(parent) end
        }
    end
end)
