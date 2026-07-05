--[[
    Folder: Developer - Libraries
    File: lia.data.md
]]
--[[
    Data

    Data persistence helpers for Lilia serialized data storage, map equivalency, entity persistence, and runtime data lookup.
]]
--[[
    Overview:
        The data library centralizes persistent data under `lia.data`. It serializes vectors, angles, colors, primitive values, and nested tables into JSON-safe data, stores scoped key/value data in Garry's Mod data files, loads scoped data, manages persistent entity records through the database, and maps equivalent map names for shared persistence.
]]
--[[
    Hooks:
        OnDataSet(string key, any value, string gamemode, string map)

    Purpose:
        Runs after `lia.data.set` updates the cached value and writes the scoped data file.

    Category:
        Data

    Parameters:
        key (string)
            The data key that was stored.

        value (any)
            The value that was stored.

        gamemode (string)
            The resolved gamemode scope used for the write.

        map (string)
            The resolved map scope used for the write.

    Example Usage:
        ```lua
        hook.Add("OnDataSet", "liaExampleOnDataSet", function(key, value, gamemode, map)
            print("[MyModule] handled OnDataSet")
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        SaveData()

    Purpose:
        Runs on the periodic data-save timer so modules and plugins can save their own data.

    Category:
        Data

    Parameters:
        This hook has no parameters.

    Example Usage:
        ```lua
        hook.Add("SaveData", "liaExampleSaveData", function()
            print("[MyModule] handled SaveData")
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        PersistenceSave()

    Purpose:
        Runs on the periodic data-save timer so modules and plugins can save persistent entities.

    Category:
        Data

    Parameters:
        This hook has no parameters.

    Example Usage:
        ```lua
        hook.Add("PersistenceSave", "liaExamplePersistenceSave", function()
            print("[MyModule] handled PersistenceSave")
        end)
        ```

    Realm:
        Server
]]
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
lia.data.equivalencyMaps = lia.data.equivalencyMaps or {}
if SERVER then
    --[[
        Purpose:
            Converts values into JSON-safe data before storage.

        Parameters:
            value (any)
                The value to encode. Vectors, angles, colors, and nested tables are converted recursively.

        Returns:
            any
                The encoded value. Vectors become `{x, y, z}`, angles become `{p, y, r}`, colors become `{r, g, b, a}`, and tables are encoded recursively.

        Example Usage:
            ```lua
            local encoded = lia.data.encodetable(Vector(1, 2, 3))
            print(util.TableToJSON(encoded))
            ```

        Realm:
            Server
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

            if x then
                local nx, ny, nz = tonumber(x), tonumber(y), tonumber(z)
                if nx and ny and nz then return Vector(nx, ny, nz) end
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

                if x then
                    local nx, ny, nz = tonumber(x), tonumber(y), tonumber(z)
                    if nx and ny and nz then return Vector(nx, ny, nz) end
                end
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

            if p then
                local np, ny, nr = tonumber(p), tonumber(y), tonumber(r)
                if np and ny and nr then return Angle(np, ny, nr) end
            end
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

                if p then
                    local np, ny, nr = tonumber(p), tonumber(y), tonumber(r)
                    if np and ny and nr then return Angle(np, ny, nr) end
                end
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
            Recursively restores encoded data values into their Garry's Mod types when possible.

        Parameters:
            value (any)
                The value to decode. Tables containing vector, angle, or color fields are converted recursively.

        Returns:
            any
                The decoded value, including restored Vector, Angle, Color, or nested table values when recognized.

        Example Usage:
            ```lua
            local decoded = lia.data.decode({x = 1, y = 2, z = 3})
            print(decoded)
            ```

        Realm:
            Server
    ]]
    function lia.data.decode(value)
        return deepDecode(value)
    end

    --[[
        Purpose:
            Serializes a value into a JSON string suitable for storage.

        Parameters:
            value (any)
                The value to encode and serialize.

        Returns:
            string
                A JSON string containing the encoded value. Primitive values are wrapped in a `value` field.

        Example Usage:
            ```lua
            local raw = lia.data.serialize(Color(255, 200, 150))
            file.Write("example.json", raw)
            ```

        Realm:
            Server
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
            Deserializes stored JSON or PON data and restores encoded Garry's Mod types.

        Parameters:
            raw (string|table|any)
                The stored value to deserialize. Strings are decoded as JSON first, then PON as a fallback.

        Returns:
            any|nil
                The decoded value, or nil when no value could be decoded.

        Example Usage:
            ```lua
            local value = lia.data.deserialize(rawData)
            print(value)
            ```

        Realm:
            Server
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
            Attempts to decode a stored value into a Vector.

        Parameters:
            raw (string|table|Vector|any)
                The raw vector data to decode. JSON strings, PON strings, tables, and common vector string formats are supported.

        Returns:
            Vector|any|nil
                A Vector when decoding succeeds, nil for nil input, or the original decoded value when it cannot be converted.

        Example Usage:
            ```lua
            local pos = lia.data.decodeVector("[1 2 3]")
            print(pos)
            ```

        Realm:
            Server
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
            Attempts to decode a stored value into an Angle.

        Parameters:
            raw (string|table|Angle|any)
                The raw angle data to decode. JSON strings, PON strings, tables, and common angle string formats are supported.

        Returns:
            Angle|any|nil
                An Angle when decoding succeeds, nil for nil input, or the original decoded value when it cannot be converted.

        Example Usage:
            ```lua
            local ang = lia.data.decodeAngle("{0 90 0}")
            print(ang)
            ```

        Realm:
            Server
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
        local gmSafe = sanitizeKeyToFilename(gamemode)
        file.CreateDir("lilia/" .. gmSafe)
        local mapSafe = sanitizeKeyToFilename(map)
        file.CreateDir("lilia/" .. gmSafe .. "/" .. mapSafe)
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

    local function getKeyFilePath(gamemode, map, key)
        local gmSafe = sanitizeKeyToFilename(gamemode)
        local mapSafe = sanitizeKeyToFilename(map)
        local keySafe = sanitizeKeyToFilename(tostring(key))
        return "lilia/" .. gmSafe .. "/" .. mapSafe .. "/" .. keySafe .. ".json"
    end

    --[[
        Purpose:
            Stores a key/value pair in memory and writes it to the resolved data-file scope.

        Parameters:
            key (string)
                The data key to store.

            value (any)
                The value to store. Supported typed values are encoded before writing.

            global (boolean|nil)
                When true, stores the value in the global/global scope.

            ignoreMap (boolean|nil)
                When true, stores the value in the gamemode/global scope instead of the current map scope.

        Returns:
            string
                The resolved storage directory in `gamemode/map/` format.

        Example Usage:
            ```lua
            lia.data.set("spawnPoint", Entity(1):GetPos())
            lia.data.set("globalSetting", true, true)
            ```

        Realm:
            Server
    ]]
    function lia.data.set(key, value, global, ignoreMap)
        lia.data.stored[key] = value
        local gamemode, map = getDataScope(nil, nil, global, ignoreMap)
        ensureDataDirs(gamemode, map)
        local path = getKeyFilePath(gamemode, map, key)
        local encoded = lia.data.encodetable(value)
        if not istable(encoded) then
            encoded = {
                value = encoded
            }
        end

        file.Write(path, util.TableToJSON(encoded, true) or "{}")
        hook.Run("OnDataSet", key, value, gamemode, map)
        return gamemode .. "/" .. map .. "/"
    end

    --[[
        Purpose:
            Deletes a stored key from memory and removes its scoped data file when it exists.

        Parameters:
            key (string)
                The data key to delete.

            global (boolean|nil)
                When true, deletes the key from the global/global scope.

            ignoreMap (boolean|nil)
                When true, deletes the key from the gamemode/global scope instead of the current map scope.

        Returns:
            boolean
                Always returns true after clearing the cached value and attempting file removal.

        Example Usage:
            ```lua
            lia.data.delete("spawnPoint")
            ```

        Realm:
            Server
    ]]
    function lia.data.delete(key, global, ignoreMap)
        lia.data.stored[key] = nil
        local gamemode, map = getDataScope(nil, nil, global, ignoreMap)
        local path = getKeyFilePath(gamemode, map, key)
        if file.Exists(path, "DATA") then file.Delete(path) end
        return true
    end

    --[[
        Purpose:
            Loads stored key/value data from global, gamemode-global, and current-map data scopes.

        Parameters:
            This function has no parameters.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.data.loadTables()
            ```

        Realm:
            Server
    ]]
    function lia.data.loadTables()
        local gamemode = (SCHEMA and SCHEMA.folder) or engine.ActiveGamemode()
        local map = lia.data.getEquivalencyMap(game.GetMap())
        local function loadScope(gm, m)
            ensureDataDirs(gm, m)
            local gmSafe = sanitizeKeyToFilename(gm)
            local mapSafe = sanitizeKeyToFilename(m)
            local dir = "lilia/" .. gmSafe .. "/" .. mapSafe
            local filesFound = file.Find(dir .. "/*.json", "DATA")
            for _, fileName in ipairs(filesFound or {}) do
                local keyName = fileName:sub(1, -6)
                if lia.data.stored[keyName] == nil then
                    local raw = file.Read(dir .. "/" .. fileName, "DATA")
                    lia.data.stored[keyName] = lia.data.deserialize(raw)
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
            Ensures the persistence database table contains the base persistence columns.

        Parameters:
            This function has no parameters.

        Returns:
            Deferred
                A database deferred chain for the column checks and additions.

        Example Usage:
            ```lua
            lia.data.loadPersistence():next(function()
                print("Persistence columns are ready")
            end)
            ```

        Realm:
            Server
    ]]
    function lia.data.loadPersistence()
        return ensurePersistenceColumns(baseCols)
    end

    --[[
        Purpose:
            Saves persistent entity data for the current gamemode and equivalent map.

        Parameters:
            entities (table)
                An array of entity persistence records. Each record should include base fields such as `class`, `pos`, `angles`, and `model`; extra fields are added as dynamic columns.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.data.savePersistence({
                {class = "prop_physics", pos = pos, angles = ang, model = model}
            })
            ```

        Realm:
            Server
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

    local function hasNearbyPersistentPosition(positions, pos)
        if not isvector(pos) then return false end
        for _, existingPos in ipairs(positions) do
            if isvector(existingPos) and existingPos:DistToSqr(pos) <= 2500 then return true end
        end
        return false
    end

    --[[
        Purpose:
            Loads persistent entity data for the current gamemode and equivalent map.

        Parameters:
            callback (function|nil)
                Optional callback called with the loaded entity persistence records after the database query finishes.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.data.loadPersistenceData(function(entities)
                PrintTable(entities)
            end)
            ```

        Realm:
            Server
    ]]
    function lia.data.loadPersistenceData(callback)
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        map = lia.data.getEquivalencyMap(map)
        local condition = buildCondition(gamemode, map)
        ensurePersistenceColumns(baseCols):next(function() return lia.db.select("*", "persistence", condition) end):next(function(res)
            local rows = res.results or {}
            local entities = {}
            local nearbyByClass = {}
            local removedDuplicates = false
            table.sort(rows, function(a, b) return tonumber(a.id) > tonumber(b.id) end)
            for _, row in ipairs(rows) do
                local ent = {}
                for k, v in pairs(row) do
                    if not defaultCols[k] and k ~= "id" and k ~= "gamemode" and k ~= "map" then ent[k] = lia.data.deserialize(v) end
                end

                ent.class = row.class
                ent.pos = lia.data.decodeVector(row.pos)
                ent.angles = lia.data.decodeAngle(row.angles)
                ent.model = row.model
                if isstring(ent.class) and ent.class ~= "" and isvector(ent.pos) then
                    nearbyByClass[ent.class] = nearbyByClass[ent.class] or {}
                    if hasNearbyPersistentPosition(nearbyByClass[ent.class], ent.pos) then
                        removedDuplicates = true
                        lia.warning(string.format("Skipping duplicate persistent entity '%s' near (%.2f, %.2f, %.2f); keeping the newest saved row.", ent.class, ent.pos.x, ent.pos.y, ent.pos.z))
                        continue
                    end

                    nearbyByClass[ent.class][#nearbyByClass[ent.class] + 1] = ent.pos
                end

                entities[#entities + 1] = ent
            end

            lia.data.persistCache = entities
            if removedDuplicates then lia.data.savePersistence(entities) end
            if callback then callback(entities) end
        end)
    end

    --[[
        Purpose:
            Retrieves a cached data value by key.

        Parameters:
            key (string)
                The data key to retrieve.

            default (any)
                The fallback value returned when the key is not cached.

        Returns:
            any
                The stored value when present, otherwise the provided default value.

        Example Usage:
            ```lua
            local spawnPoint = lia.data.get("spawnPoint", Vector(0, 0, 0))
            ```

        Realm:
            Server
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
            Returns the currently cached persistence data.

        Parameters:
            This function has no parameters.

        Returns:
            table
                The cached persistence records, or an empty table when none are loaded.

        Example Usage:
            ```lua
            for _, data in ipairs(lia.data.getPersistence()) do
                print(data.class)
            end
            ```

        Realm:
            Server
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
        Registers two map names as equivalent persistence scopes.

    Parameters:
        map1 (string)
            The first map name.

        map2 (string)
            The second map name.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.data.addEquivalencyMap("rp_city_v1", "rp_city_v2")
        ```

    Realm:
        Shared
]]
function lia.data.addEquivalencyMap(map1, map2)
    lia.data.equivalencyMaps[map1] = map2
    lia.data.equivalencyMaps[map2] = map1
end

--[[
    Purpose:
        Returns the equivalent map name for a registered map, or the original map name when no equivalent exists.

    Parameters:
        map (string)
            The map name to resolve.

    Returns:
        string
            The registered equivalent map name, or the original map name.

    Example Usage:
        ```lua
        local map = lia.data.getEquivalencyMap(game.GetMap())
        ```

    Realm:
        Shared
]]
function lia.data.getEquivalencyMap(map)
    return lia.data.equivalencyMaps[map] or map
end
