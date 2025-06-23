file.CreateDir("lilia")
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
if SERVER then
    --[[
    lia.data.set(key, value, global, ignoreMap)

      Description:
         Saves the provided value under the specified key to persistent storage.
         The data is written to a file whose path is constructed based on the folder, map, and flags.
         Also caches the value in lia.data.stored.

      Parameters:
         key (string) - The key under which the data is stored.
         value (any) - The value to store.
         global (boolean) - If true, uses a global path; otherwise, includes folder and map.
         ignoreMap (boolean) - If true, ignores the map directory.

    Returns:
        string - The path where the data was saved.

    Realm:
        Shared
   ]]
    function lia.data.set(key, value, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
        if not global then file.CreateDir("lilia/" .. folder .. "/") end
        file.CreateDir(path)
        file.Write(path .. key .. ".txt", pon.encode({value}))
        lia.data.stored[key] = value
        return path
    end

    --[[
    lia.data.delete(key, global, ignoreMap)

      Description:
         Deletes the stored data file corresponding to the specified key.
         Also removes the value from the cached storage.

      Parameters:
         key (string) - The key corresponding to the data to be deleted.
         global (boolean) - If true, uses a global path; otherwise, includes folder and map.
         ignoreMap (boolean) - If true, ignores the map directory.

    Returns:
        boolean - True if the file was deleted, false otherwise.

    Realm:
        Shared
   ]]
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

--[[
    lia.data.get(key, default, global, ignoreMap, refresh)

   Description:
      Retrieves the stored data for the specified key.
      If refresh is not set and data exists in cache, returns the cached data.
      Otherwise, reads from the file, decodes, and caches the value.

   Parameters:
      key (string) - The key corresponding to the data.
      default (any) - The default value to return if no data is found.
      global (boolean) - If true, uses a global path; otherwise, includes folder and map.
      ignoreMap (boolean) - If true, ignores the map directory.
      refresh (boolean) - If true, forces reading from file instead of cache.

    Returns:
        any - The stored value, or the default if not found.

    Realm:
        Shared
]]
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