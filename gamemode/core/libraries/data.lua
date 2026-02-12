--[[
    Folder: Libraries
    File: data.md
]]
--[[
    Data

    Data persistence, serialization, and management system for the Lilia framework.
]]
--[[
    Overview:
        The data library provides comprehensive functionality for data persistence, serialization, and management within the Lilia framework. It handles encoding and decoding of complex data types including vectors, angles, colors, and nested tables for database storage. The library manages both general data storage with gamemode and map-specific scoping, as well as entity persistence for maintaining spawned entities across server restarts. It includes automatic serialization/deserialization, database integration, and caching mechanisms to ensure efficient data access and storage operations.
]]
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
lia.data.equivalencyMaps = lia.data.equivalencyMaps or {}
if SERVER then
    --[[
    Purpose:
        Encode vectors/angles/colors/tables into JSON-safe structures.

    When Called:
        Before persisting data to DB or file storage.

    Parameters:
        value (any)

    Returns:
        any
            Encoded representation.

    Realm:
        Server

    Example Usage:
        ```lua
        local payload = lia.data.encodetable({
            pos = Vector(0, 0, 64),
            ang = Angle(0, 90, 0),
            tint = Color(255, 0, 0)
        })
        ```
    ]]
    function lia.data.encodetable(value)
        if isvector(value) then
            return {
                x = value.x,
                y = value.y,
                z = value.z
            }
        elseif isangle(value) then
            return {
                p = value.p,
                y = value.y,
                r = value.r
            }
        elseif IsColor(value) then
            return {
                r = value.r,
                g = value.g,
                b = value.b,
                a = value.a
            }
        elseif istable(value) and value.r and value.g and value.b then
            return {
                r = value.r,
                g = value.g,
                b = value.b,
                a = value.a or 255
            }
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
        if isvector(data) or isangle(data) then return data end
        if isstring(data) and data:lower():match("^models/") then return data end
        if istable(data) then
            if data.x and data.y and data.z then
                local x, y, z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
                if x and y and z then return Vector(x, y, z) end
            end

            if data[1] and data[2] and data[3] and not data.r and not data.g then
                local x, y, z = tonumber(data[1]), tonumber(data[2]), tonumber(data[3])
                if x and y and z then return Vector(x, y, z) end
            end
        elseif isstring(data) then
            local tbl = util.JSONToTable(data)
            if istable(tbl) then
                if tbl.x and tbl.y and tbl.z then
                    local x, y, z = tonumber(tbl.x), tonumber(tbl.y), tonumber(tbl.z)
                    if x and y and z then return Vector(x, y, z) end
                end

                if tbl[1] and tbl[2] and tbl[3] then
                    local x, y, z = tonumber(tbl[1]), tonumber(tbl[2]), tonumber(tbl[3])
                    if x and y and z then return Vector(x, y, z) end
                end
            end

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
        if isangle(data) or isvector(data) then return data end
        if isstring(data) and data:lower():match("^models/") then return data end
        if istable(data) then
            if data.p and data.y and data.r then
                local p, y, r = tonumber(data.p or 0), tonumber(data.y or 0), tonumber(data.r or 0)
                if p and y and r then return Angle(p, y, r) end
            end

            if data[1] and data[2] and data[3] then
                local p, y, r = tonumber(data[1]), tonumber(data[2]), tonumber(data[3])
                if p and y and r then return Angle(p, y, r) end
            end
        elseif isstring(data) then
            local tbl = util.JSONToTable(data)
            if istable(tbl) then
                if tbl.p and tbl.y and tbl.r then
                    local p, y, r = tonumber(tbl.p or 0), tonumber(tbl.y or 0), tonumber(tbl.r or 0)
                    if p and y and r then return Angle(p, y, r) end
                end

                if tbl[1] and tbl[2] and tbl[3] then
                    local p, y, r = tonumber(tbl[1]), tonumber(tbl[2]), tonumber(tbl[3])
                    if p and y and r then return Angle(p, y, r) end
                end
            end

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
                local jsonTbl = util.JSONToTable(data)
                if istable(jsonTbl) and jsonTbl[1] and jsonTbl[2] and jsonTbl[3] then
                    local p_num, y_num, r_num = tonumber(jsonTbl[1]), tonumber(jsonTbl[2]), tonumber(jsonTbl[3])
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

    local function _decodeColor(data)
        if IsColor(data) then return data end
        if istable(data) and data.r and data.g and data.b then return Color(tonumber(data.r) or 255, tonumber(data.g) or 255, tonumber(data.b) or 255, tonumber(data.a) or 255) end
        return data
    end

    local function deepDecode(value)
        if istable(value) then
            if value.x and value.y and value.z and not value.r and not value.g and not value.b then
                local x, y, z = tonumber(value.x), tonumber(value.y), tonumber(value.z)
                if x and y and z then return Vector(x, y, z) end
            elseif value.p and value.y and value.r and not value.x then
                local p, y, r = tonumber(value.p or 0), tonumber(value.y or 0), tonumber(value.r or 0)
                if p and y and r then return Angle(p, y, r) end
            elseif value.r and value.g and value.b then
                return Color(tonumber(value.r) or 255, tonumber(value.g) or 255, tonumber(value.b) or 255, tonumber(value.a) or 255)
            end

            local t = {}
            for k, v in pairs(value) do
                t[k] = deepDecode(v)
            end

            value = t
        end

        local col = _decodeColor(value)
        if IsColor(col) then return col end
        local vec = _decodeVector(value)
        if isvector(vec) then return vec end
        local ang = _decodeAngle(value)
        if isangle(ang) then return ang end
        return value
    end

    --[[
    Purpose:
        Decode nested structures into native types (Vector/Angle/Color).

    When Called:
        After reading serialized data from DB/file.

    Parameters:
        value (any)

    Returns:
        any
            Decoded value with deep conversion.

    Realm:
        Server

    Example Usage:
        ```lua
        local decoded = lia.data.decode(storedJsonTable)
        local pos = decoded.spawnPos
        ```
    ]]
    function lia.data.decode(value)
        return deepDecode(value)
    end

    --[[
    Purpose:
        Serialize a value into JSON, pre-encoding special types.

    When Called:
        Before writing data blobs into DB columns.

    Parameters:
        value (any)

    Returns:
        string
            JSON string.

    Realm:
        Server

    Example Usage:
        ```lua
        local json = lia.data.serialize({pos = Vector(1,2,3)})
        lia.db.updateSomewhere(json)
        ```
    ]]
    function lia.data.serialize(value)
        local encoded = lia.data.encodetable(value)
        if encoded == nil and value ~= nil then encoded = value end
        if not istable(encoded) then
            encoded = {
                value = encoded
            }
        end
        return util.TableToJSON(encoded)
    end

    --[[
    Purpose:
        Deserialize JSON/pon or raw tables back into native types.

    When Called:
        After fetching data rows from DB.

    Parameters:
        raw (string|table|any)

    Returns:
        any

    Realm:
        Server

    Example Usage:
        ```lua
        local row = lia.db.select(...):get()
        local data = lia.data.deserialize(row.data)
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
    Purpose:
        Decode a vector from various string/table encodings.

    When Called:
        While rebuilding persistent entities or map data.

    Parameters:
        raw (any)

    Returns:
        Vector|any

    Realm:
        Server

    Example Usage:
        ```lua
        local pos = lia.data.decodeVector(row.pos)
        if isvector(pos) then ent:SetPos(pos) end
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
    Purpose:
        Decode an angle from string/table encodings.

    When Called:
        During persistence loading or data deserialization.

    Parameters:
        raw (any)

    Returns:
        Angle|any

    Realm:
        Server

    Example Usage:
        ```lua
        local ang = lia.data.decodeAngle(row.angles)
        if isangle(ang) then ent:SetAngles(ang) end
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

    local function sanitizeKeyToFilename(key)
        key = tostring(key or "")
        key = key:gsub("[\\/]", "_")
        key = key:gsub("[^%w%-%._]", "_")
        key = key:gsub("_+", "_")
        key = key:gsub("^_+", "")
        key = key:gsub("_+$", "")
        if key == "" then key = "unnamed" end
        return key
    end

    local function ensureDataDirs(gamemode, map)
        file.CreateDir("lilia")
    end

    local function getDataScope(gamemode, map, global, ignoreMap)
        local gm = gamemode or (SCHEMA and SCHEMA.folder) or engine.ActiveGamemode()
        local m = ignoreMap and "global" or (map or game.GetMap())
        if global then
            gm = "global"
            m = "global"
        else
            if m ~= "global" then m = lia.data.getEquivalencyMap(m) end
        end

        gm = tostring(gm or "global")
        m = tostring(m or "global")
        return gm, m
    end

    local function getScopeMapFilePath(gamemode, map)
        ensureDataDirs(gamemode, map)
        local gmSafe = sanitizeKeyToFilename(gamemode)
        local mapSafe = sanitizeKeyToFilename(map)
        return "lilia/" .. gmSafe .. "_" .. mapSafe .. "_map.json"
    end

    local function readScopeMap(gamemode, map)
        local path = getScopeMapFilePath(gamemode, map)
        if not file.Exists(path, "DATA") then return {}, path end
        local raw = file.Read(path, "DATA")
        local decoded = raw and util.JSONToTable(raw) or nil
        if not istable(decoded) then return {}, path end
        return decoded, path
    end

    local function writeScopeMap(path, data)
        if not istable(data) then data = {} end
        file.Write(path, util.TableToJSON(data, true) or "{}")
    end

    --[[
    Purpose:
        Persist a key/value pair scoped to gamemode/map (or global).

    When Called:
        To save configuration/state data into the DB.

    Parameters:
        key (string)
        value (any)
        global (boolean|nil)
        ignoreMap (boolean|nil)

    Returns:
        string
            Path prefix used for file save fallback.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.data.set("event.active", true, false, false)
        ```
    ]]
    function lia.data.set(key, value, global, ignoreMap)
        lia.data.stored[key] = value
        local gamemode, map = getDataScope(nil, nil, global, ignoreMap)
        local mapData, mapPath = readScopeMap(gamemode, map)
        mapData[tostring(key)] = lia.data.encodetable(value)
        writeScopeMap(mapPath, mapData)
        hook.Run("OnDataSet", key, value, gamemode, map)
        return gamemode .. "/" .. map .. "/"
    end

    --[[
    Purpose:
        Delete a stored key (and row if empty) from DB cache.

    When Called:
        To remove saved state/config entries.

    Parameters:
        key (string)
        global (boolean|nil)
        ignoreMap (boolean|nil)

    Returns:
        boolean

    Realm:
        Server

    Example Usage:
        ```lua
        lia.data.delete("event.active")
        ```
    ]]
    function lia.data.delete(key, global, ignoreMap)
        lia.data.stored[key] = nil
        local gamemode, map = getDataScope(nil, nil, global, ignoreMap)
        local mapData, mapPath = readScopeMap(gamemode, map)
        mapData[tostring(key)] = nil
        writeScopeMap(mapPath, mapData)
        return true
    end

    --[[
    Purpose:
        Load stored data rows for global, gamemode, and map scopes.

    When Called:
        On database ready to hydrate lia.data.stored cache.

    Parameters:
        None

    Realm:
        Server

    Example Usage:
        ```lua
        hook.Add("DatabaseConnected", "LoadLiliaData", lia.data.loadTables)
        ```
    ]]
    function lia.data.loadTables()
        local gamemode = (SCHEMA and SCHEMA.folder) or engine.ActiveGamemode()
        local map = lia.data.getEquivalencyMap(game.GetMap())
        local function loadScope(gm, m)
            local mapPath = getScopeMapFilePath(gm, m)
            if file.Exists(mapPath, "DATA") then
                local raw = file.Read(mapPath, "DATA")
                local decoded = raw and util.JSONToTable(raw) or nil
                if istable(decoded) then
                    for keyName, storedValue in pairs(decoded) do
                        if isstring(storedValue) then
                            lia.data.stored[tostring(keyName)] = lia.data.deserialize(storedValue)
                        else
                            lia.data.stored[tostring(keyName)] = lia.data.decode(storedValue)
                        end
                    end
                end
            end

            ensureDataDirs(gm, m)
            local filesFound = file.Find(gm .. "/" .. m .. "/*.json", "DATA")
            for _, fileName in ipairs(filesFound or {}) do
                local keyName = fileName:sub(1, -6)
                if lia.data.stored[keyName] == nil then
                    local raw = file.Read(gm .. "/" .. m .. "/" .. fileName, "DATA")
                    local value = lia.data.deserialize(raw)
                    lia.data.stored[keyName] = value
                end
            end
        end

        loadScope("global", "global")
        loadScope(tostring(gamemode), "global")
        loadScope(tostring(gamemode), tostring(map))
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
        return lia.db.query("ALTER TABLE lia_persistence ADD COLUMN " .. lia.db.escapeIdentifier(col) .. " TEXT")
    end

    local function ensurePersistenceColumns(cols)
        local d = lia.db.waitForTablesToLoad()
        for _, col in ipairs(cols) do
            d = d:next(function() return lia.db.fieldExists("lia_persistence", col) end):next(function(exists) if not exists then return addPersistenceColumn(col) end end)
        end
        return d
    end

    --[[
    Purpose:
        Ensure persistence table has required columns; add if missing.

    When Called:
        Before saving/loading persistent entities.

    Parameters:
        None

    Returns:
        promise

    Realm:
        Server

    Example Usage:
        ```lua
        lia.data.loadPersistence():next(function() print("Persistence columns ready") end)
        ```
    ]]
    function lia.data.loadPersistence()
        return ensurePersistenceColumns(baseCols)
    end

    --[[
    Purpose:
        Save persistent entities to the database (with dynamic columns).

    When Called:
        On PersistenceSave hook/timer with collected entities.

    Parameters:
        entities (table)
            Array of entity data tables.

    Returns:
        promise|nil

    Realm:
        Server

    Example Usage:
        ```lua
        hook.Run("PersistenceSave", collectedEntities)
        ```
    ]]
    function lia.data.savePersistence(entities)
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        map = lia.data.getEquivalencyMap(map)
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

        ensurePersistenceColumns(cols):next(function()
            if #entities == 0 then return end
            return lia.db.delete("persistence", condition)
        end):next(function()
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
    Purpose:
        Load persistent entities from DB, decode fields, and cache them.

    When Called:
        On server start or when manually reloading persistence.

    Parameters:
        callback (function|nil)
            Invoked with entities table once loaded.

    Returns:
        promise

    Realm:
        Server

    Example Usage:
        ```lua
        lia.data.loadPersistenceData(function(entities)
            for _, entData in ipairs(entities) do
                -- spawn logic here
            end
        end)
        ```
    ]]
    function lia.data.loadPersistenceData(callback)
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        map = lia.data.getEquivalencyMap(map)
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
    Purpose:
        Fetch a stored key from cache, deserializing strings on demand.

    When Called:
        Anywhere stored data is read after loadTables.

    Parameters:
        key (string)
        default (any)

    Returns:
        any

    Realm:
        Server

    Example Usage:
        ```lua
        local eventData = lia.data.get("event.settings", {})
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
    Purpose:
        Return the cached list of persistent entities (last loaded/saved).

    When Called:
        For admin tools or debug displays.

    Parameters:
        None

    Returns:
        table

    Realm:
        Server

    Example Usage:
        ```lua
        PrintTable(lia.data.getPersistence())
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
end

--[[
    Purpose:
        Register an equivalency between two map names (bidirectional).

    When Called:
        To share data/persistence across multiple map aliases.

    Parameters:
        map1 (string)
        map2 (string)

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.data.addEquivalencyMap("rp_downtown_v1", "rp_downtown_v2")
        ```
]]
function lia.data.addEquivalencyMap(map1, map2)
    lia.data.equivalencyMaps[map1] = map2
    lia.data.equivalencyMaps[map2] = map1
end

--[[
    Purpose:
        Resolve a map name to its equivalency (if registered).

    When Called:
        Before saving/loading data keyed by map name.

    Parameters:
        map (string)

    Returns:
        string

    Realm:
        Shared

    Example Usage:
        ```lua
        local canonical = lia.data.getEquivalencyMap(game.GetMap())
    ```
]]
function lia.data.getEquivalencyMap(map)
    return lia.data.equivalencyMaps[map] or map
end