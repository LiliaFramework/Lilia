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
    local decoded
    if istable(raw) then
        decoded = raw
    else
        decoded = util.JSONToTable(raw)
        if not decoded then
            local ok, ponDecoded = pcall(pon.decode, raw)
            if ok then decoded = ponDecoded end
        end
    end

    if decoded == nil then return nil end
    return lia.data.decode(decoded)
end

function lia.data.decodeVector(raw)
    if not raw then return nil end
    local decoded
    if istable(raw) then
        decoded = raw
    else
        decoded = util.JSONToTable(raw)
        if not decoded then
            local ok, ponDecoded = pcall(pon.decode, raw)
            if ok then decoded = ponDecoded end
        end
    end

    if decoded == nil then return nil end
    return _decodeVector(decoded)
end

function lia.data.decodeAngle(raw)
    if not raw then return nil end
    local decoded
    if istable(raw) then
        decoded = raw
    else
        decoded = util.JSONToTable(raw)
        if not decoded then
            local ok, ponDecoded = pcall(pon.decode, raw)
            if ok then decoded = ponDecoded end
        end
    end

    if decoded == nil then return nil end
    return _decodeAngle(decoded)
end

local function buildCondition(folder, map)
    local cond = folder and "_folder = " .. lia.db.convertDataType(folder) or "_folder IS NULL"
    cond = cond .. " AND " .. (map and "_map = " .. lia.db.convertDataType(map) or "_map IS NULL")
    return cond
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
    lia.db.waitForTablesToLoad():next(function()
        local row = {
            _folder = folder,
            _map = map,
            _data = lia.data.serialize(lia.data.stored)
        }
        return lia.db.upsert(row, "data")
    end):next(function() hook.Run("OnDataSet", key, value, folder, map) end)

    local path = "lilia/"
    if folder and folder ~= NULL then path = path .. folder .. "/" end
    if map and map ~= NULL then path = path .. map .. "/" end
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
    lia.db.waitForTablesToLoad():next(function()
        if not next(lia.data.stored) then
            return lia.db.delete("data", condition)
        else
            local row = {
                _folder = folder,
                _map = map,
                _data = lia.data.serialize(lia.data.stored)
            }
            return lia.db.upsert(row, "data")
        end
    end)
    return true
end

function lia.data.loadTables()
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local function loadData(f, m)
        local cond = buildCondition(f, m)
        return lia.db.select("_data", "data", cond):next(function(res)
            local row = res.results and res.results[1]
            if row then
                local data = lia.data.deserialize(row._data) or {}
                for k, v in pairs(data) do
                    lia.data.stored[k] = v
                end
            end
        end)
    end

    lia.db.waitForTablesToLoad():next(function() return loadData(nil, nil) end):next(function() return loadData(folder, nil) end):next(function() return loadData(folder, map) end)
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
    return ensurePersistenceColumns(baseCols)
end

function lia.data.savePersistence(entities)
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    lia.data.persistCache = entities
    local condition = buildCondition(folder, map)
    local dynamic = {}
    local dynamicList = {}
    local vendors = {}
    local others = {}
    for _, ent in ipairs(entities) do
        if ent.class == "lia_vendor" then
            vendors[#vendors + 1] = ent
        else
            others[#others + 1] = ent
        end

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

    ensurePersistenceColumns(cols):next(function() return lia.db.delete("vendors", condition) end):next(function()
        if #vendors > 0 then
            local vrows = {}
            for _, ent in ipairs(vendors) do
                vrows[#vrows + 1] = {
                    _folder = folder,
                    _map = map,
                    class = ent.class,
                    pos = lia.data.serialize(ent.pos),
                    angles = lia.data.serialize(ent.angles),
                    model = ent.model,
                    data = lia.data.serialize(ent.data)
                }
            end
            return lia.db.bulkInsert("vendors", vrows)
        end
    end):next(function() return lia.db.delete("persistence", condition) end):next(function()
        local rows = {}
        for _, ent in ipairs(others) do
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

        if #rows > 0 then return lia.db.bulkInsert("persistence", rows) end
    end)
end

function lia.data.loadPersistenceData(callback)
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local condition = buildCondition(folder, map)
    ensurePersistenceColumns(baseCols):next(function() return lia.db.select("*", "vendors", condition) end):next(function(vres)
        local vendors = vres.results or {}
        return lia.db.select("*", "persistence", condition):next(function(res)
            local rows = res.results or {}
            local entities = {}
            for _, row in ipairs(vendors) do
                local ent = lia.data.deserialize(row.data) or {}
                ent.class = row.class or "lia_vendor"
                ent.pos = lia.data.decodeVector(row.pos)
                ent.angles = lia.data.decodeAngle(row.angles)
                ent.model = row.model
                entities[#entities + 1] = ent
            end

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

timer.Create("liaSaveData", lia.config.get("DataSaveInterval", 600), 0, function()
    if lia.shuttingDown then return end
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end)