--[[
    Folder: Developer - Libraries
    File: lia.database.md
]]
--[[
    Database

    Database helpers for Lilia storage module setup, schema creation, SQL value conversion, table queries, migrations, transactions, and snapshot import/export.
]]
--[[
    Overview:
        The database library centralizes server-side persistence under `lia.db`. It initializes the active storage module, queues queries until the database is connected, creates core Lilia tables, adds missing character and warning fields, provides convenience helpers for selecting, inserting, updating, deleting, counting, and checking records, and supports administrative schema and snapshot utilities.
]]
--[[
    Hooks:
        OnDatabaseLoaded()

    Purpose:
        Runs after core database tables finish loading, database fields are checked, `lia.db.tablesLoaded` is set, and follow-up configuration, interaction, and item synchronization timers are scheduled.

    Category:
        Database

    Example Usage:
        ```lua
        hook.Add("OnDatabaseLoaded", "liaExampleOnDatabaseLoaded", function()
            lia.db.selectOne("*", "players", nil, 1):next(function(row)
                PrintTable(row or {})
            end)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnLoadTables()

    Purpose:
        Runs immediately after the core table creation query is submitted by `lia.db.loadTables`.

    Category:
        Database

    Example Usage:
        ```lua
        hook.Add("OnLoadTables", "liaExampleOnLoadTables", function()
            print("Database table creation query was submitted.")
        end)
        ```

    Realm:
        Server
]]
lia.db = lia.db or {}
lia.db.queryQueue = lia.db.queue or {}
lia.db.prepared = lia.db.prepared or {}
local function devLog(...)
    if not lia.devmode then return end
    local parts = {...}
    for i = 1, #parts do
        parts[i] = tostring(parts[i])
    end

    MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 200, 0), "[DevMode] ", Color(255, 255, 255), table.concat(parts, " "), "\n")
end

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

            local started = SysTime()
            local data = sql.Query(query)
            local duration = SysTime() - started
            local err = sql.LastError()
            if lia.devmode and duration >= 0.25 then devLog(string.format("SQLite query took %.3fs:", duration), query) end
            if data == false then
                if lia.devmode then
                    devLog("SQLite query failed:", query)
                    devLog("SQLite error:", tostring(err))
                end

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

--[[
    Purpose:
        Escapes a value with the active database module escape function.

    Parameters:
        value (any)
            Value to escape for SQL usage.

    Returns:
        string
            Escaped value suitable for SQL string construction.

    Example Usage:
        ```lua
        local escaped = lia.db.escape(client:SteamID())
        ```

    Realm:
        Server
]]
lia.db.escape = lia.db.escape or lia.db.modules.sqlite.escape
--[[
    Purpose:
        Executes a SQL query through the active database module, or queues it until a database connection is available.

    Parameters:
        ... (any)
            Query arguments passed through to the active database query implementation.

    Returns:
        any
            Returns the active database query result when connected, or nil while the query is queued.

    Example Usage:
        ```lua
        lia.db.query("SELECT * FROM lia_players", function(data)
            PrintTable(data or {})
        end)
        ```

    Realm:
        Server
]]
lia.db.query = lia.db.query or function(...) lia.db.queryQueue[#lia.db.queryQueue + 1] = {...} end
--[[
    Purpose:
        Connects the configured database module, marks the database as connected, assigns the module query and escape functions, and flushes queued queries.

    Parameters:
        callback (function|nil)
            Optional function called after the database module finishes connecting.

        reconnect (boolean|nil)
            When true, allows the connection routine to run even if the database was previously marked as connected.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.db.connect(function()
            lia.db.loadTables()
        end)
        ```

    Realm:
        Server
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
        Drops every SQLite table whose name starts with `lia_`, logs the wiped tables, and then runs an optional callback.

    Parameters:
        callback (function|nil)
            Optional function called after all matching tables have been dropped.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.db.wipeTables(function()
            lia.db.loadTables()
        end)
        ```

    Realm:
        Server
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
        Creates the core Lilia database tables, adds missing database fields, marks tables as loaded, runs database load hooks, and schedules configuration, interaction, and item synchronization.

    Parameters:
        None.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.db.loadTables()
        ```

    Realm:
        Server
]]
function lia.db.loadTables()
    local function done()
        lia.db.addDatabaseFields()
        lia.db.ensureIndexes()
        lia.db.tablesLoaded = true
        hook.Run("OnDatabaseLoaded")
        timer.Simple(0, function() lia.config.load() end)
        timer.Simple(0.1, function()
            lia.config.send()
            lia.playerinteract.sync()
            lia.item.loadWeaponOverrides()
            lia.item.loadWeaponRuntimeOverrides()
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
        Returns a deferred object that resolves immediately if tables are already loaded, or resolves when `OnDatabaseLoaded` runs.

    Parameters:
        None.

    Returns:
        Deferred
            Resolves after database tables are available.

    Example Usage:
        ```lua
        lia.db.waitForTablesToLoad():next(function()
            print("Tables are ready")
        end)
        ```

    Realm:
        Server
]]
function lia.db.waitForTablesToLoad()
    TABLE_WAIT_ID = TABLE_WAIT_ID or 0
    local d = deferred.new()
    if lia.db.tablesLoaded then
        d:resolve()
    else
        hook.Add("OnDatabaseLoaded", tostring(TABLE_WAIT_ID), function() d:resolve() end)
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
        Converts Lua values into SQL-safe literal values used when constructing database queries.

    Parameters:
        value (any)
            The value to convert. Strings and tables are escaped unless `noEscape` is true.

        noEscape (boolean|nil)
            When true, string and table values are returned without SQL escaping or quoting.

    Returns:
        string|number
            The converted SQL literal, numeric boolean value, NULL literal, or original numeric value.

    Example Usage:
        ```lua
        local value = lia.db.convertDataType({enabled = true})
        ```

    Realm:
        Server
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
        Inserts a row into a `lia_` database table and resolves with the query results and last inserted row ID.

    Parameters:
        value (table)
            Key-value pairs to insert into the target table.

        callback (function|nil)
            Optional function called with `results` and `lastID` after the insert query completes.

        dbTable (string|nil)
            Table suffix to insert into. Defaults to `characters`, producing `lia_characters`.

    Returns:
        Deferred
            Resolves with a table containing `results` and `lastID`.

    Example Usage:
        ```lua
        lia.db.insertTable({steamID = client:SteamID(), steamName = client:Name()}, nil, "players")
        ```

    Realm:
        Server
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
        Updates rows in a `lia_` database table using the supplied values and optional condition.

    Parameters:
        value (table)
            Key-value pairs to assign in the update statement.

        callback (function|nil)
            Optional function called with `results` and `lastID` after the update query completes.

        dbTable (string|nil)
            Table suffix to update. Defaults to `characters`, producing `lia_characters`.

        condition (string|table|nil)
            Optional WHERE clause as a raw string or a table of field comparisons.

    Returns:
        Deferred
            Resolves with a table containing `results` and `lastID`.

    Example Usage:
        ```lua
        lia.db.updateTable({lastOnline = os.time()}, nil, "players", {steamID = client:SteamID()})
        ```

    Realm:
        Server
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
        Selects rows from a `lia_` database table with optional conditions and result limiting.

    Parameters:
        fields (string|table)
            Field list to select, or `*` for all fields.

        dbTable (string|nil)
            Table suffix to select from. Defaults to `characters`, producing `lia_characters`.

        condition (string|table|nil)
            Optional WHERE clause as a raw string or a table of field comparisons.

        limit (number|string|nil)
            Optional SQL LIMIT value.

    Returns:
        Deferred
            Resolves with a table containing `results` and `lastID`.

    Example Usage:
        ```lua
        lia.db.select({"id", "name"}, "characters", {steamID = client:SteamID()}, 1)
        ```

    Realm:
        Server
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
        Selects rows from a `lia_` database table using optional conditions, ordering, and result limiting.

    Parameters:
        fields (string|table)
            Field list to select, or `*` for all fields.

        dbTable (string|nil)
            Table suffix to select from. Defaults to `characters`, producing `lia_characters`.

        conditions (string|table|nil)
            Optional WHERE clause as a raw string or a table of field comparisons.

        limit (number|string|nil)
            Optional SQL LIMIT value.

        orderBy (string|nil)
            Optional SQL ORDER BY expression.

    Returns:
        Deferred
            Resolves with a table containing `results` and `lastID`.

    Example Usage:
        ```lua
        lia.db.selectWithCondition("*", "logs", {category = "admin"}, 25, "timestamp DESC")
        ```

    Realm:
        Server
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
        Counts rows in a `lia_` database table that match an optional condition.

    Parameters:
        dbTable (string)
            Table suffix to count from, producing `lia_<dbTable>`.

        condition (string|table|nil)
            Optional WHERE clause as a raw string or a table of field comparisons.

    Returns:
        Deferred
            Resolves with the numeric row count.

    Example Usage:
        ```lua
        lia.db.count("characters", {steamID = client:SteamID()}):next(function(total)
            print(total)
        end)
        ```

    Realm:
        Server
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
        Adds missing database columns for character variables defined in `lia.char.vars` and ensures the warnings table has a severity column.

    Parameters:
        None.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.db.addDatabaseFields()
        ```

    Realm:
        Server
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
        Creates indexes for the highest-traffic lookup paths used during player join and character switching.

    Parameters:
        None.

    Example Usage:
        ```lua
        lia.db.waitForTablesToLoad():next(function()
            lia.db.ensureIndexes()
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
function lia.db.ensureIndexes()
    local queries = {"CREATE INDEX IF NOT EXISTS idx_lia_players_steamID ON lia_players(steamID)", "CREATE INDEX IF NOT EXISTS idx_lia_characters_steamID_schema ON lia_characters(steamID, schema)", "CREATE INDEX IF NOT EXISTS idx_lia_inventories_charID ON lia_inventories(charID)", "CREATE INDEX IF NOT EXISTS idx_lia_items_invID ON lia_items(invID)"}
    for _, query in ipairs(queries) do
        lia.db.query(query)
    end
end

--[[
    Purpose:
        Checks whether at least one row exists in a `lia_` database table for the supplied condition.

    Parameters:
        dbTable (string)
            Table suffix to check, producing `lia_<dbTable>`.

        condition (string|table|nil)
            Optional WHERE clause as a raw string or a table of field comparisons.

    Returns:
        Deferred
            Resolves with true when at least one matching row exists, otherwise false.

    Example Usage:
        ```lua
        lia.db.exists("players", {steamID = client:SteamID()}):next(function(found)
            print(found)
        end)
        ```

    Realm:
        Server
]]
function lia.db.exists(dbTable, condition)
    return lia.db.count(dbTable, condition):next(function(n) return n > 0 end)
end

--[[
    Purpose:
        Selects the first row from a `lia_` database table that matches an optional condition.

    Parameters:
        fields (string|table)
            Field list to select, or `*` for all fields.

        dbTable (string)
            Table suffix to select from, producing `lia_<dbTable>`.

        condition (string|table|nil)
            Optional WHERE clause as a raw string or a table of field comparisons.

    Returns:
        Deferred
            Resolves with the first result row, or nil when no row matches.

    Example Usage:
        ```lua
        lia.db.selectOne("*", "players", {steamID = client:SteamID()}):next(function(row)
            PrintTable(row or {})
        end)
        ```

    Realm:
        Server
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
        Inserts multiple rows into a `lia_` database table with one multi-value INSERT query.

    Parameters:
        dbTable (string)
            Table suffix to insert into, producing `lia_<dbTable>`.

        rows (table)
            Array of row tables to insert. Column names are taken from the first row.

    Returns:
        Deferred
            Resolves when the bulk insert finishes.

    Example Usage:
        ```lua
        lia.db.bulkInsert("logs", {
            {category = "server", message = "Started"},
            {category = "server", message = "Loaded"}
        })
        ```

    Realm:
        Server
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
        Inserts or replaces multiple rows in a `lia_` database table with one multi-value INSERT OR REPLACE query.

    Parameters:
        dbTable (string)
            Table suffix to upsert into, producing `lia_<dbTable>`.

        rows (table)
            Array of row tables to upsert. Column names are taken from the first row.

    Returns:
        Deferred
            Resolves when the bulk upsert finishes.

    Example Usage:
        ```lua
        lia.db.bulkUpsert("invdata", {
            {invID = 1, key = "width", value = "6"},
            {invID = 1, key = "height", value = "4"}
        })
        ```

    Realm:
        Server
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
        Inserts a row into a `lia_` database table only when it does not conflict with existing constraints.

    Parameters:
        value (table)
            Key-value pairs to insert into the target table.

        dbTable (string|nil)
            Table suffix to insert into. Defaults to `characters`, producing `lia_characters`.

    Returns:
        Deferred
            Resolves with a table containing `results` and `lastID`.

    Example Usage:
        ```lua
        lia.db.insertOrIgnore({usergroup = "admin", privileges = "{}"}, "admin")
        ```

    Realm:
        Server
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
        Checks whether a table exists in SQLite by its exact table name.

    Parameters:
        tbl (string)
            Exact table name to check, such as `lia_characters`.

    Returns:
        Deferred
            Resolves with true when the table exists, otherwise false.

    Example Usage:
        ```lua
        lia.db.tableExists("lia_characters"):next(function(exists)
            print(exists)
        end)
        ```

    Realm:
        Server
]]
function lia.db.tableExists(tbl)
    local d = deferred.new()
    local qt = "'" .. tbl:gsub("'", "''") .. "'"
    lia.db.query("SELECT name FROM sqlite_master WHERE type='table' AND name=" .. qt, function(res) d:resolve(res and #res > 0) end, function(err) d:reject(err) end)
    return d
end

--[[
    Purpose:
        Checks whether a column exists in a table using SQLite table information.

    Parameters:
        tbl (string)
            Exact table name to inspect, such as `lia_characters`.

        field (string)
            Column name to find.

    Returns:
        Deferred
            Resolves with true when the column exists, otherwise false.

    Example Usage:
        ```lua
        lia.db.fieldExists("lia_characters", "money"):next(function(exists)
            print(exists)
        end)
        ```

    Realm:
        Server
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
        Retrieves all SQLite table names that start with `lia_`.

    Parameters:
        None.

    Returns:
        Deferred
            Resolves with an array of matching table names.

    Example Usage:
        ```lua
        lia.db.getTables():next(function(tables)
            PrintTable(tables)
        end)
        ```

    Realm:
        Server
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
        Runs a list of SQL queries inside a transaction, committing when all queries pass and rolling back if any query fails.

    Parameters:
        queries (table)
            Ordered array of SQL query strings to run.

    Returns:
        Deferred
            Resolves after COMMIT succeeds, or rejects after ROLLBACK on failure.

    Example Usage:
        ```lua
        lia.db.transaction({
            "UPDATE lia_players SET userGroup = 'admin' WHERE steamID = 'STEAM_0:1:1'",
            "INSERT INTO lia_logs (category, message) VALUES ('admin', 'Promoted user')"
        })
        ```

    Realm:
        Server
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
        Escapes a SQL identifier with backticks and doubles embedded backticks.

    Parameters:
        id (any)
            Identifier value to convert into a safely quoted SQL identifier.

    Returns:
        string
            Backtick-quoted SQL identifier.

    Example Usage:
        ```lua
        local field = lia.db.escapeIdentifier("steamID")
        ```

    Realm:
        Server
]]
function lia.db.escapeIdentifier(id)
    return "`" .. tostring(id):gsub("`", "``") .. "`"
end

--[[
    Purpose:
        Inserts or replaces a row in a `lia_` database table.

    Parameters:
        value (table)
            Key-value pairs to insert or replace in the target table.

        dbTable (string|nil)
            Table suffix to upsert into. Defaults to `characters`, producing `lia_characters`.

    Returns:
        Deferred
            Resolves with a table containing `results` and `lastID`.

    Example Usage:
        ```lua
        lia.db.upsert({id = 1, name = "Example"}, "characters")
        ```

    Realm:
        Server
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
        Deletes rows from a `lia_` database table using an optional condition.

    Parameters:
        dbTable (string|nil)
            Table suffix to delete from. Defaults to `character`, producing `lia_character`.

        condition (string|table|nil)
            Optional WHERE clause as a raw string or a table of field comparisons.

    Returns:
        Deferred
            Resolves with a table containing `results` and `lastID`.

    Example Usage:
        ```lua
        lia.db.delete("characters", {id = 5})
        ```

    Realm:
        Server
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
        Creates a `lia_` prefixed table from a schema definition when it does not already exist.

    Parameters:
        dbName (string)
            Table suffix to create, producing `lia_<dbName>`.

        primaryKey (string|nil)
            Optional primary key column name.

        schema (table)
            Array of column definitions with `name`, `type`, optional `not_null`, and optional `default` fields.

    Returns:
        Deferred
            Resolves with true when the create-table query completes.

    Example Usage:
        ```lua
        lia.db.createTable("example", "id", {
            {name = "id", type = "integer", not_null = true},
            {name = "value", type = "text", default = ""}
        })
        ```

    Realm:
        Server
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
        Adds a column to a `lia_` prefixed table when the column does not already exist.

    Parameters:
        tableName (string)
            Table suffix to alter, producing `lia_<tableName>`.

        columnName (string)
            Column name to add.

        columnType (string)
            SQL column type to add.

        defaultValue (any|nil)
            Optional default value for the new column.

    Returns:
        Deferred
            Resolves with true when the column is added, or false when it already exists.

    Example Usage:
        ```lua
        lia.db.createColumn("warnings", "notes", "text", "")
        ```

    Realm:
        Server
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
        Drops a `lia_` prefixed table when it exists.

    Parameters:
        tableName (string)
            Table suffix to remove, producing `lia_<tableName>`.

    Returns:
        Deferred
            Resolves with true when the table is dropped, or false when it does not exist.

    Example Usage:
        ```lua
        lia.db.removeTable("example")
        ```

    Realm:
        Server
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
        Removes a column from a `lia_` prefixed table by rebuilding the table without that column.

    Parameters:
        tableName (string)
            Table suffix to alter, producing `lia_<tableName>`.

        columnName (string)
            Column name to remove.

    Returns:
        Deferred
            Resolves with true when the column is removed, false when the table or column does not exist, or rejects when removal is not possible.

    Example Usage:
        ```lua
        lia.db.removeColumn("warnings", "notes")
        ```

    Realm:
        Server
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
        Retrieves the column names from the `lia_characters` table and passes them to a callback.

    Parameters:
        callback (function)
            Function called with an array of character table column names.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.db.getCharacterTable(function(columns)
            PrintTable(columns)
        end)
        ```

    Realm:
        Server
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
        Saves all rows from a `lia_` prefixed table to a JSON snapshot file under `data/lilia/snapshots`.

    Parameters:
        tableName (string)
            Table suffix to snapshot, producing `lia_<tableName>`.

    Returns:
        Deferred
            Resolves with snapshot file name, path, and record count.

    Example Usage:
        ```lua
        lia.db.createSnapshot("characters"):next(function(snapshot)
            print(snapshot.path)
        end)
        ```

    Realm:
        Server
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
        Loads a JSON snapshot from `data/lilia/snapshots`, clears the target table, and restores the snapshot rows in batches.

    Parameters:
        fileName (string)
            Snapshot file name to load from `lilia/snapshots`.

    Returns:
        Deferred
            Resolves with restored table name, record count, and snapshot timestamp.

    Example Usage:
        ```lua
        lia.db.loadSnapshot("snapshot_characters_1700000000.json")
        ```

    Realm:
        Server
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
