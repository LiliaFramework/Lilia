lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
-- Create a folder to store data in.
file.CreateDir("lilia")

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

    return path
end

-- Gets a piece of information for Lilia.
function lia.data.get(key, default, global, ignoreMap, refresh)
    -- If it exists in the cache, return the cached value so it is faster.
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
    -- If we provided a default, return that since we couldn't retrieve
    -- the data.
end
-- Deletes existing data in lilia framework.
function lia.data.delete(key, global, ignoreMap)
    -- Get the path to read from.
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
    -- Read the data from a local file.
    local contents = file.Read(path .. key .. ".txt", "DATA")

    if contents and contents ~= "" then
        file.Delete(path .. key .. ".txt")
        lia.data.stored[key] = nil

        return true
    else
        return false
    end
    -- If we provided a default, return that since we couldn't retrieve
    -- the data.
end

timer.Create("liaSaveData", 600, 0, function()
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end)
