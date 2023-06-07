lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
file.CreateDir("lilia")

-- @type function lia.data.set
-- @typeCommentStart
-- Sets a key-value pair in the data storage.
-- @typeCommentEnd
-- @classmod Data
-- @realm server
-- @usageStart
-- Usage:
--     lia.data.set(key, value, global, ignoreMap)
-- 
-- Parameters:
--     - key (string): The key for the data.
--     - value (any): The value to be stored.
--     - global (boolean): (Optional) Whether the data is global or specific to the current gamemode. Defaults to false.
--     - ignoreMap (boolean): (Optional) Whether to ignore the current map and store the data in the base folder. Defaults to false.
-- @usageEnd
function lia.data.set(key, value, global, ignoreMap)
    -- Get the base path to write to.
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")

    -- Create the schema folder if the data is not global.
    if not global then
        file.CreateDir("lilia/" .. folder .. "/")
    end

    -- If we're not ignoring the map, create a folder for the map.
    file.CreateDir(path)

    -- Write the data using pON encoding.
    file.Write(path .. key .. ".txt", pon.encode({value}))

    -- Cache the data value here.
    lia.data.stored[key] = value
    -- Return the path where the data was stored.

    return path
end

-- @type function lia.data.get
-- @typeCommentStart
-- Gets a piece of information from the data storage.
-- @typeCommentEnd
-- @classmod Data
-- @realm server
-- @usageStart
-- Usage:
--     lia.data.get(key, default, global, ignoreMap, refresh)
-- 
-- Parameters:
--     - key (string): The key for the data.
--     - default (any): The default value to be returned if the data is not found. Defaults to nil.
--     - global (boolean): (Optional) Whether the data is global or specific to the current gamemode. Defaults to false.
--     - ignoreMap (boolean): (Optional) Whether to ignore the current map and search in the base folder. Defaults to false.
--     - refresh (boolean): (Optional) Whether to force a refresh and bypass the cached value. Defaults to false.
-- @usageEnd
function lia.data.get(key, default, global, ignoreMap, refresh)
    -- If it exists in the cache, return the cached value to improve performance.
    if not refresh then
        local stored = lia.data.stored[key]
        if stored ~= nil then return stored end
    end

    -- Get the path to read from.
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
    -- Read the data from a local file.
    local contents = file.Read(path .. key .. ".txt", "DATA")

    if contents and contents ~= "" then
        -- Decode the contents and return the data.
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
    -- If a default value is provided, return it since the data couldn't be retrieved.
end

-- @type function lia.data.delete
-- @typeCommentStart
-- Deletes existing data from the data storage.
-- @typeCommentEnd
-- @classmod Data
-- @realm server
-- @usageStart
-- Usage:
--     lia.data.delete(key, global, ignoreMap)
-- 
-- Parameters:
--     - key (string): The key of the data to be deleted.
--     - global (boolean): (Optional) Whether the data is global or specific to the current gamemode. Defaults to false.
--     - ignoreMap (boolean): (Optional) Whether to ignore the current map and search in the base folder. Defaults to false.
-- @usageEnd
function lia.data.delete(key, global, ignoreMap)
    -- Get the path to read from.
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
    -- Read the data from a local file.
    local contents = file.Read(path .. key .. ".txt", "DATA")

    if contents and contents ~= "" then
        -- Delete the file and remove the cached value.
        file.Delete(path .. key .. ".txt")
        lia.data.stored[key] = nil

        return true
    else
        return false
    end
    -- If the data couldn't be found, return false.
end

-- Timer to save data periodically.
timer.Create("liaSaveData", 600, 0, function()
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end)