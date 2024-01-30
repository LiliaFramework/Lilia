---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
file.CreateDir("lilia")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.data.set(key, value, global, ignoreMap)
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
    if not global then file.CreateDir("lilia/" .. folder .. "/") end
    file.CreateDir(path)
    file.Write(path .. key .. ".txt", pon.encode({value}))
    lia.data.stored[key] = value
    return path
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
timer.Create("liaSaveData", lia.config.DataSaveInterval, 0, function()
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
