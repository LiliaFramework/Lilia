lia.db = lia.db or {}
lia.db.queryQueue = {}
lia.db.prepared = lia.db.prepared or {}
lia.db.cache = lia.db.cache or {
    enabled = true,
    ttl = 5,
    store = {},
    index = {}
}

local function cacheNow()
    return (CurTime and CurTime()) or os.time()
end

function lia.db.setCacheEnabled(enabled)
    lia.db.cache.enabled = not not enabled
end

function lia.db.setCacheTTL(seconds)
    local ttl = tonumber(seconds) or 0
    lia.db.cache.ttl = ttl > 0 and ttl or 0
end

function lia.db.cacheClear()
    lia.db.cache.store = {}
    lia.db.cache.index = {}
end

local function stripTicks(name)
    if not isstring(name) then return name end
    return name:gsub("`", "")
end

function lia.db.cacheGet(key)
    if not lia.db.cache.enabled then return nil end
    local entry = lia.db.cache.store[key]
    if not entry then return nil end
    if entry.expireAt and entry.expireAt <= cacheNow() then
        lia.db.cache.store[key] = nil
        return nil
    end
    return entry.value
end

function lia.db.cacheSet(tableName, key, value)
    if not lia.db.cache.enabled then return end
    if not key then return end
    local expires = lia.db.cache.ttl > 0 and (cacheNow() + lia.db.cache.ttl) or nil
    lia.db.cache.store[key] = {
        value = value,
        expireAt = expires
    }

    local tn = stripTicks(tableName)
    lia.db.cache.index[tn] = lia.db.cache.index[tn] or {}
    lia.db.cache.index[tn][key] = true
end

function lia.db.invalidateTable(tableName)
    local tn = stripTicks(tableName)
    local keys = lia.db.cache.index[tn]
    if not keys then return end
    for key in pairs(keys) do
        lia.db.cache.store[key] = nil
    end

    lia.db.cache.index[tn] = nil
end

function lia.db.normalizeIdentifier(name)
    if name == nil then return name end
    local str = tostring(name)
    return str:gsub("^_+", "")
end

function lia.db.normalizeSQLIdentifiers(sql)
    if not isstring(sql) then return sql end
    local fixed = sql:gsub("`_([%w_]+)`", function(rest) return "`" .. rest:gsub("^_+", "") .. "`" end)
    return fixed
end

local function promisifyIfNoCallback(queryHandler)
    return function(query, callback)
        local d
        local function throw(err)
            if d then
                d:reject(err)
            else
                if not err or not isstring(err) then return end
                if string.find(err, "duplicate column name:") or string.find(err, "UNIQUE constraint failed: lia_config") then return end
            end
        end

        if not isfunction(callback) then
            d = deferred.new()
            callback = function(results, lastID)
                d:resolve({
                    results = results,
                    lastID = lastID
                })
            end
        end

        queryHandler(query, callback, throw)
        return d
    end
end

local sqliteQuery = promisifyIfNoCallback(function(query, callback, throw)
    local data = sql.Query(query)
    local err = sql.LastError()
    if data == false then throw(err) end
    if callback then
        local lastID = nil
        if string.find(string.upper(query), "INSERT") then lastID = tonumber(sql.QueryValue("SELECT last_insert_rowid()")) end
        callback(data, lastID)
    end
end)

function sqliteEscape(value)
    return sql.SQLStr(value, true)
end

lia.db.escape = sqliteEscape
lia.db.query = function(...) lia.db.queryQueue[#lia.db.queryQueue + 1] = {...} end
function lia.db.connect(connectCallback, reconnect)
    if reconnect or not lia.db.connected then
        lia.db.connected = true
        if lia.db.cacheClear then lia.db.cacheClear() end
        lia.db.query = function(query, queryCallback, onError)
            query = lia.db.normalizeSQLIdentifiers(query)
            return sqliteQuery(query, queryCallback, onError)
        end

        if isfunction(connectCallback) then connectCallback() end
        for i = 1, #lia.db.queryQueue do
            lia.db.query(unpack(lia.db.queryQueue[i]))
        end

        lia.db.queryQueue = {}
    end
end

function lia.db.wipeTables(callback)
    local wipedTables = {}
    local function realCallback()
        if lia.db.cacheClear then lia.db.cacheClear() end
        if isfunction(callback) then callback() end
    end

    sqliteQuery("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'lia_%'"):next(function(result)
        data = result.results or {}
        local remaining = #data
        if remaining == 0 then
            realCallback()
            return
        end

        for _, row in ipairs(data) do
            local tableName = row.name
            table.insert(wipedTables, tableName)
            lia.db.removeTable(tableName:gsub("lia_", "")):next(function()
                remaining = remaining - 1
                if remaining <= 0 then realCallback() end
            end):catch(function()
                remaining = remaining - 1
                if remaining <= 0 then realCallback() end
            end)
        end
    end)
end

function lia.db.loadTables()
    local function done()
        lia.db.addDatabaseFields()
        lia.db.migrateDatabaseSchemas():next(function()
            lia.db.autoRemoveUnderscoreColumns():next(function()
                lia.db.tablesLoaded = true
                hook.Run("LiliaTablesLoaded")
                hook.Run("OnDatabaseLoaded")
            end):catch(function()
                lia.db.tablesLoaded = true
                hook.Run("LiliaTablesLoaded")
                hook.Run("OnDatabaseLoaded")
            end)
        end):catch(function()
            lia.db.tablesLoaded = true
            hook.Run("LiliaTablesLoaded")
            hook.Run("OnDatabaseLoaded")
        end)
    end

    lia.db.createTable("players", nil, {
        {
            name = "steamID",
            type = "string"
        },
        {
            name = "steamName",
            type = "string"
        },
        {
            name = "firstJoin",
            type = "datetime"
        },
        {
            name = "lastJoin",
            type = "datetime"
        },
        {
            name = "userGroup",
            type = "string"
        },
        {
            name = "data",
            type = "text"
        },
        {
            name = "lastIP",
            type = "string"
        },
        {
            name = "lastOnline",
            type = "integer"
        },
        {
            name = "totalOnlineTime",
            type = "float"
        }
    }):next(function()
        return lia.db.createTable("chardata", {"charID", "key"}, {
            {
                name = "charID",
                type = "integer",
                not_null = true
            },
            {
                name = "key",
                type = "string",
                not_null = true
            },
            {
                name = "value",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("characters", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "steamID",
                type = "string"
            },
            {
                name = "schema",
                type = "string"
            },
            {
                name = "createTime",
                type = "datetime"
            },
            {
                name = "lastJoinTime",
                type = "datetime"
            }
        })
    end):next(function()
        return lia.db.createTable("inventories", "invID", {
            {
                name = "invID",
                type = "integer",
                auto_increment = true
            },
            {
                name = "charID",
                type = "integer"
            },
            {
                name = "invType",
                type = "string"
            }
        })
    end):next(function()
        return lia.db.createTable("items", "itemID", {
            {
                name = "itemID",
                type = "integer",
                auto_increment = true
            },
            {
                name = "invID",
                type = "integer"
            },
            {
                name = "uniqueID",
                type = "string"
            },
            {
                name = "data",
                type = "text"
            },
            {
                name = "quantity",
                type = "integer"
            },
            {
                name = "x",
                type = "integer"
            },
            {
                name = "y",
                type = "integer"
            }
        })
    end):next(function()
        return lia.db.createTable("invdata", {"invID", "key"}, {
            {
                name = "invID",
                type = "integer",
                not_null = true
            },
            {
                name = "key",
                type = "text",
                not_null = true
            },
            {
                name = "value",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("config", {"schema", "key"}, {
            {
                name = "schema",
                type = "text",
                not_null = true
            },
            {
                name = "key",
                type = "text",
                not_null = true
            },
            {
                name = "value",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("logs", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "timestamp",
                type = "datetime"
            },
            {
                name = "gamemode",
                type = "string"
            },
            {
                name = "category",
                type = "string"
            },
            {
                name = "message",
                type = "text"
            },
            {
                name = "charID",
                type = "integer"
            },
            {
                name = "steamID",
                type = "string"
            }
        })
    end):next(function()
        return lia.db.createTable("ticketclaims", nil, {
            {
                name = "timestamp",
                type = "datetime"
            },
            {
                name = "requester",
                type = "text"
            },
            {
                name = "requesterSteamID",
                type = "text"
            },
            {
                name = "admin",
                type = "text"
            },
            {
                name = "adminSteamID",
                type = "text"
            },
            {
                name = "message",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("warnings", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "charID",
                type = "integer"
            },
            {
                name = "warned",
                type = "text"
            },
            {
                name = "warnedSteamID",
                type = "text"
            },
            {
                name = "timestamp",
                type = "datetime"
            },
            {
                name = "message",
                type = "text"
            },
            {
                name = "warner",
                type = "text"
            },
            {
                name = "warnerSteamID",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("permakills", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "player",
                type = "string",
                not_null = true
            },
            {
                name = "reason",
                type = "string"
            },
            {
                name = "steamID",
                type = "string"
            },
            {
                name = "charID",
                type = "integer"
            },
            {
                name = "submitterName",
                type = "string"
            },
            {
                name = "submitterSteamID",
                type = "string"
            },
            {
                name = "timestamp",
                type = "integer"
            },
            {
                name = "evidence",
                type = "string"
            }
        })
    end):next(function()
        return lia.db.createTable("bans", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "player",
                type = "string",
                not_null = true
            },
            {
                name = "playerSteamID",
                type = "string"
            },
            {
                name = "reason",
                type = "string"
            },
            {
                name = "bannerName",
                type = "string"
            },
            {
                name = "bannerSteamID",
                type = "string"
            },
            {
                name = "timestamp",
                type = "integer"
            },
            {
                name = "evidence",
                type = "string"
            }
        })
    end):next(function()
        return lia.db.createTable("staffactions", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "player",
                type = "string",
                not_null = true
            },
            {
                name = "playerSteamID",
                type = "string"
            },
            {
                name = "steamID",
                type = "string"
            },
            {
                name = "action",
                type = "string"
            },
            {
                name = "staffName",
                type = "string"
            },
            {
                name = "staffSteamID",
                type = "string"
            },
            {
                name = "timestamp",
                type = "integer"
            }
        })
    end):next(function()
        return lia.db.createTable("doors", {"gamemode", "map", "id"}, {
            {
                name = "gamemode",
                type = "text",
                not_null = true
            },
            {
                name = "map",
                type = "text",
                not_null = true
            },
            {
                name = "id",
                type = "integer",
                not_null = true
            },
            {
                name = "factions",
                type = "text"
            },
            {
                name = "classes",
                type = "text"
            },
            {
                name = "disabled",
                type = "integer"
            },
            {
                name = "hidden",
                type = "integer"
            },
            {
                name = "ownable",
                type = "integer"
            },
            {
                name = "name",
                type = "text"
            },
            {
                name = "price",
                type = "integer"
            },
            {
                name = "locked",
                type = "integer"
            },
            {
                name = "children",
                type = "text"
            },
            {
                name = "door_group",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("persistence", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "gamemode",
                type = "text"
            },
            {
                name = "map",
                type = "text"
            },
            {
                name = "class",
                type = "text"
            },
            {
                name = "pos",
                type = "text"
            },
            {
                name = "angles",
                type = "text"
            },
            {
                name = "model",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("saveditems", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "schema",
                type = "text"
            },
            {
                name = "map",
                type = "text"
            },
            {
                name = "itemID",
                type = "integer"
            },
            {
                name = "pos",
                type = "text"
            },
            {
                name = "angles",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("admin", "usergroup", {
            {
                name = "usergroup",
                type = "text",
                not_null = true
            },
            {
                name = "privileges",
                type = "text"
            },
            {
                name = "inheritance",
                type = "text"
            },
            {
                name = "types",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("data", {"gamemode", "map"}, {
            {
                name = "gamemode",
                type = "text",
                not_null = true
            },
            {
                name = "map",
                type = "text",
                not_null = true
            },
            {
                name = "data",
                type = "text"
            }
        })
    end):next(function()
        return lia.db.createTable("vendor_presets", "id", {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "name",
                type = "text",
                not_null = true
            },
            {
                name = "data",
                type = "text"
            }
        })
    end):next(function() done() end):catch(function() done() end)

    hook.Run("OnLoadTables")
end

function lia.db.waitForTablesToLoad()
    TABLE_WAIT_ID = TABLE_WAIT_ID or 0
    local d = deferred.new()
    if lia.db.tablesLoaded then
        d:resolve()
    else
        hook.Add("LiliaTablesLoaded", tostring(TABLE_WAIT_ID), function() d:resolve() end)
    end

    TABLE_WAIT_ID = TABLE_WAIT_ID + 1
    return d
end

local function genInsertValues(value, dbTable)
    local query = "lia_" .. (dbTable or "characters") .. " ("
    local keys = {}
    local values = {}
    for k, v in pairs(value) do
        keys[#keys + 1] = lia.db.escapeIdentifier(k)
        values[#keys] = lia.db.convertDataType(v)
    end
    return query .. table.concat(keys, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")"
end

local function genUpdateList(value)
    local changes = {}
    for k, v in pairs(value) do
        changes[#changes + 1] = lia.db.escapeIdentifier(k) .. " = " .. lia.db.convertDataType(v)
    end
    return table.concat(changes, ", ")
end

function lia.db.convertDataType(value, noEscape)
    if value == nil then
        return "NULL"
    elseif isstring(value) then
        if noEscape then
            return value
        else
            return "'" .. sqliteEscape(value) .. "'"
        end
    elseif isnumber(value) then
        return tostring(value)
    elseif istable(value) then
        if noEscape then
            return util.TableToJSON(value)
        else
            return "'" .. sqliteEscape(util.TableToJSON(value)) .. "'"
        end
    elseif isbool(value) then
        return value and 1 or 0
    elseif value == NULL then
        return "NULL"
    end
    return tostring(value)
end

function lia.db.insertTable(value, callback, dbTable)
    local query = "INSERT INTO " .. genInsertValues(value, dbTable)
    local function cb(...)
        if callback then callback(...) end
        lia.db.invalidateTable("lia_" .. (dbTable or "characters"))
    end
    return sqliteQuery(query):next(function(result)
        cb(result.results, result.lastID)
        return result
    end)
end

function lia.db.updateTable(value, callback, dbTable, condition)
    local query = "UPDATE " .. "lia_" .. (dbTable or "characters") .. " SET " .. genUpdateList(value) .. (condition and " WHERE " .. condition or "")
    local function cb(...)
        if callback then callback(...) end
        lia.db.invalidateTable("lia_" .. (dbTable or "characters"))
    end
    return sqliteQuery(query):next(function(result)
        cb(result.results, result.lastID)
        return result
    end)
end

function lia.db.select(fields, dbTable, condition, limit, orderBy, maybeOrderBy)
    local d = deferred.new()
    local from = istable(fields) and table.concat(fields, ", ") or tostring(fields)
    local tableName = "lia_" .. (dbTable or "characters")
    local query = "SELECT " .. from .. " FROM " .. tableName
    if condition then query = query .. " WHERE " .. tostring(condition) end
    local ob = orderBy
    if (not ob) and isstring(maybeOrderBy) then ob = maybeOrderBy end
    if ob and isstring(ob) and ob ~= "" then query = query .. " ORDER BY " .. ob end
    if limit then query = query .. " LIMIT " .. tostring(limit) end
    local cacheKey = "select:" .. query
    local cached = lia.db.cacheGet(cacheKey)
    if cached ~= nil then
        d:resolve(cached)
        return d
    end

    sqliteQuery(query):next(function(result)
        local payload = {
            results = result.results,
            lastID = result.lastID
        }

        lia.db.cacheSet(tableName, cacheKey, payload)
        d:resolve(payload)
    end)
    return d
end

function lia.db.selectWithCondition(fields, dbTable, conditions, limit, orderBy)
    local d = deferred.new()
    local from = istable(fields) and table.concat(fields, ", ") or tostring(fields)
    local tableName = "lia_" .. (dbTable or "characters")
    local query = "SELECT " .. from .. " FROM " .. tableName
    if conditions and istable(conditions) and next(conditions) then
        local whereParts = {}
        for field, value in pairs(conditions) do
            if value ~= nil then
                local operator = "="
                local conditionValue = value
                if istable(value) and value.operator and value.value ~= nil then
                    operator = value.operator
                    conditionValue = value.value
                end

                local escapedField = lia.db.escapeIdentifier(field)
                local convertedValue = lia.db.convertDataType(conditionValue)
                table.insert(whereParts, escapedField .. " " .. operator .. " " .. convertedValue)
            end
        end

        if #whereParts > 0 then query = query .. " WHERE " .. table.concat(whereParts, " AND ") end
    elseif isstring(conditions) then
        query = query .. " WHERE " .. tostring(conditions)
    end

    if orderBy then query = query .. " ORDER BY " .. tostring(orderBy) end
    if limit then query = query .. " LIMIT " .. tostring(limit) end
    local cacheKey = "select:" .. query
    local cached = lia.db.cacheGet(cacheKey)
    if cached ~= nil then
        d:resolve(cached)
        return d
    end

    lia.db.query(query, function(results, lastID)
        local payload = {
            results = results,
            lastID = lastID
        }

        lia.db.cacheSet(tableName, cacheKey, payload)
        d:resolve(payload)
    end)
    return d
end

function lia.db.count(dbTable, condition)
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local q = "SELECT COUNT(*) AS cnt FROM " .. tbl .. (condition and " WHERE " .. condition or "")
    local cacheKey = "count:" .. q
    local cached = lia.db.cacheGet(cacheKey)
    if cached ~= nil then
        c:resolve(cached)
        return c
    end

    sqliteQuery(q):next(function(result)
        if istable(result.results) then
            local num = tonumber(result.results[1].cnt)
            lia.db.cacheSet(tbl, cacheKey, num)
            c:resolve(num)
        else
            c:resolve(0)
        end
    end)
    return c
end

function lia.db.exists(dbTable, condition)
    return lia.db.count(dbTable, condition):next(function(count) return count > 0 end)
end

lia.db.expectedSchemas = {
    players = {
        steamID = {
            type = "string"
        },
        steamName = {
            type = "string"
        },
        firstJoin = {
            type = "datetime"
        },
        lastJoin = {
            type = "datetime"
        },
        userGroup = {
            type = "string"
        },
        data = {
            type = "text"
        },
        lastIP = {
            type = "string"
        },
        lastOnline = {
            type = "integer"
        },
        totalOnlineTime = {
            type = "float"
        }
    },
    chardata = {
        charID = {
            type = "integer",
            not_null = true
        },
        key = {
            type = "string",
            not_null = true
        },
        value = {
            type = "text"
        }
    },
    characters = {
        id = {
            type = "integer",
            auto_increment = true
        },
        steamID = {
            type = "string"
        },
        schema = {
            type = "string"
        },
        createTime = {
            type = "datetime"
        },
        lastJoinTime = {
            type = "datetime"
        }
    },
    inventories = {
        invID = {
            type = "integer",
            auto_increment = true
        },
        charID = {
            type = "integer"
        },
        invType = {
            type = "string"
        }
    },
    items = {
        itemID = {
            type = "integer",
            auto_increment = true
        },
        invID = {
            type = "integer"
        },
        uniqueID = {
            type = "string"
        },
        data = {
            type = "text"
        },
        quantity = {
            type = "integer"
        },
        x = {
            type = "integer"
        },
        y = {
            type = "integer"
        }
    },
    invdata = {
        invID = {
            type = "integer",
            not_null = true
        },
        key = {
            type = "text",
            not_null = true
        },
        value = {
            type = "text"
        }
    },
    config = {
        schema = {
            type = "text",
            not_null = true
        },
        key = {
            type = "text",
            not_null = true
        },
        value = {
            type = "text"
        }
    },
    logs = {
        id = {
            type = "integer",
            auto_increment = true
        },
        timestamp = {
            type = "datetime"
        },
        gamemode = {
            type = "string"
        },
        category = {
            type = "string"
        },
        message = {
            type = "text"
        },
        charID = {
            type = "integer"
        },
        steamID = {
            type = "string"
        }
    },
    ticketclaims = {
        timestamp = {
            type = "datetime"
        },
        requester = {
            type = "text"
        },
        requesterSteamID = {
            type = "text"
        },
        admin = {
            type = "text"
        },
        adminSteamID = {
            type = "text"
        },
        message = {
            type = "text"
        }
    },
    warnings = {
        id = {
            type = "integer",
            auto_increment = true
        },
        charID = {
            type = "integer"
        },
        warned = {
            type = "text"
        },
        warnedSteamID = {
            type = "text"
        },
        timestamp = {
            type = "datetime"
        },
        message = {
            type = "text"
        },
        warner = {
            type = "text"
        },
        warnerSteamID = {
            type = "text"
        }
    },
    permakills = {
        id = {
            type = "integer",
            auto_increment = true
        },
        player = {
            type = "string",
            not_null = true
        },
        reason = {
            type = "string"
        },
        steamID = {
            type = "string"
        },
        charID = {
            type = "integer"
        },
        submitterName = {
            type = "string"
        },
        submitterSteamID = {
            type = "string"
        },
        timestamp = {
            type = "integer"
        },
        evidence = {
            type = "string"
        }
    },
    bans = {
        id = {
            type = "integer",
            auto_increment = true
        },
        player = {
            type = "string",
            not_null = true
        },
        playerSteamID = {
            type = "string"
        },
        reason = {
            type = "string"
        },
        bannerName = {
            type = "string"
        },
        bannerSteamID = {
            type = "string"
        },
        timestamp = {
            type = "integer"
        },
        evidence = {
            type = "string"
        }
    },
    staffactions = {
        id = {
            type = "integer",
            auto_increment = true
        },
        player = {
            type = "string",
            not_null = true
        },
        playerSteamID = {
            type = "string"
        },
        steamID = {
            type = "string"
        },
        action = {
            type = "string"
        },
        staffName = {
            type = "string"
        },
        staffSteamID = {
            type = "string"
        },
        timestamp = {
            type = "integer"
        }
    },
    doors = {
        gamemode = {
            type = "text",
            not_null = true
        },
        map = {
            type = "text",
            not_null = true
        },
        id = {
            type = "integer",
            not_null = true
        },
        factions = {
            type = "text"
        },
        classes = {
            type = "text"
        },
        disabled = {
            type = "integer"
        },
        hidden = {
            type = "integer"
        },
        ownable = {
            type = "integer"
        },
        name = {
            type = "text"
        },
        price = {
            type = "integer"
        },
        locked = {
            type = "integer"
        },
        children = {
            type = "text"
        },
        door_group = {
            type = "text"
        }
    },
    persistence = {
        id = {
            type = "integer",
            auto_increment = true
        },
        gamemode = {
            type = "text"
        },
        map = {
            type = "text"
        },
        class = {
            type = "text"
        },
        pos = {
            type = "text"
        },
        angles = {
            type = "text"
        },
        model = {
            type = "text"
        }
    },
    saveditems = {
        id = {
            type = "integer",
            auto_increment = true
        },
        schema = {
            type = "text"
        },
        map = {
            type = "text"
        },
        itemID = {
            type = "integer"
        },
        pos = {
            type = "text"
        },
        angles = {
            type = "text"
        }
    },
    admin = {
        usergroup = {
            type = "text",
            not_null = true
        },
        privileges = {
            type = "text"
        },
        inheritance = {
            type = "text"
        },
        types = {
            type = "text"
        }
    },
    data = {
        gamemode = {
            type = "text",
            not_null = true
        },
        map = {
            type = "text",
            not_null = true
        },
        data = {
            type = "text"
        }
    },
    vendor_presets = {
        id = {
            type = "integer",
            auto_increment = true
        },
        name = {
            type = "text",
            not_null = true
        },
        data = {
            type = "text"
        }
    }
}

function lia.db.addExpectedSchema(tableName, schema)
    if not lia.db.expectedSchemas then lia.db.expectedSchemas = {} end
    lia.db.expectedSchemas[tableName] = schema
end

function lia.db.migrateDatabaseSchemas()
    local migrationPromises = {}
    for tableName, expectedColumns in pairs(lia.db.expectedSchemas) do
        local fullTableName = "lia_" .. tableName
        local promise = lia.db.tableExists(fullTableName):next(function(tableExists)
            if not tableExists then return end
            return lia.db.getTableColumns(fullTableName):next(function(columnTypes)
                if not columnTypes then return end
                local existingColumns = {}
                for colName, colType in pairs(columnTypes) do
                    existingColumns[colName] = {
                        type = colType,
                        notnull = false,
                        pk = false
                    }
                end

                local missingColumns = {}
                for colName, colDef in pairs(expectedColumns) do
                    if not existingColumns[colName] then
                        table.insert(missingColumns, {
                            name = colName,
                            def = colDef
                        })
                    end
                end

                if #missingColumns > 0 then
                    local columnPromises = {}
                    for _, colInfo in ipairs(missingColumns) do
                        local colPromise = lia.db.createColumn(tableName, colInfo.name, colInfo.def.type, {
                            not_null = colInfo.def.not_null,
                            auto_increment = colInfo.def.auto_increment,
                            default = colInfo.def.default
                        }):next(function() end):catch(function() end)

                        table.insert(columnPromises, colPromise)
                    end
                    return deferred.all(columnPromises)
                end
            end)
        end):catch(function() end)

        table.insert(migrationPromises, promise)
    end
    return deferred.all(migrationPromises):next(function() end):catch(function() end)
end

function lia.db.addDatabaseFields()
    local typeMap = {
        string = function(d) return ("%s VARCHAR(%d)"):format(lia.db.escapeIdentifier(d.field), d.length or 255) end,
        integer = function(d) return ("%s INT"):format(lia.db.escapeIdentifier(d.field)) end,
        float = function(d) return ("%s FLOAT"):format(lia.db.escapeIdentifier(d.field)) end,
        boolean = function(d) return ("%s TINYINT(1)"):format(lia.db.escapeIdentifier(d.field)) end,
        datetime = function(d) return ("%s DATETIME"):format(lia.db.escapeIdentifier(d.field)) end,
        text = function(d) return ("%s TEXT"):format(lia.db.escapeIdentifier(d.field)) end
    }

    local ignore = function() end
    if not istable(lia.char.vars) then return end
    for _, v in pairs(lia.char.vars) do
        if v.field and typeMap[v.fieldType] then
            lia.db.fieldExists("lia_characters", v.field):next(function(exists)
                if not exists then
                    local schemaType = "string"
                    if v.fieldType == "integer" then
                        schemaType = "integer"
                    elseif v.fieldType == "float" then
                        schemaType = "float"
                    elseif v.fieldType == "boolean" then
                        schemaType = "boolean"
                    elseif v.fieldType == "datetime" then
                        schemaType = "datetime"
                    elseif v.fieldType == "text" then
                        schemaType = "text"
                    end

                    lia.db.createColumn("characters", v.field, schemaType, {
                        default = v.default,
                        not_null = false
                    }):next(function() end):catch(ignore)
                end
            end)
        end
    end
end

function lia.db.exists(dbTable, condition)
    return lia.db.count(dbTable, condition):next(function(n) return n > 0 end)
end

function lia.db.selectOne(fields, dbTable, condition)
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local f = istable(fields) and table.concat(fields, ", ") or fields
    local q = "SELECT " .. f .. " FROM " .. tbl
    if condition then q = q .. " WHERE " .. condition end
    q = q .. " LIMIT 1"
    local cacheKey = "selectOne:" .. q
    local cached = lia.db.cacheGet(cacheKey)
    if cached ~= nil then
        c:resolve(cached)
        return c
    end

    lia.db.query(q, function(results)
        if istable(results) then
            local row = results[1]
            lia.db.cacheSet(tbl, cacheKey, row)
            c:resolve(row)
        else
            c:resolve(nil)
        end
    end)
    return c
end

function lia.db.selectWithJoin(query)
    local d = deferred.new()
    local cacheKey = "selectWithJoin:" .. query
    local cached = lia.db.cacheGet(cacheKey)
    if cached ~= nil then
        d:resolve(cached)
        return d
    end

    lia.db.query(query, function(results, lastID)
        local payload = {
            results = results,
            lastID = lastID
        }

        lia.db.cacheSet("custom", cacheKey, payload)
        d:resolve(payload)
    end)
    return d
end

function lia.db.bulkInsert(dbTable, rows)
    if #rows == 0 then return deferred.new():resolve() end
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local keys = {}
    for k in pairs(rows[1]) do
        keys[#keys + 1] = lia.db.escapeIdentifier(k)
    end

    local vals = {}
    for _, row in ipairs(rows) do
        local items = {}
        for _, k in ipairs(keys) do
            local key = k:sub(2, -2)
            items[#items + 1] = lia.db.convertDataType(row[key])
        end

        vals[#vals + 1] = "(" .. table.concat(items, ",") .. ")"
    end

    local q = "INSERT OR IGNORE INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(vals, ",")
    lia.db.query(q, function()
        lia.db.invalidateTable(tbl)
        c:resolve()
    end, function(err) c:reject(err) end)
    return c
end

function lia.db.bulkUpsert(dbTable, rows)
    if #rows == 0 then return deferred.new():resolve() end
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local keys = {}
    for k in pairs(rows[1]) do
        keys[#keys + 1] = lia.db.escapeIdentifier(k)
    end

    local vals = {}
    for _, row in ipairs(rows) do
        local items = {}
        for _, k in ipairs(keys) do
            local key = k:sub(2, -2)
            items[#items + 1] = lia.db.convertDataType(row[key])
        end

        vals[#vals + 1] = "(" .. table.concat(items, ",") .. ")"
    end

    lia.db.query("INSERT OR REPLACE INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(vals, ","), function()
        lia.db.invalidateTable(tbl)
        c:resolve()
    end, function(err) c:reject(err) end)
    return c
end

function lia.db.insertOrIgnore(value, dbTable)
    local c = deferred.new()
    local tbl = "`lia_" .. (dbTable or "characters") .. "`"
    local keys, vals = {}, {}
    for k, v in pairs(value) do
        keys[#keys + 1] = lia.db.escapeIdentifier(k)
        vals[#vals + 1] = lia.db.convertDataType(v)
    end

    local cmd = "INSERT OR IGNORE"
    lia.db.query(cmd .. " INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(vals, ",") .. ")", function(results, lastID)
        c:resolve({
            results = results,
            lastID = lastID
        })

        lia.db.invalidateTable(tbl)
    end, function(err) c:reject(err) end)
    return c
end

function lia.db.tableExists(tbl)
    local qt = "'" .. tbl:gsub("'", "''") .. "'"
    return sqliteQuery("SELECT name FROM sqlite_master WHERE type='table' AND name=" .. qt):next(function(result) return result.results and #result.results > 0 end)
end

function lia.db.fieldExists(tbl, field)
    local d = deferred.new()
    field = lia.db.normalizeIdentifier(field)
    lia.db.query("PRAGMA table_info(" .. tbl .. ")", function(res)
        for _, r in ipairs(res) do
            if r.name == field then return d:resolve(true) end
        end

        d:resolve(false)
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.getTables()
    return sqliteQuery("SELECT name FROM sqlite_master WHERE type='table'"):next(function(result)
        local tables = {}
        local res = result.results or {}
        for _, row in ipairs(res) do
            if row.name and string.StartWith(row.name, "lia_") then tables[#tables + 1] = row.name end
        end
        return tables
    end)
end

function lia.db.getTableColumns(tbl)
    local d = deferred.new()
    lia.db.query("PRAGMA table_info(" .. tbl .. ")", function(res)
        local columns = {}
        for _, row in ipairs(res or {}) do
            columns[row.name] = string.lower(row.type)
        end

        d:resolve(columns)
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.transaction(queries)
    local c = deferred.new()
    lia.db.query("BEGIN TRANSACTION", function()
        local i = 1
        local function nextQuery()
            if i > #queries then
                lia.db.query("COMMIT", function()
                    if lia.db.cacheClear then lia.db.cacheClear() end
                    c:resolve()
                end)
            else
                lia.db.query(queries[i], function()
                    i = i + 1
                    nextQuery()
                end, function(err) lia.db.query("ROLLBACK", function() c:reject(err) end) end)
            end
        end

        nextQuery()
    end, function(err) c:reject(err) end)
    return c
end

function lia.db.escapeIdentifier(id)
    return "`" .. tostring(lia.db.normalizeIdentifier(id)):gsub("`", "``") .. "`"
end

function lia.db.upsert(value, dbTable)
    local d = deferred.new()
    lia.db.query("INSERT OR REPLACE INTO " .. genInsertValues(value, dbTable), function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })

        lia.db.invalidateTable("lia_" .. (dbTable or "characters"))
    end)
    return d
end

function lia.db.delete(dbTable, condition)
    local query
    dbTable = "lia_" .. (dbTable or "characters")
    if condition then
        query = "DELETE FROM " .. dbTable .. " WHERE " .. condition
    else
        query = "DELETE FROM " .. dbTable
    end
    return sqliteQuery(query):next(function(result)
        lia.db.invalidateTable(dbTable)
        return {
            results = result.results,
            lastID = result.lastID
        }
    end)
end

function lia.db.createTable(dbName, primaryKey, schema)
    local d = deferred.new()
    if not dbName or type(dbName) ~= "string" then
        d:reject("Invalid table name: must be a non-empty string")
        return d
    end

    if not schema or type(schema) ~= "table" then
        d:reject("Invalid schema: must be a table of column definitions")
        return d
    end

    if #schema == 0 then
        d:reject("Invalid schema: table must have at least one column")
        return d
    end

    local tableName = "lia_" .. dbName
    local columns = {}
    local indexes = {}
    local foreignKeys = {}
    local typeMap = {
        string = "VARCHAR(255)",
        text = "TEXT",
        integer = "INTEGER",
        int = "INTEGER",
        float = "REAL",
        double = "REAL",
        boolean = "TINYINT(1)",
        bool = "TINYINT(1)",
        datetime = "DATETIME",
        date = "DATE",
        time = "TIME",
        blob = "BLOB"
    }

    for _, column in ipairs(schema) do
        if not column.name or type(column.name) ~= "string" then
            d:reject("Invalid column definition: missing or invalid column name")
            return d
        end

        if not column.type or type(column.type) ~= "string" then
            d:reject("Invalid column definition: missing or invalid column type for '" .. column.name .. "'")
            return d
        end

        local sqlType = typeMap[column.type:lower()]
        if not sqlType then
            d:reject("Unsupported column type '" .. column.type .. "' for column '" .. column.name .. "'")
            return d
        end

        local colDef = lia.db.escapeIdentifier(column.name) .. " " .. sqlType
        if column.unique then colDef = colDef .. " UNIQUE" end
        if column.not_null or column.required then colDef = colDef .. " NOT NULL" end
        if column.default ~= nil then
            if column.type:lower() == "string" or column.type:lower() == "text" then
                colDef = colDef .. " DEFAULT '" .. sqliteEscape(tostring(column.default)) .. "'"
            elseif column.type:lower() == "boolean" or column.type:lower() == "bool" then
                colDef = colDef .. " DEFAULT " .. (column.default and "1" or "0")
            elseif column.type:lower() == "integer" or column.type:lower() == "int" then
                local num = tonumber(column.default)
                if num then colDef = colDef .. " DEFAULT " .. math.floor(num) end
            elseif column.type:lower() == "float" or column.type:lower() == "double" then
                local num = tonumber(column.default)
                if num then colDef = colDef .. " DEFAULT " .. num end
            else
                colDef = colDef .. " DEFAULT " .. tostring(column.default)
            end
        end

        if column.auto_increment and (column.type:lower() == "integer" or column.type:lower() == "int") then
            if type(primaryKey) == "string" and primaryKey == column.name then
                colDef = colDef .. " PRIMARY KEY AUTOINCREMENT"
            elseif type(primaryKey) == "table" and table.HasValue(primaryKey, column.name) then
                colDef = colDef .. " AUTOINCREMENT"
            else
                colDef = colDef .. " AUTOINCREMENT"
            end
        end

        table.insert(columns, colDef)
        if column.index then
            table.insert(indexes, {
                name = column.name,
                unique = column.unique_index or false
            })
        end

        if column.references then
            table.insert(foreignKeys, {
                column = column.name,
                references = column.references
            })
        end
    end

    if primaryKey then
        if type(primaryKey) == "string" then
            local pkColumnDefined = false
            for _, col in ipairs(columns) do
                if col:find("`" .. primaryKey .. "`") and col:find("PRIMARY KEY") then
                    pkColumnDefined = true
                    break
                end
            end

            if not pkColumnDefined then table.insert(columns, "PRIMARY KEY (" .. lia.db.escapeIdentifier(primaryKey) .. ")") end
        elseif type(primaryKey) == "table" then
            local allPkColumnsDefined = true
            for _, pkCol in ipairs(primaryKey) do
                local found = false
                for _, col in ipairs(columns) do
                    if col:find("`" .. pkCol .. "`") and col:find("PRIMARY KEY") then
                        found = true
                        break
                    end
                end

                if not found then
                    allPkColumnsDefined = false
                    break
                end
            end

            if not allPkColumnsDefined then
                local pkColumns = {}
                for _, col in ipairs(primaryKey) do
                    table.insert(pkColumns, lia.db.escapeIdentifier(col))
                end

                table.insert(columns, "PRIMARY KEY (" .. table.concat(pkColumns, ", ") .. ")")
            end
        end
    end

    for _, fk in ipairs(foreignKeys) do
        local refTable, refColumn = fk.references:match("(.+)%.(.+)")
        if refTable and refColumn then table.insert(columns, "FOREIGN KEY (" .. lia.db.escapeIdentifier(fk.column) .. ") REFERENCES " .. lia.db.escapeIdentifier(refTable) .. "(" .. lia.db.escapeIdentifier(refColumn) .. ")") end
    end

    local createQuery = "CREATE TABLE IF NOT EXISTS " .. tableName .. " (" .. table.concat(columns, ", ") .. ")"
    lia.db.query(createQuery, function()
        local indexPromises = {}
        for _, indexInfo in ipairs(indexes) do
            local indexName = tableName .. "_" .. indexInfo.name .. "_idx"
            local indexType = indexInfo.unique and "UNIQUE INDEX" or "INDEX"
            local indexQuery = "CREATE " .. indexType .. " IF NOT EXISTS " .. indexName .. " ON " .. tableName .. "(" .. lia.db.escapeIdentifier(indexInfo.name) .. ")"
            local indexPromise = deferred.new()
            table.insert(indexPromises, indexPromise)
            lia.db.query(indexQuery, function() indexPromise:resolve() end, function(err) indexPromise:reject("Failed to create index on " .. indexInfo.name .. ": " .. err) end)
        end

        if #indexPromises > 0 then
            deferred.all(indexPromises):next(function()
                if lia.db.cacheClear then lia.db.cacheClear() end
                d:resolve({
                    success = true,
                    table = tableName,
                    columns = #columns,
                    indexes = #indexes,
                    foreignKeys = #foreignKeys
                })
            end):catch(function(err) d:reject("Table created but index creation failed: " .. err) end)
        else
            if lia.db.cacheClear then lia.db.cacheClear() end
            d:resolve({
                success = true,
                table = tableName,
                columns = #columns,
                indexes = 0,
                foreignKeys = #foreignKeys
            })
        end
    end, function(err) d:reject("Failed to create table '" .. tableName .. "': " .. err) end)
    return d
end

function lia.db.createColumn(tableName, columnName, columnType, options)
    local d = deferred.new()
    if not tableName or type(tableName) ~= "string" then
        d:reject("Invalid table name: must be a non-empty string")
        return d
    end

    if not columnName or type(columnName) ~= "string" then
        d:reject("Invalid column name: must be a non-empty string")
        return d
    end

    if not columnType or type(columnType) ~= "string" then
        d:reject("Invalid column type: must be a non-empty string")
        return d
    end

    options = options or {}
    local fullTableName = "lia_" .. tableName
    lia.db.tableExists(fullTableName):next(function(tableExists)
        if not tableExists then
            d:reject("Table '" .. fullTableName .. "' does not exist")
            return
        end

        lia.db.fieldExists(fullTableName, columnName):next(function(exists)
            if exists then
                d:resolve({
                    success = false,
                    message = "Column '" .. columnName .. "' already exists in table '" .. fullTableName .. "'"
                })
                return
            end

            local typeMap = {
                string = "VARCHAR(255)",
                text = "TEXT",
                integer = "INTEGER",
                int = "INTEGER",
                float = "REAL",
                double = "REAL",
                boolean = "TINYINT(1)",
                bool = "TINYINT(1)",
                datetime = "DATETIME",
                date = "DATE",
                time = "TIME",
                blob = "BLOB"
            }

            local sqlType = typeMap[columnType:lower()]
            if not sqlType then
                d:reject("Unsupported column type '" .. columnType .. "'")
                return
            end

            local colDef = lia.db.escapeIdentifier(columnName) .. " " .. sqlType
            if options.unique then colDef = colDef .. " UNIQUE" end
            if options.not_null or options.required then colDef = colDef .. " NOT NULL" end
            if options.default ~= nil then
                if columnType:lower() == "string" or columnType:lower() == "text" then
                    colDef = colDef .. " DEFAULT '" .. sqliteEscape(tostring(options.default)) .. "'"
                elseif columnType:lower() == "boolean" or columnType:lower() == "bool" then
                    colDef = colDef .. " DEFAULT " .. (options.default and "1" or "0")
                elseif columnType:lower() == "integer" or columnType:lower() == "int" then
                    local num = tonumber(options.default)
                    if num then colDef = colDef .. " DEFAULT " .. math.floor(num) end
                elseif columnType:lower() == "float" or columnType:lower() == "double" then
                    local num = tonumber(options.default)
                    if num then colDef = colDef .. " DEFAULT " .. num end
                else
                    colDef = colDef .. " DEFAULT " .. tostring(options.default)
                end
            end

            if options.auto_increment and (columnType:lower() == "integer" or columnType:lower() == "int") then colDef = colDef .. " AUTOINCREMENT" end
            local alterQuery = "ALTER TABLE " .. fullTableName .. " ADD COLUMN " .. colDef
            lia.db.query(alterQuery, function()
                if options.index then
                    local indexName = fullTableName .. "_" .. columnName .. "_idx"
                    local indexType = options.unique_index and "UNIQUE INDEX" or "INDEX"
                    local indexQuery = "CREATE " .. indexType .. " IF NOT EXISTS " .. indexName .. " ON " .. fullTableName .. "(" .. lia.db.escapeIdentifier(columnName) .. ")"
                    lia.db.query(indexQuery, function()
                        if lia.db.cacheClear then lia.db.cacheClear() end
                        d:resolve({
                            success = true,
                            table = fullTableName,
                            column = columnName,
                            type = columnType,
                            indexed = true
                        })
                    end, function(err)
                        if lia.db.cacheClear then lia.db.cacheClear() end
                        d:resolve({
                            success = true,
                            table = fullTableName,
                            column = columnName,
                            type = columnType,
                            indexed = false,
                            index_error = err
                        })
                    end)
                else
                    if lia.db.cacheClear then lia.db.cacheClear() end
                    d:resolve({
                        success = true,
                        table = fullTableName,
                        column = columnName,
                        type = columnType,
                        indexed = false
                    })
                end
            end, function(err) d:reject("Failed to add column '" .. columnName .. "' to table '" .. fullTableName .. "': " .. err) end)
        end):catch(function(err) d:reject("Failed to check if column exists: " .. err) end)
    end):catch(function(err) d:reject("Failed to check if table exists: " .. err) end)
    return d
end

function lia.db.removeTable(tableName)
    local d = deferred.new()
    local fullTableName = "lia_" .. tableName
    lia.db.tableExists(fullTableName):next(function(exists)
        if not exists then
            d:resolve(false)
            return
        end

        lia.db.getTableColumns(fullTableName):next(function(columns)
            local _ = columns and table.Count(columns) or 0
            lia.db.query("DROP TABLE " .. fullTableName, function()
                if lia.db.cacheClear then lia.db.cacheClear() end
                d:resolve(true)
            end, function(err) d:reject(err) end)
        end):catch(function(err) d:reject(err) end)
    end):catch(function(err) d:reject(err) end)
    return d
end

function lia.db.removeColumn(tableName, columnName)
    local d = deferred.new()
    local fullTableName = "lia_" .. tableName
    lia.db.tableExists(fullTableName):next(function(tableExists)
        if not tableExists then
            d:resolve(false)
            return
        end

        lia.db.fieldExists(fullTableName, columnName):next(function(columnExists)
            if not columnExists then
                d:resolve(false)
                return
            end

            lia.db.query("PRAGMA table_info(" .. fullTableName .. ")", function(columns)
                if not columns then
                    d:reject("Failed to get table info")
                    return
                end

                local newColumns = {}
                for _, col in ipairs(columns) do
                    if col.name ~= columnName then
                        local colDef = col.name .. " " .. col.type
                        if col.notnull == 1 then colDef = colDef .. " NOT NULL" end
                        if col.dflt_value then colDef = colDef .. " DEFAULT " .. col.dflt_value end
                        if col.pk == 1 then colDef = colDef .. " PRIMARY KEY" end
                        table.insert(newColumns, colDef)
                    end
                end

                if #newColumns == 0 then
                    d:reject("Cannot remove the last column from table")
                    return
                end

                local tempTableName = fullTableName .. "_temp_" .. os.time()
                local createTempQuery = "CREATE TABLE " .. tempTableName .. " (" .. table.concat(newColumns, ", ") .. ")"
                local insertQuery = "INSERT INTO " .. tempTableName .. " SELECT " .. table.concat(newColumns, ", ") .. " FROM " .. fullTableName
                local dropOldQuery = "DROP TABLE " .. fullTableName
                local renameQuery = "ALTER TABLE " .. tempTableName .. " RENAME TO " .. fullTableName
                lia.db.transaction({createTempQuery, insertQuery, dropOldQuery, renameQuery}):next(function()
                    if lia.db.cacheClear then lia.db.cacheClear() end
                    d:resolve(true)
                end):catch(function() d:reject() end)
            end, function(err) d:reject(err) end)
        end):catch(function(err) d:reject(err) end)
    end):catch(function(err) d:reject(err) end)
    return d
end

function lia.db.GetCharacterTable(callback)
    lia.db.getTableColumns("lia_characters"):next(function(columnTypes)
        if not columnTypes then return callback({}) end
        local columns = {}
        for columnName, _ in pairs(columnTypes) do
            table.insert(columns, columnName)
        end

        callback(columns)
    end):catch(function() callback({}) end)
end

concommand.Add("lia_load_snapshot", function(ply, _, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_load_snapshot'\n")
        return
    end

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player ", IsValid(ply) and ply:Nick() or "Console", " initiated database snapshot loading\n")
    if #args < 1 then
        print("Usage: lia_load_snapshot <table_name> [timestamp]")
        print("Examples:")
        print("  lia_load_snapshot characters")
        print("  lia_load_snapshot characters 20241225_143022")
        return
    end

    local tableName = args[1]
    local timestamp = args[2]
    local function sendFeedback(msg)
        print("[DB Load] " .. msg)
    end

    local filename
    if timestamp then
        filename = "lilia/database/" .. tableName .. "_" .. timestamp .. ".txt"
    else
        local files = file.Find("lilia/database/" .. tableName .. "_*.txt", "DATA")
        if #files > 0 then
            table.sort(files, function(a, b) return a > b end)
            filename = "lilia/database/" .. files[1]
        end
    end

    if not filename then
        sendFeedback("No snapshot file found for table '" .. tableName .. "'", Color(255, 0, 0))
        return
    end

    sendFeedback("Loading snapshot from: " .. filename, Color(0, 255, 0))
    local content = file.Read(filename, "DATA")
    if not content then
        sendFeedback("Failed to read snapshot file: " .. filename, Color(255, 0, 0))
        return
    end

    local rows = {}
    local lineCount = 0
    for line in content:gmatch("[^\r\n]+") do
        lineCount = lineCount + 1
        if not line:match("^%s*%-%-") and line:trim() ~= "" then
            local insertPattern = "INSERT INTO lia_(%w+)%s*%((.+)%)%s*;"
            local stmtTable, valuesStr = line:match(insertPattern)
            if stmtTable and valuesStr then
                local row = {}
                for pair in valuesStr:gmatch("([^,]+)") do
                    pair = pair:trim()
                    local key, value = pair:match("(%w+)='([^']*)'")
                    if not key then key, value = pair:match("(%w+)=([^',]+)") end
                    if key and value then
                        if value == "NULL" then
                            row[key] = nil
                        elseif tonumber(value) then
                            row[key] = tonumber(value)
                        else
                            row[key] = value
                        end
                    end
                end

                if next(row) then table.insert(rows, row) end
            end
        end
    end

    if #rows == 0 then
        sendFeedback("No valid INSERT statements found in snapshot file", Color(255, 0, 0))
        return
    end

    sendFeedback("Found " .. #rows .. " rows to insert into lia_" .. tableName, Color(255, 255, 255))
    if SERVER and IsValid(ply) then
        ply:ChatPrint("WARNING: This will replace existing data in the table!")
        ply:ChatPrint("Use 'lia_clear_table " .. tableName .. "' first if you want to clear existing data")
    end

    lia.db.bulkInsert(tableName, rows):next(function() sendFeedback("? Successfully loaded " .. #rows .. " rows into lia_" .. tableName, Color(0, 255, 0)) end):catch(function(err) sendFeedback("? Failed to load snapshot: " .. err, Color(255, 0, 0)) end)
end)

concommand.Add("lia_clear_table", function(ply, _, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_clear_table'\n")
        return
    end

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player ", IsValid(ply) and ply:Nick() or "Console", " initiated table clearing\n")
    if #args < 1 then
        if SERVER and IsValid(ply) then
            ply:ChatPrint("Usage: lia_clear_table <table_name>")
            ply:ChatPrint("Example: lia_clear_table characters")
        end

        if CLIENT then
            print("Usage: lia_clear_table <table_name>")
            print("Example: lia_clear_table characters")
        end
        return
    end

    local tableName = args[1]
    local function sendFeedback(msg, color)
        if SERVER then
            print("[DB Clear] " .. msg)
            if IsValid(ply) then ply:ChatPrint(msg) end
        elseif CLIENT then
            print("[DB Clear] " .. msg)
            if color then
                chat.AddText(color, "[DB Clear] " .. msg)
            else
                chat.AddText(Color(255, 255, 255), "[DB Clear] " .. msg)
            end
        end
    end

    sendFeedback("Clearing all data from table: lia_" .. tableName, Color(255, 255, 0))
    if SERVER and IsValid(ply) then
        ply:ChatPrint("WARNING: This will DELETE ALL DATA from lia_" .. tableName .. "!")
        ply:ChatPrint("This action cannot be undone!")
    end

    lia.db.delete(tableName):next(function() sendFeedback("? Successfully cleared all data from lia_" .. tableName, Color(0, 255, 0)) end):catch(function(err) sendFeedback("? Failed to clear table: " .. err, Color(255, 0, 0)) end)
end)

concommand.Add("lia_list_snapshots", function(ply, _, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_list_snapshots'\n")
        return
    end

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player ", IsValid(ply) and ply:Nick() or "Console", " initiated snapshot listing\n")
    local tableFilter = args[1]
    local function sendFeedback(msg)
        print("[DB Snapshots] " .. msg)
    end

    sendFeedback("Listing available snapshot files...", Color(0, 255, 0))
    local pattern = tableFilter and ("*_" .. tableFilter .. "_*.txt") or "*.txt"
    local files = file.Find("lilia/database/" .. pattern, "DATA")
    if #files == 0 then
        sendFeedback("No snapshot files found" .. (tableFilter and " for table '" .. tableFilter .. "'" or ""), Color(255, 255, 0))
        return
    end

    local tableGroups = {}
    for _, filename in ipairs(files) do
        local tableName = filename:match("^(.-)_%d+_%d+%.txt$")
        if tableName then
            if not tableGroups[tableName] then tableGroups[tableName] = {} end
            table.insert(tableGroups[tableName], filename)
        end
    end

    sendFeedback("Found " .. #files .. " snapshot files:", Color(255, 255, 255))
    for _, fileList in pairs(tableGroups) do
        table.sort(fileList, function(a, b) return a > b end)
        for _, filename in ipairs(fileList) do
            local timestamp = filename:match("_(%d+_%d+)%.txt$")
            sendFeedback("  - " .. filename .. " (timestamp: " .. (timestamp or "unknown") .. ")", Color(255, 255, 255))
        end
    end

    sendFeedback("Use 'lia_load_snapshot <table> [timestamp]' to load a specific snapshot", Color(255, 255, 255))
end)

concommand.Add("lia_snapshot", function(ply)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_snapshot'\n")
        return
    end

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player ", IsValid(ply) and ply:Nick() or "Console", " initiated database snapshot creation\n")
    local function sendFeedback(msg)
        print("[DB Snapshot] " .. msg)
    end

    sendFeedback("Starting database snapshot of all lia_* tables...", Color(0, 255, 0))
    lia.db.getTables():next(function(tables)
        if #tables == 0 then
            sendFeedback("No lia_* tables found!", Color(255, 255, 0))
            return
        end

        sendFeedback("Found " .. #tables .. " tables: " .. table.concat(tables, ", "), Color(255, 255, 255))
        local completed = 0
        local total = #tables
        local timestamp = os.date("%Y%m%d_%H%M%S")
        for _, tableName in ipairs(tables) do
            lia.db.select("*", tableName:gsub("lia_", "")):next(function(selectResult)
                if selectResult and selectResult.results then
                    local shortName = tableName:gsub("lia_", "")
                    local filename = "lilia/database/" .. shortName .. "_" .. timestamp .. ".txt"
                    local content = "Database snapshot for table: " .. tableName .. "\n"
                    content = content .. "Generated on: " .. os.date() .. "\n"
                    content = content .. "Total records: " .. #selectResult.results .. "\n\n"
                    for _, row in ipairs(selectResult.results) do
                        local rowData = {}
                        for k, v in pairs(row) do
                            if isstring(v) then
                                rowData[#rowData + 1] = string.format("%s='%s'", k, v:gsub("'", "''"))
                            elseif isnumber(v) then
                                rowData[#rowData + 1] = string.format("%s=%s", k, tostring(v))
                            elseif v == nil then
                                rowData[#rowData + 1] = string.format("%s=NULL", k)
                            else
                                rowData[#rowData + 1] = string.format("%s='%s'", k, tostring(v):gsub("'", "''"))
                            end
                        end

                        content = content .. "INSERT INTO " .. tableName .. " (" .. table.concat(rowData, ", ") .. ");\n"
                    end

                    file.Write(filename, content)
                    sendFeedback("? Saved " .. #result.results .. " records from " .. tableName .. " to " .. filename, Color(0, 255, 0))
                else
                    sendFeedback("? Failed to query table: " .. tableName, Color(255, 0, 0))
                end

                completed = completed + 1
                if completed >= total then sendFeedback("Snapshot creation completed for all tables", Color(0, 255, 0)) end
            end):catch(function(err)
                sendFeedback("? Error processing table " .. tableName .. ": " .. err, Color(255, 0, 0))
                completed = completed + 1
                if completed >= total then sendFeedback("Snapshot creation completed with errors", Color(255, 255, 0)) end
            end)
        end
    end):catch(function(err) sendFeedback("? Failed to get table list: " .. err, Color(255, 0, 0)) end)
end)

concommand.Add("lia_snapshot_table", function(ply, _, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_snapshot_table'\n")
        return
    end

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player ", IsValid(ply) and ply:Nick() or "Console", " initiated table snapshot creation\n")
    if #args == 0 then
        print("Usage: lia_snapshot_table <table_name> [table_name2] [table_name3] ...")
        return
    end

    local function sendFeedback(msg)
        print("[DB Snapshot] " .. msg)
    end

    local tablesToSnapshot = {}
    for _, tableName in ipairs(args) do
        if tableName:StartWith("lia_") then
            table.insert(tablesToSnapshot, tableName:gsub("lia_", ""))
        else
            table.insert(tablesToSnapshot, tableName)
        end
    end

    sendFeedback("Starting database snapshot for tables: " .. table.concat(tablesToSnapshot, ", "), Color(0, 255, 0))
    local completed = 0
    local total = #tablesToSnapshot
    local timestamp = os.date("%Y%m%d_%H%M%S")
    for _, tableName in ipairs(tablesToSnapshot) do
        lia.db.select("*", tableName):next(function(selectResult)
            if selectResult and selectResult.results then
                local fullTableName = "lia_" .. tableName
                local filename = "lilia/database/" .. tableName .. "_" .. timestamp .. ".txt"
                local content = "Database snapshot for table: " .. fullTableName .. "\n"
                content = content .. "Generated on: " .. os.date() .. "\n"
                content = content .. "Total records: " .. #selectResult.results .. "\n\n"
                for _, row in ipairs(selectResult.results) do
                    local rowData = {}
                    for k, v in pairs(row) do
                        if isstring(v) then
                            rowData[#rowData + 1] = string.format("%s='%s'", k, v:gsub("'", "''"))
                        elseif isnumber(v) then
                            rowData[#rowData + 1] = string.format("%s=%s", k, tostring(v))
                        elseif v == nil then
                            rowData[#rowData + 1] = string.format("%s=NULL", k)
                        else
                            rowData[#rowData + 1] = string.format("%s='%s'", k, tostring(v):gsub("'", "''"))
                        end
                    end

                    content = content .. "INSERT INTO " .. fullTableName .. " (" .. table.concat(rowData, ", ") .. ");\n"
                end

                file.Write(filename, content)
            else
                sendFeedback("? Failed to query table: lia_" .. tableName, Color(255, 0, 0))
            end

            completed = completed + 1
            if completed >= total then sendFeedback("Table snapshot creation completed for all specified tables", Color(0, 255, 0)) end
        end):catch(function(err)
            sendFeedback("? Error processing table lia_" .. tableName .. ": " .. err, Color(255, 0, 0))
            completed = completed + 1
            if completed >= total then sendFeedback("Table snapshot creation completed with errors", Color(255, 255, 0)) end
        end)
    end
end)

concommand.Add("lia_dbtest", function(ply)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_dbtest'\n")
        return
    end

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "=== Starting Comprehensive Database Test ===\n")
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player: ", IsValid(ply) and ply:Nick() or "Console", "\n")
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Timestamp: ", os.date("%Y-%m-%d %H:%M:%S"), "\n\n")
    local testResults = {
        total = 0,
        passed = 0,
        failed = 0,
        errors = {}
    }

    local function logTest(testName, success, message)
        testResults.total = testResults.total + 1
        if success then
            testResults.passed = testResults.passed + 1
            MsgC(Color(0, 255, 0), "[PASS] ", Color(255, 255, 255), testName, ": ", message or "OK", "\n")
        else
            testResults.failed = testResults.failed + 1
            MsgC(Color(255, 0, 0), "[FAIL] ", Color(255, 255, 255), testName, ": ", message or "FAILED", "\n")
            if message then
                table.insert(testResults.errors, {
                    test = testName,
                    error = message
                })
            end
        end
    end

    local function logSection(sectionName)
        MsgC(Color(255, 255, 0), "\n=== ", sectionName, " ===\n")
    end

    logSection("CACHE FUNCTIONS")
    local startTime = SysTime()
    lia.db.setCacheEnabled(true)
    logTest("Cache Enable", lia.db.cache.enabled == true, "Cache enabled successfully")
    lia.db.setCacheEnabled(false)
    logTest("Cache Disable", lia.db.cache.enabled == false, "Cache disabled successfully")
    lia.db.setCacheEnabled(true)
    lia.db.setCacheTTL(30)
    logTest("Cache TTL Set", lia.db.cache.ttl == 30, "TTL set to 30 seconds")
    lia.db.cacheSet("test_table", "test_key", {
        data = "test_value"
    })

    local cached = lia.db.cacheGet("test_key")
    logTest("Cache Set/Get", cached and cached.data == "test_value", "Cache set and retrieved successfully")
    lia.db.cacheClear()
    cached = lia.db.cacheGet("test_key")
    logTest("Cache Clear", cached == nil, "Cache cleared successfully")
    lia.db.cacheSet("test_table", "table_key", "table_value")
    lia.db.invalidateTable("test_table")
    cached = lia.db.cacheGet("table_key")
    logTest("Table Invalidation", cached == nil, "Table cache invalidated successfully")
    logTest("Cache Functions", true, string.format("Completed in %.3fs", SysTime() - startTime))
    logSection("UTILITY FUNCTIONS")
    startTime = SysTime()
    local escaped = lia.db.escape("test'value")
    logTest("SQL Escape", escaped == "test''value", "SQL escaping works correctly")
    local ident = lia.db.escapeIdentifier("test_field")
    logTest("Identifier Escape", ident == "`test_field`", "Identifier escaping works correctly")
    local converted = lia.db.convertDataType("test")
    logTest("String Conversion", converted == "'test'", "String conversion works")
    converted = lia.db.convertDataType(123)
    logTest("Number Conversion", converted == "123", "Number conversion works")
    converted = lia.db.convertDataType(nil)
    logTest("NULL Conversion", converted == "NULL", "NULL conversion works")
    converted = lia.db.convertDataType({
        key = "value"
    })

    logTest("Table Conversion", converted == "'{\"key\":\"value\"}'", "Table conversion works")
    logTest("Utility Functions", true, string.format("Completed in %.3fs", SysTime() - startTime))
    logSection("TABLE OPERATIONS")
    startTime = SysTime()
    lia.db.waitForTablesToLoad():next(function()
        if not lia.db.connected then
            logTest("Database Connection", false, "Database not connected")
            return
        end

        lia.db.tableExists("lia_characters"):next(function(exists) logTest("Table Exists Check", exists, "lia_characters table exists") end):catch(function(err) logTest("Table Exists Check", false, "Error: " .. err) end)
        lia.db.getTables():next(function(tables)
            local hasLiaTables = false
            for _, table in ipairs(tables) do
                if string.StartWith(table, "lia_") then
                    hasLiaTables = true
                    break
                end
            end

            logTest("Get Tables", hasLiaTables and #tables > 0, "Found " .. #tables .. " tables including lia_ tables")
        end):catch(function(err) logTest("Get Tables", false, "Error: " .. err) end)

        local testTableSchema = {
            {
                name = "id",
                type = "integer",
                auto_increment = true
            },
            {
                name = "name",
                type = "string"
            },
            {
                name = "value",
                type = "integer"
            }
        }

        lia.db.createTable("dbtest_temp", "id", testTableSchema):next(function(result) logTest("Create Table", result.success, "Test table created successfully") end):catch(function(err) logTest("Create Table", false, "Error creating table: " .. err) end)
        timer.Simple(0.1, function() lia.db.removeTable("dbtest_temp"):next(function(success) logTest("Remove Table", success, "Test table removed successfully") end):catch(function(err) logTest("Remove Table", false, "Error removing table: " .. err) end) end)
        logTest("Table Operations", true, string.format("Completed in %.3fs", SysTime() - startTime))
    end):catch(function(err) logTest("Table Operations", false, "Error waiting for tables to load: " .. err) end)

    logSection("COLUMN OPERATIONS")
    startTime = SysTime()
    lia.db.createTable("dbtest_columns", "id", {
        {
            name = "id",
            type = "integer",
            auto_increment = true
        },
        {
            name = "name",
            type = "string"
        }
    }):next(function()
        logTest("Column Test Table", true, "Column test table created")
        lia.db.fieldExists("lia_dbtest_columns", "name"):next(function(exists) logTest("Field Exists", exists, "Field existence check works") end):catch(function(err) logTest("Field Exists", false, "Error: " .. err) end)
        lia.db.createColumn("dbtest_columns", "test_column", "string"):next(function(result) logTest("Create Column", result and result.success, "Column created successfully") end):catch(function(err) logTest("Create Column", false, "Error: " .. err) end)
        lia.db.getTableColumns("lia_dbtest_columns"):next(function(columns) logTest("Get Table Columns", columns and type(columns) == "table", "Retrieved " .. table.Count(columns) .. " columns") end):catch(function(err) logTest("Get Table Columns", false, "Error: " .. err) end)
        timer.Simple(0.2, function() lia.db.removeColumn("dbtest_columns", "test_column"):next(function(success) logTest("Remove Column", success, "Column removed successfully") end):catch(function(err) logTest("Remove Column", false, "Error: " .. err) end) end)
    end):catch(function(err) logTest("Column Test Table", false, "Error creating column test table: " .. err) end)

    timer.Simple(0.5, function() lia.db.removeTable("dbtest_columns"):next(function() logTest("Column Test Cleanup", true, "Column test table cleaned up") end):catch(function(err) logTest("Column Test Cleanup", false, "Error cleaning up: " .. err) end) end)
    logTest("Column Operations", true, string.format("Completed in %.3fs", SysTime() - startTime))
    logSection("DATA OPERATIONS")
    startTime = SysTime()
    lia.db.createTable("dbtest_data", "id", {
        {
            name = "id",
            type = "integer",
            auto_increment = true
        },
        {
            name = "name",
            type = "string"
        },
        {
            name = "value",
            type = "integer"
        }
    }):next(function()
        logTest("Data Test Table", true, "Data test table created")
        lia.db.delete("dbtest_data"):next(function()
            lia.db.insertTable({
                name = "test_item",
                value = 42
            }, nil, "dbtest_data"):next(function() logTest("Insert Data", true, "Data inserted successfully") end):catch(function(err) logTest("Insert Data", false, "Error: " .. err) end)

            lia.db.select("*", "dbtest_data"):next(function(result) logTest("Select Data", result.results and #result.results > 0, "Data selected successfully") end):catch(function(err) logTest("Select Data", false, "Error: " .. err) end)
            lia.db.selectOne("*", "dbtest_data"):next(function(row) logTest("Select One", row and row.name == "test_item", "Single row selected successfully") end):catch(function(err) logTest("Select One", false, "Error: " .. err) end)
            lia.db.count("dbtest_data"):next(function(count) logTest("Count Records", count > 0, "Counted " .. count .. " records") end):catch(function(err) logTest("Count Records", false, "Error: " .. err) end)
            lia.db.exists("dbtest_data", "name = 'test_item'"):next(function(exists) logTest("Exists Check", exists, "Record existence check works") end):catch(function(err) logTest("Exists Check", false, "Error: " .. err) end)
            lia.db.updateTable({
                value = 100
            }, nil, "dbtest_data", "name = 'test_item'"):next(function() logTest("Update Data", true, "Data updated successfully") end):catch(function(err) logTest("Update Data", false, "Error: " .. err) end)

            local bulkData = {
                {
                    name = "bulk1",
                    value = 1
                },
                {
                    name = "bulk2",
                    value = 2
                },
                {
                    name = "bulk3",
                    value = 3
                }
            }

            lia.db.bulkInsert("dbtest_data", bulkData):next(function() logTest("Bulk Insert", true, "Bulk insert completed successfully") end):catch(function(err) logTest("Bulk Insert", false, "Error: " .. err) end)
            lia.db.upsert({
                name = "upsert_test",
                value = 999
            }, "dbtest_data"):next(function() logTest("Upsert", true, "Upsert completed successfully") end):catch(function(err) logTest("Upsert", false, "Error: " .. err) end)

            lia.db.insertOrIgnore({
                name = "upsert_test",
                value = 888
            }, "dbtest_data"):next(function() logTest("Insert or Ignore", true, "Insert or ignore completed successfully") end):catch(function(err) logTest("Insert or Ignore", false, "Error: " .. err) end)

            lia.db.delete("dbtest_data", "name = 'test_item'"):next(function() logTest("Delete Data", true, "Data deleted successfully") end):catch(function(err) logTest("Delete Data", false, "Error: " .. err) end)
        end):catch(function(err) logTest("Data Clear", false, "Error clearing data: " .. err) end)
    end):catch(function(err) logTest("Data Test Table", false, "Error creating data test table: " .. err) end)

    timer.Simple(1.0, function() lia.db.removeTable("dbtest_data"):next(function() logTest("Data Test Cleanup", true, "Data test table cleaned up") end):catch(function(err) logTest("Data Test Cleanup", false, "Error cleaning up: " .. err) end) end)
    logTest("Data Operations", true, string.format("Completed in %.3fs", SysTime() - startTime))
    logSection("TRANSACTION OPERATIONS")
    startTime = SysTime()
    lia.db.createTable("dbtest_transaction", "id", {
        {
            name = "id",
            type = "integer",
            auto_increment = true
        },
        {
            name = "name",
            type = "string"
        }
    }):next(function()
        logTest("Transaction Table", true, "Transaction test table created")
        lia.db.delete("dbtest_transaction"):next(function()
            local transactionQueries = {"INSERT INTO lia_dbtest_transaction (name) VALUES ('transaction1')", "INSERT INTO lia_dbtest_transaction (name) VALUES ('transaction2')", "INSERT INTO lia_dbtest_transaction (name) VALUES ('transaction3')"}
            lia.db.transaction(transactionQueries):next(function()
                logTest("Transaction", true, "Transaction completed successfully")
                lia.db.count("dbtest_transaction"):next(function(count) logTest("Transaction Verification", count == 3, "Transaction inserted " .. count .. " records") end):catch(function(err) logTest("Transaction Verification", false, "Error: " .. err) end)
            end):catch(function(err) logTest("Transaction", false, "Error: " .. err) end)
        end):catch(function(err) logTest("Transaction Clear", false, "Error clearing table: " .. err) end)
    end):catch(function(err) logTest("Transaction Table", false, "Error creating transaction table: " .. err) end)

    timer.Simple(1.5, function() lia.db.removeTable("dbtest_transaction"):next(function() logTest("Transaction Cleanup", true, "Transaction test table cleaned up") end):catch(function(err) logTest("Transaction Cleanup", false, "Error cleaning up: " .. err) end) end)
    logTest("Transaction Operations", true, string.format("Completed in %.3fs", SysTime() - startTime))
    logSection("SCHEMA & MIGRATION")
    startTime = SysTime()
    lia.db.addExpectedSchema("test_schema", {
        id = {
            type = "integer",
            auto_increment = true
        },
        name = {
            type = "string"
        }
    })

    logTest("Add Expected Schema", lia.db.expectedSchemas and lia.db.expectedSchemas.test_schema, "Schema added successfully")
    logTest("Migration Functions", true, "Migration functions are available (skipped execution to avoid table modifications)")
    logTest("Schema & Migration", true, string.format("Completed in %.3fs", SysTime() - startTime))
    timer.Simple(2.0, function()
        logSection("TEST SUMMARY")
        MsgC(Color(255, 255, 255), "Total Tests: ", Color(0, 255, 0), testResults.total, "\n")
        MsgC(Color(255, 255, 255), "Passed: ", Color(0, 255, 0), testResults.passed, "\n")
        MsgC(Color(255, 255, 255), "Failed: ", Color(255, 0, 0), testResults.failed, "\n")
        if testResults.failed > 0 then
            MsgC(Color(255, 0, 0), "\n=== ERRORS ===\n")
            for _, error in ipairs(testResults.errors) do
                MsgC(Color(255, 0, 0), error.test, ": ", error.error, "\n")
            end
        end

        local successRate = (testResults.passed / testResults.total) * 100
        if successRate >= 90 then
            MsgC(Color(0, 255, 0), "\n=== RESULT: EXCELLENT ===", "\n")
            MsgC(Color(0, 255, 0), string.format("Database functions are working correctly (%.1f%% success rate)", successRate), "\n")
        elseif successRate >= 75 then
            MsgC(Color(255, 255, 0), "\n=== RESULT: GOOD ===", "\n")
            MsgC(Color(255, 255, 0), string.format("Most database functions are working (%.1f%% success rate)", successRate), "\n")
        else
            MsgC(Color(255, 0, 0), "\n=== RESULT: ISSUES DETECTED ===", "\n")
            MsgC(Color(255, 0, 0), string.format("Database functions have issues (%.1f%% success rate)", successRate), "\n")
        end

        MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "=== Database Test Completed ===\n")
    end)
end)

concommand.Add("lia_list_tables", function(ply)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_list_tables'\n")
        return
    end

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "=== Listing All lia_* Tables ===\n")
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player: ", IsValid(ply) and ply:Nick() or "Console", "\n")
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Timestamp: ", os.date("%Y-%m-%d %H:%M:%S"), "\n\n")
    lia.db.waitForTablesToLoad():next(function()
        if not lia.db.connected then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Database not connected!\n")
            return
        end

        lia.db.getTables():next(function(tables)
            if not tables or #tables == 0 then
                MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "No lia_* tables found!\n")
                return
            end

            MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Found ", #tables, " lia_* tables in the database:\n\n")
            table.sort(tables)
            local processedTables = 0
            local totalColumns = 0
            for i, tableName in ipairs(tables) do
                local shortName = tableName:gsub("^lia_", "")
                lia.db.getTableColumns(tableName):next(function(columns)
                    processedTables = processedTables + 1
                    local columnCount = 0
                    local columnNames = {}
                    if columns then
                        for columnName, _ in pairs(columns) do
                            columnCount = columnCount + 1
                            table.insert(columnNames, columnName)
                        end

                        totalColumns = totalColumns + columnCount
                        table.sort(columnNames)
                    end

                    local status = columnCount > 0 and "ACTIVE" or "EMPTY"
                    local statusColor = columnCount > 0 and Color(0, 255, 0) or Color(255, 255, 0)
                    MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "┌─ ", tableName, " (", shortName, ") ─", string.rep("─", math.max(0, 50 - #tableName - #shortName)), "┐\n")
                    MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "│ Columns: ", columnCount, " | Status: ", "")
                    MsgC(statusColor, status, "")
                    MsgC(Color(255, 255, 255), " │\n")
                    if columnCount > 0 then
                        MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "├─ Column Names:", string.rep("─", 60), "┤\n")
                        for j = 1, #columnNames, 4 do
                            local rowColumns = {}
                            for k = j, math.min(j + 3, #columnNames) do
                                table.insert(rowColumns, columnNames[k])
                            end

                            local columnLine = "│ "
                            for k, colName in ipairs(rowColumns) do
                                columnLine = columnLine .. string.format("%-15s", colName)
                                if k < #rowColumns then columnLine = columnLine .. " │ " end
                            end

                            local remainingSpace = 75 - #columnLine + 1
                            if remainingSpace > 0 then columnLine = columnLine .. string.rep(" ", remainingSpace) end
                            columnLine = columnLine .. "│"
                            MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), columnLine, "\n")
                        end
                    else
                        MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "│ No columns found", string.rep(" ", 58), "│\n")
                    end

                    MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "└", string.rep("─", 75), "┘\n")
                    if i < #tables then MsgC(Color(128, 128, 128), "[Lilia] ", Color(128, 128, 128), string.rep("─", 80), "\n") end
                    if processedTables >= #tables then
                        MsgC(Color(255, 255, 0), "\n[Lilia] ", Color(255, 255, 255), "=== SUMMARY ===\n")
                        MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "Total Tables: ", #tables, "\n")
                        MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "Total Columns: ", totalColumns, "\n")
                        MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "Average Columns per Table: ", math.floor(totalColumns / #tables), "\n")
                        MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "=== Table Listing Completed ===\n")
                    end
                end):catch(function(err)
                    processedTables = processedTables + 1
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "┌─ ", tableName, " (", shortName, ") ─", string.rep("─", math.max(0, 50 - #tableName - #shortName)), "┐\n")
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "│ ERROR: Failed to get columns", string.rep(" ", 45), "│\n")
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "│ ", err, string.rep(" ", math.max(0, 70 - #tostring(err))), "│\n")
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "└", string.rep("─", 75), "┘\n")
                    if i < #tables then MsgC(Color(128, 128, 128), "[Lilia] ", Color(128, 128, 128), string.rep("─", 80), "\n") end
                    if processedTables >= #tables then MsgC(Color(255, 255, 0), "\n[Lilia] ", Color(255, 255, 255), "=== Table Listing Completed with Errors ===\n") end
                end)
            end
        end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get table list: ", err, "\n") end)
    end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to wait for database tables to load: ", err, "\n") end)
end)

concommand.Add("lia_list_columns", function(ply, _, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_list_columns'\n")
        return
    end

    if #args < 1 then
        MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Usage: lia_list_columns <table_name>\n")
        MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Example: lia_list_columns characters\n")
        MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Example: lia_list_columns lia_characters\n")
        return
    end

    local tableName = args[1]
    local fullTableName = tableName
    if not tableName:StartWith("lia_") then fullTableName = "lia_" .. tableName end
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "=== Listing Columns for Table: ", fullTableName, " ===\n")
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player: ", IsValid(ply) and ply:Nick() or "Console", "\n")
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Timestamp: ", os.date("%Y-%m-%d %H:%M:%S"), "\n\n")
    lia.db.waitForTablesToLoad():next(function()
        if not lia.db.connected then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Database not connected!\n")
            return
        end

        lia.db.tableExists(fullTableName):next(function(exists)
            if not exists then
                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Table '", fullTableName, "' does not exist!\n")
                MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Available lia_* tables:\n")
                lia.db.getTables():next(function(tables)
                    if tables and #tables > 0 then
                        for _, tbl in ipairs(tables) do
                            MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "  - ", tbl, "\n")
                        end
                    else
                        MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "  No lia_* tables found\n")
                    end
                end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get table list: ", err, "\n") end)
                return
            end

            lia.db.getTableColumns(fullTableName):next(function(columns)
                if not columns then
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get columns for table: ", fullTableName, "\n")
                    return
                end

                local columnCount = 0
                for _ in pairs(columns) do
                    columnCount = columnCount + 1
                end

                MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Found ", columnCount, " columns in table '", fullTableName, "':\n\n")
                lia.db.query("PRAGMA table_info(" .. fullTableName .. ")"):next(function(result)
                    if not result or not result.results then
                        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get detailed column information\n")
                        return
                    end

                    local columnData = result.results
                    table.sort(columnData, function(a, b) return a.cid < b.cid end)
                    MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), string.format("%-20s %-15s %-8s %-8s %-8s %-10s", "Column Name", "Type", "Not Null", "Default", "Primary Key", "Auto Inc"), "\n")
                    MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), string.rep("-", 80), "\n")
                    for _, col in ipairs(columnData) do
                        local notNull = col.notnull == 1 and "YES" or "NO"
                        local defaultValue = col.dflt_value or "NULL"
                        local primaryKey = col.pk == 1 and "YES" or "NO"
                        local autoIncrement = col.type:lower():find("auto") and "YES" or "NO"
                        MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), string.format("%-20s %-15s %-8s %-8s %-8s %-10s", col.name, col.type, notNull, defaultValue, primaryKey, autoIncrement), "\n")
                    end

                    MsgC(Color(255, 255, 0), "\n[Lilia] ", Color(255, 255, 255), "=== Column Listing Completed ===\n")
                end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get detailed column information: ", err, "\n") end)
            end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get columns for table '", fullTableName, "': ", err, "\n") end)
        end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to check if table exists: ", err, "\n") end)
    end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to wait for database tables to load: ", err, "\n") end)
end)

concommand.Add("lia_remove_column_underscores", function(ply)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("This command requires super admin privileges.")
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Access denied: Player ", ply:Nick(), " attempted to use command 'lia_remove_column_underscores'\n")
        return
    end

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "=== Starting Column Underscore Removal ===\n")
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Player: ", IsValid(ply) and ply:Nick() or "Console", "\n")
    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Timestamp: ", os.date("%Y-%m-%d %H:%M:%S"), "\n\n")
    lia.db.waitForTablesToLoad():next(function()
        if not lia.db.connected then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Database not connected!\n")
            return
        end

        MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Scanning lia_* tables for columns with leading underscores...\n")
        lia.db.getTables():next(function(tables)
            if not tables or #tables == 0 then
                MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "No tables found!\n")
                return
            end

            local totalTables = #tables
            local processedTables = 0
            local totalColumnsRemoved = 0
            MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "Found ", totalTables, " lia_* tables to process\n\n")
            for _, tableName in ipairs(tables) do
                lia.db.getTableColumns(tableName):next(function(columns)
                    processedTables = processedTables + 1
                    if not columns then
                        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get columns for table: ", tableName, "\n")
                        return
                    end

                    local columnsToRemove = {}
                    local columnsToRename = {}
                    for columnName, columnType in pairs(columns) do
                        if columnName:sub(1, 1) == "_" then
                            local newColumnName = columnName:gsub("^_+", "")
                            if newColumnName ~= columnName then
                                if columns[newColumnName] then
                                    table.insert(columnsToRemove, {
                                        oldName = columnName,
                                        newName = newColumnName,
                                        type = columnType
                                    })
                                else
                                    table.insert(columnsToRename, {
                                        oldName = columnName,
                                        newName = newColumnName,
                                        type = columnType
                                    })
                                end
                            end
                        end
                    end

                    if #columnsToRemove == 0 and #columnsToRename == 0 then
                        MsgC(Color(255, 255, 255), "[Lilia] ", Color(255, 255, 255), "Table ", tableName, ": No columns with leading underscores found\n")
                        return
                    end

                    local totalColumns = #columnsToRemove + #columnsToRename
                    MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Table ", tableName, ": Found ", totalColumns, " columns to process (", #columnsToRemove, " to remove, ", #columnsToRename, " to rename)\n")
                    local processPromises = {}
                    for _, columnInfo in ipairs(columnsToRemove) do
                        local processPromise = deferred.new()
                        table.insert(processPromises, processPromise)
                        local shortTableName = tableName:gsub("^lia_", "")
                        lia.db.removeColumn(shortTableName, columnInfo.oldName):next(function(removeResult)
                            if removeResult then
                                MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "  ✓ Removed duplicate column ", columnInfo.oldName, " (", columnInfo.newName, " already exists) in ", tableName, "\n")
                                totalColumnsRemoved = totalColumnsRemoved + 1
                                processPromise:resolve()
                            else
                                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "  ✗ Failed to remove duplicate column ", columnInfo.oldName, " from ", tableName, "\n")
                                processPromise:reject("Failed to remove duplicate column")
                            end
                        end):catch(function(err)
                            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "  ✗ Failed to remove column ", columnInfo.oldName, " from ", tableName, ": ", err, "\n")
                            processPromise:reject(err)
                        end)
                    end

                    for _, columnInfo in ipairs(columnsToRename) do
                        local processPromise = deferred.new()
                        table.insert(processPromises, processPromise)
                        local shortTableName = tableName:gsub("^lia_", "")
                        local createColumnPromise = lia.db.createColumn(shortTableName, columnInfo.newName, columnInfo.type:lower())
                        createColumnPromise:next(function(createResult)
                            if createResult and createResult.success then
                                local updateQuery = "UPDATE " .. tableName .. " SET " .. lia.db.escapeIdentifier(columnInfo.newName) .. " = " .. lia.db.escapeIdentifier(columnInfo.oldName)
                                lia.db.query(updateQuery):next(function()
                                    lia.db.removeColumn(shortTableName, columnInfo.oldName):next(function(removeResult)
                                        if removeResult then
                                            MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "  ✓ Renamed ", columnInfo.oldName, " -> ", columnInfo.newName, " in ", tableName, "\n")
                                            totalColumnsRemoved = totalColumnsRemoved + 1
                                            processPromise:resolve()
                                        else
                                            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "  ✗ Failed to remove old column ", columnInfo.oldName, " from ", tableName, "\n")
                                            processPromise:reject("Failed to remove old column")
                                        end
                                    end):catch(function(err)
                                        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "  ✗ Failed to remove column ", columnInfo.oldName, " from ", tableName, ": ", err, "\n")
                                        processPromise:reject(err)
                                    end)
                                end):catch(function(err)
                                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "  ✗ Failed to copy data for ", columnInfo.oldName, " in ", tableName, ": ", err, "\n")
                                    processPromise:reject(err)
                                end)
                            else
                                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "  ✗ Failed to create new column ", columnInfo.newName, " in ", tableName, ": ", createResult and createResult.message or "Unknown error", "\n")
                                processPromise:reject(createResult and createResult.message or "Unknown error")
                            end
                        end):catch(function(err)
                            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "  ✗ Failed to create column ", columnInfo.newName, " in ", tableName, ": ", err, "\n")
                            processPromise:reject(err)
                        end)
                    end

                    deferred.all(processPromises):next(function() MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Table ", tableName, ": Successfully processed ", totalColumns, " columns\n\n") end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Table ", tableName, ": Some column operations failed: ", err, "\n\n") end)
                end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get columns for table ", tableName, ": ", err, "\n") end)
            end

            timer.Simple(2.0, function()
                MsgC(Color(255, 255, 0), "\n[Lilia] ", Color(255, 255, 255), "=== Column Underscore Removal Summary ===\n")
                MsgC(Color(255, 255, 255), "lia_* tables processed: ", totalTables, "\n")
                MsgC(Color(255, 255, 255), "Columns processed: ", totalColumnsRemoved, "\n")
                if totalColumnsRemoved > 0 then
                    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "✓ Successfully processed ", totalColumnsRemoved, " column(s) across ", totalTables, " lia_* table(s)\n")
                else
                    MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "! No columns with leading underscores were found to process in lia_* tables\n")
                end

                MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "=== Column Underscore Removal Completed ===\n")
            end)
        end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to get table list: ", err, "\n") end)
    end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Failed to wait for database tables to load: ", err, "\n") end)
end)

function lia.db.autoRemoveUnderscoreColumns()
    local d = deferred.new()
    if not lia.db.connected then
        d:resolve()
        return d
    end

    lia.db.getTables():next(function(tables)
        if not tables or #tables == 0 then
            d:resolve()
            return
        end

        local totalColumnsRemoved = 0
        local processPromises = {}
        for _, tableName in ipairs(tables) do
            local processPromise = deferred.new()
            table.insert(processPromises, processPromise)
            lia.db.getTableColumns(tableName):next(function(columns)
                if not columns then
                    processPromise:resolve()
                    return
                end

                local columnsToRemove = {}
                local columnsToRename = {}
                for columnName, columnType in pairs(columns) do
                    if columnName:sub(1, 1) == "_" then
                        local newColumnName = columnName:gsub("^_+", "")
                        if newColumnName ~= columnName then
                            if columns[newColumnName] then
                                table.insert(columnsToRemove, {
                                    oldName = columnName,
                                    newName = newColumnName,
                                    type = columnType
                                })
                            else
                                table.insert(columnsToRename, {
                                    oldName = columnName,
                                    newName = newColumnName,
                                    type = columnType
                                })
                            end
                        end
                    end
                end

                if #columnsToRemove == 0 and #columnsToRename == 0 then
                    processPromise:resolve()
                    return
                end

                local columnPromises = {}
                for _, columnInfo in ipairs(columnsToRemove) do
                    local columnPromise = deferred.new()
                    table.insert(columnPromises, columnPromise)
                    local shortTableName = tableName:gsub("^lia_", "")
                    lia.db.removeColumn(shortTableName, columnInfo.oldName):next(function(removeResult)
                        if removeResult then
                            totalColumnsRemoved = totalColumnsRemoved + 1
                            columnPromise:resolve()
                        else
                            columnPromise:reject("Failed to remove duplicate column")
                        end
                    end):catch(function(err) columnPromise:reject(err) end)
                end

                for _, columnInfo in ipairs(columnsToRename) do
                    local columnPromise = deferred.new()
                    table.insert(columnPromises, columnPromise)
                    local shortTableName = tableName:gsub("^lia_", "")
                    local createColumnPromise = lia.db.createColumn(shortTableName, columnInfo.newName, columnInfo.type:lower())
                    createColumnPromise:next(function(createResult)
                        if createResult and createResult.success then
                            local updateQuery = "UPDATE " .. tableName .. " SET " .. lia.db.escapeIdentifier(columnInfo.newName) .. " = " .. lia.db.escapeIdentifier(columnInfo.oldName)
                            lia.db.query(updateQuery):next(function()
                                lia.db.removeColumn(shortTableName, columnInfo.oldName):next(function(removeResult)
                                    if removeResult then
                                        totalColumnsRemoved = totalColumnsRemoved + 1
                                        columnPromise:resolve()
                                    else
                                        columnPromise:reject("Failed to remove old column")
                                    end
                                end):catch(function(err) columnPromise:reject(err) end)
                            end):catch(function(err) columnPromise:reject(err) end)
                        else
                            columnPromise:reject(createResult and createResult.message or "Unknown error")
                        end
                    end):catch(function(err) columnPromise:reject(err) end)
                end

                deferred.all(columnPromises):next(function() processPromise:resolve() end):catch(function() processPromise:resolve() end)
            end):catch(function() processPromise:resolve() end)
        end

        deferred.all(processPromises):next(function()
            if totalColumnsRemoved > 0 then MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Auto-removed ", totalColumnsRemoved, " underscore-prefixed column(s) on database connection\n") end
            d:resolve()
        end):catch(function() d:resolve() end)
    end):catch(function() d:resolve() end)
    return d
end