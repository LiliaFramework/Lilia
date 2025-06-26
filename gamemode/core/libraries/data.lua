file.CreateDir("lilia")
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
if SERVER then
    function lia.data.set(key, value, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
        if not global then file.CreateDir("lilia/" .. folder .. "/") end
        file.CreateDir(path)
        file.Write(path .. key .. ".txt", pon.encode({value}))
        lia.data.stored[key] = value
        return path
    end

    function lia.data.delete(key, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
        local contents = file.Read(path .. key .. ".txt", "DATA")
        if contents and contents ~= "" then
            file.Delete(path .. key .. ".txt")
            lia.data.stored[key] = nil
            return true
        else
            return false
        end
    end

    timer.Create("liaSaveData", lia.config.get("DataSaveInterval", 600), 0, function()
        hook.Run("SaveData")
        hook.Run("PersistenceSave")
    end)
end

function lia.data.get(key, default, global, ignoreMap, refresh)
    if not refresh then
        local stored = lia.data.stored[key]
        if stored ~= nil then return stored end
    end

    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
    local contents = file.Read(path .. key .. ".txt", "DATA")
    if contents and contents ~= "" then
        local status, decoded = pcall(pon.decode, contents)
        if status and decoded then
            local value = decoded[1]
            lia.data.stored[key] = value
            if value ~= nil then
                return value
            else
                return default
            end
        else
            return default
        end
    else
        return default
    end
end
