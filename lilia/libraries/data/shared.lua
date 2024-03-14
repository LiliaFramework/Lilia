--- Helper library for reading/writing files to the data folder.
-- @module lia.data
file.CreateDir("lilia")
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
if SERVER then
    --- Populates a file in the `data/lilia` folder with some serialized data.
    -- @realm shared
    -- @string key Name of the file to save
    -- @param value Some sort of data to save
    -- @bool[opt=false] global Whether or not to write directly to the `data/lilia` folder, or the `data/lilia/schema` folder,
    -- where `schema` is the name of the current schema.
    -- @bool[opt=false] ignoreMap Whether or not to ignore the map and save in the schema folder, rather than
    -- `data/lilia/schema/map`, where `map` is the name of the current map.
    -- @treturn string The path where the file is saved
    function lia.data.set(key, value, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
        if not global then file.CreateDir("lilia/" .. folder .. "/") end
        file.CreateDir(path)
        file.Write(path .. key .. ".txt", pon.encode({value}))
        lia.data.stored[key] = value
        return path
    end

    --- Deletes the contents of a saved file in the `data/lilia` folder.
    -- @realm shared
    -- @string key Name of the file to delete
    -- @bool[opt=false] global Whether or not the data is in the `data/lilia` folder, or the `data/lilia/schema` folder,
    -- where `schema` is the name of the current schema.
    -- @bool[opt=false] ignoreMap Whether or not to ignore the map and delete from the schema folder, rather than
    -- `data/lilia/schema/map`, where `map` is the name of the current map.
    -- @treturn bool Whether or not the deletion has succeeded
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

    timer.Create("liaSaveData", lia.config.DataSaveInterval, 0, function()
        hook.Run("SaveData")
        hook.Run("PersistenceSave")
    end)
end

--- Retrieves the contents of a saved file in the `data/lilia` folder.
-- @realm shared
-- @string key Name of the file to load
-- @param default Value to return if the file could not be loaded successfully
-- @bool[opt=false] global Whether or not the data is in the `data/lilia` folder, or the `data/lilia/schema` folder,
-- where `schema` is the name of the current schema.
-- @bool[opt=false] ignoreMap Whether or not to ignore the map and load from the schema folder, rather than
-- `data/lilia/schema/map`, where `map` is the name of the current map.
-- @bool[opt=false] refresh Whether or not to skip the cache and forcefully load from disk.
-- @return Value associated with the key, or the default that was given if it doesn't exist
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
