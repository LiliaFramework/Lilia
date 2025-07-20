file.CreateDir("lilia")
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
function lia.data.encodeVector(vec)
    return {vec.x, vec.y, vec.z}
end

function lia.data.encodeAngle(ang)
    return {ang.p, ang.y, ang.r}
end

local function deepEncode(value)
    if isvector(value) then
        return lia.data.encodeVector(value)
    elseif isangle(value) then
        return lia.data.encodeAngle(value)
    elseif istable(value) then
        local t = {}
        for k, v in pairs(value) do
            t[k] = deepEncode(v)
        end

        return t
    end

    return value
end

local function decodeVector(data)
    if isvector(data) then return data end
    if istable(data) then
        if data.x then return Vector(data.x, data.y, data.z) end
        if data[1] and data[2] and data[3] then return Vector(data[1], data[2], data[3]) end
    elseif isstring(data) then
        local x, y, z = data:match("%[([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%]")
        if x then return Vector(tonumber(x), tonumber(y), tonumber(z)) end
    end
    return data
end

local function decodeAngle(data)
    if isangle(data) then return data end
    if isvector(data) then return Angle(data.x, data.y, data.z) end
    if istable(data) then
        if data.p then return Angle(data.p, data.y, data.r) end
        if data[1] and data[2] and data[3] then return Angle(data[1], data[2], data[3]) end
    elseif isstring(data) then
        local p, y, r = data:match("%{([-%d%.]+)%s+([-%d%.]+)%s+([-%d%.]+)%}")
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

    value = decodeVector(value)
    value = decodeAngle(value)
    return value
end

function lia.data.decode(value)
    return deepDecode(value)
end

function lia.data.serialize(value)
    return util.TableToJSON(deepEncode(value) or {})
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

lia.data.decodeVector = decodeVector
lia.data.decodeAngle = decodeAngle
if SERVER then
    local function buildCondition(folder, map)
        local cond = folder and "_folder = " .. lia.db.convertDataType(folder) or "_folder IS NULL"
        cond = cond .. " AND " .. (map and "_map = " .. lia.db.convertDataType(map) or "_map IS NULL")
        return cond
    end


    local function ensureTable(key)
        local tbl = "lia_data_" .. key
        return lia.db.tableExists(tbl):next(function(exists)
            if not exists then
                return lia.db.query("CREATE TABLE IF NOT EXISTS " .. lia.db.escapeIdentifier(tbl) .. [[ (
                    _folder TEXT,
                    _map TEXT,
                    PRIMARY KEY (_folder, _map)
                );]])
            end
        end)
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
            d = d:next(function()
                return lia.db.fieldExists(tbl, col)
            end):next(function(exists)
                if not exists then return addDataColumn(tbl, col) end
            end)
        end
        return d
    end

    function lia.data.set(key, value, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = ignoreMap and NULL or game.GetMap()
        if global then
            folder = NULL
            map = NULL
        else
            if folder == nil then folder = NULL end
            if map == nil then map = NULL end
        end

        lia.data.stored[key] = value

        local tbl = "lia_data_" .. key
        local dynamic = {}
        local dynamicList = {}
        if istable(value) then
            for k in pairs(value) do
                if isstring(k) and not defaultDataCols[k] and not dynamic[k] then
                    dynamic[k] = true
                    dynamicList[#dynamicList + 1] = k
                end
            end
        else
            dynamicList[#dynamicList + 1] = "value"
        end

        lia.db.waitForTablesToLoad():next(function()
            return ensureTable(key)
        end):next(function()
            return ensureDataColumns(tbl, dynamicList)
        end):next(function()
            local row = {
                _folder = folder,
                _map = map
            }
            if istable(value) then
                for _, col in ipairs(dynamicList) do
                    row[col] = lia.data.serialize(value[col])
                end
            else
                row.value = lia.data.serialize(value)
            end
            return lia.db.upsert(row, "data_" .. key)
        end):next(function()
            hook.Run("OnDataSet", key, value, folder, map)
        end)

        local path = "lilia/"
        if folder and folder ~= NULL then
            path = path .. folder .. "/"
        end
        if map and map ~= NULL then
            path = path .. map .. "/"
        end
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
        lia.db.waitForTablesToLoad():next(function()
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
            d = d:next(function()
                return lia.db.fieldExists("lia_persistence", col)
            end):next(function(exists)
                if not exists then return addPersistenceColumn(col) end
            end)
        end
        return d
    end

    function lia.data.loadPersistence()
        lia.db.waitForTablesToLoad():next(function()
            createPersistenceTable()
            return ensurePersistenceColumns(baseCols)
        end)
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

        lia.db.waitForTablesToLoad():next(function()
            createPersistenceTable()
        end):next(function()
            local cols = {}
            for _, c in ipairs(baseCols) do cols[#cols + 1] = c end
            for _, c in ipairs(dynamicList) do cols[#cols + 1] = c end
            return ensurePersistenceColumns(cols)
        end):next(function()
            return lia.db.delete("persistence", condition)
        end):next(function()
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
        lia.db.waitForTablesToLoad():next(function()
            createPersistenceTable()
            return ensurePersistenceColumns(baseCols)
        end):next(function()
            return lia.db.select("*", "persistence", condition)
        end):next(function(res)
            local rows = res.results or {}
            local entities = {}
            for _, row in ipairs(rows) do
                local ent = {}
                for k, v in pairs(row) do
                    if not defaultCols[k] and k ~= "_id" and k ~= "_folder" and k ~= "_map" then
                        ent[k] = lia.data.deserialize(v)
                    end
                end
                ent.class = row.class
                ent.pos = lia.data.deserialize(row.pos)
                ent.angles = lia.data.deserialize(row.angles)
                ent.model = row.model
                entities[#entities + 1] = ent
            end
            lia.data.persistCache = entities
            if callback then callback(entities) end
        end)
    end

    timer.Create("liaSaveData", lia.config.get("DataSaveInterval", 600), 0, function()
        hook.Run("SaveData")
        hook.Run("PersistenceSave")
    end)
end

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

function lia.data.getPersistence()
    return lia.data.persistCache or {}
end
