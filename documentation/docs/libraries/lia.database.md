# Database Library

This page documents the functions for working with database operations and management.

---

## Overview

The database library (`lia.db`) provides a comprehensive system for database operations, schema management, and data persistence in the Lilia framework, serving as the primary data access layer for all persistent storage needs. This library offers advanced SQL operations with support for SQLite database backend with automatic query queuing and connection management for optimal performance. The system features robust schema management with automatic field additions, table creation, and migration support for seamless framework updates. The library provides comprehensive transaction management with rollback capabilities and deferred promise-based operations for asynchronous database interactions. Additional features include database administration utilities, table and column management, and security features such as SQL injection prevention through proper escaping, making it the cornerstone of all persistent data operations within the Lilia framework.

---

### escapeIdentifier

**Purpose**

Escapes a database identifier to prevent SQL injection.

**Parameters**

* `identifier` (*string*): The identifier to escape.

**Returns**

* `escapedIdentifier` (*string*): The escaped identifier wrapped in backticks.

**Realm**

Shared.

**Example Usage**

```lua
-- Escape identifier
local function escapeIdentifier(identifier)
    return lia.db.escapeIdentifier(identifier)
end

-- Use in a function
local function buildSafeQuery(tableName, columnName)
    local safeTable = lia.db.escapeIdentifier(tableName)
    local safeColumn = lia.db.escapeIdentifier(columnName)
    return "SELECT " .. safeColumn .. " FROM " .. safeTable
end

-- Use in a function
local function createSafeTable(tableName)
    local safeName = lia.db.escapeIdentifier(tableName)
    print("Creating safe table:", safeName)
end
```

---

### connect

**Purpose**

Establishes a database connection and processes queued queries.

**Parameters**

* `callback` (*function*): Optional callback function to execute after connection.
* `reconnect` (*boolean*): Optional flag to force reconnection.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Connect to database
local function connectToDatabase()
    lia.db.connect(function()
        print("Database connected successfully")
    end)
end

-- Use in a hook
hook.Add("Initialize", "ConnectDatabase", function()
    lia.db.connect()
end)

-- Use with callback
local function initializeDatabase()
    lia.db.connect(function()
        print("Database initialized")
        -- Process any queued queries
    end)
end

-- Force reconnection
local function reconnectDatabase()
    lia.db.connect(function()
        print("Database reconnected")
    end, true)
end
```

---

### wipeTables

**Purpose**

Wipes all Lilia database tables (tables starting with 'lia_').

**Parameters**

* `callback` (*function*): Optional callback function to execute after wiping.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Wipe all tables
local function wipeAllTables()
    lia.db.wipeTables(function()
        print("All tables wiped")
    end)
end

-- Use in a command
lia.command.add("wipetables", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.wipeTables(function()
            client:notify("All tables wiped")
        end)
    end
})

-- Use in a function
local function resetDatabase()
    lia.db.wipeTables(function()
        lia.db.loadTables()
        print("Database reset")
    end)
end
```

---

### loadTables

**Purpose**

Creates and loads all required Lilia database tables with their schemas.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load database tables
local function loadTables()
    lia.db.loadTables()
    print("Database tables loaded")
end

-- Use in a hook
hook.Add("Initialize", "LoadTables", function()
    lia.db.loadTables()
end)

-- Use in a function
local function initializeTables()
    lia.db.loadTables()
    print("Tables initialized")
end
```

---

### waitForTablesToLoad

**Purpose**

Waits for all tables to finish loading and returns a promise.

**Parameters**

*None*

**Returns**

* `promise` (*Promise*): A promise that resolves when tables are loaded.

**Realm**

Server.

**Example Usage**

```lua
-- Wait for tables to load
local function waitForTables()
    lia.db.waitForTablesToLoad():next(function()
        print("All tables loaded")
    end)
end

-- Use in a function
local function ensureTablesLoaded()
    return lia.db.waitForTablesToLoad():next(function()
        print("Tables are ready")
    end)
end

-- Use in a hook
hook.Add("Initialize", "WaitForTables", function()
    lia.db.waitForTablesToLoad():next(function()
        print("Database ready")
    end)
end)

-- Chain with other operations
local function initializeAfterTables()
    lia.db.waitForTablesToLoad():next(function()
        print("Tables loaded, initializing...")
        -- Continue with initialization
    end):catch(function(err)
        print("Error loading tables:", err)
    end)
end
```

---

### convertDataType

**Purpose**

Converts a Lua value to a SQL-compatible string for database storage.

**Parameters**

* `value` (*any*): The value to convert.
* `noEscape` (*boolean*): Optional flag to skip SQL escaping.

**Returns**

* `convertedValue` (*string*): The SQL-compatible string representation.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert data type
local function convertValue(value)
    return lia.db.convertDataType(value)
end

-- Use in a function
local function createColumn(columnName, value)
    local convertedValue = lia.db.convertDataType(value)
    print("Creating column:", columnName, "with value:", convertedValue)
end

-- Use with noEscape flag
local function convertWithoutEscape(value)
    return lia.db.convertDataType(value, true)
end

-- Convert different data types
local function demonstrateConversion()
    print("String:", lia.db.convertDataType("hello")) -- 'hello'
    print("Number:", lia.db.convertDataType(42)) -- 42
    print("Boolean:", lia.db.convertDataType(true)) -- 1
    print("Table:", lia.db.convertDataType({a = 1})) -- '{"a":1}'
    print("Nil:", lia.db.convertDataType(nil)) -- NULL
end
```

---

### insertTable

**Purpose**

Inserts data into a Lilia database table.

**Parameters**

* `data` (*table*): The data to insert.
* `callback` (*function*): Optional callback function for the query result.
* `dbTable` (*string*): The table name (without 'lia_' prefix).

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Insert data into table
local function insertData(data, dbTable)
    lia.db.insertTable(data, function(results, lastID)
        print("Data inserted with ID:", lastID)
    end, dbTable)
end

-- Use in a function
local function createPlayerRecord(client)
    local data = {
        steamID = client:SteamID(),
        steamName = client:Name(),
        firstJoin = os.date("%Y-%m-%d %H:%M:%S"),
        lastJoin = os.date("%Y-%m-%d %H:%M:%S"),
        userGroup = "user",
        data = "{}",
        lastIP = client:IPAddress(),
        lastOnline = os.time(),
        totalOnlineTime = 0
    }
    lia.db.insertTable(data, function(results, lastID)
        print("Player record created with ID:", lastID)
    end, "players")
end

-- Use in a command
lia.command.add("insertdata", {
    arguments = {
        {name = "table", type = "string"},
        {name = "data", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local data = util.JSONToTable(arguments[2])
        if data then
            lia.db.insertTable(data, function(results, lastID)
                client:notify("Data inserted with ID: " .. lastID)
            end, arguments[1])
        else
            client:notify("Invalid data format")
        end
    end
})
```

---

### updateTable

**Purpose**

Updates data in a Lilia database table.

**Parameters**

* `data` (*table*): The data to update.
* `callback` (*function*): Optional callback function for the query result.
* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `condition` (*string*): Optional WHERE condition.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Update table data
local function updateData(data, dbTable, condition)
    lia.db.updateTable(data, function(results, lastID)
        print("Data updated")
    end, dbTable, condition)
end

-- Use in a function
local function updatePlayerData(client, newData)
    local condition = "steamID = '" .. client:SteamID() .. "'"
    lia.db.updateTable(newData, function(results, lastID)
        print("Player data updated")
    end, "players", condition)
end

-- Use in a command
lia.command.add("updatedata", {
    arguments = {
        {name = "table", type = "string"},
        {name = "data", type = "string"},
        {name = "condition", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local data = util.JSONToTable(arguments[2])
        if data then
            lia.db.updateTable(data, function(results, lastID)
                client:notify("Data updated")
            end, arguments[1], arguments[3])
        else
            client:notify("Invalid data format")
        end
    end
})
```

---

### select

**Purpose**

Selects data from a Lilia database table and returns a promise.

**Parameters**

* `fields` (*string|table*): The fields to select.
* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `condition` (*string*): Optional WHERE condition.
* `limit` (*number*): Optional LIMIT clause.

**Returns**

* `promise` (*Promise*): A promise that resolves with query results.

**Realm**

Server.

**Example Usage**

```lua
-- Select data from table
local function selectData(fields, dbTable, condition, limit)
    return lia.db.select(fields, dbTable, condition, limit)
end

-- Use in a function
local function getPlayerData(client)
    local condition = "steamID = '" .. client:SteamID() .. "'"
    lia.db.select("*", "players", condition):next(function(result)
        if result.results and #result.results > 0 then
            print("Player data found")
            return result.results[1]
        end
        return nil
    end):catch(function(err)
        print("Error getting player data:", err)
    end)
end

-- Use in a command
lia.command.add("selectdata", {
    arguments = {
        {name = "table", type = "string"},
        {name = "columns", type = "string"},
        {name = "condition", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.select(arguments[2], arguments[1], arguments[3]):next(function(result)
            if result.results then
                client:notify("Results: " .. util.TableToJSON(result.results))
            else
                client:notify("No results found")
            end
        end):catch(function(err)
            client:notify("Error: " .. err)
        end)
    end
})
```

---

### selectWithCondition

**Purpose**

Selects data from a Lilia database table with advanced condition handling and returns a promise.

**Parameters**

* `fields` (*string|table*): The fields to select.
* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `conditions` (*string|table*): The WHERE conditions (string or table with field-value pairs).
* `limit` (*number*): Optional LIMIT clause.
* `orderBy` (*string*): Optional ORDER BY clause.

**Returns**

* `promise` (*Promise*): A promise that resolves with query results.

**Realm**

Server.

**Example Usage**

```lua
-- Select data with condition
local function selectWithCondition(fields, dbTable, conditions, limit, orderBy)
    return lia.db.selectWithCondition(fields, dbTable, conditions, limit, orderBy)
end

-- Use in a function
local function getPlayersByLevel(level)
    local conditions = {level = {operator = ">=", value = level}}
    lia.db.selectWithCondition("*", "players", conditions):next(function(result)
        if result.results then
            print("Found", #result.results, "players with level", level)
        end
    end):catch(function(err)
        print("Error:", err)
    end)
end

-- Use with string condition
local function searchPlayers(name)
    local condition = "name LIKE '%" .. name .. "%'"
    return lia.db.selectWithCondition("*", "players", condition)
end

-- Use with table conditions
local function getActivePlayers()
    local conditions = {
        lastOnline = {operator = ">", value = os.time() - 3600},
        userGroup = "user"
    }
    return lia.db.selectWithCondition("*", "players", conditions, 10, "lastOnline DESC")
end
```

---

### count

**Purpose**

Counts records in a Lilia database table and returns a promise.

**Parameters**

* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `condition` (*string*): Optional WHERE condition.

**Returns**

* `promise` (*Promise*): A promise that resolves with the record count.

**Realm**

Server.

**Example Usage**

```lua
-- Count records in table
local function countRecords(dbTable, condition)
    return lia.db.count(dbTable, condition)
end

-- Use in a function
local function getPlayerCount()
    lia.db.count("players"):next(function(count)
        print("Total players:", count)
        return count
    end):catch(function(err)
        print("Error counting players:", err)
    end)
end

-- Use in a function
local function getActivePlayers()
    local condition = "lastOnline > " .. (os.time() - 3600)
    lia.db.count("players", condition):next(function(count)
        print("Active players:", count)
        return count
    end):catch(function(err)
        print("Error counting active players:", err)
    end)
end
```

---

### exists

**Purpose**

Checks if a record exists in a Lilia database table and returns a promise.

**Parameters**

* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `condition` (*string*): The WHERE condition.

**Returns**

* `promise` (*Promise*): A promise that resolves with true if record exists.

**Realm**

Server.

**Example Usage**

```lua
-- Check if record exists
local function recordExists(dbTable, condition)
    return lia.db.exists(dbTable, condition)
end

-- Use in a function
local function playerExists(client)
    local condition = "steamID = '" .. client:SteamID() .. "'"
    lia.db.exists("players", condition):next(function(exists)
        if exists then
            print("Player exists in database")
        else
            print("Player not found in database")
        end
        return exists
    end):catch(function(err)
        print("Error checking player existence:", err)
    end)
end

-- Use in a function
local function checkPlayerName(name)
    local condition = "steamName = '" .. name .. "'"
    return lia.db.exists("players", condition):next(function(exists)
        return exists
    end)
end
```

---

### addDatabaseFields

**Purpose**

Automatically adds database fields to the lia_characters table based on character variables.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add database fields
local function addFields()
    lia.db.addDatabaseFields()
    print("Database fields added")
end

-- This function is automatically called by loadTables()
-- It reads from lia.char.vars and adds corresponding database columns
-- Example character variable definition:
lia.char.registerVar("level", {
    field = "level",
    fieldType = "integer",
    default = 1,
    onDisplay = function(client, value)
        return "Level: " .. value
    end
})

-- The addDatabaseFields function will automatically create a 'level' column
-- in the lia_characters table when called
```

---

### query

**Purpose**

Executes a raw SQL query with automatic queuing and connection management.

**Parameters**

* `query` (*string*): The SQL query string.
* `callback` (*function*): Optional callback function to handle the query result.
* `onError` (*function*): Optional error callback function.

**Returns**

* `promise` (*Promise*): A promise object that resolves with the query results.

**Realm**

Server.

**Example Usage**

```lua
-- Execute a simple query
local function executeQuery()
    lia.db.query("SELECT * FROM lia_players WHERE steamID = 'STEAM_0:1:12345678'", function(results, lastID)
        if results then
            print("Query successful, found " .. #results .. " results")
            for _, row in ipairs(results) do
                print("Player: " .. row.steamName)
            end
        end
    end, function(err)
        print("Query failed: " .. err)
    end)
end

-- Use with promise
local function getPlayerCount()
    return lia.db.query("SELECT COUNT(*) as count FROM lia_players"):next(function(result)
        local count = result.results[1].count
        print("Total players: " .. count)
        return count
    end):catch(function(err)
        print("Failed to get player count: " .. err)
        return 0
    end)
end

-- Insert data
local function addPlayer(steamid, name)
    lia.db.query("INSERT INTO lia_players (steamID, steamName, firstJoin) VALUES ('" .. steamid .. "', '" .. name .. "', '" .. os.date("%Y-%m-%d %H:%M:%S") .. "')", function(results, lastID)
        print("Player added with ID: " .. lastID)
    end)
end

-- Update data
local function updatePlayerLastSeen(steamid)
    lia.db.query("UPDATE lia_players SET lastOnline = " .. os.time() .. " WHERE steamID = '" .. steamid .. "'", function(results)
        print("Player last seen updated")
    end)
end
```

---

### selectOne

**Purpose**

Selects a single record from a Lilia database table and returns a promise.

**Parameters**

* `fields` (*string|table*): The fields to select.
* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `condition` (*string*): Optional WHERE condition.

**Returns**

* `promise` (*Promise*): A promise that resolves with the single record or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Select one record
local function selectOne(fields, dbTable, condition)
    return lia.db.selectOne(fields, dbTable, condition)
end

-- Use in a function
local function getPlayer(client)
    local condition = "steamID = '" .. client:SteamID() .. "'"
    lia.db.selectOne("*", "players", condition):next(function(record)
        if record then
            print("Player found:", record.steamName)
            return record
        else
            print("Player not found")
            return nil
        end
    end):catch(function(err)
        print("Error getting player:", err)
    end)
end

-- Use in a function
local function findPlayerByName(name)
    local condition = "steamName = '" .. name .. "'"
    return lia.db.selectOne("*", "players", condition):next(function(record)
        return record
    end)
end
```

---


---

### bulkInsert

**Purpose**

Performs a bulk insert operation for multiple records and returns a promise.

**Parameters**

* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `rows` (*table*): Array of data rows to insert.

**Returns**

* `promise` (*Promise*): A promise that resolves when insertion is complete.

**Realm**

Server.

**Example Usage**

```lua
-- Bulk insert data
local function bulkInsert(dbTable, rows)
    return lia.db.bulkInsert(dbTable, rows)
end

-- Use in a function
local function insertMultiplePlayers(players)
    lia.db.bulkInsert("players", players):next(function()
        print("Bulk insert successful")
    end):catch(function(err)
        print("Bulk insert failed:", err)
    end)
end

-- Use in a function
local function insertItems(items)
    return lia.db.bulkInsert("items", items):next(function()
        print("Items inserted successfully")
    end)
end

-- Example with character data
local function createMultipleCharacters(characterData)
    lia.db.bulkInsert("characters", characterData):next(function()
        print("Characters created successfully")
    end):catch(function(err)
        print("Error creating characters:", err)
    end)
end
```

---

### bulkUpsert

**Purpose**

Performs a bulk upsert operation (insert or replace) for multiple records and returns a promise.

**Parameters**

* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `rows` (*table*): Array of data rows to upsert.

**Returns**

* `promise` (*Promise*): A promise that resolves when upsert is complete.

**Realm**

Server.

**Example Usage**

```lua
-- Bulk upsert data
local function bulkUpsert(dbTable, rows)
    return lia.db.bulkUpsert(dbTable, rows)
end

-- Use in a function
local function upsertPlayers(players)
    lia.db.bulkUpsert("players", players):next(function()
        print("Bulk upsert successful")
    end):catch(function(err)
        print("Bulk upsert failed:", err)
    end)
end

-- Use in a function
local function upsertItems(items)
    return lia.db.bulkUpsert("items", items):next(function()
        print("Items upserted successfully")
    end)
end

-- Example with character data
local function updateOrCreateCharacters(characterData)
    lia.db.bulkUpsert("characters", characterData):next(function()
        print("Characters updated/created successfully")
    end):catch(function(err)
        print("Error upserting characters:", err)
    end)
end
```

---

### insertOrIgnore

**Purpose**

Inserts data or ignores if it already exists and returns a promise.

**Parameters**

* `data` (*table*): The data to insert.
* `dbTable` (*string*): The table name (without 'lia_' prefix).

**Returns**

* `promise` (*Promise*): A promise that resolves with the query results.

**Realm**

Server.

**Example Usage**

```lua
-- Insert or ignore
local function insertOrIgnore(data, dbTable)
    return lia.db.insertOrIgnore(data, dbTable)
end

-- Use in a function
local function addPlayerIfNotExists(client)
    local data = {
        steamID = client:SteamID(),
        steamName = client:Name(),
        firstJoin = os.date("%Y-%m-%d %H:%M:%S"),
        lastJoin = os.date("%Y-%m-%d %H:%M:%S"),
        userGroup = "user",
        data = "{}",
        lastIP = client:IPAddress(),
        lastOnline = os.time(),
        totalOnlineTime = 0
    }
    lia.db.insertOrIgnore(data, "players"):next(function(result)
        print("Player added or ignored")
    end):catch(function(err)
        print("Error:", err)
    end)
end

-- Use in a function
local function addItemIfNotExists(itemData)
    return lia.db.insertOrIgnore(itemData, "items"):next(function(result)
        print("Item added or ignored")
    end)
end
```

---

### tableExists

**Purpose**

Checks if a table exists in the database and returns a promise.

**Parameters**

* `tableName` (*string*): The table name (with or without 'lia_' prefix).

**Returns**

* `promise` (*Promise*): A promise that resolves with true if table exists.

**Realm**

Server.

**Example Usage**

```lua
-- Check if table exists
local function tableExists(tableName)
    return lia.db.tableExists(tableName)
end

-- Use in a function
local function checkRequiredTables()
    local tables = {"lia_players", "lia_items", "lia_characters"}
    local promises = {}
    for _, tableName in ipairs(tables) do
        table.insert(promises, lia.db.tableExists(tableName))
    end
    
    -- Wait for all checks to complete
    deferred.all(promises):next(function(results)
        for i, exists in ipairs(results) do
            if not exists then
                print("Required table missing:", tables[i])
                return false
            end
        end
        print("All required tables exist")
        return true
    end)
end

-- Use in a function
local function createTableIfNotExists(tableName, schema)
    lia.db.tableExists(tableName):next(function(exists)
        if not exists then
            lia.db.createTable(tableName, nil, schema):next(function()
                print("Table created:", tableName)
            end)
        end
    end)
end
```

---

### fieldExists

**Purpose**

Checks if a field exists in a table and returns a promise.

**Parameters**

* `tableName` (*string*): The table name (with or without 'lia_' prefix).
* `fieldName` (*string*): The field name.

**Returns**

* `promise` (*Promise*): A promise that resolves with true if field exists.

**Realm**

Server.

**Example Usage**

```lua
-- Check if field exists
local function fieldExists(tableName, fieldName)
    return lia.db.fieldExists(tableName, fieldName)
end

-- Use in a function
local function checkPlayerFields()
    local fields = {"steamID", "steamName", "level", "lastOnline"}
    for _, fieldName in ipairs(fields) do
        lia.db.fieldExists("lia_players", fieldName):next(function(exists)
            if not exists then
                print("Player field missing:", fieldName)
            end
        end)
    end
end

-- Use in a function
local function addFieldIfNotExists(tableName, fieldName, fieldType)
    lia.db.fieldExists(tableName, fieldName):next(function(exists)
        if not exists then
            lia.db.createColumn(tableName, fieldName, fieldType):next(function()
                print("Field added:", fieldName)
            end)
        end
    end)
end
```

---

### getTables

**Purpose**

Gets a list of all Lilia database tables and returns a promise.

**Parameters**

*None*

**Returns**

* `promise` (*Promise*): A promise that resolves with a list of table names.

**Realm**

Server.

**Example Usage**

```lua
-- Get all tables
local function getAllTables()
    return lia.db.getTables()
end

-- Use in a function
local function listTables()
    lia.db.getTables():next(function(tables)
        print("Database tables:")
        for _, tableName in ipairs(tables) do
            print("- " .. tableName)
        end
        return tables
    end):catch(function(err)
        print("Error getting tables:", err)
    end)
end

-- Use in a command
lia.command.add("listtables", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.getTables():next(function(tables)
            client:notify("Tables: " .. table.concat(tables, ", "))
        end):catch(function(err)
            client:notify("Error: " .. err)
        end)
    end
})
```

---


---

### transaction

**Purpose**

Executes a database transaction with multiple queries and returns a promise.

**Parameters**

* `queries` (*table*): Array of SQL query strings to execute in sequence.

**Returns**

* `promise` (*Promise*): A promise that resolves when all queries complete successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Execute transaction
local function executeTransaction(queries)
    return lia.db.transaction(queries)
end

-- Use in a function
local function transferMoney(fromPlayer, toPlayer, amount)
    local queries = {
        "UPDATE lia_players SET money = money - " .. amount .. " WHERE steamID = '" .. fromPlayer:SteamID() .. "'",
        "UPDATE lia_players SET money = money + " .. amount .. " WHERE steamID = '" .. toPlayer:SteamID() .. "'"
    }
    return lia.db.transaction(queries):next(function()
        print("Money transfer completed")
    end):catch(function(err)
        print("Transfer failed:", err)
    end)
end

-- Use in a function
local function createPlayerWithCharacter(playerData, characterData)
    local queries = {
        "INSERT INTO lia_players (steamID, steamName, firstJoin) VALUES ('" .. playerData.steamID .. "', '" .. playerData.steamName .. "', '" .. playerData.firstJoin .. "')",
        "INSERT INTO lia_characters (steamID, name, createTime) VALUES ('" .. characterData.steamID .. "', '" .. characterData.name .. "', '" .. characterData.createTime .. "')"
    }
    return lia.db.transaction(queries):next(function()
        print("Player and character created successfully")
    end):catch(function(err)
        print("Creation failed:", err)
    end)
end
```

---


---

### upsert

**Purpose**

Updates a record or inserts if it doesn't exist and returns a promise.

**Parameters**

* `data` (*table*): The data to upsert.
* `dbTable` (*string*): The table name (without 'lia_' prefix).

**Returns**

* `promise` (*Promise*): A promise that resolves with the query results.

**Realm**

Server.

**Example Usage**

```lua
-- Upsert data
local function upsertData(data, dbTable)
    return lia.db.upsert(data, dbTable)
end

-- Use in a function
local function updateOrCreatePlayer(client)
    local data = {
        steamID = client:SteamID(),
        steamName = client:Name(),
        lastJoin = os.date("%Y-%m-%d %H:%M:%S"),
        lastOnline = os.time()
    }
    lia.db.upsert(data, "players"):next(function(result)
        print("Player updated or created")
    end):catch(function(err)
        print("Error upserting player:", err)
    end)
end

-- Use in a function
local function updateOrCreateItem(itemData)
    return lia.db.upsert(itemData, "items"):next(function(result)
        print("Item updated or created")
    end)
end
```

---

### delete

**Purpose**

Deletes records from a Lilia database table and returns a promise.

**Parameters**

* `dbTable` (*string*): The table name (without 'lia_' prefix).
* `condition` (*string*): Optional WHERE condition.

**Returns**

* `promise` (*Promise*): A promise that resolves with the query results.

**Realm**

Server.

**Example Usage**

```lua
-- Delete records
local function deleteRecords(dbTable, condition)
    return lia.db.delete(dbTable, condition)
end

-- Use in a function
local function deletePlayer(client)
    local condition = "steamID = '" .. client:SteamID() .. "'"
    lia.db.delete("players", condition):next(function(result)
        print("Player deleted")
    end):catch(function(err)
        print("Error deleting player:", err)
    end)
end

-- Use in a function
local function deleteOldRecords(dbTable, daysOld)
    local condition = "createTime < '" .. os.date("%Y-%m-%d %H:%M:%S", os.time() - (daysOld * 86400)) .. "'"
    return lia.db.delete(dbTable, condition):next(function(result)
        print("Old records deleted")
    end)
end
```

---

### createTable

**Purpose**

Creates a new Lilia database table and returns a promise.

**Parameters**

* `dbName` (*string*): The table name (without 'lia_' prefix).
* `primaryKey` (*string*): Optional primary key column name.
* `schema` (*table*): The table schema definition.

**Returns**

* `promise` (*Promise*): A promise that resolves with true if table was created successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Create table
local function createTable(dbName, primaryKey, schema)
    return lia.db.createTable(dbName, primaryKey, schema)
end

-- Use in a function
local function createPlayersTable()
    local schema = {
        {name = "id", type = "INTEGER", not_null = true},
        {name = "steamID", type = "VARCHAR(20)"},
        {name = "steamName", type = "VARCHAR(100)"},
        {name = "level", type = "INTEGER", default = 1}
    }
    lia.db.createTable("players", "id", schema):next(function(success)
        if success then
            print("Players table created")
        end
    end):catch(function(err)
        print("Error creating table:", err)
    end)
end

-- Use in a function
local function createItemsTable()
    local schema = {
        {name = "id", type = "INTEGER", not_null = true},
        {name = "uniqueID", type = "VARCHAR(50)"},
        {name = "itemID", type = "VARCHAR(50)"},
        {name = "data", type = "TEXT"}
    }
    return lia.db.createTable("items", "id", schema):next(function(success)
        print("Items table created")
    end)
end
```

---

### createColumn

**Purpose**

Creates a new column in a Lilia database table and returns a promise.

**Parameters**

* `tableName` (*string*): The table name (without 'lia_' prefix).
* `columnName` (*string*): The column name.
* `columnType` (*string*): The column type.
* `defaultValue` (*any*): Optional default value.

**Returns**

* `promise` (*Promise*): A promise that resolves with true if column was created successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Create column
local function createColumn(tableName, columnName, columnType, defaultValue)
    return lia.db.createColumn(tableName, columnName, columnType, defaultValue)
end

-- Use in a function
local function addPlayerField(fieldName, fieldType, defaultValue)
    lia.db.createColumn("players", fieldName, fieldType, defaultValue):next(function(success)
        if success then
            print("Player field added:", fieldName)
        end
    end):catch(function(err)
        print("Error adding field:", err)
    end)
end

-- Use in a function
local function addItemField(fieldName, fieldType)
    return lia.db.createColumn("items", fieldName, fieldType):next(function(success)
        print("Item field added:", fieldName)
    end)
end
```

---

### removeTable

**Purpose**

Removes a Lilia database table and returns a promise.

**Parameters**

* `tableName` (*string*): The table name (without 'lia_' prefix).

**Returns**

* `promise` (*Promise*): A promise that resolves with true if table was removed successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Remove table
local function removeTable(tableName)
    return lia.db.removeTable(tableName)
end

-- Use in a function
local function cleanupOldTables()
    local oldTables = {"old_players", "old_items", "old_characters"}
    for _, tableName in ipairs(oldTables) do
        lia.db.removeTable(tableName):next(function(success)
            if success then
                print("Table removed:", tableName)
            end
        end)
    end
end

-- Use in a command
lia.command.add("removetable", {
    arguments = {
        {name = "table", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.removeTable(arguments[1]):next(function(success)
            client:notify("Table " .. (success and "removed" or "removal failed"))
        end):catch(function(err)
            client:notify("Error: " .. err)
        end)
    end
})
```

---

### removeColumn

**Purpose**

Removes a column from a Lilia database table and returns a promise.

**Parameters**

* `tableName` (*string*): The table name (without 'lia_' prefix).
* `columnName` (*string*): The column name.

**Returns**

* `promise` (*Promise*): A promise that resolves with true if column was removed successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Remove column
local function removeColumn(tableName, columnName)
    return lia.db.removeColumn(tableName, columnName)
end

-- Use in a function
local function removePlayerField(fieldName)
    lia.db.removeColumn("players", fieldName):next(function(success)
        if success then
            print("Player field removed:", fieldName)
        end
    end):catch(function(err)
        print("Error removing field:", err)
    end)
end

-- Use in a function
local function removeItemField(fieldName)
    return lia.db.removeColumn("items", fieldName):next(function(success)
        print("Item field removed:", fieldName)
    end)
end
```

---

### GetCharacterTable

**Purpose**

Gets the character table column information via callback.

**Parameters**

* `callback` (*function*): Callback function that receives the column names array.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Get character table columns
local function getCharacterTableColumns()
    lia.db.GetCharacterTable(function(columns)
        print("Character table columns:")
        for _, column in ipairs(columns) do
            print("- " .. column)
        end
    end)
end

-- Use in a function
local function getCharacterData(characterId)
    lia.db.GetCharacterTable(function(columns)
        local condition = "id = " .. characterId
        lia.db.selectOne("*", "characters", condition):next(function(record)
            if record then
                print("Character found:", record.name)
            end
        end)
    end)
end

-- Use in a function
local function createCharacter(characterData)
    lia.db.GetCharacterTable(function(columns)
        lia.db.insertTable(characterData, function(results, lastID)
            print("Character created with ID:", lastID)
        end, "characters")
    end)
end
```

---

### createSnapshot

**Purpose**

Creates a snapshot of a database table by exporting all data to a JSON file and returns a promise.

**Parameters**

* `tableName` (*string*): The table name (without 'lia_' prefix).

**Returns**

* `promise` (*Promise*): A promise that resolves with snapshot information including file name, path, and record count.

**Realm**

Server.

**Example Usage**

```lua
-- Create snapshot
local function createSnapshot(tableName)
    return lia.db.createSnapshot(tableName)
end

-- Use in a function
local function backupPlayersTable()
    lia.db.createSnapshot("players"):next(function(result)
        print("Snapshot created successfully!")
        print("File:", result.file)
        print("Path:", result.path)
        print("Records:", result.records)
    end):catch(function(err)
        print("Snapshot failed:", err)
    end)
end

-- Use in a command
lia.command.add("backup", {
    arguments = {
        {name = "table", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.createSnapshot(arguments[1]):next(function(result)
            client:notify("Backup created: " .. result.file .. " (" .. result.records .. " records)")
        end):catch(function(err)
            client:notify("Backup failed: " .. err)
        end)
    end
})

-- Backup multiple tables
local function backupAllTables()
    local tables = {"players", "characters", "items"}
    for _, tableName in ipairs(tables) do
        lia.db.createSnapshot(tableName):next(function(result)
            print("Backed up " .. tableName .. ": " .. result.records .. " records")
        end)
    end
end
```

---

### loadSnapshot

**Purpose**

Loads a database snapshot from a JSON file and restores the data to the target table, returning a promise.

**Parameters**

* `fileName` (*string*): The snapshot file name (with or without path).

**Returns**

* `promise` (*Promise*): A promise that resolves with restoration information including table name, record count, and timestamp.

**Realm**

Server.

**Example Usage**

```lua
-- Load snapshot
local function loadSnapshot(fileName)
    return lia.db.loadSnapshot(fileName)
end

-- Use in a function
local function restorePlayersTable(fileName)
    lia.db.loadSnapshot(fileName):next(function(result)
        print("Snapshot loaded successfully!")
        print("Table:", result.table)
        print("Records:", result.records)
        if result.timestamp then
            print("Original timestamp:", os.date("%Y-%m-%d %H:%M:%S", result.timestamp))
        end
    end):catch(function(err)
        print("Snapshot load failed:", err)
    end)
end

-- Use in a command
lia.command.add("restore", {
    arguments = {
        {name = "filename", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.loadSnapshot(arguments[1]):next(function(result)
            client:notify("Restored " .. result.records .. " records to " .. result.table)
        end):catch(function(err)
            client:notify("Restore failed: " .. err)
        end)
    end
})

-- List available snapshots
local function listSnapshots()
    local files, _ = file.Find("data/lilia/snapshots/*/*.json", "DATA")
    if files and #files > 0 then
        print("Available snapshots:")
        for _, file in ipairs(files) do
            print("- " .. file)
        end
    else
        print("No snapshots found")
    end
end
```
