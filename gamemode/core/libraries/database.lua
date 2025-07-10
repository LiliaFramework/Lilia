lia.db = lia.db or {}
lia.db.queryQueue = lia.db.queue or {}
lia.db.prepared = lia.db.prepared or {}
MYSQLOO_QUEUE = MYSQLOO_QUEUE or {}
PREPARE_CACHE = {}
MYSQLOO_INTEGER = 0
MYSQLOO_STRING = 1
MYSQLOO_BOOL = 2
local modules = {}
local function ThrowQueryFault(query, fault)
    if string.find(fault, "duplicate column name:") or string.find(fault, "UNIQUE constraint failed: lia_config") then return end
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " * " .. query .. "\n")
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " " .. fault .. "\n")
end

local function ThrowConnectionFault(fault)
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " " .. L("dbConnectionFail") .. "\n")
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " " .. fault .. "\n")
    setNetVar("dbError", fault)
end

local function promisifyIfNoCallback(queryHandler)
    return function(query, callback)
        local d
        local function throw(err)
            if d then
                d:reject(err)
            else
                ThrowQueryFault(query, err)
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

modules.sqlite = {
    query = promisifyIfNoCallback(function(query, callback, throw)
        local data = sql.Query(query)
        local err = sql.LastError()
        if data == false then throw(err) end
        if callback then
            local lastID = tonumber(sql.QueryValue("SELECT last_insert_rowid()"))
            callback(data, lastID)
        end
    end),
    escape = function(value) return sql.SQLStr(value, true) end,
    connect = function(callback)
        lia.db.query = modules.sqlite.query
        if callback then callback() end
    end
}

modules.mysqloo = {
    query = promisifyIfNoCallback(function(query, callback, throw)
        if lia.db.getObject and lia.db.getObject() then
            local object = lia.db.getObject():query(query)
            if callback then
                function object:onSuccess(data)
                    callback(data, self:lastInsert())
                end
            end

            function object:onError(fault)
                if lia.db.getObject():status() == mysqloo.DATABASE_NOT_CONNECTED then
                    lia.db.queryQueue[#lia.db.queryQueue + 1] = {query, callback}
                    lia.db.connect(nil, true)
                    return
                end

                throw(fault)
            end

            object:start()
        else
            lia.db.queryQueue[#lia.db.queryQueue + 1] = {query, callback}
        end
    end),
    escape = function(value)
        local object = lia.db.getObject and lia.db.getObject()
        if object then
            return object:escape(value)
        else
            return sql.SQLStr(value, true)
        end
    end,
    queue = function()
        local count = 0
        for _, v in pairs(lia.db.pool) do
            count = count + v:queueSize()
        end
        return count
    end,
    abort = function()
        for _, v in pairs(lia.db.pool) do
            v:abortAllQueries()
        end
    end,
    getObject = function()
        local lowest = nil
        local lowestCount = 0
        local lowestIndex = 0
        for k, db in pairs(lia.db.pool) do
            local queueSize = db:queueSize()
            if not lowest or queueSize < lowestCount then
                lowest = db
                lowestCount = queueSize
                lowestIndex = k
            end
        end

        if not lowest then error(L("dbPoolFail")) end
        return lowest, lowestIndex
    end,
    connect = function(callback)
        if not pcall(require, "mysqloo") then return setNetVar("dbError", system.IsWindows() and "Server is missing VC++ redistributables! " or "Server is missing binaries for mysqloo! ") end
        if mysqloo.VERSION ~= "9" or not mysqloo.MINOR_VERSION or tonumber(mysqloo.MINOR_VERSION) < 1 then
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " " .. L("mysqlooOutdated") .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " " .. L("mysqlooDownload") .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " " .. L("mysqlooDownloadURL") .. "\n")
            return
        end

        local hostname = lia.db.hostname
        local username = lia.db.username
        local password = lia.db.password
        local database = lia.db.database
        local port = lia.db.port
        mysqloo.connect(hostname, username, password, database, port)
        lia.db.pool = {}
        local poolNum = 6
        local connectedPools = 0
        for i = 1, poolNum do
            lia.db.pool[i] = mysqloo.connect(hostname, username, password, database, port)
            local pool = lia.db.pool[i]
            pool:setAutoReconnect(true)
            pool:connect()
            function pool:onConnectionFailed(fault)
                ThrowConnectionFault(fault)
            end

            function pool:onConnected()
                pool:setCharacterSet("utf8")
                connectedPools = connectedPools + 1
                if connectedPools == poolNum then
                    lia.db.escape = modules.mysqloo.escape
                    lia.db.query = modules.mysqloo.query
                    lia.db.prepare = modules.mysqloo.prepare
                    lia.db.abort = modules.mysqloo.abort
                    lia.db.queue = modules.mysqloo.queue
                    lia.db.getObject = modules.mysqloo.getObject
                    lia.db.preparedCall = modules.mysqloo.preparedCall
                    if callback then callback() end
                    hook.Run("OnMySQLOOConnected")
                end
            end

            timer.Create("liaMySQLWakeUp" .. i, 600 + i, 0, function() pool:query("SELECT 1 + 1") end)
        end

        lia.db.object = lia.db.pool
    end,
    prepare = function(key, str, values)
        lia.db.prepared[key] = {
            query = str,
            values = values,
        }
    end,
    preparedCall = function(key, callback, ...)
        local preparedStatement = lia.db.prepared[key]
        if preparedStatement then
            local _, freeIndex = lia.db.getObject()
            PREPARE_CACHE[key] = PREPARE_CACHE[key] or {}
            PREPARE_CACHE[key][freeIndex] = PREPARE_CACHE[key][freeIndex] or lia.db.getObject():prepare(preparedStatement.query)
            local prepObj = PREPARE_CACHE[key][freeIndex]
            function prepObj:onSuccess(data)
                if callback then callback(data, self:lastInsert()) end
            end

            function prepObj:onError(err)
                ServerLog(err)
            end

            local arguments = {...}
            if table.Count(arguments) == table.Count(preparedStatement.values) then
                local index = 1
                for _, type in pairs(preparedStatement.values) do
                    if type == MYSQLOO_INTEGER then
                        prepObj:setNumber(index, arguments[index])
                    elseif type == MYSQLOO_STRING then
                        prepObj:setString(index, lia.db.convertDataType(arguments[index], true))
                    elseif type == MYSQLOO_BOOL then
                        prepObj:setBoolean(index, arguments[index])
                    end

                    index = index + 1
                end
            end

            prepObj:start()
        else
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), L("invalidPreparedStatement", key) .. "\n")
        end
    end
}

lia.db.escape = lia.db.escape or modules.sqlite.escape
lia.db.query = lia.db.query or function(...) lia.db.queryQueue[#lia.db.queryQueue + 1] = {...} end
function lia.db.connect(callback, reconnect)
    local dbModule = modules[lia.db.module]
    if dbModule then
        if (reconnect or not lia.db.connected) and not lia.db.object then
            dbModule.connect(function()
                lia.db.connected = true
                if isfunction(callback) then callback() end
                for i = 1, #lia.db.queryQueue do
                    lia.db.query(unpack(lia.db.queryQueue[i]))
                end

                lia.db.queryQueue = {}
            end)
        end

        lia.db.escape = dbModule.escape
        lia.db.query = dbModule.query
    else
        lia.error("[Lilia] '" .. (lia.db.module or "Unavailable") .. "' is not a valid data storage method! \n")
    end
end

function lia.db.wipeTables(callback)
    local function realCallback()
        if lia.db.module == "mysqloo" then
            lia.db.query("SET FOREIGN_KEY_CHECKS = 1;", function()
                MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " ALL LILIA DATA HAS BEEN WIPED\n")
                if isfunction(callback) then callback() end
            end)
        else
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " ALL LILIA DATA HAS BEEN WIPED\n")
            if isfunction(callback) then callback() end
        end
    end

    if lia.db.module == "mysqloo" then
        local function startDeleting()
            local queries = string.Explode(";", [[
    DROP TABLE IF EXISTS `lia_players`;
    DROP TABLE IF EXISTS `lia_characters`;
    DROP TABLE IF EXISTS `lia_inventories`;
    DROP TABLE IF EXISTS `lia_items`;
    DROP TABLE IF EXISTS `lia_invdata`;
    DROP TABLE IF EXISTS `lia_config`;
    DROP TABLE IF EXISTS `lia_data`;
    DROP TABLE IF EXISTS `lia_logs`;
]])
            local done = 0
            for i = 1, #queries do
                queries[i] = string.Trim(queries[i])
                if queries[i] == "" then
                    done = done + 1
                else
                    lia.db.query(queries[i], function()
                        done = done + 1
                        if done >= #queries then realCallback() end
                    end)
                end
            end
        end

        lia.db.query("SET FOREIGN_KEY_CHECKS = 0;", startDeleting)
    else
        lia.db.query([[
    DROP TABLE IF EXISTS lia_players;
    DROP TABLE IF EXISTS lia_characters;
    DROP TABLE IF EXISTS lia_inventories;
    DROP TABLE IF EXISTS lia_items;
    DROP TABLE IF EXISTS lia_invdata;
    DROP TABLE IF EXISTS lia_config;
    DROP TABLE IF EXISTS lia_data;
    DROP TABLE IF EXISTS lia_logs;
]], realCallback)
    end
end

function lia.db.loadTables()
    local function done()
        local ignore = function() end
        lia.db.query("ALTER TABLE IF EXISTS lia_players ADD COLUMN _firstJoin DATETIME"):catch(ignore)
        lia.db.query("ALTER TABLE IF EXISTS lia_players ADD COLUMN _lastJoin DATETIME"):catch(ignore)
        lia.db.query("ALTER TABLE IF EXISTS lia_items ADD COLUMN _quantity INTEGER"):catch(ignore)
        lia.db.addDatabaseFields()
        lia.db.tablesLoaded = true
        hook.Run("LiliaTablesLoaded")
    end

    if lia.db.module == "sqlite" then
        lia.db.query([[
            CREATE TABLE IF NOT EXISTS lia_players (
                _steamID varchar,
                _steamName varchar,
                _firstJoin datetime,
                _lastJoin datetime,
                _data varchar,
                _intro binary
            );

            CREATE TABLE IF NOT EXISTS lia_characters (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                _steamID VARCHAR,
                _name VARCHAR,
                _desc VARCHAR,
                _model VARCHAR,
                _attribs VARCHAR,
                _schema VARCHAR,
                _createTime DATETIME,
                _lastJoinTime DATETIME,
                _data VARCHAR,
                _money VARCHAR,
                _faction VARCHAR,
                recognition TEXT NOT NULL DEFAULT '',
                recognized_as TEXT NOT NULL DEFAULT ''
            );

            CREATE TABLE IF NOT EXISTS lia_inventories (
                _invID integer PRIMARY KEY AUTOINCREMENT,
                _charID integer,
                _invType varchar
            );

            CREATE TABLE IF NOT EXISTS lia_items (
                _itemID integer PRIMARY KEY AUTOINCREMENT,
                _invID integer,
                _uniqueID varchar,
                _data varchar,
                _quantity integer,
                _x integer,
                _y integer
            );

            CREATE TABLE IF NOT EXISTS lia_invdata (
                _invID integer,
                _key text,
                _value text,
                FOREIGN KEY(_invID) REFERENCES lia_inventories(_invID),
                PRIMARY KEY (_invID, _key)
            );

            CREATE TABLE IF NOT EXISTS lia_config (
                _schema text,
                _key text,
                _value text,
                PRIMARY KEY (_schema, _key)
            );

            CREATE TABLE IF NOT EXISTS lia_data (
                _key text,
                _folder text,
                _map text,
                _value text,
                PRIMARY KEY (_key, _folder, _map)
            );

            CREATE TABLE IF NOT EXISTS lia_logs (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                _timestamp DATETIME,
                _gamemode VARCHAR,
                _category VARCHAR,
                _message TEXT,
                _charID INTEGER,
                _steamID VARCHAR
            );
        ]], done)
    else
        local queries = string.Explode(";", [[
            CREATE TABLE IF NOT EXISTS `lia_players` (
                `_steamID` VARCHAR(20) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_steamName` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_firstJoin` DATETIME,
                `_lastJoin` DATETIME,
                `_data` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_intro` BINARY(1) NULL DEFAULT 0,
                PRIMARY KEY (`_steamID`)
            );

            CREATE TABLE IF NOT EXISTS `lia_characters` (
                `_id` INT(12) NOT NULL AUTO_INCREMENT,
                `_steamID` VARCHAR(20) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_name` VARCHAR(70) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_desc` VARCHAR(512) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_model` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_attribs` VARCHAR(512) DEFAULT NULL COLLATE 'utf8mb4_general_ci',
                `_schema` VARCHAR(24) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_createTime` DATETIME NOT NULL,
                `_lastJoinTime` DATETIME NOT NULL,
                `_data` VARCHAR(1024) DEFAULT NULL COLLATE 'utf8mb4_general_ci',
                `_money` INT(10) UNSIGNED NULL DEFAULT '0',
                `_faction` VARCHAR(255) DEFAULT NULL COLLATE 'utf8mb4_general_ci',
                `recognition` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
                `recognized_as` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
                PRIMARY KEY (`_id`)
            );

            CREATE TABLE IF NOT EXISTS `lia_inventories` (
                `_invID` INT(12) NOT NULL AUTO_INCREMENT,
                `_charID` INT(12) NULL DEFAULT NULL,
                `_invType` VARCHAR(24) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
                PRIMARY KEY (`_invID`)
            );

            CREATE TABLE IF NOT EXISTS `lia_items` (
                `_itemID` INT(12) NOT NULL AUTO_INCREMENT,
                `_invID` INT(12) NULL DEFAULT NULL,
                `_uniqueID` VARCHAR(60) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_data` VARCHAR(512) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
                `_quantity` INT(16),
                `_x` INT(4),
                `_y` INT(4),
                PRIMARY KEY (`_itemID`)
            );

            CREATE TABLE IF NOT EXISTS `lia_invdata` (
                `_invID` INT(12) NOT NULL,
                `_key` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_value` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
                FOREIGN KEY (`_invID`) REFERENCES lia_inventories(_invID) ON DELETE CASCADE,
                PRIMARY KEY (`_invID`, `_key`)
            );

            CREATE TABLE IF NOT EXISTS `lia_config` (
                `_schema` VARCHAR(24) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_key` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_value` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
                PRIMARY KEY (`_schema`, `_key`)
            );

            CREATE TABLE IF NOT EXISTS `lia_data` (
                `_key` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_folder` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
                `_map` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
                `_value` TEXT NULL COLLATE 'utf8mb4_general_ci',
                PRIMARY KEY (`_key`, `_folder`, `_map`)
            );

            CREATE TABLE IF NOT EXISTS `lia_logs` (
                `_id` INT(12) NOT NULL AUTO_INCREMENT,
                `_timestamp` DATETIME NOT NULL,
                `_gamemode` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_category` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_message` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
                `_charID` INT(12) NULL,
                `_steamID` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
                PRIMARY KEY (`_id`)
            );
        ]])
        local i = 1
        local function doNextQuery()
            if i > #queries then return done() end
            local query = string.Trim(queries[i])
            if query == "" then
                i = i + 1
                return doNextQuery()
            end

            lia.db.query(query, function()
                i = i + 1
                doNextQuery()
            end)
        end

        doNextQuery()
    end

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

function lia.db.convertDataType(value, noEscape)
    if isstring(value) then
        if noEscape then
            return value
        else
            return "'" .. lia.db.escape(value) .. "'"
        end
    elseif istable(value) then
        if noEscape then
            return util.TableToJSON(value)
        else
            return "'" .. lia.db.escape(util.TableToJSON(value)) .. "'"
        end
    elseif value == NULL then
        return "NULL"
    end
    return value
end

local function genInsertValues(value, dbTable)
    local query = "lia_" .. (dbTable or "characters") .. " ("
    local keys = {}
    local values = {}
    for k, v in pairs(value) do
        keys[#keys + 1] = k
        values[#keys] = lia.db.convertDataType(v)
    end
    return query .. table.concat(keys, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")"
end

local function genUpdateList(value)
    local changes = {}
    for k, v in pairs(value) do
        changes[#changes + 1] = k .. " = " .. lia.db.convertDataType(v)
    end
    return table.concat(changes, ", ")
end

function lia.db.insertTable(value, callback, dbTable)
    local query = "INSERT INTO " .. genInsertValues(value, dbTable)
    lia.db.query(query, callback)
end

function lia.db.updateTable(value, callback, dbTable, condition)
    local query = "UPDATE " .. "lia_" .. (dbTable or "characters") .. " SET " .. genUpdateList(value) .. (condition and " WHERE " .. condition or "")
    lia.db.query(query, callback)
end

function lia.db.select(fields, dbTable, condition, limit)
    local d = deferred.new()
    local from = istable(fields) and table.concat(fields, ", ") or tostring(fields)
    local tableName = "lia_" .. (dbTable or "characters")
    local query = "SELECT " .. from .. " FROM " .. tableName
    if condition then query = query .. " WHERE " .. tostring(condition) end
    if limit then query = query .. " LIMIT " .. tostring(limit) end
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

function lia.db.count(dbTable, condition)
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local q = "SELECT COUNT(*) AS cnt FROM " .. tbl .. (condition and " WHERE " .. condition or "")
    lia.db.query(q, function(results) c:resolve(tonumber(results[1].cnt)) end)
    return c
end

function lia.db.addDatabaseFields()
    if not DatabaseQueryRan then
        local typeMap = {
            string = function(d) return ("%s VARCHAR(%d)"):format(d.field, d.length or 255) end,
            integer = function(d) return ("%s INT"):format(d.field) end,
            float = function(d) return ("%s FLOAT"):format(d.field) end,
            boolean = function(d) return ("%s TINYINT(1)"):format(d.field) end,
            datetime = function(d) return ("%s DATETIME"):format(d.field) end,
            text = function(d) return ("%s TEXT"):format(d.field) end
        }

        local dbModule = lia.db.module or "sqlite"
        local getColumnsQuery = dbModule == "sqlite" and "PRAGMA table_info(lia_characters)" or "DESCRIBE lia_characters"
        lia.db.query(getColumnsQuery, function(results)
            local existing = {}
            if results and #results > 0 then
                if dbModule == "sqlite" then
                    for _, row in ipairs(results) do
                        if row.name then existing[string.lower(row.name)] = true end
                    end
                else
                    for _, row in ipairs(results) do
                        existing[string.lower(row.Field)] = true
                    end
                end
            end

            for _, v in pairs(lia.char.vars) do
                if v.field then
                    local lower = string.lower(v.field)
                    if not existing[lower] and typeMap[v.fieldType] then
                        local colDef = typeMap[v.fieldType](v)
                        if v.default ~= nil then colDef = colDef .. " DEFAULT '" .. tostring(v.default) .. "'" end
                        local alter = ("ALTER TABLE lia_characters ADD COLUMN %s"):format(colDef)
                        lia.db.query(alter, function()
                            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database] ", Color(255, 255, 255), L("addedMissingColumn", v.field) .. "\n")
                        end)
                        existing[lower] = true
                    end
                end
            end
        end)

        DatabaseQueryRan = true
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
    lia.db.query(q, function(results) c:resolve(results[1]) end)
    return c
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

    local q = "INSERT INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(vals, ",")
    lia.db.query(q, function() c:resolve() end, function(err) c:reject(err) end)
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

    local cmd = lia.db.module == "sqlite" and "INSERT OR IGNORE" or "INSERT IGNORE"
    local q = cmd .. " INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(vals, ",") .. ")"
    lia.db.query(q, function(results, lastID)
        c:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) c:reject(err) end)
    return c
end

function lia.db.transaction(queries)
    local c = deferred.new()
    lia.db.query("BEGIN TRANSACTION", function()
        local i = 1
        local function nextQuery()
            if i > #queries then
                lia.db.query("COMMIT", function() c:resolve() end)
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
    return "`" .. tostring(id):gsub("`", "``") .. "`"
end

function lia.db.upsert(value, dbTable)
    local query
    if lia.db.object then
        query = "INSERT INTO " .. genInsertValues(value, dbTable) .. " ON DUPLICATE KEY UPDATE " .. genUpdateList(value)
    else
        query = "INSERT OR REPLACE INTO " .. genInsertValues(value, dbTable)
    end

    local d = deferred.new()
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

function lia.db.delete(dbTable, condition)
    local query
    dbTable = "lia_" .. (dbTable or "character")
    if condition then
        query = "DELETE FROM " .. dbTable .. " WHERE " .. condition
    else
        query = "DELETE * FROM " .. dbTable
    end

    local d = deferred.new()
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

function lia.db.GetCharacterTable(callback)
    local query = lia.db.module == "sqlite" and "PRAGMA table_info(lia_characters)" or "DESCRIBE lia_characters"
    lia.db.query(query, function(results)
        if not results or #results == 0 then return callback({}) end
        local columns = {}
        if lia.db.module == "sqlite" then
            for _, row in ipairs(results) do
                table.insert(columns, row.name)
            end
        else
            for _, row in ipairs(results) do
                table.insert(columns, row.Field)
            end
        end

        callback(columns)
    end)
end

concommand.Add("database_list", function(ply)
    if IsValid(ply) then return end
    lia.db.GetCharacterTable(function(columns)
        if #columns == 0 then
            print(L("dbColumnsNone"))
        else
            print(L("dbColumnsList", table.concat(columns, ", ")))
        end
    end)
end)

function GM:RegisterPreparedStatements()
    lia.bootstrap("Database", L("preparedStatementsAdded"))
    lia.db.prepare("itemData", "UPDATE lia_items SET _data = ? WHERE _itemID = ?", {MYSQLOO_STRING, MYSQLOO_INTEGER})
    lia.db.prepare("itemx", "UPDATE lia_items SET _x = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemy", "UPDATE lia_items SET _y = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemq", "UPDATE lia_items SET _quantity = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemInstance", "INSERT INTO lia_items (_invID, _uniqueID, _data, _x, _y, _quantity) VALUES (?, ?, ?, ?, ?, ?)", {MYSQLOO_INTEGER, MYSQLOO_STRING, MYSQLOO_STRING, MYSQLOO_INTEGER, MYSQLOO_INTEGER, MYSQLOO_INTEGER,})
end

function GM:SetupDatabase()
    local databasePath = engine.ActiveGamemode() .. "/schema/database.lua"
    local databaseOverrideExists = file.Exists(databasePath, "LUA")
    if databaseOverrideExists then
        local databaseConfig = include(databasePath)
        if databaseConfig then
            lia.db.config = databaseConfig
            for k, v in pairs(databaseConfig) do
                lia.db[k] = v
            end
        end
    end

    if not lia.db.config then
        for k, v in pairs({
            module = "sqlite",
            hostname = "127.0.0.1",
            username = "",
            password = "",
            database = "",
            port = 3306,
        }) do
            lia.db[k] = v
        end
    end
end

function GM:DatabaseConnected()
    lia.bootstrap("Database", L("databaseConnected", lia.db.module), Color(0, 255, 0))
    if SERVER then
        lia.log.loadTables()
        lia.data.loadTables()
    end
end

function GM:OnMySQLOOConnected()
    hook.Run("RegisterPreparedStatements")
    MYSQLOO_PREPARED = true
end