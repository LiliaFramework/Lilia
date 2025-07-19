lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
function lia.data.encodeVector(vec)
    return {vec.x, vec.y, vec.z}
end

function lia.data.encodeAngle(ang)
    return {ang.p, ang.y, ang.r}
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
        return lia.db.tableExists(tbl):next(function(exists) if not exists then return lia.db.query("CREATE TABLE IF NOT EXISTS " .. lia.db.escapeIdentifier(tbl) .. [[ (
                    _folder TEXT,
                    _map TEXT,
                    _value TEXT,
                    PRIMARY KEY (_folder, _map)
                );]]) end end)
    end

    function lia.data.set(key, value, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = ignoreMap and nil or game.GetMap()
        if global then
            folder = nil
            map = nil
        end

        lia.data.stored[key] = value
        lia.db.waitForTablesToLoad():next(function() return ensureTable(key) end):next(function()
            return lia.db.upsert({
                _folder = folder,
                _map = map,
                _value = {value}
            }, "data_" .. key)
        end):next(function() hook.Run("OnDataSet", key, value, folder, map) end)
        return "lilia/" .. (folder and folder .. "/" or "") .. (map and map .. "/" or "")
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
                    lia.db.select({"_folder", "_map", "_value"}, "data_" .. key, condition):next(function(res2)
                        local rows = res2.results or {}
                        for _, row in ipairs(rows) do
                            local raw = row._value or "[]"
                            local decoded = util.JSONToTable(raw)
                            if not decoded then
                                local ok, ponDecoded = pcall(pon.decode, raw)
                                if ok and ponDecoded then decoded = ponDecoded end
                            end

                            if istable(decoded) then lia.data.stored[key] = lia.data.decode(decoded[1] or decoded) end
                        end

                        loadNext(i + 1)
                    end)
                end

                loadNext()
            end)
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
            local decoded = util.JSONToTable(stored)
            local depth = 0
            while isstring(decoded) and depth < 5 do
                depth = depth + 1
                decoded = util.JSONToTable(decoded)
            end

            if not decoded then
                local ok, ponDecoded = pcall(pon.decode, stored)
                if ok and ponDecoded then decoded = ponDecoded end
            end

            if istable(decoded) then
                stored = decoded[1] or decoded
            elseif decoded ~= nil then
                stored = decoded
            end

            lia.data.stored[key] = stored
        end
        return lia.data.decode(stored)
    end
    return default
end