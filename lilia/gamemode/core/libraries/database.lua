--- Helper library for managing database.
-- @library lia.db
lia.db = lia.db or {}
lia.db.queryQueue = lia.db.queue or {}
lia.db.prepared = lia.db.prepared or {}
MYSQLOO_QUEUE = {}
PREPARE_CACHE = {}
MYSQLOO_INTEGER = 0
MYSQLOO_STRING = 1
MYSQLOO_BOOL = 2
local modules = {}
local function ThrowQueryFault(query, fault)
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " * " .. query .. "\n")
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " " .. fault .. "\n")
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

lia.db.escape = lia.db.escape or modules.sqlite.escape
lia.db.query = lia.db.query or function(...) lia.db.queryQueue[#lia.db.queryQueue + 1] = {...} end
--- Establishes a connection to the database module specified in the configuration.
-- If the database is not connected yet or if reconnection is forced, it connects to the database module.
-- @func[opt] callback A function to be called after the database connection is established.
-- @bool[opt] reconnect Whether to force a reconnection to the database module.
-- @realm server
-- @internal
function lia.db.connect(callback, reconnect)
    local dbModule = modules[lia.db.module]
    if dbModule then
        if (reconnect or not lia.db.connected) and not lia.db.object then
            dbModule.connect(function()
                lia.db.connected = true
                if isfunction(callback) then callback() end
                -- Process any queued queries that came in before the DB was connected
                for i = 1, #lia.db.queryQueue do
                    lia.db.query(unpack(lia.db.queryQueue[i]))
                end

                lia.db.queryQueue = {}
            end)
        end

        lia.db.escape = dbModule.escape
        lia.db.query = dbModule.query
    else
        ErrorNoHalt("[Lilia] '" .. (lia.db.module or "Unavailable") .. "' is not a valid data storage method!\n")
    end
end

--- Wipes all Lilia-related tables in the database (SQLite version only).
-- @func[opt] callback A function to be called after the wipe operation is completed.
-- @realm server
-- @internal
function lia.db.wipeTables(callback)
    local function realCallback()
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " ALL LILIA DATA HAS BEEN WIPED\n")
        if isfunction(callback) then callback() end
    end

    lia.db.query([[
        DROP TABLE IF EXISTS lia_players;
        DROP TABLE IF EXISTS lia_characters;
        DROP TABLE IF EXISTS lia_inventories;
        DROP TABLE IF EXISTS lia_items;
        DROP TABLE IF EXISTS lia_invdata;
        DROP TABLE IF EXISTS lilia_logs;
    ]], realCallback)
end

--- Loads the necessary tables into the database (SQLite version only).
-- @realm server
-- @internal
function lia.db.loadTables()
    local function done()
        lia.db.tablesLoaded = true
        hook.Run("LiliaTablesLoaded")
    end

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

        CREATE TABLE IF NOT EXISTS lilia_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            log TEXT NOT NULL,
            time INTEGER NOT NULL
        );
    ]], done)
    hook.Run("OnLoadTables")
end

--- Waits for the database tables to be loaded.
-- @treturn Deferred A deferred object that resolves when the tables are loaded.
-- @realm server
-- @internal
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

--- Converts a Lua value to a format suitable for insertion into the database.
-- @param value The value to be converted.
-- @bool[opt] noEscape Whether to skip escaping the value. Defaults to false.
-- @treturn string The converted value suitable for database insertion.
-- @realm server
-- @internal
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
        values[#keys] = k:find("steamID") and v or lia.db.convertDataType(v)
    end
    return query .. table.concat(keys, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")"
end

local function genUpdateList(value)
    local changes = {}
    for k, v in pairs(value) do
        local converted = k:find("steamID") and v or lia.db.convertDataType(v)
        changes[#changes + 1] = k .. " = " .. converted
    end
    return table.concat(changes, ", ")
end

--- Inserts a new row into the specified database table with the provided values.
-- @param value The values to be inserted into the table.
-- @func[opt] callback A function to be called after the insertion operation is completed.
-- @string[opt] dbTable The name of the database table. Defaults to "characters".
-- @realm server
function lia.db.insertTable(value, callback, dbTable)
    local query = "INSERT INTO " .. genInsertValues(value, dbTable)
    lia.db.query(query, callback)
end

--- Updates rows in the specified database table with the provided values based on the given condition.
-- @param value The values to be updated in the table.
-- @func[opt] callback A function to be called after the update operation is completed.
-- @string[opt] dbTable The name of the database table. Defaults to "characters".
-- @func[opt] condition The condition to apply to the update operation.
-- @realm server
function lia.db.updateTable(value, callback, dbTable, condition)
    local query = "UPDATE lia_" .. (dbTable or "characters") .. " SET " .. genUpdateList(value) .. (condition and " WHERE " .. condition or "")
    lia.db.query(query, callback)
end

--- Selects data from the specified database table based on the provided fields, condition, and limit.
-- @tab fields The fields to select from the table.
-- @string[opt] dbTable The name of the database table. Defaults to "characters".
-- @func[opt] condition The condition to apply to the selection.
-- @int[opt] limit The maximum number of rows to retrieve.
-- @treturn Deferred A deferred object that resolves to a table containing the selected results and the last inserted ID.
-- @realm server
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

--- Inserts or updates rows in the specified database table with the provided values.
-- (SQLite version uses INSERT OR REPLACE.)
-- @param value The values to be inserted or updated in the table.
-- @string dbTable The name of the database table. Defaults to "characters".
-- @treturn Deferred A deferred object that resolves to a table containing the insertion or update results and the last inserted ID.
-- @realm server
function lia.db.upsert(value, dbTable)
    -- SQLite syntax for upsert:
    local query = "INSERT OR REPLACE INTO " .. genInsertValues(value, dbTable)
    local d = deferred.new()
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

--- Deletes rows from the specified database table based on the given condition.
-- @string dbTable The name of the database table. Defaults to "character".
-- @func[opt] condition The condition to apply to the deletion.
-- @treturn Deferred A deferred object that resolves to a table containing the deletion results and the last inserted ID.
-- @realm server
function lia.db.delete(dbTable, condition)
    dbTable = "lia_" .. (dbTable or "character")
    local query
    if condition then
        query = "DELETE FROM " .. dbTable .. " WHERE " .. condition
    else
        -- In SQLite, "DELETE * FROM" is invalid syntax, so we use "DELETE FROM"
        query = "DELETE FROM " .. dbTable
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

local GM = GM or GAMEMODE
function GM:SetupDatabase()
    local databasePath = engine.ActiveGamemode() .. "/schema/.json"
    local databaseOverrideExists = file.Exists(databasePath, "DATA")
    if databaseOverrideExists then
        local databaseConfig = file.Read(databasePath, "DATA")
        if databaseConfig then
            lia.db.config = databaseConfig
            for k, v in pairs(util.JSONToTable(lia.db.config)) do
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
    LiliaBootstrap("Database", "Lilia has connected to the database. We are using " .. lia.db.module .. "!", Color(0, 255, 0))
end

function GM:LiliaTablesLoaded()
    local ignore = function() end
    lia.db.query("ALTER TABLE IF EXISTS lia_players ADD COLUMN _firstJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE IF EXISTS lia_players ADD COLUMN _lastJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE IF EXISTS lia_items ADD COLUMN _quantity INTEGER"):catch(ignore)
end