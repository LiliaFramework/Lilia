lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}

function lia.config.add(key, value, desc, callback, data, noNetworking, schemaOnly)
    assert(isstring(key), "expected config key to be string, got " .. type(key))
    local oldConfig = lia.config.stored[key]

    lia.config.stored[key] = {
        data = data,
        value = oldConfig and oldConfig.value or value,
        default = value,
        desc = desc,
        noNetworking = noNetworking,
        global = not schemaOnly,
        callback = callback
    }
end

function lia.config.setDefault(key, value)
    local config = lia.config.stored[key]

    if config then
        config.default = value
    end
end

function lia.config.forceSet(key, value, noSave)
    local config = lia.config.stored[key]

    if config then
        config.value = value
    end

    if noSave then
        lia.config.save()
    end
end

function lia.config.set(key, value)
    local config = lia.config.stored[key]

    if config then
        local oldValue = value
        config.value = value

        if SERVER then
            if not config.noNetworking then
                netstream.Start(nil, "cfgSet", key, value)
            end

            if config.callback then
                config.callback(oldValue, value)
            end

            lia.config.save()
        end
    end
end

function lia.config.get(key, default)
    local config = lia.config.stored[key]

    if config then
        if config.value ~= nil then
            -- if the value is a table with rgb values
            if istable(config.value) and config.value.r and config.value.g and config.value.b then
                config.value = Color(config.value.r, config.value.g, config.value.b) -- convert it to a Color table
            end

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

    lia.util.include("lilia/gamemode/config/sh_clientconfig.lua")
    lia.util.include("lilia/gamemode/config/sh_generalconfig.lua")
    lia.util.include("lilia/gamemode/config/sh_serverconfig.lua")
    hook.Run("InitializedConfig")
end

if SERVER then
    function lia.config.getChangedValues()
        local data = {}

        for k, v in pairs(lia.config.stored) do
            if v.default ~= v.value then
                data[k] = v.value
            end
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

        -- Global and schema data set respectively.
        lia.data.set("config", globals, true, true)
        lia.data.set("config", data, false, true)
    end

    netstream.Hook("cfgSet", function(client, key, value)
        if client:IsSuperAdmin() and type(lia.config.stored[key].default) == type(value) and hook.Run("CanPlayerModifyConfig", client, key) ~= false then
            lia.config.set(key, value)

            if type(value) == "table" then
                local value2 = "["
                local count = table.Count(value)
                local i = 1

                for _, v in SortedPairs(value) do
                    value2 = value2 .. v .. (i == count and "]" or ", ")
                    i = i + 1
                end

                value = value2
            end

            lia.util.notifyLocalized("cfgSet", nil, client:Name(), key, tostring(value))
        end
    end)
else
    netstream.Hook("cfgList", function(data)
        for k, v in pairs(data) do
            if lia.config.stored[k] then
                lia.config.stored[k].value = v
            end
        end

        hook.Run("InitializedConfig", data)
    end)

    netstream.Hook("cfgSet", function(key, value)
        local config = lia.config.stored[key]

        if config then
            if config.callback then
                config.callback(config.value, value)
            end

            config.value = value
            local properties = lia.gui.properties

            if IsValid(properties) then
                local row = properties:GetCategory(L(config.data and config.data.category or "misc")):GetRow(key)

                if IsValid(row) then
                    if istable(value) and value.r and value.g and value.b then
                        value = Vector(value.r / 255, value.g / 255, value.b / 255)
                    end

                    row:SetValue(value)
                end
            end
        end
    end)
end