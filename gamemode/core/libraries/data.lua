--[[
    Data Library

    Data persistence, serialization, and management system for the Lilia framework.
]]

--[[
    Overview:
    The data library provides comprehensive functionality for data persistence, serialization,
    and management within the Lilia framework. It handles encoding and decoding of complex
    data types including vectors, angles, colors, and nested tables for database storage.
    The library manages both general data storage with gamemode and map-specific scoping,
    as well as entity persistence for maintaining spawned entities across server restarts.
    It includes automatic serialization/deserialization, database integration, and caching
    mechanisms to ensure efficient data access and storage operations.
]]
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
--[[
    Purpose: Converts complex data types (vectors, angles, colors, tables) into database-storable formats
    When Called: Automatically called during data serialization before database storage
    Parameters: value (any) - The value to encode (vector, angle, color table, or regular table)
    Returns: table or any - Encoded representation suitable for JSON serialization
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Encode a vector
    local encoded = lia.data.encodetable(Vector(100, 200, 300))
    -- Returns: {100, 200, 300}
    ```

    Medium Complexity:
    ```lua
    -- Medium: Encode a color with alpha
    local color = Color(255, 128, 64, 200)
    local encoded = lia.data.encodetable(color)
    -- Returns: {255, 128, 64, 200}
    ```

    High Complexity:
    ```lua
    -- High: Encode nested table with mixed data types
    local complexData = {
        position = Vector(0, 0, 0),
        rotation = Angle(0, 90, 0),
        color = Color(255, 0, 0),
        settings = {enabled = true, count = 5}
    }
    local encoded = lia.data.encodetable(complexData)
    -- Returns: {position = {0, 0, 0}, rotation = {0, 90, 0}, color = {255, 0, 0, 255}, settings = {enabled = true, count = 5}}
    ```
]]
function lia.data.encodetable(value)
    if isvector(value) then
        return {value.x, value.y, value.z}
    elseif isangle(value) then
        return {value.p, value.y, value.r}
    elseif istable(value) and value.r ~= nil and value.g ~= nil and value.b ~= nil then
        return {value.r, value.g, value.b, value.a or 255}
    elseif istable(value) then
        local t = {}
        for k, v in pairs(value) do
            t[k] = lia.data.encodetable(v)
        end
        return t
    end
    return value
end

local function _decodeVector(data)
    if isvector(data) then return data end
    if isstring(data) and data:lower():match("^models/") then return data end
    if istable(data) then
        if data.x then
            local x, y, z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
            if x and y and z then return Vector(x, y, z) end
        end

        if data.p and data.y and data.r then
            local x, y, z = tonumber(data.p), tonumber(data.y), tonumber(data.r)
            if x and y and z then return Vector(x, y, z) end
        end

        if data[1] and data[2] and data[3] then
            local x, y, z = tonumber(data[1]), tonumber(data[2]), tonumber(data[3])
            if x and y and z then return Vector(x, y, z) end
        end
    elseif isstring(data) then
        local x, y, z = data:match("%[([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%]")
        if not x then x, y, z = data:match("%[([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%]") end
        if not x then x, y, z = data:match("Vector%(([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%)") end
        if not x then x, y, z = data:match("^%s*([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%s*$") end
        if not x then
            local nums = {}
            for num in string.gmatch(data, "[-%d%.]+") do
                nums[#nums + 1] = num
                if #nums >= 3 then break end
            end

            if #nums >= 3 then x, y, z = nums[1], nums[2], nums[3] end
        end

        if x then return Vector(tonumber(x), tonumber(y), tonumber(z)) end
        local tbl = util.JSONToTable(data)
        if istable(tbl) and tbl[1] and tbl[2] and tbl[3] then
            local tx, ty, tz = tonumber(tbl[1]), tonumber(tbl[2]), tonumber(tbl[3])
            if tx and ty and tz then return Vector(tx, ty, tz) end
        end
    else
        local s = tostring(data)
        if s and s ~= "" then
            local x, y, z = s:match("%[([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%]")
            if not x then x, y, z = s:match("%[([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%]") end
            if not x then x, y, z = s:match("Vector%(([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%)") end
            if not x then x, y, z = s:match("^%s*([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%s*$") end
            if not x then
                local nums = {}
                for num in string.gmatch(s, "[-%d%.]+") do
                    nums[#nums + 1] = num
                    if #nums >= 3 then break end
                end

                if #nums >= 3 then x, y, z = nums[1], nums[2], nums[3] end
            end

            if x then return Vector(tonumber(x), tonumber(y), tonumber(z)) end
        end
    end
    return data
end

local function _decodeAngle(data)
    if isangle(data) then return data end
    if isstring(data) and data:lower():match("^models/") then return data end
    if istable(data) then
        if data.p or data.y or data.r then
            local p, y, r = tonumber(data.p or 0), tonumber(data.y or 0), tonumber(data.r or 0)
            if p and y and r then return Angle(p, y, r) end
        end

        if data[1] and data[2] and data[3] then
            local p, y, r = tonumber(data[1]), tonumber(data[2]), tonumber(data[3])
            if p and y and r then return Angle(p, y, r) end
        end
    elseif isstring(data) then
        local p, y, r = data:match("%{([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%}")
        if not p then p, y, r = data:match("%{([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%}") end
        if not p then p, y, r = data:match("Angle%(([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%)") end
        if not p then p, y, r = data:match("^%s*([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%s*$") end
        if not p then
            local nums = {}
            for num in string.gmatch(data, "[-%d%.]+") do
                nums[#nums + 1] = num
                if #nums >= 3 then break end
            end

            if #nums >= 3 then p, y, r = nums[1], nums[2], nums[3] end
        end

        if not p then
            local tbl = util.JSONToTable(data)
            if istable(tbl) and tbl[1] and tbl[2] and tbl[3] then
                local p_num, y_num, r_num = tonumber(tbl[1]), tonumber(tbl[2]), tonumber(tbl[3])
                if p_num and y_num and r_num then p, y, r = p_num, y_num, r_num end
            end
        end

        if p then return Angle(tonumber(p), tonumber(y), tonumber(r)) end
    else
        local s = tostring(data)
        if s and s ~= "" then
            local p, y, r = s:match("%{([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%}")
            if not p then p, y, r = s:match("%{([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%}") end
            if not p then p, y, r = s:match("Angle%(([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%)") end
            if not p then p, y, r = s:match("^%s*([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%s*$") end
            if not p then
                local nums = {}
                for num in string.gmatch(s, "[-%d%.]+") do
                    nums[#nums + 1] = num
                    if #nums >= 3 then break end
                end

                if #nums >= 3 then p, y, r = nums[1], nums[2], nums[3] end
            end

            if p then return Angle(tonumber(p), tonumber(y), tonumber(r)) end
        end
    end
    return data
end

local function deepDecode(value)
    if istable(value) then
        local t = {}
        for k, v in pairs(value) do
            t[k] = deepDecode(v)
        end

        value = t
    end

    value = _decodeAngle(value)
    value = _decodeVector(value)
    return value
end

--[[
    Purpose: Converts encoded data back to original complex data types (vectors, angles, colors)
    When Called: Automatically called during data deserialization after database retrieval
    Parameters: value (any) - The encoded value to decode (table, string, or raw data)
    Returns: any - Decoded value with proper data types restored
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Decode a vector from encoded format
    local decoded = lia.data.decode({100, 200, 300})
    -- Returns: Vector(100, 200, 300)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Decode an angle from encoded format
    local encodedAngle = {0, 90, 0}
    local decoded = lia.data.decode(encodedAngle)
    -- Returns: Angle(0, 90, 0)
    ```

    High Complexity:
    ```lua
    -- High: Decode complex nested data structure
    local encodedData = {
        position = {100, 200, 300},
        rotation = {0, 90, 0},
        color = {255, 0, 0, 255},
        settings = {enabled = true, count = 5}
    }
    local decoded = lia.data.decode(encodedData)
    -- Returns: {position = Vector(100, 200, 300), rotation = Angle(0, 90, 0), color = Color(255, 0, 0, 255), settings = {enabled = true, count = 5}}
    ```
]]
function lia.data.decode(value)
    return deepDecode(value)
end

--[[
    Purpose: Converts any data structure into a JSON string suitable for database storage
    When Called: Called before storing data in the database to ensure proper serialization
    Parameters: value (any) - The data to serialize (tables, vectors, angles, colors, etc.)
    Returns: string - JSON string representation of the encoded data
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Serialize a basic table
    local serialized = lia.data.serialize({name = "test", value = 42})
    -- Returns: '{"name":"test","value":42}'
    ```

    Medium Complexity:
    ```lua
    -- Medium: Serialize a vector
    local serialized = lia.data.serialize(Vector(100, 200, 300))
    -- Returns: '{"value":[100,200,300]}'
    ```

    High Complexity:
    ```lua
    -- High: Serialize complex nested data with mixed types
    local complexData = {
        position = Vector(0, 0, 0),
        rotation = Angle(0, 90, 0),
        color = Color(255, 0, 0),
        settings = {enabled = true, count = 5}
    }
    local serialized = lia.data.serialize(complexData)
    -- Returns: JSON string with all data properly encoded
    ```
]]
function lia.data.serialize(value)
    local encoded = lia.data.encodetable(value) or {}
    if not istable(encoded) then
        encoded = {
            value = encoded
        }
    end
    return util.TableToJSON(encoded)
end

--[[
    Purpose: Converts serialized data (JSON strings or tables) back to original data structures
    When Called: Called after retrieving data from database to restore original data types
    Parameters: raw (string|table) - Serialized data from database (JSON string or table)
    Returns: any - Deserialized data with proper types restored, or nil if invalid
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Deserialize a JSON string
    local deserialized = lia.data.deserialize('{"name":"test","value":42}')
    -- Returns: {name = "test", value = 42}
    ```

    Medium Complexity:
    ```lua
    -- Medium: Deserialize encoded vector data
    local jsonData = '{"value":[100,200,300]}'
    local deserialized = lia.data.deserialize(jsonData)
    -- Returns: Vector(100, 200, 300)
    ```

    High Complexity:
    ```lua
    -- High: Deserialize complex data with fallback handling
    local complexJson = '{"position":[0,0,0],"rotation":[0,90,0],"color":[255,0,0,255],"settings":{"enabled":true,"count":5}}'
    local deserialized = lia.data.deserialize(complexJson)
    -- Returns: {position = Vector(0, 0, 0), rotation = Angle(0, 90, 0), color = Color(255, 0, 0, 255), settings = {enabled = true, count = 5}}
    ```
]]
function lia.data.deserialize(raw)
    if not raw then return nil end
    local decoded
    if istable(raw) then
        decoded = raw
    elseif isstring(raw) then
        decoded = util.JSONToTable(raw)
        if not decoded then
            local ok, ponDecoded = pcall(pon.decode, raw)
            if ok then decoded = ponDecoded end
        end
    else
        decoded = raw
    end

    if decoded == nil then return nil end
    if istable(decoded) and decoded.value ~= nil and table.Count(decoded) == 1 then return lia.data.decode(decoded.value) end
    return lia.data.decode(decoded)
end

--[[
    Purpose: Specifically decodes vector data from various formats (JSON, strings, tables)
    When Called: Called when specifically needing to decode vector data from database or serialized format
    Parameters: raw (any) - Raw data that should contain vector information
    Returns: Vector or any - Decoded Vector object, or original data if not vector format
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Decode vector from array format
    local vector = lia.data.decodeVector({100, 200, 300})
    -- Returns: Vector(100, 200, 300)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Decode vector from JSON string
    local jsonString = '[100,200,300]'
    local vector = lia.data.decodeVector(jsonString)
    -- Returns: Vector(100, 200, 300)
    ```

    High Complexity:
    ```lua
    -- High: Decode vector with multiple format fallbacks
    local vectorData = "Vector(100, 200, 300)"
    local vector = lia.data.decodeVector(vectorData)
    -- Returns: Vector(100, 200, 300) - handles string parsing
    ```
]]
function lia.data.decodeVector(raw)
    if not raw then return nil end
    local direct = _decodeVector(raw)
    if isvector(direct) then return direct end
    local decoded
    if isstring(raw) then
        decoded = util.JSONToTable(raw)
        if not decoded then
            local ok, ponDecoded = pcall(pon.decode, raw)
            if ok then decoded = ponDecoded end
        end
    else
        decoded = raw
    end

    if decoded == nil then decoded = raw end
    return _decodeVector(decoded)
end

--[[
    Purpose: Specifically decodes angle data from various formats (JSON, strings, tables)
    When Called: Called when specifically needing to decode angle data from database or serialized format
    Parameters: raw (any) - Raw data that should contain angle information
    Returns: Angle or any - Decoded Angle object, or original data if not angle format
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Decode angle from array format
    local angle = lia.data.decodeAngle({0, 90, 0})
    -- Returns: Angle(0, 90, 0)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Decode angle from JSON string
    local jsonString = '[0,90,0]'
    local angle = lia.data.decodeAngle(jsonString)
    -- Returns: Angle(0, 90, 0)
    ```

    High Complexity:
    ```lua
    -- High: Decode angle with multiple format fallbacks
    local angleData = "Angle(0, 90, 0)"
    local angle = lia.data.decodeAngle(angleData)
    -- Returns: Angle(0, 90, 0) - handles string parsing
    ```
]]
function lia.data.decodeAngle(raw)
    if not raw then return nil end
    local direct = _decodeAngle(raw)
    if isangle(direct) then return direct end
    local decoded
    if isstring(raw) then
        decoded = util.JSONToTable(raw)
        if not decoded then
            local ok, ponDecoded = pcall(pon.decode, raw)
            if ok then decoded = ponDecoded end
        end
    else
        decoded = raw
    end

    if decoded == nil then decoded = raw end
    return _decodeAngle(decoded)
end

local function buildCondition(gamemode, map)
    local cond = gamemode and "gamemode = " .. lia.db.convertDataType(gamemode) or "gamemode IS NULL"
    cond = cond .. " AND " .. (map and "map = " .. lia.db.convertDataType(map) or "map IS NULL")
    return cond
end

--[[
    Purpose: Stores data in the database with gamemode and map-specific scoping
    When Called: Called when storing persistent data that should survive server restarts
    Parameters: key (string) - Unique identifier for the data, value (any) - Data to store, global (boolean, optional) - Store globally across all gamemodes/maps, ignoreMap (boolean, optional) - Store for all maps in current gamemode
    Returns: string - Database path where data was stored
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Store basic data for current gamemode and map
    lia.data.set("playerCount", 25)
    -- Stores data scoped to current gamemode and map
    ```

    Medium Complexity:
    ```lua
    -- Medium: Store data globally across all gamemodes and maps
    lia.data.set("serverVersion", "1.0.0", true)
    -- Stores data globally, accessible from any gamemode/map
    ```

    High Complexity:
    ```lua
    -- High: Store complex data with custom scoping
    local playerData = {
        position = Vector(100, 200, 300),
        inventory = {weapon = "pistol", ammo = 50},
        settings = {volume = 0.8, graphics = "high"}
    }
    lia.data.set("player_" .. player:SteamID64(), playerData, false, true)
    -- Stores player data for current gamemode but all maps
    ```
]]
function lia.data.set(key, value, global, ignoreMap)
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = ignoreMap and NULL or game.GetMap()
    if global then
        gamemode = NULL
        map = NULL
    else
        if gamemode == nil then gamemode = NULL end
        if map == nil then map = NULL end
    end

    lia.data.stored[key] = value
    lia.db.waitForTablesToLoad():next(function()
        local row = {
            gamemode = gamemode,
            map = map,
            data = lia.data.serialize(lia.data.stored)
        }
        return lia.db.upsert(row, "data")
    end):next(function() hook.Run("OnDataSet", key, value, gamemode, map) end)

    local path = "lilia/"
    if gamemode and gamemode ~= NULL then path = path .. gamemode .. "/" end
    if map and map ~= NULL then path = path .. map .. "/" end
    return path
end

--[[
    Purpose: Removes data from the database with gamemode and map-specific scoping
    When Called: Called when removing persistent data that should no longer be stored
    Parameters: key (string) - Unique identifier for the data to delete, global (boolean, optional) - Delete from global scope, ignoreMap (boolean, optional) - Delete from all maps in current gamemode
    Returns: boolean - Always returns true
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Delete data for current gamemode and map
    lia.data.delete("playerCount")
    -- Removes data scoped to current gamemode and map
    ```

    Medium Complexity:
    ```lua
    -- Medium: Delete data globally across all gamemodes and maps
    lia.data.delete("serverVersion", true)
    -- Removes data from global scope
    ```

    High Complexity:
    ```lua
    -- High: Delete player data with custom scoping
    local playerID = "player_" .. player:SteamID64()
    lia.data.delete(playerID, false, true)
    -- Removes player data for current gamemode but all maps
    ```
]]
function lia.data.delete(key, global, ignoreMap)
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = ignoreMap and nil or game.GetMap()
    if global then
        gamemode = nil
        map = nil
    end

    lia.data.stored[key] = nil
    local condition = buildCondition(gamemode, map)
    lia.db.waitForTablesToLoad():next(function()
        if table.IsEmpty(lia.data.stored) then
            return lia.db.delete("data", condition)
        else
            local row = {
                gamemode = gamemode,
                map = map,
                data = lia.data.serialize(lia.data.stored)
            }
            return lia.db.upsert(row, "data")
        end
    end)
    return true
end

--[[
    Purpose: Loads all stored data from database into memory with hierarchical scoping
    When Called: Called during server startup to restore all persistent data
    Parameters: None
    Returns: None
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Load all data tables
    lia.data.loadTables()
    -- Loads global, gamemode, and map-specific data
    ```

    Medium Complexity:
    ```lua
    -- Medium: Load data with custom initialization
    lia.data.loadTables()
    -- After loading, access specific data
    local playerCount = lia.data.get("playerCount", 0)
    ```

    High Complexity:
    ```lua
    -- High: Load data with validation and error handling
    lia.data.loadTables()
    -- Data is loaded hierarchically: global -> gamemode -> map-specific
    -- Later data overrides earlier data (map overrides gamemode overrides global)
    ```
]]
function lia.data.loadTables()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local function loadData(gm, m)
        local cond = buildCondition(gm, m)
        return lia.db.select("data", "data", cond):next(function(res)
            local row = res.results and res.results[1]
            if row then
                local data = lia.data.deserialize(row.data) or {}
                for k, v in pairs(data) do
                    lia.data.stored[k] = v
                end
            end
        end)
    end

    lia.db.waitForTablesToLoad():next(function() return loadData(nil, nil) end):next(function() return loadData(gamemode, nil) end):next(function() return loadData(gamemode, map) end)
end

local defaultCols = {
    gamemode = true,
    map = true,
    class = true,
    pos = true,
    angles = true,
    model = true
}

local baseCols = {}
for col in pairs(defaultCols) do
    baseCols[#baseCols + 1] = col
end

local function addPersistenceColumn(col)
    local query
    if lia.db.module == "sqlite" then
        query = ([[ALTER TABLE lia_persistence ADD COLUMN %s TEXT]]):format(lia.db.escapeIdentifier(col))
    else
        query = ([[ALTER TABLE `lia_persistence` ADD COLUMN %s TEXT NULL]]):format(lia.db.escapeIdentifier(col))
    end
    return lia.db.query(query)
end

local function ensurePersistenceColumns(cols)
    local d = lia.db.waitForTablesToLoad()
    for _, col in ipairs(cols) do
        d = d:next(function() return lia.db.fieldExists("lia_persistence", col) end):next(function(exists) if not exists then return addPersistenceColumn(col) end end)
    end
    return d
end

--[[
    Purpose: Ensures persistence table has required columns for entity storage
    When Called: Called during server startup to prepare database schema for entity persistence
    Parameters: None
    Returns: Promise - Database operation promise
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Load persistence schema
    lia.data.loadPersistence()
    -- Ensures all required columns exist in persistence table
    ```

    Medium Complexity:
    ```lua
    -- Medium: Load persistence with error handling
    lia.data.loadPersistence():next(function()
        print("Persistence schema loaded successfully")
    end):catch(function(err)
        print("Failed to load persistence schema: " .. err)
    end)
    ```

    High Complexity:
    ```lua
    -- High: Load persistence as part of initialization sequence
    lia.data.loadPersistence():next(function()
        return lia.data.loadPersistenceData(function(entities)
            -- Process loaded entities
            for _, ent in ipairs(entities) do
                -- Spawn entities or process data
            end
        end)
    end)
    ```
]]
function lia.data.loadPersistence()
    return ensurePersistenceColumns(baseCols)
end

--[[
    Purpose: Saves entity data to database for persistence across server restarts
    When Called: Called during server shutdown or periodic saves to persist entity states
    Parameters: entities (table) - Array of entity data tables to save
    Returns: None
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Save basic entity data
    local entities = {
        {class = "prop_physics", pos = Vector(0, 0, 0), angles = Angle(0, 0, 0), model = "models/props_c17/FurnitureTable001a.mdl"}
    }
    lia.data.savePersistence(entities)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Save entities with custom properties
    local entities = {
        {
            class = "lia_vendor",
            pos = Vector(100, 200, 0),
            angles = Angle(0, 90, 0),
            model = "models/player.mdl",
            name = "Weapon Vendor",
            items = {"weapon_pistol", "weapon_shotgun"}
        }
    }
    lia.data.savePersistence(entities)
    ```

    High Complexity:
    ```lua
    -- High: Save complex entities with dynamic properties
    local entities = {}
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetClass() == "lia_item" then
            table.insert(entities, {
                class = ent:GetClass(),
                pos = ent:GetPos(),
                angles = ent:GetAngles(),
                model = ent:GetModel(),
                itemID = ent:GetItemID(),
                amount = ent:GetAmount(),
                data = ent:GetData()
            })
        end
    end
    lia.data.savePersistence(entities)
    ```
]]
function lia.data.savePersistence(entities)
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    lia.data.persistCache = entities
    local condition = buildCondition(gamemode, map)
    local dynamic = {}
    local dynamicList = {}
    for _, ent in ipairs(entities) do
        for k in pairs(ent) do
            if not defaultCols[k] and not dynamic[k] then
                dynamic[k] = true
                dynamicList[#dynamicList + 1] = k
            end
        end
    end

    local cols = {}
    for _, c in ipairs(baseCols) do
        cols[#cols + 1] = c
    end

    for _, c in ipairs(dynamicList) do
        cols[#cols + 1] = c
    end

    ensurePersistenceColumns(cols):next(function() return lia.db.delete("persistence", condition) end):next(function()
        local rows = {}
        for _, ent in ipairs(entities) do
            local row = {
                gamemode = gamemode,
                map = map,
                class = ent.class,
                pos = lia.data.serialize(ent.pos),
                angles = lia.data.serialize(ent.angles),
                model = ent.model
            }

            for _, col in ipairs(dynamicList) do
                row[col] = lia.data.serialize(ent[col])
            end

            rows[#rows + 1] = row
        end

        if #rows > 0 then return lia.db.bulkInsert("persistence", rows) end
    end)
end

--[[
    Purpose: Loads persisted entity data from database and optionally executes callback
    When Called: Called during server startup to restore persisted entities
    Parameters: callback (function, optional) - Function to call with loaded entity data
    Returns: Promise - Database operation promise
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Load persistence data
    lia.data.loadPersistenceData()
    -- Loads entity data into cache
    ```

    Medium Complexity:
    ```lua
    -- Medium: Load persistence data with callback
    lia.data.loadPersistenceData(function(entities)
        print("Loaded " .. #entities .. " entities")
        for _, ent in ipairs(entities) do
            print("Entity: " .. ent.class .. " at " .. tostring(ent.pos))
        end
    end)
    ```

    High Complexity:
    ```lua
    -- High: Load persistence data with entity spawning
    lia.data.loadPersistenceData(function(entities)
        for _, entData in ipairs(entities) do
            local ent = ents.Create(entData.class)
            if IsValid(ent) then
                ent:SetPos(entData.pos)
                ent:SetAngles(entData.angles)
                ent:SetModel(entData.model)
                ent:Spawn()

                -- Restore custom properties
                for k, v in pairs(entData) do
                    if not defaultCols[k] then
                        ent:SetNWVar(k, v)
                    end
                end
            end
        end
    end)
    ```
]]
function lia.data.loadPersistenceData(callback)
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local condition = buildCondition(gamemode, map)
    ensurePersistenceColumns(baseCols):next(function() return lia.db.select("*", "persistence", condition) end):next(function(res)
        local rows = res.results or {}
        local entities = {}
        for _, row in ipairs(rows) do
            local ent = {}
            for k, v in pairs(row) do
                if not defaultCols[k] and k ~= "id" and k ~= "gamemode" and k ~= "map" then ent[k] = lia.data.deserialize(v) end
            end

            ent.class = row.class
            ent.pos = lia.data.decodeVector(row.pos)
            ent.angles = lia.data.decodeAngle(row.angles)
            ent.model = row.model
            entities[#entities + 1] = ent
        end

        lia.data.persistCache = entities
        if callback then callback(entities) end
    end)
end

--[[
    Purpose: Retrieves stored data from memory cache with automatic deserialization
    When Called: Called when accessing stored persistent data
    Parameters: key (string) - Unique identifier for the data, default (any, optional) - Default value if key not found
    Returns: any - Stored data or default value if not found
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get basic data
    local playerCount = lia.data.get("playerCount", 0)
    -- Returns stored player count or 0 if not found
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get data with default fallback
    local serverSettings = lia.data.get("serverSettings", {
        maxPlayers = 32,
        mapRotation = {"gm_flatgrass", "gm_construct"}
    })
    -- Returns stored settings or default configuration
    ```

    High Complexity:
    ```lua
    -- High: Get complex data with validation
    local playerData = lia.data.get("player_" .. player:SteamID64(), {})
    if playerData.position then
        player:SetPos(playerData.position)
    end
    if playerData.inventory then
        player:GetInventory():LoadFromData(playerData.inventory)
    end
    -- Retrieves and processes complex player data
    ```
]]
function lia.data.get(key, default)
    local stored = lia.data.stored[key]
    if stored ~= nil then
        if isstring(stored) then
            stored = lia.data.deserialize(stored)
            lia.data.stored[key] = stored
        end
        return stored
    end
    return default
end

--[[
    Purpose: Retrieves cached entity persistence data from memory
    When Called: Called when accessing loaded entity persistence data
    Parameters: None
    Returns: table - Array of entity data tables or empty table if none loaded
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get persistence data
    local entities = lia.data.getPersistence()
    print("Loaded " .. #entities .. " entities")
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get persistence data with filtering
    local entities = lia.data.getPersistence()
    local vendors = {}
    for _, ent in ipairs(entities) do
        if ent.class == "lia_vendor" then
            table.insert(vendors, ent)
        end
    end
    print("Found " .. #vendors .. " vendors")
    ```

    High Complexity:
    ```lua
    -- High: Get persistence data with processing
    local entities = lia.data.getPersistence()
    local entityStats = {}
    for _, ent in ipairs(entities) do
        if not entityStats[ent.class] then
            entityStats[ent.class] = 0
        end
        entityStats[ent.class] = entityStats[ent.class] + 1
    end

    for class, count in pairs(entityStats) do
        print(class .. ": " .. count .. " entities")
    end
    ```
]]
function lia.data.getPersistence()
    return lia.data.persistCache or {}
end

timer.Create("liaSaveData", lia.config.get("DataSaveInterval", 600), 0, function()
    if lia.shuttingDown then return end
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end)
