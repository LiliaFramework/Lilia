file.CreateDir("lilia")
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
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

function lia.data.decode(value)
    return deepDecode(value)
end

function lia.data.serialize(value)
    return util.TableToJSON(lia.data.encodetable(value) or {})
end

function lia.data.deserialize(raw)
    if not raw then return nil end
    local decoded = util.JSONToTable(raw)
    if not decoded then
        local ok, ponDecoded = pcall(pon.decode, raw)
        if ok then decoded = ponDecoded end
    end

    if decoded == nil then return nil end
    return lia.data.decode(decoded)
end

function lia.data.decodeVector(raw)
    if not raw then return nil end
    local decoded = util.JSONToTable(raw)
    if not decoded then
        local ok, ponDecoded = pcall(pon.decode, raw)
        if ok then decoded = ponDecoded end
    end

    if decoded == nil then return nil end
    return _decodeVector(decoded)
end

function lia.data.decodeAngle(raw)
    if not raw then return nil end
    local decoded = util.JSONToTable(raw)
    if not decoded then
        local ok, ponDecoded = pcall(pon.decode, raw)
        if ok then decoded = ponDecoded end
    end

    if decoded == nil then return nil end
    return _decodeAngle(decoded)
end

local function buildCondition(folder, map)
    local cond = folder and "_folder = " .. lia.db.convertDataType(folder) or "_folder IS NULL"
    cond = cond .. " AND " .. (map and "_map = " .. lia.db.convertDataType(map) or "_map IS NULL")
    return cond
end

local function ensureTable(key)
    local tbl = "lia_data_" .. key
    return lia.db.tableExists(tbl):next(function(exists) if not exists then return lia.db.query("CREATE TABLE IF NOT EXISTS " .. lia.db.escapeIdentifier(tbl) .. [[ (
                    _folder TEXT,
                    _map TEXT,
                    PRIMARY KEY (_folder, _map)
                );]]) end end)
end

local defaultDataCols = {
    _folder = true,
    _map = true
}

local function addDataColumn(tbl, col)
    local query
    if lia.db.module == "sqlite" then
        query = ([[ALTER TABLE %s ADD COLUMN %s TEXT]]):format(tbl, lia.db.escapeIdentifier(col))
    else
        query = ([[ALTER TABLE %s ADD COLUMN %s TEXT NULL]]):format(lia.db.escapeIdentifier(tbl), lia.db.escapeIdentifier(col))
    end
    return lia.db.query(query)
end

local function ensureDataColumns(tbl, cols)
    local d = lia.db.waitForTablesToLoad()
    for _, col in ipairs(cols) do
        d = d:next(function() return lia.db.fieldExists(tbl, col) end):next(function(exists) if not exists then return addDataColumn(tbl, col) end end)
    end
    return d
end

function lia.data.set(key, value, global, ignoreMap)
    print("lia.data.set called with key:", key, "value:", value, "global:", global, "ignoreMap:", ignoreMap)
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = ignoreMap and NULL or game.GetMap()
    print("Initial folder:", folder, "map:", map)
    if global then
        folder = NULL
        map = NULL
        print("Global true; overriding folder and map to NULL")
    else
        if folder == nil then
            folder = NULL
            print("Folder was nil; set to NULL")
        end

        if map == nil then
            map = NULL
            print("Map was nil; set to NULL")
        end
    end

    print("Resolved folder:", folder, "map:", map)
    lia.data.stored[key] = value
    local tbl = "lia_data_" .. key
    local dynamic = {}
    local dynamicList = {}
    if istable(value) then
        for k in pairs(value) do
            if isstring(k) and not defaultDataCols[k] and not dynamic[k] then
                dynamic[k] = true
                dynamicList[#dynamicList + 1] = k
                print("Adding dynamic column:", k)
            elseif isstring(k) then
                print("Skipping column (default or duplicate):", k)
            end
        end
    else
        dynamicList[#dynamicList + 1] = "value"
        print("Value is not a table; using column 'value'")
    end

    print("Final dynamicList for", key, ":", unpack(dynamicList))
    print("Waiting for tables to load...")
    lia.db.waitForTablesToLoad():next(function()
        print("ensureTable for key:", key)
        return ensureTable(key)
    end):next(function()
        print("ensureDataColumns for table:", tbl, "columns:", unpack(dynamicList))
        return ensureDataColumns(tbl, dynamicList)
    end):next(function()
        print("Building row for upsert")
        local row = {
            _folder = folder,
            _map = map
        }

        if istable(value) then
            for _, col in ipairs(dynamicList) do
                local serialized = lia.data.serialize(value[col])
                print("Serializing column:", col, "original:", value[col], "serialized:", serialized)
                row[col] = serialized
            end
        else
            local serialized = lia.data.serialize(value)
            print("Serializing value:", value, "serialized:", serialized)
            row.value = serialized
        end

        print("Row content:")
        PrintTable(row)
        return lia.db.upsert(row, "data_" .. key)
    end):next(function()
        print("Upsert complete for key:", key)
        print("Running hook OnDataSet with", key, value, folder, map)
        hook.Run("OnDataSet", key, value, folder, map)
    end)

    local path = "lilia/"
    if folder and folder ~= NULL then path = path .. folder .. "/" end
    if map and map ~= NULL then path = path .. map .. "/" end
    print("Returning path:", path)
    return path
end

function lia.data.delete(key, global, ignoreMap)
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = ignoreMap and nil or game.GetMap()
    if global then
        folder = nil
        map = nil
    end

    lia.data.stored[key] = nil
    local condition = buildCondition(folder, map)
    lia.db.waitForTablesToLoad():next(function() return ensureTable(key) end):next(function() lia.db.delete("data_" .. key, condition) end)
    return true
end

function lia.data.loadTables()
    local query = lia.db.module == "sqlite" and "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'lia_data_%'" or "SHOW TABLES LIKE 'lia_data_%'"
    lia.db.query(query, function(res)
        local tables = {}
        if res then
            if lia.db.module == "sqlite" then
                for _, row in ipairs(res) do
                    tables[#tables + 1] = row.name
                end
            else
                local k = next(res[1] or {})
                for _, row in ipairs(res) do
                    tables[#tables + 1] = row[k]
                end
            end
        end

        local function loadNext(i)
            i = i or 1
            local tbl = tables[i]
            if not tbl then return end
            local key = tbl:match("^lia_data_(.+)$")
            local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
            local map = game.GetMap()
            local condition = buildCondition(folder, map)
            lia.db.select("*", "data_" .. key, condition):next(function(res2)
                local rows = res2.results or {}
                for _, row in ipairs(rows) do
                    local data = {}
                    for col, val in pairs(row) do
                        if not defaultDataCols[col] then
                            local k = col == "_value" and "value" or col
                            data[k] = lia.data.deserialize(val)
                        end
                    end

                    if data.value ~= nil and table.Count(data) == 1 then
                        lia.data.stored[key] = data.value
                    else
                        lia.data.stored[key] = data
                    end
                end

                loadNext(i + 1)
            end)
        end

        loadNext()
    end)
end

local function createPersistenceTable()
    if lia.db.module == "sqlite" then
        lia.db.query([[CREATE TABLE IF NOT EXISTS lia_persistence (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                _folder TEXT,
                _map TEXT,
                class TEXT,
                pos TEXT,
                angles TEXT,
                model TEXT
            );]])
    else
        lia.db.query([[CREATE TABLE IF NOT EXISTS `lia_persistence` (
                `_id` INT(12) NOT NULL AUTO_INCREMENT,
                `_folder` TEXT NULL,
                `_map` TEXT NULL,
                `class` TEXT NULL,
                `pos` TEXT NULL,
                `angles` TEXT NULL,
                `model` TEXT NULL,
                PRIMARY KEY (`_id`)
            );]])
    end
end

local defaultCols = {
    _folder = true,
    _map = true,
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

function lia.data.loadPersistence()
    createPersistenceTable()
    return ensurePersistenceColumns(baseCols)
end

function lia.data.savePersistence(entities)
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    lia.data.persistCache = entities
    local condition = buildCondition(folder, map)
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

    createPersistenceTable()
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
                _folder = folder,
                _map = map,
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
        return lia.db.bulkInsert("persistence", rows)
    end)
end

function lia.data.loadPersistenceData(callback)
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local condition = buildCondition(folder, map)
    createPersistenceTable()
    ensurePersistenceColumns(baseCols):next(function() return lia.db.select("*", "persistence", condition) end):next(function(res)
        local rows = res.results or {}
        local entities = {}
        for _, row in ipairs(rows) do
            local ent = {}
            for k, v in pairs(row) do
                if not defaultCols[k] and k ~= "_id" and k ~= "_folder" and k ~= "_map" then ent[k] = lia.data.deserialize(v) end
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

function lia.data.get(key, default)
    print("lia.data.get called with key:", key, "default:", default)
    local stored = lia.data.stored[key]
    print("Raw stored value for key:", key, "->", stored)
    if stored ~= nil then
        print("Stored value is not nil for key:", key)
        if isstring(stored) then
            print("Stored value is a string for key:", key, "- deserializing")
            stored = lia.data.deserialize(stored)
            lia.data.stored[key] = stored
            print("Deserialized value for key:", key, "->", stored)
        else
            print("Stored value is not a string for key:", key, "type:", type(stored))
        end

        print("Returning stored value for key:", key, "->", stored)
        return stored
    end

    print("No stored value for key:", key, "- returning default:", default)
    return default
end

function lia.data.getPersistence()
    return lia.data.persistCache or {}
end

local dev = true
timer.Create("liaSaveData", dev and 5 or lia.config.get("DataSaveInterval", 600), 0, function()
    if lia.shuttingDown then return end
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end)