lia.option = lia.option or {}
lia.option.stored = lia.option.stored or {}
function lia.option.add(key, name, desc, default, callback, data)
    assert(isstring(key), "Expected option key to be a string, got " .. type(key))
    assert(isstring(name), "Expected option name to be a string, got " .. type(name))
    assert(istable(data), "Expected option data to be a table, got " .. type(data))
    local t = type(default)
    local optionType = t == "boolean" and "Boolean" or t == "number" and (math.floor(default) == default and "Int" or "Float") or (t == "table" and default.r and default.g and default.b and "Color") or "Generic"
    if optionType == "Int" or optionType == "Float" then
        data.min = data.min or (optionType == "Int" and math.floor(default / 2) or default / 2)
        data.max = data.max or (optionType == "Int" and math.floor(default * 2) or default * 2)
    end

    local oldOption = lia.option.stored[key]
    local savedValue = oldOption and oldOption.value or default
    lia.option.stored[key] = {
        name = name,
        desc = desc,
        data = data,
        value = savedValue,
        default = default,
        callback = callback,
        type = optionType,
    }
end

function lia.option.set(key, value)
    local option = lia.option.stored[key]
    if option then
        local oldValue = option.value
        option.value = value
        if option.callback then option.callback(oldValue, value) end
        lia.option.save()
    end
end

function lia.option.get(key, default)
    local option = lia.option.stored[key]
    if option then
        if option.value ~= nil then
            return option.value
        elseif option.default ~= nil then
            return option.default
        end
    end
    return default
end

function lia.option.save()
    local dirPath = "lilia/options/" .. engine.ActiveGamemode()
    file.CreateDir(dirPath)
    local ipWithoutPort = string.Explode(":", game.GetIPAddress())[1]
    local formattedIP = ipWithoutPort:gsub("%.", "_")
    local saveLocation = dirPath .. "/" .. formattedIP .. ".txt"
    local data = {}
    for k, v in pairs(lia.option.stored) do
        if v and v.value ~= nil then data[k] = v.value end
    end

    local jsonData = util.TableToJSON(data, true)
    if jsonData then file.Write(saveLocation, jsonData) end
end

function lia.option.load()
    local dirPath = "lilia/options/" .. engine.ActiveGamemode()
    file.CreateDir(dirPath)
    local ipWithoutPort = string.Explode(":", game.GetIPAddress())[1]
    local formattedIP = ipWithoutPort:gsub("%.", "_")
    local loadLocation = dirPath .. "/" .. formattedIP .. ".txt"
    local data = file.Read(loadLocation, "DATA")
    if data then
        local savedOptions = util.JSONToTable(data)
        for k, v in pairs(savedOptions) do
            if lia.option.stored[k] then lia.option.stored[k].value = v end
        end
    else
        lia.option.save()
    end

    hook.Run("InitializedOptions")
end