# Database Library

This page documents the functions for working with database operations and management.

---

## Overview

The database library (`lia.db`) provides a comprehensive system for database operations, caching, schema management, and data persistence in the Lilia framework. It includes SQL operations, caching, transactions, and database administration functionality.

---

### lia.db.setCacheEnabled

**Purpose**

Enables or disables database caching.

**Parameters**

* `enabled` (*boolean*): Whether to enable caching.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Enable database caching
local function enableCaching()
    lia.db.setCacheEnabled(true)
    print("Database caching enabled")
end

-- Disable database caching
local function disableCaching()
    lia.db.setCacheEnabled(false)
    print("Database caching disabled")
end

-- Use in a command
lia.command.add("togglecache", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local enabled = lia.db.isCacheEnabled()
        lia.db.setCacheEnabled(not enabled)
        client:notify("Database caching " .. (enabled and "disabled" or "enabled"))
    end
})

-- Use in a function
local function configureCaching()
    if lia.config.get("EnableDBCache") then
        lia.db.setCacheEnabled(true)
    else
        lia.db.setCacheEnabled(false)
    end
end
```

---

### lia.db.setCacheTTL

**Purpose**

Sets the cache time-to-live in seconds.

**Parameters**

* `ttl` (*number*): The TTL in seconds.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set cache TTL
local function setCacheTTL(ttl)
    lia.db.setCacheTTL(ttl)
    print("Cache TTL set to", ttl, "seconds")
end

-- Use in a function
local function configureCache()
    lia.db.setCacheTTL(300) -- 5 minutes
    lia.db.setCacheEnabled(true)
end

-- Use in a command
lia.command.add("setcachettl", {
    arguments = {
        {name = "ttl", type = "number"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local ttl = tonumber(arguments[1])
        if ttl and ttl > 0 then
            lia.db.setCacheTTL(ttl)
            client:notify("Cache TTL set to " .. ttl .. " seconds")
        else
            client:notify("Invalid TTL value")
        end
    end
})

-- Use in a function
local function optimizeCache()
    lia.db.setCacheTTL(600) -- 10 minutes
    lia.db.cacheClear()
    print("Cache optimized")
end
```

---

### lia.db.cacheClear

**Purpose**

Clears the database cache.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Clear database cache
local function clearCache()
    lia.db.cacheClear()
    print("Database cache cleared")
end

-- Use in a function
local function resetCache()
    lia.db.cacheClear()
    lia.db.setCacheEnabled(true)
    print("Cache reset")
end

-- Use in a command
lia.command.add("clearcache", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.cacheClear()
        client:notify("Database cache cleared")
    end
})

-- Use in a timer
timer.Create("ClearCache", 3600, 0, function()
    lia.db.cacheClear()
    print("Cache cleared automatically")
end)
```

---

### lia.db.cacheGet

**Purpose**

Gets a value from the database cache.

**Parameters**

* `key` (*string*): The cache key.

**Returns**

* `value` (*any*): The cached value or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Get from cache
local function getFromCache(key)
    return lia.db.cacheGet(key)
end

-- Use in a function
local function getPlayerData(client)
    local key = "player_" .. client:SteamID()
    local data = lia.db.cacheGet(key)
    if data then
        print("Data found in cache")
        return data
    else
        print("Data not in cache, querying database")
        return nil
    end
end

-- Use in a function
local function checkCache(key)
    local value = lia.db.cacheGet(key)
    if value then
        print("Cache hit for key:", key)
    else
        print("Cache miss for key:", key)
    end
    return value
end
```

---

### lia.db.cacheSet

**Purpose**

Sets a value in the database cache.

**Parameters**

* `key` (*string*): The cache key.
* `value` (*any*): The value to cache.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set in cache
local function setInCache(key, value)
    lia.db.cacheSet(key, value)
end

-- Use in a function
local function cachePlayerData(client, data)
    local key = "player_" .. client:SteamID()
    lia.db.cacheSet(key, data)
    print("Player data cached")
end

-- Use in a function
local function updateCache(key, value)
    lia.db.cacheSet(key, value)
    print("Cache updated for key:", key)
end
```

---

### lia.db.invalidateTable

**Purpose**

Invalidates cache entries for a specific table.

**Parameters**

* `tableName` (*string*): The table name to invalidate.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Invalidate table cache
local function invalidateTable(tableName)
    lia.db.invalidateTable(tableName)
    print("Cache invalidated for table:", tableName)
end

-- Use in a function
local function updateTableData(tableName, data)
    lia.db.invalidateTable(tableName)
    -- Update table data
    print("Table updated and cache invalidated")
end

-- Use in a command
lia.command.add("invalidate", {
    arguments = {
        {name = "table", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.invalidateTable(arguments[1])
        client:notify("Cache invalidated for table: " .. arguments[1])
    end
})
```

---

### lia.db.normalizeIdentifier

**Purpose**

Normalizes a database identifier.

**Parameters**

* `identifier` (*string*): The identifier to normalize.

**Returns**

* `normalizedIdentifier` (*string*): The normalized identifier.

**Realm**

Shared.

**Example Usage**

```lua
-- Normalize identifier
local function normalizeIdentifier(identifier)
    return lia.db.normalizeIdentifier(identifier)
end

-- Use in a function
local function createTable(tableName)
    local normalized = lia.db.normalizeIdentifier(tableName)
    print("Creating table:", normalized)
end

-- Use in a function
local function validateIdentifier(identifier)
    local normalized = lia.db.normalizeIdentifier(identifier)
    if normalized ~= identifier then
        print("Identifier normalized:", identifier, "->", normalized)
    end
    return normalized
end
```

---

### lia.db.normalizeSQLIdentifiers

**Purpose**

Normalizes SQL identifiers in a query.

**Parameters**

* `query` (*string*): The SQL query to normalize.

**Returns**

* `normalizedQuery` (*string*): The normalized query.

**Realm**

Shared.

**Example Usage**

```lua
-- Normalize SQL identifiers
local function normalizeSQL(query)
    return lia.db.normalizeSQLIdentifiers(query)
end

-- Use in a function
local function executeQuery(query)
    local normalized = lia.db.normalizeSQLIdentifiers(query)
    print("Executing normalized query:", normalized)
end

-- Use in a function
local function buildQuery(tableName, columns)
    local query = "SELECT " .. table.concat(columns, ", ") .. " FROM " .. tableName
    return lia.db.normalizeSQLIdentifiers(query)
end
```

---

### lia.db.connect

**Purpose**

Establishes a database connection.

**Parameters**

*None*

**Returns**

* `success` (*boolean*): True if connection was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Connect to database
local function connectToDatabase()
    local success = lia.db.connect()
    if success then
        print("Database connected successfully")
    else
        print("Failed to connect to database")
    end
    return success
end

-- Use in a hook
hook.Add("Initialize", "ConnectDatabase", function()
    lia.db.connect()
end)

-- Use in a function
local function initializeDatabase()
    if lia.db.connect() then
        print("Database initialized")
        return true
    else
        print("Database initialization failed")
        return false
    end
end
```

---

### lia.db.wipeTables

**Purpose**

Wipes all database tables.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Wipe all tables
local function wipeAllTables()
    lia.db.wipeTables()
    print("All tables wiped")
end

-- Use in a command
lia.command.add("wipetables", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.wipeTables()
        client:notify("All tables wiped")
    end
})

-- Use in a function
local function resetDatabase()
    lia.db.wipeTables()
    lia.db.loadTables()
    print("Database reset")
end
```

---

### lia.db.loadTables

**Purpose**

Loads database tables.

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

### lia.db.waitForTablesToLoad

**Purpose**

Waits for all tables to finish loading.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Wait for tables to load
local function waitForTables()
    lia.db.waitForTablesToLoad()
    print("All tables loaded")
end

-- Use in a function
local function ensureTablesLoaded()
    lia.db.waitForTablesToLoad()
    print("Tables are ready")
end

-- Use in a hook
hook.Add("Initialize", "WaitForTables", function()
    lia.db.waitForTablesToLoad()
    print("Database ready")
end)
```

---

### lia.db.convertDataType

**Purpose**

Converts a data type for database storage.

**Parameters**

* `dataType` (*string*): The data type to convert.

**Returns**

* `convertedType` (*string*): The converted data type.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert data type
local function convertDataType(dataType)
    return lia.db.convertDataType(dataType)
end

-- Use in a function
local function createColumn(columnName, dataType)
    local convertedType = lia.db.convertDataType(dataType)
    print("Creating column:", columnName, "with type:", convertedType)
end

-- Use in a function
local function validateDataType(dataType)
    local converted = lia.db.convertDataType(dataType)
    if converted ~= dataType then
        print("Data type converted:", dataType, "->", converted)
    end
    return converted
end
```

---

### lia.db.insertTable

**Purpose**

Inserts data into a table.

**Parameters**

* `tableName` (*string*): The table name.
* `data` (*table*): The data to insert.

**Returns**

* `success` (*boolean*): True if insertion was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Insert data into table
local function insertData(tableName, data)
    return lia.db.insertTable(tableName, data)
end

-- Use in a function
local function createPlayerRecord(client)
    local data = {
        steamid = client:SteamID(),
        name = client:Name(),
        join_time = os.time()
    }
    local success = lia.db.insertTable("players", data)
    if success then
        print("Player record created")
    end
    return success
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
            local success = lia.db.insertTable(arguments[1], data)
            client:notify("Data " .. (success and "inserted" or "insertion failed"))
        else
            client:notify("Invalid data format")
        end
    end
})
```

---

### lia.db.updateTable

**Purpose**

Updates data in a table.

**Parameters**

* `tableName` (*string*): The table name.
* `data` (*table*): The data to update.
* `condition` (*string*): The WHERE condition.

**Returns**

* `success` (*boolean*): True if update was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Update table data
local function updateData(tableName, data, condition)
    return lia.db.updateTable(tableName, data, condition)
end

-- Use in a function
local function updatePlayerData(client, newData)
    local condition = "steamid = '" .. client:SteamID() .. "'"
    local success = lia.db.updateTable("players", newData, condition)
    if success then
        print("Player data updated")
    end
    return success
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
            local success = lia.db.updateTable(arguments[1], data, arguments[3])
            client:notify("Data " .. (success and "updated" or "update failed"))
        else
            client:notify("Invalid data format")
        end
    end
})
```

---

### lia.db.select

**Purpose**

Selects data from a table.

**Parameters**

* `tableName` (*string*): The table name.
* `columns` (*string*): The columns to select.
* `condition` (*string*): The WHERE condition.

**Returns**

* `results` (*table*): The query results.

**Realm**

Server.

**Example Usage**

```lua
-- Select data from table
local function selectData(tableName, columns, condition)
    return lia.db.select(tableName, columns, condition)
end

-- Use in a function
local function getPlayerData(client)
    local condition = "steamid = '" .. client:SteamID() .. "'"
    local results = lia.db.select("players", "*", condition)
    if results and #results > 0 then
        print("Player data found")
        return results[1]
    end
    return nil
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
        local results = lia.db.select(arguments[1], arguments[2], arguments[3])
        if results then
            client:notify("Results: " .. util.TableToJSON(results))
        else
            client:notify("No results found")
        end
    end
})
```

---

### lia.db.selectWithCondition

**Purpose**

Selects data from a table with a condition.

**Parameters**

* `tableName` (*string*): The table name.
* `columns` (*string*): The columns to select.
* `condition` (*string*): The WHERE condition.

**Returns**

* `results` (*table*): The query results.

**Realm**

Server.

**Example Usage**

```lua
-- Select data with condition
local function selectWithCondition(tableName, columns, condition)
    return lia.db.selectWithCondition(tableName, columns, condition)
end

-- Use in a function
local function getPlayersByLevel(level)
    local condition = "level >= " .. level
    local results = lia.db.selectWithCondition("players", "*", condition)
    if results then
        print("Found", #results, "players with level", level)
    end
    return results
end

-- Use in a function
local function searchPlayers(name)
    local condition = "name LIKE '%" .. name .. "%'"
    return lia.db.selectWithCondition("players", "*", condition)
end
```

---

### lia.db.count

**Purpose**

Counts records in a table.

**Parameters**

* `tableName` (*string*): The table name.
* `condition` (*string*): The WHERE condition.

**Returns**

* `count` (*number*): The record count.

**Realm**

Server.

**Example Usage**

```lua
-- Count records in table
local function countRecords(tableName, condition)
    return lia.db.count(tableName, condition)
end

-- Use in a function
local function getPlayerCount()
    local count = lia.db.count("players")
    print("Total players:", count)
    return count
end

-- Use in a function
local function getActivePlayers()
    local condition = "last_seen > " .. (os.time() - 3600)
    local count = lia.db.count("players", condition)
    print("Active players:", count)
    return count
end
```

---

### lia.db.exists

**Purpose**

Checks if a record exists in a table.

**Parameters**

* `tableName` (*string*): The table name.
* `condition` (*string*): The WHERE condition.

**Returns**

* `exists` (*boolean*): True if record exists.

**Realm**

Server.

**Example Usage**

```lua
-- Check if record exists
local function recordExists(tableName, condition)
    return lia.db.exists(tableName, condition)
end

-- Use in a function
local function playerExists(client)
    local condition = "steamid = '" .. client:SteamID() .. "'"
    return lia.db.exists("players", condition)
end

-- Use in a function
local function checkPlayerName(name)
    local condition = "name = '" .. name .. "'"
    return lia.db.exists("players", condition)
end
```

---

### lia.db.addExpectedSchema

**Purpose**

Adds an expected database schema.

**Parameters**

* `tableName` (*string*): The table name.
* `schema` (*table*): The schema definition.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add expected schema
local function addSchema(tableName, schema)
    lia.db.addExpectedSchema(tableName, schema)
end

-- Use in a function
local function definePlayerSchema()
    local schema = {
        {name = "id", type = "INTEGER", primary = true, auto_increment = true},
        {name = "steamid", type = "VARCHAR(20)", unique = true},
        {name = "name", type = "VARCHAR(100)"},
        {name = "level", type = "INTEGER", default = 1}
    }
    lia.db.addExpectedSchema("players", schema)
end

-- Use in a function
local function defineItemSchema()
    local schema = {
        {name = "id", type = "INTEGER", primary = true, auto_increment = true},
        {name = "uniqueid", type = "VARCHAR(50)", unique = true},
        {name = "itemid", type = "VARCHAR(50)"},
        {name = "data", type = "TEXT"}
    }
    lia.db.addExpectedSchema("items", schema)
end
```

---

### lia.db.migrateDatabaseSchemas

**Purpose**

Migrates database schemas to match expected schemas.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Migrate database schemas
local function migrateSchemas()
    lia.db.migrateDatabaseSchemas()
    print("Database schemas migrated")
end

-- Use in a hook
hook.Add("Initialize", "MigrateSchemas", function()
    lia.db.migrateDatabaseSchemas()
end)

-- Use in a function
local function updateDatabase()
    lia.db.migrateDatabaseSchemas()
    print("Database updated")
end
```

---

### lia.db.addDatabaseFields

**Purpose**

Adds fields to a database table.

**Parameters**

* `tableName` (*string*): The table name.
* `fields` (*table*): The fields to add.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add database fields
local function addFields(tableName, fields)
    lia.db.addDatabaseFields(tableName, fields)
end

-- Use in a function
local function addPlayerFields()
    local fields = {
        {name = "last_seen", type = "INTEGER", default = 0},
        {name = "playtime", type = "INTEGER", default = 0}
    }
    lia.db.addDatabaseFields("players", fields)
end

-- Use in a function
local function addItemFields()
    local fields = {
        {name = "quantity", type = "INTEGER", default = 1},
        {name = "condition", type = "INTEGER", default = 100}
    }
    lia.db.addDatabaseFields("items", fields)
end
```

---

### lia.db.selectOne

**Purpose**

Selects a single record from a table.

**Parameters**

* `tableName` (*string*): The table name.
* `columns` (*string*): The columns to select.
* `condition` (*string*): The WHERE condition.

**Returns**

* `record` (*table*): The single record or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Select one record
local function selectOne(tableName, columns, condition)
    return lia.db.selectOne(tableName, columns, condition)
end

-- Use in a function
local function getPlayer(client)
    local condition = "steamid = '" .. client:SteamID() .. "'"
    return lia.db.selectOne("players", "*", condition)
end

-- Use in a function
local function findPlayerByName(name)
    local condition = "name = '" .. name .. "'"
    return lia.db.selectOne("players", "*", condition)
end
```

---

### lia.db.selectWithJoin

**Purpose**

Selects data from multiple tables with a JOIN.

**Parameters**

* `query` (*string*): The JOIN query.

**Returns**

* `results` (*table*): The query results.

**Realm**

Server.

**Example Usage**

```lua
-- Select with JOIN
local function selectWithJoin(query)
    return lia.db.selectWithJoin(query)
end

-- Use in a function
local function getPlayerWithItems(client)
    local query = "SELECT p.*, i.* FROM players p LEFT JOIN items i ON p.id = i.player_id WHERE p.steamid = '" .. client:SteamID() .. "'"
    return lia.db.selectWithJoin(query)
end

-- Use in a function
local function getPlayersWithStats()
    local query = "SELECT p.name, s.kills, s.deaths FROM players p LEFT JOIN stats s ON p.id = s.player_id"
    return lia.db.selectWithJoin(query)
end
```

---

### lia.db.bulkInsert

**Purpose**

Performs a bulk insert operation.

**Parameters**

* `tableName` (*string*): The table name.
* `data` (*table*): The data to insert.

**Returns**

* `success` (*boolean*): True if insertion was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Bulk insert data
local function bulkInsert(tableName, data)
    return lia.db.bulkInsert(tableName, data)
end

-- Use in a function
local function insertMultiplePlayers(players)
    local success = lia.db.bulkInsert("players", players)
    if success then
        print("Bulk insert successful")
    end
    return success
end

-- Use in a function
local function insertItems(items)
    return lia.db.bulkInsert("items", items)
end
```

---

### lia.db.bulkUpsert

**Purpose**

Performs a bulk upsert operation.

**Parameters**

* `tableName` (*string*): The table name.
* `data` (*table*): The data to upsert.

**Returns**

* `success` (*boolean*): True if upsert was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Bulk upsert data
local function bulkUpsert(tableName, data)
    return lia.db.bulkUpsert(tableName, data)
end

-- Use in a function
local function upsertPlayers(players)
    local success = lia.db.bulkUpsert("players", players)
    if success then
        print("Bulk upsert successful")
    end
    return success
end

-- Use in a function
local function upsertItems(items)
    return lia.db.bulkUpsert("items", items)
end
```

---

### lia.db.insertOrIgnore

**Purpose**

Inserts data or ignores if it already exists.

**Parameters**

* `tableName` (*string*): The table name.
* `data` (*table*): The data to insert.

**Returns**

* `success` (*boolean*): True if operation was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Insert or ignore
local function insertOrIgnore(tableName, data)
    return lia.db.insertOrIgnore(tableName, data)
end

-- Use in a function
local function addPlayerIfNotExists(client)
    local data = {
        steamid = client:SteamID(),
        name = client:Name(),
        join_time = os.time()
    }
    return lia.db.insertOrIgnore("players", data)
end

-- Use in a function
local function addItemIfNotExists(itemData)
    return lia.db.insertOrIgnore("items", itemData)
end
```

---

### lia.db.tableExists

**Purpose**

Checks if a table exists in the database.

**Parameters**

* `tableName` (*string*): The table name.

**Returns**

* `exists` (*boolean*): True if table exists.

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
    local tables = {"players", "items", "characters"}
    for _, tableName in ipairs(tables) do
        if not lia.db.tableExists(tableName) then
            print("Required table missing:", tableName)
            return false
        end
    end
    return true
end

-- Use in a function
local function createTableIfNotExists(tableName, schema)
    if not lia.db.tableExists(tableName) then
        lia.db.createTable(tableName, schema)
        print("Table created:", tableName)
    end
end
```

---

### lia.db.fieldExists

**Purpose**

Checks if a field exists in a table.

**Parameters**

* `tableName` (*string*): The table name.
* `fieldName` (*string*): The field name.

**Returns**

* `exists` (*boolean*): True if field exists.

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
    local fields = {"steamid", "name", "level", "last_seen"}
    for _, fieldName in ipairs(fields) do
        if not lia.db.fieldExists("players", fieldName) then
            print("Player field missing:", fieldName)
        end
    end
end

-- Use in a function
local function addFieldIfNotExists(tableName, fieldName, fieldType)
    if not lia.db.fieldExists(tableName, fieldName) then
        lia.db.createColumn(tableName, fieldName, fieldType)
        print("Field added:", fieldName)
    end
end
```

---

### lia.db.getTables

**Purpose**

Gets a list of all database tables.

**Parameters**

*None*

**Returns**

* `tables` (*table*): List of table names.

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
    local tables = lia.db.getTables()
    print("Database tables:")
    for _, tableName in ipairs(tables) do
        print("- " .. tableName)
    end
    return tables
end

-- Use in a command
lia.command.add("listtables", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local tables = lia.db.getTables()
        client:notify("Tables: " .. table.concat(tables, ", "))
    end
})
```

---

### lia.db.getTableColumns

**Purpose**

Gets the columns of a table.

**Parameters**

* `tableName` (*string*): The table name.

**Returns**

* `columns` (*table*): List of column information.

**Realm**

Server.

**Example Usage**

```lua
-- Get table columns
local function getTableColumns(tableName)
    return lia.db.getTableColumns(tableName)
end

-- Use in a function
local function describeTable(tableName)
    local columns = lia.db.getTableColumns(tableName)
    print("Table " .. tableName .. " columns:")
    for _, column in ipairs(columns) do
        print("- " .. column.name .. " (" .. column.type .. ")")
    end
    return columns
end

-- Use in a function
local function validateTableStructure(tableName, expectedColumns)
    local columns = lia.db.getTableColumns(tableName)
    for _, expectedColumn in ipairs(expectedColumns) do
        local found = false
        for _, column in ipairs(columns) do
            if column.name == expectedColumn.name then
                found = true
                break
            end
        end
        if not found then
            print("Missing column:", expectedColumn.name)
        end
    end
end
```

---

### lia.db.transaction

**Purpose**

Executes a database transaction.

**Parameters**

* `callback` (*function*): The transaction callback function.

**Returns**

* `success` (*boolean*): True if transaction was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Execute transaction
local function executeTransaction(callback)
    return lia.db.transaction(callback)
end

-- Use in a function
local function transferMoney(fromPlayer, toPlayer, amount)
    return lia.db.transaction(function()
        -- Deduct money from sender
        local fromCondition = "steamid = '" .. fromPlayer:SteamID() .. "'"
        local fromData = {money = lia.db.selectOne("players", "money", fromCondition).money - amount}
        lia.db.updateTable("players", fromData, fromCondition)
        
        -- Add money to receiver
        local toCondition = "steamid = '" .. toPlayer:SteamID() .. "'"
        local toData = {money = lia.db.selectOne("players", "money", toCondition).money + amount}
        lia.db.updateTable("players", toData, toCondition)
        
        return true
    end)
end

-- Use in a function
local function createPlayerWithCharacter(playerData, characterData)
    return lia.db.transaction(function()
        -- Insert player
        local playerId = lia.db.insertTable("players", playerData)
        if not playerId then return false end
        
        -- Insert character
        characterData.player_id = playerId
        local characterId = lia.db.insertTable("characters", characterData)
        if not characterId then return false end
        
        return true
    end)
end
```

---

### lia.db.escapeIdentifier

**Purpose**

Escapes a database identifier.

**Parameters**

* `identifier` (*string*): The identifier to escape.

**Returns**

* `escapedIdentifier` (*string*): The escaped identifier.

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

### lia.db.upsert

**Purpose**

Updates a record or inserts if it doesn't exist.

**Parameters**

* `tableName` (*string*): The table name.
* `data` (*table*): The data to upsert.
* `condition` (*string*): The WHERE condition.

**Returns**

* `success` (*boolean*): True if operation was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Upsert data
local function upsertData(tableName, data, condition)
    return lia.db.upsert(tableName, data, condition)
end

-- Use in a function
local function updateOrCreatePlayer(client)
    local data = {
        steamid = client:SteamID(),
        name = client:Name(),
        last_seen = os.time()
    }
    local condition = "steamid = '" .. client:SteamID() .. "'"
    return lia.db.upsert("players", data, condition)
end

-- Use in a function
local function updateOrCreateItem(itemData)
    local condition = "uniqueid = '" .. itemData.uniqueid .. "'"
    return lia.db.upsert("items", itemData, condition)
end
```

---

### lia.db.delete

**Purpose**

Deletes records from a table.

**Parameters**

* `tableName` (*string*): The table name.
* `condition` (*string*): The WHERE condition.

**Returns**

* `success` (*boolean*): True if deletion was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Delete records
local function deleteRecords(tableName, condition)
    return lia.db.delete(tableName, condition)
end

-- Use in a function
local function deletePlayer(client)
    local condition = "steamid = '" .. client:SteamID() .. "'"
    return lia.db.delete("players", condition)
end

-- Use in a function
local function deleteOldRecords(tableName, daysOld)
    local condition = "created_at < " .. (os.time() - (daysOld * 86400))
    return lia.db.delete(tableName, condition)
end
```

---

### lia.db.createTable

**Purpose**

Creates a new database table.

**Parameters**

* `tableName` (*string*): The table name.
* `schema` (*table*): The table schema.

**Returns**

* `success` (*boolean*): True if table was created successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Create table
local function createTable(tableName, schema)
    return lia.db.createTable(tableName, schema)
end

-- Use in a function
local function createPlayersTable()
    local schema = {
        {name = "id", type = "INTEGER", primary = true, auto_increment = true},
        {name = "steamid", type = "VARCHAR(20)", unique = true},
        {name = "name", type = "VARCHAR(100)"},
        {name = "level", type = "INTEGER", default = 1}
    }
    return lia.db.createTable("players", schema)
end

-- Use in a function
local function createItemsTable()
    local schema = {
        {name = "id", type = "INTEGER", primary = true, auto_increment = true},
        {name = "uniqueid", type = "VARCHAR(50)", unique = true},
        {name = "itemid", type = "VARCHAR(50)"},
        {name = "data", type = "TEXT"}
    }
    return lia.db.createTable("items", schema)
end
```

---

### lia.db.createColumn

**Purpose**

Creates a new column in a table.

**Parameters**

* `tableName` (*string*): The table name.
* `columnName` (*string*): The column name.
* `columnType` (*string*): The column type.

**Returns**

* `success` (*boolean*): True if column was created successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Create column
local function createColumn(tableName, columnName, columnType)
    return lia.db.createColumn(tableName, columnName, columnType)
end

-- Use in a function
local function addPlayerField(fieldName, fieldType)
    return lia.db.createColumn("players", fieldName, fieldType)
end

-- Use in a function
local function addItemField(fieldName, fieldType)
    return lia.db.createColumn("items", fieldName, fieldType)
end
```

---

### lia.db.removeTable

**Purpose**

Removes a table from the database.

**Parameters**

* `tableName` (*string*): The table name.

**Returns**

* `success` (*boolean*): True if table was removed successfully.

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
        lia.db.removeTable(tableName)
    end
end

-- Use in a command
lia.command.add("removetable", {
    arguments = {
        {name = "table", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local success = lia.db.removeTable(arguments[1])
        client:notify("Table " .. (success and "removed" or "removal failed"))
    end
})
```

---

### lia.db.removeColumn

**Purpose**

Removes a column from a table.

**Parameters**

* `tableName` (*string*): The table name.
* `columnName` (*string*): The column name.

**Returns**

* `success` (*boolean*): True if column was removed successfully.

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
    return lia.db.removeColumn("players", fieldName)
end

-- Use in a function
local function removeItemField(fieldName)
    return lia.db.removeColumn("items", fieldName)
end
```

---

### lia.db.GetCharacterTable

**Purpose**

Gets the character table name.

**Parameters**

*None*

**Returns**

* `tableName` (*string*): The character table name.

**Realm**

Shared.

**Example Usage**

```lua
-- Get character table name
local function getCharacterTableName()
    return lia.db.GetCharacterTable()
end

-- Use in a function
local function getCharacterData(characterId)
    local tableName = lia.db.GetCharacterTable()
    local condition = "id = " .. characterId
    return lia.db.selectOne(tableName, "*", condition)
end

-- Use in a function
local function createCharacter(characterData)
    local tableName = lia.db.GetCharacterTable()
    return lia.db.insertTable(tableName, characterData)
end
```

---

### lia.db.autoRemoveUnderscoreColumns

**Purpose**

Automatically removes columns with underscores from tables.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Auto remove underscore columns
local function removeUnderscoreColumns()
    lia.db.autoRemoveUnderscoreColumns()
    print("Underscore columns removed")
end

-- Use in a function
local function cleanupDatabase()
    lia.db.autoRemoveUnderscoreColumns()
    print("Database cleaned up")
end

-- Use in a command
lia.command.add("cleanupdb", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.db.autoRemoveUnderscoreColumns()
        client:notify("Database cleaned up")
    end
})
```