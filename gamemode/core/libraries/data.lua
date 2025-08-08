--[[
# Data Library

This page documents the functions for working with data serialization and storage.

---

## Overview

The data library provides utilities for encoding, decoding, and managing data structures within the Lilia framework. It handles serialization of complex data types like Vectors, Angles, and Colors, and provides functions for data persistence and retrieval. The library supports various data formats and provides utilities for working with stored data.
]]
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
--[[
    lia.data.encodetable

    Purpose:
        Recursively encodes tables, vectors, angles, and color tables into a serializable format suitable for storage (e.g., JSON).
        Converts Vectors to {x, y, z}, Angles to {p, y, r}, and color tables to {r, g, b, a}.

    Parameters:
        value (any) - The value to encode. Can be a table, Vector, Angle, or color table.

    Returns:
        Encoded value (table or primitive).

    Realm:
        Server.

    Example Usage:
        local vec = Vector(1, 2, 3)
        local encodedVec = lia.data.encodetable(vec)
        -- encodedVec is {1, 2, 3}

        local ang = Angle(10, 20, 30)
        local encodedAng = lia.data.encodetable(ang)
        -- encodedAng is {10, 20, 30}

        local color = {r = 255, g = 128, b = 64, a = 200}
        local encodedColor = lia.data.encodetable(color)
        -- encodedColor is {255, 128, 64, 200}
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
    if istable(data) then
        if data.x then return Vector(data.x, data.y, data.z) end
        if data.p and data.y and data.r then return Vector(data.p, data.y, data.r) end
        if data[1] and data[2] and data[3] then return Vector(data[1], data[2], data[3]) end
    elseif isstring(data) then
        local x, y, z = data:match("%[([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%]")
        if not x then x, y, z = data:match("%[([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%]") end
        if not x then x, y, z = data:match("Vector%(([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%)") end
        if x then return Vector(tonumber(x), tonumber(y), tonumber(z)) end
        local tbl = util.JSONToTable(data)
        if istable(tbl) and tbl[1] and tbl[2] and tbl[3] then return Vector(tonumber(tbl[1]), tonumber(tbl[2]), tonumber(tbl[3])) end
    end
    return data
end

local function _decodeAngle(data)
    if isangle(data) then return data end
    if istable(data) then
        if data.p or data.y or data.r then return Angle(data.p or 0, data.y or 0, data.r or 0) end
        if data[1] and data[2] and data[3] then return Angle(data[1], data[2], data[3]) end
    elseif isstring(data) then
        local p, y, r = data:match("%{([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%}")
        if not p then p, y, r = data:match("%{([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%}") end
        if not p then p, y, r = data:match("Angle%(([-%d%.]+),%s*([-%d%.]+),%s*([-%d%.]+)%)") end
        if not p then
            local tbl = util.JSONToTable(data)
            if istable(tbl) and tbl[1] and tbl[2] and tbl[3] then p, y, r = tbl[1], tbl[2], tbl[3] end
        end

        if p then return Angle(tonumber(p), tonumber(y), tonumber(r)) end
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
    lia.data.decode

    Purpose:
        Recursively decodes a value, converting tables or strings that represent Angles or Vectors back into their respective types.
        Useful for restoring data that was previously encoded and serialized.

    Parameters:
        value (any) - The value to decode. Can be a table, string, or primitive.

    Returns:
        Decoded value (table, Vector, Angle, or primitive).

    Realm:
        Server.

    Example Usage:
        local encoded = {1, 2, 3}
        local vec = lia.data.decode(encoded)
        -- vec is Vector(1, 2, 3)

        local encodedAng = {10, 20, 30}
        local ang = lia.data.decode(encodedAng)
        -- ang is Angle(10, 20, 30)
]]
function lia.data.decode(value)
    return deepDecode(value)
end

--[[
    lia.data.serialize

    Purpose:
        Serializes a value (table, Vector, Angle, etc.) into a JSON string for storage.
        Uses lia.data.encodetable to ensure all data is in a serializable format.

    Parameters:
        value (any) - The value to serialize.

    Returns:
        (string) - JSON-encoded string.

    Realm:
        Server.

    Example Usage:
        local data = {pos = Vector(1, 2, 3), ang = Angle(10, 20, 30)}
        local json = lia.data.serialize(data)
        -- json is a string like '{"pos":[1,2,3],"ang":[10,20,30]}'
]]
function lia.data.serialize(value)
    return util.TableToJSON(lia.data.encodetable(value) or {})
end

--[[
    lia.data.deserialize

    Purpose:
        Deserializes a JSON string or table into a Lua table, and decodes any encoded Vectors or Angles.
        Supports both JSON and PON formats.

    Parameters:
        raw (string|table) - The raw data to deserialize.

    Returns:
        (table|any) - The deserialized and decoded value, or nil if input is invalid.

    Realm:
        Server.

    Example Usage:
        local json = '{"pos":[1,2,3],"ang":[10,20,30]}'
        local data = lia.data.deserialize(json)
        -- data.pos is Vector(1, 2, 3)
        -- data.ang is Angle(10, 20, 30)
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
    return lia.data.decode(decoded)
end

--[[
    lia.data.decodeVector

    Purpose:
        Decodes a value into a Vector, supporting tables, JSON strings, and PON strings.
        Returns nil if the input is invalid or cannot be converted.

    Parameters:
        raw (any) - The value to decode as a Vector.

    Returns:
        (Vector|any) - The decoded Vector, or the original value if not convertible.

    Realm:
        Server.

    Example Usage:
        local json = '[1,2,3]'
        local vec = lia.data.decodeVector(json)
        -- vec is Vector(1, 2, 3)

        local tbl = {1, 2, 3}
        local vec2 = lia.data.decodeVector(tbl)
        -- vec2 is Vector(1, 2, 3)
]]
function lia.data.decodeVector(raw)
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
    return _decodeVector(decoded)
end

--[[
    lia.data.decodeAngle

    Purpose:
        Decodes a value into an Angle, supporting tables, JSON strings, and PON strings.
        Returns nil if the input is invalid or cannot be converted.

    Parameters:
        raw (any) - The value to decode as an Angle.

    Returns:
        (Angle|any) - The decoded Angle, or the original value if not convertible.

    Realm:
        Server.

    Example Usage:
        local json = '[10,20,30]'
        local ang = lia.data.decodeAngle(json)
        -- ang is Angle(10, 20, 30)

        local tbl = {10, 20, 30}
        local ang2 = lia.data.decodeAngle(tbl)
        -- ang2 is Angle(10, 20, 30)
]]
function lia.data.decodeAngle(raw)
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
    return _decodeAngle(decoded)
end

local function buildCondition(gamemode, map)
    local cond = gamemode and "gamemode = " .. lia.db.convertDataType(gamemode) or "gamemode IS NULL"
    cond = cond .. " AND " .. (map and "map = " .. lia.db.convertDataType(map) or "map IS NULL")
    return cond
end

--[[
    lia.data.set

    Purpose:
        Sets a key-value pair in the persistent data store, optionally scoped to a gamemode and map.
        Updates both the in-memory cache and the database asynchronously.

    Parameters:
        key (string)      - The key to set.
        value (any)       - The value to store.
        global (boolean)  - If true, stores globally (ignores gamemode and map).
        ignoreMap (bool)  - If true, ignores the map when scoping.

    Returns:
        (string) - The path used for storage.

    Realm:
        Server.

    Example Usage:
        lia.data.set("spawnPos", Vector(100, 200, 300))
        -- Stores the spawn position for the current gamemode and map.

        lia.data.set("globalSetting", true, true)
        -- Stores a global setting, not tied to any gamemode or map.
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
    lia.data.delete

    Purpose:
        Deletes a key from the persistent data store, optionally scoped to a gamemode and map.
        Updates both the in-memory cache and the database asynchronously.

    Parameters:
        key (string)      - The key to delete.
        global (boolean)  - If true, deletes globally (ignores gamemode and map).
        ignoreMap (bool)  - If true, ignores the map when scoping.

    Returns:
        (boolean) - Always true.

    Realm:
        Server.

    Example Usage:
        lia.data.delete("spawnPos")
        -- Removes the spawn position for the current gamemode and map.

        lia.data.delete("globalSetting", true)
        -- Removes a global setting, not tied to any gamemode or map.
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
        if not next(lia.data.stored) then
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
    lia.data.loadTables

    Purpose:
        Loads persistent data from the database for the current gamemode and map, as well as global and gamemode-only data.
        Populates lia.data.stored with the loaded data.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        -- Typically called automatically on server start, but can be called manually:
        lia.data.loadTables()
        -- Loads all relevant persistent data into lia.data.stored.
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
    lia.data.loadPersistence

    Purpose:
        Ensures that all required columns exist in the persistence table for entity saving/loading.
        Adds any missing columns for default entity fields.

    Parameters:
        None.

    Returns:
        (Promise) - Resolves when all columns are ensured.

    Realm:
        Server.

    Example Usage:
        lia.data.loadPersistence():next(function()
            print("Persistence columns are ready!")
        end)
]]
function lia.data.loadPersistence()
    return ensurePersistenceColumns(baseCols)
end

--[[
    lia.data.savePersistence

    Purpose:
        Saves a list of entities to the persistence table in the database, including dynamic fields.
        Ensures all necessary columns exist before saving.

    Parameters:
        entities (table) - A list of entity tables to persist.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        local entities = {
            {class = "prop_physics", pos = Vector(1,2,3), angles = Angle(0,0,0), model = "models/props_c17/oildrum001.mdl"},
            {class = "npc_citizen", pos = Vector(4,5,6), angles = Angle(0,90,0), model = "models/Humans/Group01/male_01.mdl"}
        }
        lia.data.savePersistence(entities)
        -- Saves the provided entities to the database for the current gamemode and map.
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
    lia.data.loadPersistenceData

    Purpose:
        Loads all persisted entities for the current gamemode and map from the database.
        Decodes all fields and passes the result to the provided callback.

    Parameters:
        callback (function) - Function to call with the loaded entities table.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        lia.data.loadPersistenceData(function(entities)
            for _, ent in ipairs(entities) do
                print("Loaded entity:", ent.class, ent.pos, ent.angles)
            end
        end)
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
    lia.data.get

    Purpose:
        Retrieves a value from the persistent data store by key, decoding it if necessary.
        If the value is not found, returns the provided default.

    Parameters:
        key (string)      - The key to retrieve.
        default (any)     - The default value to return if the key is not found.

    Returns:
        (any) - The stored value, or the default if not found.

    Realm:
        Server.

    Example Usage:
        local spawnPos = lia.data.get("spawnPos", Vector(0,0,0))
        -- Returns the stored spawn position, or Vector(0,0,0) if not set.
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
    lia.data.getPersistence

    Purpose:
        Retrieves the current cache of persisted entities loaded from the database.

    Parameters:
        None.

    Returns:
        (table) - The list of persisted entities, or an empty table if none are loaded.

    Realm:
        Server.

    Example Usage:
        local entities = lia.data.getPersistence()
        for _, ent in ipairs(entities) do
            print(ent.class, ent.pos)
        end
]]
function lia.data.getPersistence()
    return lia.data.persistCache or {}
end

timer.Create("liaSaveData", lia.config.get("DataSaveInterval", 600), 0, function()
    if lia.shuttingDown then return end
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end)