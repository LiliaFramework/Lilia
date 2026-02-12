--[[
    Folder: Libraries
    File: db.md
]]
--[[
    Database

    Comprehensive database management system with SQLite support for the Lilia framework.
]]
--[[
    Overview:
        The database library provides comprehensive database management functionality for the Lilia framework. It handles all database operations including connection management, table creation and modification, data insertion, updates, queries, and schema management. The library supports SQLite as the primary database engine with extensible module support for other database systems. It includes advanced features such as prepared statements, transactions, bulk operations, data type conversion, and database snapshots for backup and restore operations. The library ensures data persistence across server restarts and provides robust error handling with deferred promise-based operations for asynchronous database queries. It manages core gamemode tables for players, characters, inventories, items, configuration, logs, and administrative data while supporting dynamic schema modifications.
]]
lia.db = lia.db or {}
lia.db.queryQueue = lia.db.queue or {}
lia.db.prepared = lia.db.prepared or {}
lia.db.modules = {
    ["sqlite"] = {
        query = function(query, callback)
            local d
            if not isfunction(callback) then
                d = deferred.new()
                callback = function(results, lastID)
                    d:resolve({
                        results = results,
                        lastID = lastID
                    })
                end
            end

            local data = sql.Query(query)
            local err = sql.LastError()
            if data == false then
                if string.find(err, "duplicate column name:") or string.find(err, "UNIQUE constraint failed: lia_config") then
                    if d then
                        d:resolve({
                            results = {},
                            lastID = 0
                        })
                    end
                    return d
                end

                if d then
                    d:reject(err)
                else
                    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " * " .. query .. "\n")
                    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " " .. err .. "\n")
                end
            end

            if callback then
                local lastID = tonumber(sql.QueryValue("SELECT last_insert_rowid()"))
                callback(data, lastID)
            end
            return d
        end,
        escape = function(value) return sql.SQLStr(value, true) end,
        connect = function(callback)
            lia.db.query = lia.db.modules.sqlite.query
            if callback then callback() end
        end
    }
}

lia.db.escape = lia.db.escape or lia.db.modules.sqlite.escape
lia.db.query = lia.db.query or function(...) lia.db.queryQueue[#lia.db.queryQueue + 1] = {...} end
--[[
    Purpose:
        Establishes a connection to the database using the configured database module and initializes the query system.

    When Called:
        Called during gamemode initialization to set up the database connection, or when reconnecting to the database.

    Parameters:
        callback (function)
            Optional callback function to execute when the connection is established.
        reconnect (boolean)
            Optional flag to force reconnection even if already connected.
    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.connect(function()
                print("Database connected successfully!")
            end)
        ```
]]
function lia.db.connect(callback, reconnect)
    local dbModule = lia.db.modules[lia.db.module]
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
        lia.error(L("invalidStorageModule", lia.db.module or "Unavailable"))
    end
end

--[[
    Purpose:
        Completely removes all Lilia-related database tables from the database.

    When Called:
        Called when performing a complete data wipe/reset of the gamemode's database.

    Parameters:
        callback (function)
            Optional callback function to execute when all tables have been wiped.
    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.wipeTables(function()
                print("All Lilia tables have been wiped!")
            end)
        ```
]]
function lia.db.wipeTables(callback)
    local wipedTables = {}
    local function realCallback()
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), L("dataWiped") .. "\n")
        if #wipedTables > 0 then MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), L("wipedTables", table.concat(wipedTables, ", ")) .. "\n") end
        if isfunction(callback) then callback() end
    end

    lia.db.query([[SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'lia_%';]], function(data)
        data = data or {}
        local remaining = #data
        if remaining == 0 then
            realCallback()
            return
        end

        for _, row in ipairs(data) do
            local tableName = row.name or row[1]
            table.insert(wipedTables, tableName)
            lia.db.query("DROP TABLE IF EXISTS " .. tableName .. ";", function()
                remaining = remaining - 1
                if remaining <= 0 then realCallback() end
            end)
        end
    end)
end

--[[
    Purpose:
        Creates all core Lilia database tables if they don't exist, including tables for players, characters, inventories, items, configuration, logs, and administrative data.

    When Called:
        Called during gamemode initialization to set up the database schema and prepare the database for use.

    Parameters:
        None
    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.loadTables()
        ```
]]
function lia.db.loadTables()
    local function done()
        lia.db.addDatabaseFields()
        lia.db.tablesLoaded = true
        hook.Run("LiliaTablesLoaded")
        hook.Run("OnDatabaseLoaded")
        timer.Simple(0, function() lia.config.load() end)
        timer.Simple(0.1, function()
            lia.config.send()
            lia.playerinteract.sync()
        end)
    end

    lia.db.query([[
CREATE TABLE IF NOT EXISTS lia_players (
    steamID varchar,
    steamName varchar,
    firstJoin datetime,
    lastJoin datetime,
    userGroup varchar,
    data varchar,
    lastIP varchar,
    lastOnline integer,
    totalOnlineTime float
);
CREATE TABLE IF NOT EXISTS lia_chardata (
    charID integer not null,
    key varchar(255) not null,
    value text(1024),
    PRIMARY KEY (charID, key)
);
CREATE TABLE IF NOT EXISTS lia_characters (
    id integer primary key autoincrement,
    steamID varchar,
    name varchar,
    desc varchar,
    model varchar,
    attribs varchar,
    schema varchar,
    createTime datetime,
    lastJoinTime datetime,
    money varchar,
    faction varchar,
    recognition text not null default '',
    fakenames text not null default ''
);
CREATE TABLE IF NOT EXISTS lia_inventories (
    invID integer primary key autoincrement,
    charID integer,
    invType varchar
);
CREATE TABLE IF NOT EXISTS lia_items (
    itemID integer primary key autoincrement,
    invID integer,
    uniqueID varchar,
    data varchar,
    quantity integer,
    x integer,
    y integer
);
CREATE TABLE IF NOT EXISTS lia_invdata (
    invID integer,
    key text,
    value text,
    FOREIGN KEY(invID) REFERENCES lia_inventories(invID),
    PRIMARY KEY (invID, key)
);
CREATE TABLE IF NOT EXISTS lia_config (
    schema text,
    key text,
    value text,
    PRIMARY KEY (schema, key)
);
CREATE TABLE IF NOT EXISTS lia_logs (
    id integer primary key autoincrement,
    timestamp datetime,
    gamemode varchar,
    category varchar,
    message text,
    charID integer,
    steamID varchar
);
CREATE TABLE IF NOT EXISTS lia_ticketclaims (
    timestamp datetime,
    requester text,
    requesterSteamID text,
    admin text,
    adminSteamID text,
    message text
);
CREATE TABLE IF NOT EXISTS lia_warnings (
    id integer primary key autoincrement,
    charID integer,
    warned text,
    warnedSteamID text,
    timestamp datetime,
    message text,
    warner text,
    warnerSteamID text,
    severity text default 'Medium'
);
CREATE TABLE IF NOT EXISTS lia_permakills (
    id integer primary key autoincrement,
    player varchar(255) NOT NULL,
    reason varchar(255),
    steamID varchar(255),
    charID integer,
    submitterName varchar(255),
    submitterSteamID varchar(255),
    timestamp integer,
    evidence varchar(255)
);
CREATE TABLE IF NOT EXISTS lia_bans (
    id integer primary key autoincrement,
    player varchar(255) NOT NULL,
    playerSteamID varchar(255),
    reason varchar(255),
    bannerName varchar(255),
    bannerSteamID varchar(255),
    timestamp integer,
    evidence varchar(255)
);
CREATE TABLE IF NOT EXISTS lia_staffactions (
    id integer primary key autoincrement,
    player varchar(255) NOT NULL,
    playerSteamID varchar(255),
    steamID varchar(255),
    action varchar(255),
    staffName varchar(255),
    staffSteamID varchar(255),
    timestamp integer
);
CREATE TABLE IF NOT EXISTS lia_doors (
    gamemode text,
    map text,
    id integer,
    factions text,
    classes text,
    disabled integer,
    hidden integer,
    ownable integer,
    name text,
    price integer,
    locked integer,
    PRIMARY KEY (gamemode, map, id)
);
CREATE TABLE IF NOT EXISTS lia_persistence (
    id integer primary key autoincrement,
    gamemode text,
    map text,
    class text,
    pos text,
    angles text,
    model text,
    data text
);
CREATE TABLE IF NOT EXISTS lia_saveditems (
    id integer primary key autoincrement,
    schema text,
    map text,
    itemID integer,
    pos text,
    angles text
);
CREATE TABLE IF NOT EXISTS lia_admin (
    usergroup text PRIMARY KEY,
    privileges text,
    inheritance text,
    types text
);
]], done)
    hook.Run("OnLoadTables")
end

--[[
    Purpose:
        Returns a deferred promise that resolves when all database tables have finished loading.

    When Called:
        Called when code needs to wait for database tables to be fully initialized before proceeding with database operations.

    Parameters:
        None

    Returns:
        Deferred
            A promise that resolves when tables are loaded.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.waitForTablesToLoad():next(function()
                -- Database tables are now ready
                lia.db.select("*", "characters"):next(function(results)
                    print("Characters loaded:", #results)
                end)
            end)
        ```
]]
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

local function buildWhereClause(conditions)
    if not conditions then return "" end
    if isstring(conditions) then return " WHERE " .. tostring(conditions) end
    if istable(conditions) and next(conditions) then
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

        if #whereParts > 0 then return " WHERE " .. table.concat(whereParts, " AND ") end
    end
    return ""
end

--[[
    Purpose:
        Converts Lua data types to SQL-compatible string formats for database queries.

    When Called:
        Automatically called when building SQL queries to ensure proper data type conversion.

    Parameters:
        value (any)
            The value to convert (string, number, boolean, table, nil).
        noEscape (boolean)
            Optional flag to skip SQL escaping for strings and tables.

    Returns:
        string
            The converted value as a SQL-compatible string.

    Realm:
        Shared

    Example Usage:
        ```lua
            local sqlValue = lia.db.convertDataType("John's Name")
            -- Returns: "'John''s Name'" (properly escaped)

            local sqlValue2 = lia.db.convertDataType({health = 100})
            -- Returns: "'{\"health\":100}'" (JSON encoded and escaped)
        ```
]]
function lia.db.convertDataType(value, noEscape)
    if value == nil then
        return "NULL"
    elseif isstring(value) then
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
    elseif isbool(value) then
        return value and 1 or 0
    elseif value == NULL then
        return "NULL"
    end
    return value
end

--[[
    Purpose:
        Inserts a new row into the specified database table with the provided data.

    When Called:
        Called when adding new records to database tables such as characters, items, or player data.

    Parameters:
        value (table)
            Table containing column-value pairs to insert.
        callback (function)
            Optional callback function called with (results, lastID) when the query completes.
        dbTable (string)
            Optional table name (defaults to "characters" if not specified).

    Returns:
        Deferred
            A promise that resolves with {results = results, lastID = lastID}.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.insertTable({
                steamID = "STEAM_0:1:12345678",
                name = "John Doe",
                money = "1000"
            }, function(results, lastID)
                print("Character created with ID:", lastID)
            end, "characters"):next(function(result)
                print("Insert completed, last ID:", result.lastID)
            end)
        ```
]]
function lia.db.insertTable(value, callback, dbTable)
    local d = deferred.new()
    local query = "INSERT INTO " .. genInsertValues(value, dbTable)
    lia.db.query(query, function(results, lastID)
        if callback then callback(results, lastID) end
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Updates existing rows in the specified database table with the provided data.

    When Called:
        Called when modifying existing records in database tables such as updating character data or player information.

    Parameters:
        value (table)
            Table containing column-value pairs to update.
        callback (function)
            Optional callback function called with (results, lastID) when the query completes.
        dbTable (string)
            Optional table name without "lia_" prefix (defaults to "characters" if not specified).
        condition (table|string)
            Optional WHERE condition to specify which rows to update.

    Returns:
        Deferred
            A promise that resolves with {results = results, lastID = lastID}.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Update character money
            lia.db.updateTable({
                money = "500"
            }, nil, "characters", {id = 123}):next(function()
                print("Character money updated")
            end)

            -- Update with string condition
            lia.db.updateTable({
                lastJoin = os.date("%Y-%m-%d %H:%M:%S")
            }, nil, "players", "steamID = 'STEAM_0:1:12345678'")
        ```
]]
function lia.db.updateTable(value, callback, dbTable, condition)
    local d = deferred.new()
    local query = "UPDATE " .. "lia_" .. (dbTable or "characters") .. " SET " .. genUpdateList(value) .. buildWhereClause(condition)
    lia.db.query(query, function(results, lastID)
        if callback then callback(results, lastID) end
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Selects data from the specified database table with optional conditions and limits.

    When Called:
        Called when retrieving data from database tables such as fetching character information or player data.

    Parameters:
        fields (string|table)
            Fields to select - either "*" for all fields, a string field name, or table of field names.
        dbTable (string)
            Table name without "lia_" prefix (defaults to "characters" if not specified).
        condition (table|string)
            Optional WHERE condition to filter results.
        limit (number)
            Optional LIMIT clause to restrict number of results.

    Returns:
        Deferred
            A promise that resolves with {results = results, lastID = lastID}.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Select all characters
            lia.db.select("*", "characters"):next(function(result)
                print("Found", #result.results, "characters")
            end)

            -- Select specific fields with condition
            lia.db.select({"name", "money"}, "characters", {steamID = "STEAM_0:1:12345678"}):next(function(result)
                for _, char in ipairs(result.results) do
                    print(char.name, "has", char.money, "money")
                end
            end)

            -- Select with limit
            lia.db.select("name", "characters", nil, 5):next(function(result)
                print("First 5 characters:")
                for _, char in ipairs(result.results) do
                    print("-", char.name)
                end
            end)
        ```
]]
function lia.db.select(fields, dbTable, condition, limit)
    local d = deferred.new()
    if fields == nil then
        lia.error("lia.db.select called with nil fields parameter - using default '*'")
        fields = "*"
    end

    local from = istable(fields) and table.concat(fields, ", ") or tostring(fields)
    local tableName = "lia_" .. (dbTable or "characters")
    local query = "SELECT " .. from .. " FROM " .. tableName
    query = query .. buildWhereClause(condition)
    if limit then query = query .. " LIMIT " .. tostring(limit) end
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

--[[
    Purpose:
        Selects data from the specified database table with complex conditions and optional ordering.

    When Called:
        Called when needing advanced query conditions with operator support and ordering.

    Parameters:
        fields (string|table)
            Fields to select - either "*" for all fields, a string field name, or table of field names.
        dbTable (string)
            Table name without "lia_" prefix.
        conditions (table|string)
            WHERE conditions - can be a string or table with field-operator-value structures.
        limit (number)
            Optional LIMIT clause to restrict number of results.
        orderBy (string)
            Optional ORDER BY clause for sorting results.

    Returns:
        Deferred
            A promise that resolves with {results = results, lastID = lastID}.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Select with complex conditions and ordering
            lia.db.selectWithCondition("*", "characters", {
                money = {operator = ">", value = 1000},
                faction = "citizen"
            }, 10, "name ASC"):next(function(result)
                print("Found", #result.results, "rich citizens")
            end)
        ```
]]
function lia.db.selectWithCondition(fields, dbTable, conditions, limit, orderBy)
    local d = deferred.new()
    if fields == nil then
        lia.error("lia.db.selectWithCondition called with nil fields parameter - using default '*'")
        fields = "*"
    end

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
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

--[[
    Purpose:
        Counts the number of rows in the specified database table that match the given condition.

    When Called:
        Called when needing to determine how many records exist in a table, such as counting characters or items.

    Parameters:
        dbTable (string)
            Table name without "lia_" prefix.
        condition (table|string)
            Optional WHERE condition to filter which rows to count.

    Returns:
        Deferred
            A promise that resolves with the count as a number.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Count all characters
            lia.db.count("characters"):next(function(count)
                print("Total characters:", count)
            end)

            -- Count characters for a specific player
            lia.db.count("characters", {steamID = "STEAM_0:1:12345678"}):next(function(count)
                print("Player has", count, "characters")
            end)
        ```
]]
function lia.db.count(dbTable, condition)
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local q = "SELECT COUNT(*) AS cnt FROM " .. tbl .. buildWhereClause(condition)
    lia.db.query(q, function(results)
        if istable(results) then
            c:resolve(tonumber(results[1].cnt))
        else
            c:resolve(0)
        end
    end)
    return c
end

--[[
    Purpose:
        Dynamically adds missing database fields to the characters table based on character variable definitions.

    When Called:
        Called during database initialization to ensure all character variables have corresponding database columns.

    Parameters:
        None
    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.addDatabaseFields()
        ```
]]
function lia.db.addDatabaseFields()
    local typeMap = {
        string = function(d) return ("%s VARCHAR(%d)"):format(d.field, d.length or 255) end,
        integer = function(d) return ("%s INT"):format(d.field) end,
        float = function(d) return ("%s FLOAT"):format(d.field) end,
        boolean = function(d) return ("%s TINYINT(1)"):format(d.field) end,
        datetime = function(d) return ("%s DATETIME"):format(d.field) end,
        text = function(d) return ("%s TEXT"):format(d.field) end
    }

    local ignore = function() end
    if not istable(lia.char.vars) then return end
    for _, v in pairs(lia.char.vars) do
        if v.field and typeMap[v.fieldType] then
            lia.db.fieldExists("lia_characters", v.field):next(function(exists)
                if not exists then
                    local colDef = typeMap[v.fieldType](v)
                    if v.default ~= nil then colDef = colDef .. " DEFAULT '" .. tostring(v.default) .. "'" end
                    lia.db.query("ALTER TABLE lia_characters ADD COLUMN " .. colDef):catch(ignore)
                end
            end)
        end
    end

    lia.db.fieldExists("lia_warnings", "severity"):next(function(exists) if not exists then lia.db.query("ALTER TABLE lia_warnings ADD COLUMN severity TEXT DEFAULT 'Medium'") end end)
end

--[[
    Purpose:
        Checks if any records exist in the specified table that match the given condition.

    When Called:
        Called to verify the existence of records before performing operations.

    Parameters:
        dbTable (string)
            Table name without "lia_" prefix.
        condition (table|string)
            WHERE condition to check for record existence.

    Returns:
        Deferred
            A promise that resolves to true if records exist, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.exists("characters", {steamID = "STEAM_0:1:12345678"}):next(function(exists)
                if exists then
                    print("Player has characters")
                else
                    print("Player has no characters")
                end
            end)
        ```
]]
function lia.db.exists(dbTable, condition)
    return lia.db.count(dbTable, condition):next(function(n) return n > 0 end)
end

--[[
    Purpose:
        Selects a single row from the specified database table that matches the given condition.

    When Called:
        Called when retrieving a specific record from database tables, such as finding a character by ID.

    Parameters:
        fields (string|table)
            Fields to select - either "*" for all fields, a string field name, or table of field names.
        dbTable (string)
            Table name without "lia_" prefix.
        condition (table|string)
            Optional WHERE condition to filter results.

    Returns:
        Deferred
            A promise that resolves with the first matching row as a table, or nil if no rows found.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Get character by ID
            lia.db.selectOne("*", "characters", {id = 123}):next(function(character)
                if character then
                    print("Found character:", character.name)
                else
                    print("Character not found")
                end
            end)

            -- Get player data by SteamID
            lia.db.selectOne({"name", "money"}, "players", {steamID = "STEAM_0:1:12345678"}):next(function(player)
                if player then
                    print(player.name, "has", player.money, "money")
                end
            end)
        ```
]]
function lia.db.selectOne(fields, dbTable, condition)
    local c = deferred.new()
    if fields == nil then
        lia.error("lia.db.selectOne called with nil fields parameter - using default '*'")
        fields = "*"
    end

    local tbl = "`lia_" .. dbTable .. "`"
    local f = istable(fields) and table.concat(fields, ", ") or tostring(fields)
    local q = "SELECT " .. f .. " FROM " .. tbl
    q = q .. buildWhereClause(condition)
    q = q .. " LIMIT 1"
    lia.db.query(q, function(results)
        if istable(results) then
            c:resolve(results[1])
        else
            c:resolve(nil)
        end
    end)
    return c
end

--[[
    Purpose:
        Inserts multiple rows into the specified database table in a single query for improved performance.

    When Called:
        Called when inserting large amounts of data at once, such as bulk importing items or characters.

    Parameters:
        dbTable (string)
            Table name without "lia_" prefix.
        rows (table)
            Array of row data tables, where each table contains column-value pairs.

    Returns:
        Deferred
            A promise that resolves when the bulk insert completes.

    Realm:
        Shared

    Example Usage:
        ```lua
            local items = {
                {uniqueID = "item1", invID = 1, quantity = 5},
                {uniqueID = "item2", invID = 1, quantity = 3},
                {uniqueID = "item3", invID = 2, quantity = 1}
            }

            lia.db.bulkInsert("items", items):next(function()
                print("Bulk insert completed")
            end)
        ```
]]
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

--[[
    Purpose:
        Performs bulk insert or replace operations on multiple rows in a single query.

    When Called:
        Called when bulk updating/inserting data where existing records should be replaced.

    Parameters:
        dbTable (string)
            Table name without "lia_" prefix.
        rows (table)
            Array of row data tables to insert or replace.

    Returns:
        Deferred
            A promise that resolves when the bulk upsert completes.

    Realm:
        Shared

    Example Usage:
        ```lua
            local data = {
                {id = 1, name = "Item 1", value = 100},
                {id = 2, name = "Item 2", value = 200}
            }

            lia.db.bulkUpsert("custom_items", data):next(function()
                print("Bulk upsert completed")
            end)
        ```
]]
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

    local q = "INSERT OR REPLACE INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(vals, ",")
    lia.db.query(q, function() c:resolve() end, function(err) c:reject(err) end)
    return c
end

--[[
    Purpose:
        Inserts a new row into the database table, but ignores the operation if a conflict occurs (such as duplicate keys).

    When Called:
        Called when inserting data that might already exist, where duplicates should be silently ignored.

    Parameters:
        value (table)
            Table containing column-value pairs to insert.
        dbTable (string)
            Optional table name without "lia_" prefix (defaults to "characters").

    Returns:
        Deferred
            A promise that resolves with {results = results, lastID = lastID}.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.insertOrIgnore({
                steamID = "STEAM_0:1:12345678",
                name = "Player Name"
            }, "players"):next(function(result)
                print("Player record inserted or already exists")
            end)
        ```
]]
function lia.db.insertOrIgnore(value, dbTable)
    local c = deferred.new()
    local tbl = "`lia_" .. (dbTable or "characters") .. "`"
    local keys, vals = {}, {}
    for k, v in pairs(value) do
        keys[#keys + 1] = lia.db.escapeIdentifier(k)
        vals[#vals + 1] = lia.db.convertDataType(v)
    end

    local cmd = "INSERT OR IGNORE"
    local q = cmd .. " INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(vals, ",") .. ")"
    lia.db.query(q, function(results, lastID)
        c:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) c:reject(err) end)
    return c
end

--[[
    Purpose:
        Checks if a database table with the specified name exists.

    When Called:
        Called before performing operations on tables to verify they exist, or when checking schema state.

    Parameters:
        tbl (string)
            The table name to check for existence.

    Returns:
        Deferred
            A promise that resolves to true if the table exists, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.tableExists("lia_characters"):next(function(exists)
                if exists then
                    print("Characters table exists")
                else
                    print("Characters table does not exist")
                end
            end)
        ```
]]
function lia.db.tableExists(tbl)
    local d = deferred.new()
    local qt = "'" .. tbl:gsub("'", "''") .. "'"
    lia.db.query("SELECT name FROM sqlite_master WHERE type='table' AND name=" .. qt, function(res) d:resolve(res and #res > 0) end, function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Checks if a column/field with the specified name exists in the given database table.

    When Called:
        Called before accessing table columns to verify they exist, or when checking schema modifications.

    Parameters:
        tbl (string)
            The table name to check (should include "lia_" prefix).
        field (string)
            The field/column name to check for existence.

    Returns:
        Deferred
            A promise that resolves to true if the field exists, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.fieldExists("lia_characters", "custom_field"):next(function(exists)
                if exists then
                    print("Custom field exists")
                else
                    print("Custom field does not exist")
                end
            end)
        ```
]]
function lia.db.fieldExists(tbl, field)
    local d = deferred.new()
    lia.db.query("PRAGMA table_info(" .. tbl .. ")", function(res)
        for _, r in ipairs(res) do
            if r.name == field then return d:resolve(true) end
        end

        d:resolve(false)
    end, function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Retrieves a list of all Lilia database tables (tables starting with "lia_").

    When Called:
        Called when needing to enumerate all database tables, such as for maintenance operations or schema inspection.

    Parameters:
        None

    Returns:
        Deferred
            A promise that resolves with an array of table names.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.getTables():next(function(tables)
                print("Lilia tables:")
                for _, tableName in ipairs(tables) do
                    print("-", tableName)
                end
            end)
        ```
]]
function lia.db.getTables()
    local d = deferred.new()
    lia.db.query("SELECT name FROM sqlite_master WHERE type='table'", function(res)
        local tables = {}
        for _, row in ipairs(res or {}) do
            if row.name and row.name:StartWith("lia_") then tables[#tables + 1] = row.name end
        end

        d:resolve(tables)
    end, function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Executes multiple database queries as an atomic transaction - either all queries succeed or all are rolled back.

    When Called:
        Called when performing multiple related database operations that must be atomic, such as transferring items between inventories.

    Parameters:
        queries (table)
            Array of SQL query strings to execute in sequence.

    Returns:
        Deferred
            A promise that resolves when the transaction completes successfully, or rejects if any query fails.

    Realm:
        Shared

    Example Usage:
        ```lua
            local queries = {
                "UPDATE lia_characters SET money = money - 100 WHERE id = 1",
                "UPDATE lia_characters SET money = money + 100 WHERE id = 2",
                "INSERT INTO lia_logs (message) VALUES ('Money transfer completed')"
            }

            lia.db.transaction(queries):next(function()
                print("Transaction completed successfully")
            end):catch(function(err)
                print("Transaction failed:", err)
            end)
        ```
]]
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

--[[
    Purpose:
        Escapes SQL identifiers (table and column names) by wrapping them in backticks and escaping any backticks within.

    When Called:
        Automatically called when building SQL queries to safely handle identifiers that might contain special characters.

    Parameters:
        id (string)
            The identifier (table name, column name, etc.) to escape.

    Returns:
        string
            The escaped identifier wrapped in backticks.

    Realm:
        Shared

    Example Usage:
        ```lua
            local escaped = lia.db.escapeIdentifier("user_name")
            -- Returns: "`user_name`"

            local escaped2 = lia.db.escapeIdentifier("table`with`ticks")
            -- Returns: "`table``with``ticks`"
        ```
]]
function lia.db.escapeIdentifier(id)
    return "`" .. tostring(id):gsub("`", "``") .. "`"
end

--[[
    Purpose:
        Inserts a new row into the database table, or replaces the existing row if it already exists (SQLite UPSERT operation).

    When Called:
        Called when you want to ensure a record exists with specific data, regardless of whether it was previously created.

    Parameters:
        value (table)
            Table containing column-value pairs to insert or update.
        dbTable (string)
            Optional table name without "lia_" prefix (defaults to "characters" if not specified).

    Returns:
        Deferred
            A promise that resolves with {results = results, lastID = lastID}.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Ensure a character exists with this data
            lia.db.upsert({
                id = 123,
                steamID = "STEAM_0:1:12345678",
                name = "John Doe",
                money = "1000"
            }, "characters"):next(function(result)
                print("Character upserted, last ID:", result.lastID)
            end)
        ```
]]
function lia.db.upsert(value, dbTable)
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

--[[
    Purpose:
        Deletes rows from the specified database table that match the given condition.

    When Called:
        Called when removing records from database tables, such as deleting characters or cleaning up old data.

    Parameters:
        dbTable (string)
            Table name without "lia_" prefix (defaults to "character" if not specified).
        condition (table|string)
            WHERE condition to specify which rows to delete.

    Returns:
        Deferred
            A promise that resolves with {results = results, lastID = lastID}.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Delete a specific character
            lia.db.delete("characters", {id = 123}):next(function()
                print("Character deleted")
            end)

            -- Delete all characters for a player
            lia.db.delete("characters", {steamID = "STEAM_0:1:12345678"}):next(function()
                print("All player characters deleted")
            end)
        ```
]]
function lia.db.delete(dbTable, condition)
    dbTable = "lia_" .. (dbTable or "character")
    local query = "DELETE FROM " .. dbTable .. buildWhereClause(condition)
    local d = deferred.new()
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

--[[
    Purpose:
        Creates a new database table with the specified schema definition.

    When Called:
        Called when creating custom tables for modules or extending the database schema.

    Parameters:
        dbName (string)
            Table name without "lia_" prefix.
        primaryKey (string)
            Optional name of the primary key column.
        schema (table)
            Array of column definitions with name, type, not_null, and default properties.

    Returns:
        Deferred
            A promise that resolves to true when the table is created.

    Realm:
        Shared

    Example Usage:
        ```lua
            local schema = {
                {name = "id", type = "integer", not_null = true},
                {name = "name", type = "string", not_null = true},
                {name = "value", type = "integer", default = 0}
            }

            lia.db.createTable("custom_data", "id", schema):next(function()
                print("Custom table created")
            end)
        ```
]]
function lia.db.createTable(dbName, primaryKey, schema)
    local d = deferred.new()
    local tableName = "lia_" .. dbName
    local columns = {}
    for _, column in ipairs(schema) do
        local colDef = lia.db.escapeIdentifier(column.name)
        colDef = colDef .. " " .. column.type:upper()
        if column.not_null then colDef = colDef .. " NOT NULL" end
        if column.default ~= nil then
            if column.type == "string" or column.type == "text" then
                colDef = colDef .. " DEFAULT '" .. lia.db.escape(tostring(column.default)) .. "'"
            elseif column.type == "boolean" then
                colDef = colDef .. " DEFAULT " .. (column.default and "1" or "0")
            else
                colDef = colDef .. " DEFAULT " .. tostring(column.default)
            end
        end

        table.insert(columns, colDef)
    end

    if primaryKey then table.insert(columns, "PRIMARY KEY (" .. lia.db.escapeIdentifier(primaryKey) .. ")") end
    local query = "CREATE TABLE IF NOT EXISTS " .. tableName .. " (" .. table.concat(columns, ", ") .. ")"
    lia.db.query(query, function() d:resolve(true) end, function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Adds a new column to an existing database table.

    When Called:
        Called when extending database schema by adding new fields to existing tables.

    Parameters:
        tableName (string)
            Table name without "lia_" prefix.
        columnName (string)
            Name of the new column to add.
        columnType (string)
            SQL data type for the column (e.g., "VARCHAR(255)", "INTEGER", "TEXT").
        defaultValue (any)
            Optional default value for the new column.

    Returns:
        Deferred
            A promise that resolves to true if column was added, false if it already exists.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.createColumn("characters", "custom_field", "VARCHAR(100)", "default_value"):next(function(success)
                if success then
                    print("Column added successfully")
                else
                    print("Column already exists")
                end
            end)
        ```
]]
function lia.db.createColumn(tableName, columnName, columnType, defaultValue)
    local d = deferred.new()
    local fullTableName = "lia_" .. tableName
    lia.db.fieldExists(fullTableName, columnName):next(function(exists)
        if exists then
            d:resolve(false)
            return
        end

        local colDef = lia.db.escapeIdentifier(columnName)
        colDef = colDef .. " " .. columnType:upper()
        if defaultValue ~= nil then
            if columnType == "string" or columnType == "text" then
                colDef = colDef .. " DEFAULT '" .. lia.db.escape(tostring(defaultValue)) .. "'"
            elseif columnType == "boolean" then
                colDef = colDef .. " DEFAULT " .. (defaultValue and "1" or "0")
            else
                colDef = colDef .. " DEFAULT " .. tostring(defaultValue)
            end
        end

        local query = "ALTER TABLE " .. fullTableName .. " ADD COLUMN " .. colDef
        lia.db.query(query, function() d:resolve(true) end, function(err) d:reject(err) end)
    end):catch(function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Removes a database table from the database.

    When Called:
        Called when cleaning up or removing custom tables from the database schema.

    Parameters:
        tableName (string)
            Table name without "lia_" prefix.

    Returns:
        Deferred
            A promise that resolves to true if table was removed, false if it doesn't exist.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.removeTable("custom_data"):next(function(success)
                if success then
                    print("Table removed successfully")
                else
                    print("Table does not exist")
                end
            end)
        ```
]]
function lia.db.removeTable(tableName)
    local d = deferred.new()
    local fullTableName = "lia_" .. tableName
    lia.db.tableExists(fullTableName):next(function(exists)
        if not exists then
            d:resolve(false)
            return
        end

        local query = "DROP TABLE " .. fullTableName
        lia.db.query(query, function() d:resolve(true) end, function(err) d:reject(err) end)
    end):catch(function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Removes a column from an existing database table by recreating the table without the specified column.

    When Called:
        Called when removing fields from database tables during schema cleanup or refactoring.

    Parameters:
        tableName (string)
            Table name without "lia_" prefix.
        columnName (string)
            Name of the column to remove.

    Returns:
        Deferred
            A promise that resolves to true if column was removed, false if table/column doesn't exist.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.removeColumn("characters", "old_field"):next(function(success)
                if success then
                    print("Column removed successfully")
                else
                    print("Column or table does not exist")
                end
            end)
        ```
]]
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
                    d:reject(L("failedToGetTableInfo"))
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
                    d:reject(L("cannotRemoveLastColumnFromTable"))
                    return
                end

                local tempTableName = fullTableName .. "_temp_" .. os.time()
                local createTempQuery = "CREATE TABLE " .. tempTableName .. " (" .. table.concat(newColumns, ", ") .. ")"
                local insertQuery = "INSERT INTO " .. tempTableName .. " SELECT " .. table.concat(newColumns, ", ") .. " FROM " .. fullTableName
                local dropOldQuery = "DROP TABLE " .. fullTableName
                local renameQuery = "ALTER TABLE " .. tempTableName .. " RENAME TO " .. fullTableName
                lia.db.transaction({createTempQuery, insertQuery, dropOldQuery, renameQuery}):next(function() d:resolve(true) end):catch(function(err) d:reject(err) end)
            end, function(err) d:reject(err) end)
        end):catch(function(err) d:reject(err) end)
    end):catch(function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Retrieves the column information/schema for the characters table.

    When Called:
        Called when needing to inspect the structure of the characters table for schema operations.

    Parameters:
        callback (function)
            Function to call with the array of column names.
    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.getCharacterTable(function(columns)
                print("Character table columns:")
                for _, column in ipairs(columns) do
                    print("-", column)
                end
            end)
        ```
]]
function lia.db.getCharacterTable(callback)
    local query = "PRAGMA table_info(lia_characters)"
    lia.db.query(query, function(results)
        if not results or #results == 0 then return callback({}) end
        local columns = {}
        for _, row in ipairs(results) do
            table.insert(columns, row.name)
        end

        callback(columns)
    end)
end

--[[
    Purpose:
        Creates a backup snapshot of all data in the specified table and saves it to a JSON file.

    When Called:
        Called for backup purposes before major data operations or schema changes.

    Parameters:
        tableName (string)
            Table name without "lia_" prefix.

    Returns:
        Deferred
            A promise that resolves with snapshot info {file = filename, path = filepath, records = count}.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.createSnapshot("characters"):next(function(snapshot)
                print("Snapshot created:", snapshot.file, "with", snapshot.records, "records")
            end)
        ```
]]
function lia.db.createSnapshot(tableName)
    local d = deferred.new()
    local fullTableName = "lia_" .. tableName
    lia.db.tableExists(fullTableName):next(function(exists)
        if not exists then
            d:reject("Table " .. fullTableName .. " does not exist")
            return
        end

        lia.db.query("SELECT * FROM " .. fullTableName, function(results)
            if not results then
                d:reject("Failed to query table " .. fullTableName)
                return
            end

            local snapshot = {
                table = tableName,
                timestamp = os.time(),
                data = results
            }

            local jsonData = util.TableToJSON(snapshot, true)
            local fileName = "snapshot_" .. tableName .. "_" .. os.time() .. ".json"
            local filePath = "lilia/snapshots/" .. fileName
            file.CreateDir("lilia/snapshots")
            file.Write(filePath, jsonData)
            d:resolve({
                file = fileName,
                path = filePath,
                records = #results
            })
        end, function(err) d:reject(L("databaseError") .. " " .. tostring(err)) end)
    end, function(err) d:reject(L("tableCheckError") .. " " .. tostring(err)) end)
    return d
end

--[[
    Purpose:
        Loads data from a snapshot file and restores it to the corresponding database table.

    When Called:
        Called to restore database tables from backup snapshots.

    Parameters:
        fileName (string)
            Name of the snapshot file to load.

    Returns:
        Deferred
            A promise that resolves with restore info {table = tableName, records = count, timestamp = timestamp}.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.db.loadSnapshot("snapshot_characters_1640995200.json"):next(function(result)
                print("Restored", result.records, "records to", result.table)
            end)
        ```
]]
function lia.db.loadSnapshot(fileName)
    local d = deferred.new()
    local filePath = "lilia/snapshots/" .. fileName
    if not file.Exists(filePath, "DATA") then
        d:reject(L("snapshotFileNotFound") .. " " .. fileName .. " " .. L("notFound"))
        return d
    end

    local jsonData = file.Read(filePath, "DATA")
    if not jsonData then
        d:reject("Failed to read snapshot file")
        return d
    end

    local success, snapshot = pcall(util.JSONToTable, jsonData)
    if not success then
        d:reject(L("failedParseJSONData", tostring(snapshot)))
        return d
    end

    if not snapshot.table or not snapshot.data then
        d:reject("Invalid snapshot format")
        return d
    end

    local fullTableName = "lia_" .. snapshot.table
    lia.db.tableExists(fullTableName):next(function(exists)
        if not exists then
            d:reject("Target table " .. fullTableName .. " does not exist")
            return
        end

        lia.db.query("DELETE FROM " .. fullTableName, function()
            if #snapshot.data == 0 then
                d:resolve({
                    table = snapshot.table,
                    records = 0
                })
                return
            end

            local batchSize = 100
            local batches = {}
            for i = 1, #snapshot.data, batchSize do
                local batch = {}
                for j = i, math.min(i + batchSize - 1, #snapshot.data) do
                    table.insert(batch, snapshot.data[j])
                end

                table.insert(batches, batch)
            end

            local currentBatch = 1
            local function insertNextBatch()
                if currentBatch > #batches then
                    d:resolve({
                        table = snapshot.table,
                        records = #snapshot.data,
                        timestamp = snapshot.timestamp
                    })
                    return
                end

                lia.db.bulkInsert(snapshot.table, batches[currentBatch]):next(function()
                    currentBatch = currentBatch + 1
                    insertNextBatch()
                end, function(err) d:reject("Failed to insert batch " .. currentBatch .. ": " .. tostring(err)) end)
            end

            insertNextBatch()
        end, function(err) d:reject(L("failedToClearTable") .. " " .. tostring(err)) end)
    end, function(err) d:reject(L("tableCheckError") .. " " .. tostring(err)) end)
    return d
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
    lia.bootstrap(L("database"), L("databaseConnected", lia.db.module))
end
