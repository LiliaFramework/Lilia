# Database Library

Comprehensive database management system with SQLite support for the Lilia framework.

---

## Overview

The database library provides comprehensive database management functionality for the Lilia framework. It handles all database operations including connection management, table creation and modification, data insertion, updates, queries, and schema management. The library supports SQLite as the primary database engine with extensible module support for other database systems. It includes advanced features such as prepared statements, transactions, bulk operations, data type conversion, and database snapshots for backup and restore operations. The library ensures data persistence across server restarts and provides robust error handling with deferred promise-based operations for asynchronous database queries. It manages core gamemode tables for players, characters, inventories, items, configuration, logs, and administrative data while supporting dynamic schema modifications.

---

### connect

**Purpose**

Establishes a connection to the database using the configured database module

**When Called**

During server startup, module initialization, or when reconnecting to database

**Parameters**

* `callback` (*function, optional*): Function to call after successful connection
* `reconnect` (*boolean, optional*): Force reconnection even if already connected

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Connect to database with callback
lia.db.connect(function()
print("Database connected successfully!")
end)
```

**Medium Complexity:**
```lua
-- Medium: Connect with error handling and reconnection
lia.db.connect(function()
lia.log.add("Database connection established")
lia.db.loadTables()
end, true)
```

**High Complexity:**
```lua
-- High: Connect with conditional logic and module validation
if lia.db.module and lia.db.modules[lia.db.module] then
lia.db.connect(function()
lia.bootstrap("Database", "Connected to " .. lia.db.module)
hook.Run("OnDatabaseConnected")
end, not lia.db.connected)
else
lia.error("Invalid database module: " .. tostring(lia.db.module))
end
```

---

### wipeTables

**Purpose**

Removes all Lilia database tables and their data from the database

**When Called**

During database reset operations, development testing, or administrative cleanup

**Parameters**

* `callback` (*function, optional*): Function to call after all tables are wiped

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Wipe all tables with confirmation
lia.db.wipeTables(function()
print("All database tables have been wiped!")
end)
```

**Medium Complexity:**
```lua
-- Medium: Wipe tables with logging and backup
lia.log.add("Starting database wipe operation")
lia.db.wipeTables(function()
lia.log.add("Database wipe completed successfully")
hook.Run("OnDatabaseWiped")
end)
```

**High Complexity:**
```lua
-- High: Wipe tables with confirmation and error handling
local function confirmWipe()
lia.db.wipeTables(function()
lia.bootstrap("Database", "All tables wiped successfully")
lia.db.loadTables() -- Reload empty tables
hook.Run("OnDatabaseReset")
end)
end
if lia.config.get("allowDatabaseWipe", false) then
confirmWipe()
else
lia.error("Database wipe not allowed by configuration")
end
```

---

### loadTables

**Purpose**

Creates all core Lilia database tables if they don't exist and initializes the database schema

**When Called**

During server startup after database connection, or when initializing a new database

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Load tables after connection
lia.db.connect(function()
lia.db.loadTables()
end)
```

**Medium Complexity:**
```lua
-- Medium: Load tables with hook integration
lia.db.connect(function()
lia.db.loadTables()
lia.log.add("Database tables loaded successfully")
end)
```

**High Complexity:**
```lua
-- High: Load tables with conditional logic and error handling
local function initializeDatabase()
lia.db.connect(function()
lia.db.loadTables()
hook.Run("OnDatabaseInitialized")
lia.bootstrap("Database", "Schema loaded and ready")
end, true)
end
if lia.db.module and lia.db.modules[lia.db.module] then
initializeDatabase()
else
lia.error("Cannot initialize database: invalid module")
end
```

---

### waitForTablesToLoad

**Purpose**

Returns a deferred promise that resolves when database tables have finished loading

**When Called**

Before performing database operations that require tables to be loaded

**Returns**

* Deferred promise object

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Wait for tables to load before proceeding
lia.db.waitForTablesToLoad():next(function()
print("Tables are ready!")
end)
```

**Medium Complexity:**
```lua
-- Medium: Wait for tables with error handling
lia.db.waitForTablesToLoad():next(function()
lia.log.add("Database tables loaded, proceeding with initialization")
hook.Run("OnTablesReady")
end):catch(function(err)
lia.error("Failed to load database tables: " .. tostring(err))
end)
```

**High Complexity:**
```lua
-- High: Wait for tables with timeout and fallback
local function initializeAfterTables()
lia.db.waitForTablesToLoad():next(function()
lia.char.loadCharacters()
lia.inventory.loadInventories()
lia.bootstrap("Database", "All systems initialized")
end):catch(function(err)
lia.error("Critical database initialization failure: " .. tostring(err))
lia.db.connect(function()
lia.db.loadTables()
initializeAfterTables()
end, true)
end)
end
initializeAfterTables()
```

---

### convertDataType

**Purpose**

Converts Lua values to SQL-compatible format with proper escaping and type handling

**When Called**

Internally by database functions when preparing data for SQL queries

**Parameters**

* `value` (*any*): The value to convert to SQL format
* `noEscape` (*boolean, optional*): Skip escaping for raw SQL values

**Returns**

* String representation of the value in SQL format

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Convert basic data types
local sqlString = lia.db.convertDataType("Hello World")
local sqlNumber = lia.db.convertDataType(42)
local sqlBool = lia.db.convertDataType(true)
```

**Medium Complexity:**
```lua
-- Medium: Convert complex data with escaping
local playerData = {
name = "John Doe",
level = 25,
isActive = true,
inventory = {weapon = "pistol", ammo = 100}
}
local sqlData = {}
for key, value in pairs(playerData) do
sqlData[key] = lia.db.convertDataType(value)
end
```

**High Complexity:**
```lua
-- High: Convert with conditional logic and error handling
local function safeConvert(value, fieldName)
if value == nil then
return "NULL"
elseif type(value) == "table" then
local success, json = pcall(util.TableToJSON, value)
if success then
return "'" .. lia.db.escape(json) .. "'"
else
lia.log.add("Failed to convert table for field: " .. fieldName)
return "NULL"
end
else
return lia.db.convertDataType(value)
end
end
```

---

### insertTable

**Purpose**

Inserts a new record into a specified database table

**When Called**

When creating new database records for players, characters, items, etc.

**Parameters**

* `value` (*table*): Key-value pairs representing the data to insert
* `callback` (*function, optional*): Function to call after successful insertion
* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'characters')

**Returns**

* Deferred promise object with results and lastID

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Insert a new character
lia.db.insertTable({
steamID = "STEAM_0:1:12345678",
name = "John Doe",
model = "models/player/kleiner.mdl"
}, function(results, lastID)
print("Character created with ID:", lastID)
end, "characters")
```

**Medium Complexity:**
```lua
-- Medium: Insert with error handling and validation
local characterData = {
steamID = player:SteamID(),
name = player:Name(),
model = player:GetModel(),
faction = "citizen",
money = "0"
}
lia.db.insertTable(characterData, function(results, lastID)
if lastID then
lia.log.add("Character created for " .. player:Name())
hook.Run("OnCharacterCreated", player, lastID)
end
end, "characters")
```

**High Complexity:**
```lua
-- High: Insert with validation, error handling, and rollback
local function createCharacterWithValidation(playerData)
local validation = lia.char.validateData(playerData)
if not validation.valid then
return deferred.new():reject("Validation failed: " .. validation.error)
end
return lia.db.insertTable(playerData, function(results, lastID)
if lastID then
lia.char.cache[lastID] = playerData
hook.Run("OnCharacterCreated", lastID, playerData)
end
end, "characters")
end
```

---

### updateTable

**Purpose**

Updates existing records in a specified database table based on conditions

**When Called**

When modifying existing database records for players, characters, items, etc.

**Parameters**

* `value` (*table*): Key-value pairs representing the data to update
* `callback` (*function, optional*): Function to call after successful update
* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'characters')
* `condition` (*table/string, optional*): WHERE clause conditions for the update

**Returns**

* Deferred promise object with results and lastID

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Update character money
lia.db.updateTable({
money = "1000"
}, function(results, lastID)
print("Character updated successfully!")
end, "characters", {id = 1})
```

**Medium Complexity:**
```lua
-- Medium: Update with complex conditions and logging
local updateData = {
lastJoinTime = os.date("%Y-%m-%d %H:%M:%S"),
money = tostring(character:getMoney())
}
lia.db.updateTable(updateData, function(results, lastID)
if results then
lia.log.add("Character " .. character:getName() .. " updated")
hook.Run("OnCharacterUpdated", character)
end
end, "characters", {id = character:getID()})
```

**High Complexity:**
```lua
-- High: Update with validation, transaction, and rollback
local function updateCharacterWithValidation(charID, updateData)
return lia.db.transaction({
"BEGIN TRANSACTION",
"UPDATE lia_characters SET " ..
table.concat(lia.util.map(updateData, function(k, v)
return k .. " = " .. lia.db.convertDataType(v)
end), ", ") ..
" WHERE id = " .. charID,
"COMMIT"
}):next(function()
lia.char.cache[charID] = lia.util.merge(lia.char.cache[charID] or {}, updateData)
hook.Run("OnCharacterUpdated", charID, updateData)
end):catch(function(err)
lia.error("Failed to update character " .. charID .. ": " .. tostring(err))
end)
end
```

---

### select

**Purpose**

Performs a SELECT query on a specified database table with optional conditions and limits

**When Called**

When retrieving data from database tables for players, characters, items, etc.

**Parameters**

* `fields` (*string/table*): Field names to select (string or table of strings)
* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'characters')
* `condition` (*table/string, optional*): WHERE clause conditions for the query
* `limit` (*number, optional*): Maximum number of records to return

**Returns**

* Deferred promise object with results array

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Select all characters
lia.db.select("*", "characters"):next(function(results)
print("Found " .. #results .. " characters")
end)
```

**Medium Complexity:**
```lua
-- Medium: Select with conditions and specific fields
lia.db.select({"name", "money", "faction"}, "characters", {
steamID = "STEAM_0:1:12345678"
}, 10):next(function(results)
for _, char in ipairs(results) do
print(char.name .. " has $" .. char.money)
end
end)
```

**High Complexity:**
```lua
-- High: Select with complex conditions, pagination, and error handling
local function getCharactersByFaction(faction, page, pageSize)
local offset = (page - 1) * pageSize
return lia.db.select("*", "characters", {
faction = faction,
lastJoinTime = {operator = ">", value = os.date("%Y-%m-%d", os.time() - 86400)}
}, pageSize):next(function(results)
local characters = {}
for _, char in ipairs(results) do
table.insert(characters, lia.char.new(char))
end
return characters
end):catch(function(err)
lia.error("Failed to load characters: " .. tostring(err))
return {}
end)
end
```

---

### selectWithCondition

**Purpose**

Performs a SELECT query with advanced condition handling and optional ordering

**When Called**

When retrieving data with complex WHERE clauses and ORDER BY requirements

**Parameters**

* `fields` (*string/table*): Field names to select (string or table of strings)
* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'characters')
* `conditions` (*table/string, optional*): WHERE clause conditions with operator support
* `limit` (*number, optional*): Maximum number of records to return
* `orderBy` (*string, optional*): ORDER BY clause for sorting results

**Returns**

* Deferred promise object with results array

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Select with basic condition
lia.db.selectWithCondition("*", "characters", {
faction = "citizen"
}):next(function(results)
print("Found " .. #results .. " citizens")
end)
```

**Medium Complexity:**
```lua
-- Medium: Select with operators and ordering
lia.db.selectWithCondition({"name", "money"}, "characters", {
money = {operator = ">", value = "1000"},
faction = "citizen"
}, 5, "money DESC"):next(function(results)
for _, char in ipairs(results) do
print(char.name .. " has $" .. char.money)
end
end)
```

**High Complexity:**
```lua
-- High: Select with complex conditions, pagination, and error handling
local function searchCharacters(searchTerm, faction, minMoney, maxResults)
local conditions = {}
if searchTerm then
conditions.name = {operator = "LIKE", value = "%" .. searchTerm .. "%"}
end
if faction then
conditions.faction = faction
end
if minMoney then
conditions.money = {operator = ">=", value = tostring(minMoney)}
end
return lia.db.selectWithCondition("*", "characters", conditions,
maxResults, "lastJoinTime DESC"):next(function(results)
local characters = {}
for _, char in ipairs(results) do
table.insert(characters, lia.char.new(char))
end
return characters
end):catch(function(err)
lia.error("Character search failed: " .. tostring(err))
return {}
end)
end
```

---

### count

**Purpose**

Counts the number of records in a database table matching specified conditions

**When Called**

When checking record counts for statistics, validation, or pagination

**Parameters**

* `dbTable` (*string*): Table name without 'lia_' prefix
* `condition` (*table/string, optional*): WHERE clause conditions for counting

**Returns**

* Deferred promise object resolving to the count number

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Count all characters
lia.db.count("characters"):next(function(count)
print("Total characters: " .. count)
end)
```

**Medium Complexity:**
```lua
-- Medium: Count with conditions
lia.db.count("characters", {
faction = "citizen",
money = {operator = ">", value = "1000"}
}):next(function(count)
print("Rich citizens: " .. count)
end)
```

**High Complexity:**
```lua
-- High: Count with validation and error handling
local function getPlayerStats(steamID)
return lia.db.count("characters", {steamID = steamID}):next(function(charCount)
return lia.db.count("players", {steamID = steamID}):next(function(playerCount)
return {
characters = charCount,
playerRecords = playerCount,
isNewPlayer = playerCount == 0
}
end)
end):catch(function(err)
lia.error("Failed to get player stats: " .. tostring(err))
return {characters = 0, playerRecords = 0, isNewPlayer = true}
end)
end
```

---

### addDatabaseFields

**Purpose**

Dynamically adds new columns to the lia_characters table based on character variables

**When Called**

During database initialization to ensure character table has all required fields

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add fields after table creation
lia.db.loadTables() -- This automatically calls addDatabaseFields()
```

**Medium Complexity:**
```lua
-- Medium: Add fields with logging
lia.db.addDatabaseFields()
lia.log.add("Database fields updated for character variables")
```

**High Complexity:**
```lua
-- High: Add fields with validation and error handling
local function ensureCharacterFields()
if not istable(lia.char.vars) then
lia.log.add("Character variables not defined, skipping field addition")
return
end
lia.db.addDatabaseFields()
lia.log.add("Character database fields synchronized")
hook.Run("OnCharacterFieldsUpdated")
end
ensureCharacterFields()
```

---

### exists

**Purpose**

Checks if any records exist in a database table matching specified conditions

**When Called**

When validating data existence before operations or for conditional logic

**Parameters**

* `dbTable` (*string*): Table name without 'lia_' prefix
* `condition` (*table/string, optional*): WHERE clause conditions for checking existence

**Returns**

* Deferred promise object resolving to boolean (true if records exist)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if player exists
lia.db.exists("players", {steamID = "STEAM_0:1:12345678"}):next(function(exists)
if exists then
print("Player found in database")
else
print("New player")
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Check with complex conditions
lia.db.exists("characters", {
steamID = player:SteamID(),
faction = "citizen",
money = {operator = ">", value = "1000"}
}):next(function(exists)
if exists then
lia.log.add("Player has wealthy citizen character")
end
end)
```

**High Complexity:**
```lua
-- High: Check with validation and error handling
local function validatePlayerData(steamID)
return lia.db.exists("players", {steamID = steamID}):next(function(playerExists)
if not playerExists then
return lia.db.insertTable({
steamID = steamID,
steamName = "Unknown",
firstJoin = os.date("%Y-%m-%d %H:%M:%S"),
userGroup = "user"
}, nil, "players")
end
return playerExists
end):catch(function(err)
lia.error("Failed to validate player data: " .. tostring(err))
return false
end)
end
```

---

### selectOne

**Purpose**

Retrieves a single record from a database table matching specified conditions

**When Called**

When fetching unique records like player data, character info, or single items

**Parameters**

* `fields` (*string/table*): Field names to select (string or table of strings)
* `dbTable` (*string*): Table name without 'lia_' prefix
* `condition` (*table/string, optional*): WHERE clause conditions for the query

**Returns**

* Deferred promise object resolving to the first matching record or nil

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get character by ID
lia.db.selectOne("*", "characters", {id = 1}):next(function(char)
if char then
print("Character name: " .. char.name)
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Get player data with specific fields
lia.db.selectOne({"steamName", "userGroup", "lastJoin"}, "players", {
steamID = player:SteamID()
}):next(function(playerData)
if playerData then
player:SetUserGroup(playerData.userGroup)
lia.log.add("Loaded player: " .. playerData.steamName)
end
end)
```

**High Complexity:**
```lua
-- High: Get with validation and error handling
local function loadCharacter(charID)
return lia.db.selectOne("*", "characters", {id = charID}):next(function(charData)
if not charData then
return deferred.new():reject("Character not found")
end
local character = lia.char.new(charData)
lia.char.cache[charID] = character
hook.Run("OnCharacterLoaded", character)
return character
end):catch(function(err)
lia.error("Failed to load character " .. charID .. ": " .. tostring(err))
return nil
end)
end
```

---

### bulkInsert

**Purpose**

Inserts multiple records into a database table in a single operation for better performance

**When Called**

When inserting large amounts of data like inventory items, logs, or batch operations

**Parameters**

* `dbTable` (*string*): Table name without 'lia_' prefix
* `rows` (*table*): Array of tables containing the data to insert

**Returns**

* Deferred promise object resolving when all records are inserted

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Insert multiple items
local items = {
{uniqueID = "pistol", quantity = 1, x = 1, y = 1},
{uniqueID = "ammo", quantity = 50, x = 2, y = 1}
}
lia.db.bulkInsert("items", items):next(function()
print("Items inserted successfully")
end)
```

**Medium Complexity:**
```lua
-- Medium: Insert with validation and error handling
local function insertInventoryItems(invID, items)
local rows = {}
for _, item in ipairs(items) do
table.insert(rows, {
invID = invID,
uniqueID = item.uniqueID,
data = util.TableToJSON(item.data or {}),
quantity = item.quantity or 1,
x = item.x or 1,
y = item.y or 1
})
end
return lia.db.bulkInsert("items", rows):next(function()
lia.log.add("Inserted " .. #rows .. " items into inventory " .. invID)
end):catch(function(err)
lia.error("Failed to insert items: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Insert with batching, validation, and progress tracking
local function bulkInsertWithBatching(dbTable, data, batchSize)
batchSize = batchSize or 100
local batches = {}
for i = 1, #data, batchSize do
local batch = {}
for j = i, math.min(i + batchSize - 1, #data) do
table.insert(batch, data[j])
end
table.insert(batches, batch)
end
local currentBatch = 1
local function insertNextBatch()
if currentBatch > #batches then
return deferred.new():resolve()
end
return lia.db.bulkInsert(dbTable, batches[currentBatch]):next(function()
lia.log.add("Batch " .. currentBatch .. "/" .. #batches .. " completed")
currentBatch = currentBatch + 1
return insertNextBatch()
end)
end
return insertNextBatch()
end
```

---

### bulkUpsert

**Purpose**

Performs bulk INSERT OR REPLACE operations for updating existing records or inserting new ones

**When Called**

When synchronizing data that may already exist, like configuration updates or data imports

**Parameters**

* `dbTable` (*string*): Table name without 'lia_' prefix
* `rows` (*table*): Array of tables containing the data to upsert

**Returns**

* Deferred promise object resolving when all records are upserted

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Upsert configuration data
local configs = {
{schema = "default", key = "maxPlayers", value = "32"},
{schema = "default", key = "serverName", value = "My Server"}
}
lia.db.bulkUpsert("config", configs):next(function()
print("Configuration updated")
end)
```

**Medium Complexity:**
```lua
-- Medium: Upsert with validation and error handling
local function syncPlayerData(players)
local rows = {}
for _, player in ipairs(players) do
table.insert(rows, {
steamID = player:SteamID(),
steamName = player:Name(),
lastJoin = os.date("%Y-%m-%d %H:%M:%S"),
lastIP = player:IPAddress(),
userGroup = player:GetUserGroup()
})
end
return lia.db.bulkUpsert("players", rows):next(function()
lia.log.add("Synchronized " .. #rows .. " player records")
end):catch(function(err)
lia.error("Failed to sync player data: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Upsert with conflict resolution and progress tracking
local function bulkSyncWithConflictResolution(dbTable, data, conflictFields)
local batches = {}
local batchSize = 50
for i = 1, #data, batchSize do
local batch = {}
for j = i, math.min(i + batchSize - 1, #data) do
local record = data[j]
-- Add conflict resolution metadata
record._syncTimestamp = os.time()
record._conflictFields = conflictFields
table.insert(batch, record)
end
table.insert(batches, batch)
end
local completed = 0
local function processNextBatch()
if completed >= #batches then
return deferred.new():resolve()
end
return lia.db.bulkUpsert(dbTable, batches[completed + 1]):next(function()
completed = completed + 1
lia.log.add("Batch " .. completed .. "/" .. #batches .. " synced")
return processNextBatch()
end)
end
return processNextBatch()
end
```

---

### insertOrIgnore

**Purpose**

Inserts a record into a database table, ignoring the operation if it would cause a constraint violation

**When Called**

When inserting data that may already exist, like unique configurations or duplicate-safe operations

**Parameters**

* `value` (*table*): Key-value pairs representing the data to insert
* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'characters')

**Returns**

* Deferred promise object with results and lastID

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Insert configuration without duplicates
lia.db.insertOrIgnore({
schema = "default",
key = "serverName",
value = "My Server"
}, "config"):next(function(results, lastID)
print("Configuration inserted or ignored")
end)
```

**Medium Complexity:**
```lua
-- Medium: Insert with validation and logging
local function ensureDefaultConfig(configs)
for _, config in ipairs(configs) do
lia.db.insertOrIgnore({
schema = config.schema,
key = config.key,
value = config.value
}, "config"):next(function(results, lastID)
if lastID then
lia.log.add("Added new config: " .. config.key)
end
end)
end
end
```

**High Complexity:**
```lua
-- High: Insert with conflict detection and fallback
local function safeInsertWithFallback(data, dbTable, fallbackData)
return lia.db.insertOrIgnore(data, dbTable):next(function(results, lastID)
if lastID then
-- Successfully inserted new record
return {success = true, id = lastID, action = "inserted"}
else
-- Record already exists, try fallback operation
return lia.db.updateTable(fallbackData, nil, dbTable, {
[data.primaryKey or "id"] = data.id
}):next(function()
return {success = true, action = "updated"}
end)
end
end):catch(function(err)
lia.error("Insert or ignore failed: " .. tostring(err))
return {success = false, error = err}
end)
end
```

---

### tableExists

**Purpose**

Checks if a database table exists in the current database

**When Called**

When validating table existence before operations or during schema validation

**Parameters**

* `tbl` (*string*): Table name to check for existence

**Returns**

* Deferred promise object resolving to boolean (true if table exists)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if table exists
lia.db.tableExists("lia_characters"):next(function(exists)
if exists then
print("Characters table exists")
else
print("Characters table missing")
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Check with conditional logic
lia.db.tableExists("lia_custom_table"):next(function(exists)
if not exists then
lia.log.add("Custom table missing, creating...")
lia.db.createTable("custom_table", "id", {
{name = "id", type = "INTEGER", not_null = true},
{name = "data", type = "TEXT"}
})
end
end)
```

**High Complexity:**
```lua
-- High: Check with validation and error handling
local function validateDatabaseSchema()
local requiredTables = {"characters", "players", "items", "inventories"}
local missingTables = {}
local function checkNextTable(index)
if index > #requiredTables then
if #missingTables > 0 then
lia.error("Missing tables: " .. table.concat(missingTables, ", "))
return lia.db.loadTables()
else
lia.log.add("All required tables exist")
return deferred.new():resolve()
end
end
local tableName = "lia_" .. requiredTables[index]
return lia.db.tableExists(tableName):next(function(exists)
if not exists then
table.insert(missingTables, tableName)
end
return checkNextTable(index + 1)
end)
end
return checkNextTable(1)
end
```

---

### fieldExists

**Purpose**

Checks if a specific field/column exists in a database table

**When Called**

When validating column existence before operations or during schema migrations

**Parameters**

* `tbl` (*string*): Table name to check
* `field` (*string*): Field/column name to check for existence

**Returns**

* Deferred promise object resolving to boolean (true if field exists)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if field exists
lia.db.fieldExists("lia_characters", "money"):next(function(exists)
if exists then
print("Money field exists")
else
print("Money field missing")
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Check with conditional field creation
lia.db.fieldExists("lia_characters", "newField"):next(function(exists)
if not exists then
lia.log.add("Adding new field to characters table")
lia.db.createColumn("characters", "newField", "VARCHAR(255)", "default_value")
end
end)
```

**High Complexity:**
```lua
-- High: Check with validation and error handling
local function validateCharacterFields()
local requiredFields = {"name", "steamID", "money", "faction", "model"}
local missingFields = {}
local function checkNextField(index)
if index > #requiredFields then
if #missingFields > 0 then
lia.error("Missing character fields: " .. table.concat(missingFields, ", "))
return lia.db.addDatabaseFields()
else
lia.log.add("All required character fields exist")
return deferred.new():resolve()
end
end
return lia.db.fieldExists("lia_characters", requiredFields[index]):next(function(exists)
if not exists then
table.insert(missingFields, requiredFields[index])
end
return checkNextField(index + 1)
end)
end
return checkNextField(1)
end
```

---

### getTables

**Purpose**

Retrieves a list of all Lilia database tables in the current database

**When Called**

When auditing database structure, generating reports, or managing tables

**Returns**

* Deferred promise object resolving to array of table names

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get all Lilia tables
lia.db.getTables():next(function(tables)
print("Found " .. #tables .. " Lilia tables")
for _, tableName in ipairs(tables) do
print("- " .. tableName)
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Get tables with analysis
lia.db.getTables():next(function(tables)
local coreTables = {"lia_characters", "lia_players", "lia_items"}
local missingTables = {}
for _, coreTable in ipairs(coreTables) do
if not table.HasValue(tables, coreTable) then
table.insert(missingTables, coreTable)
end
end
if #missingTables > 0 then
lia.log.add("Missing core tables: " .. table.concat(missingTables, ", "))
else
lia.log.add("All core tables present")
end
end)
```

**High Complexity:**
```lua
-- High: Get tables with validation and management
local function auditDatabaseStructure()
return lia.db.getTables():next(function(tables)
local tableStats = {}
local function analyzeNextTable(index)
if index > #tables then
lia.log.add("Database audit complete:")
for tableName, stats in pairs(tableStats) do
lia.log.add(tableName .. ": " .. stats.count .. " records")
end
return tableStats
end
local tableName = tables[index]
return lia.db.count(tableName:sub(5)):next(function(count)
tableStats[tableName] = {count = count}
return analyzeNextTable(index + 1)
end)
end
return analyzeNextTable(1)
end):catch(function(err)
lia.error("Database audit failed: " .. tostring(err))
return {}
end)
end
```

---

### transaction

**Purpose**

Executes multiple database queries as a single atomic transaction with rollback on failure

**When Called**

When performing complex operations that must succeed or fail together

**Parameters**

* `queries` (*table*): Array of SQL query strings to execute in sequence

**Returns**

* Deferred promise object resolving when all queries succeed or rejecting on failure

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Transfer money between characters
lia.db.transaction({
"UPDATE lia_characters SET money = money - 100 WHERE id = 1",
"UPDATE lia_characters SET money = money + 100 WHERE id = 2"
}):next(function()
print("Money transfer completed")
end):catch(function(err)
print("Transfer failed: " .. tostring(err))
end)
```

**Medium Complexity:**
```lua
-- Medium: Create character with inventory
local function createCharacterWithInventory(charData)
local queries = {
"INSERT INTO lia_characters (steamID, name, faction) VALUES ('" ..
charData.steamID .. "', '" .. charData.name .. "', '" .. charData.faction .. "')",
"INSERT INTO lia_inventories (charID, invType) VALUES (last_insert_rowid(), 'pocket')"
}
return lia.db.transaction(queries):next(function()
lia.log.add("Character and inventory created successfully")
hook.Run("OnCharacterCreated", charData)
end):catch(function(err)
lia.error("Failed to create character: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Complex transaction with validation and rollback
local function transferItemsWithValidation(fromChar, toChar, items)
local queries = {}
local validationQueries = {}
-- Build validation queries
for _, item in ipairs(items) do
table.insert(validationQueries,
"SELECT COUNT(*) FROM lia_items WHERE invID = " .. fromChar.invID ..
" AND uniqueID = '" .. item.uniqueID .. "' AND quantity >= " .. item.quantity)
end
-- Build transfer queries
for _, item in ipairs(items) do
table.insert(queries,
"UPDATE lia_items SET quantity = quantity - " .. item.quantity ..
" WHERE invID = " .. fromChar.invID .. " AND uniqueID = '" .. item.uniqueID .. "'")
table.insert(queries,
"INSERT OR REPLACE INTO lia_items (invID, uniqueID, quantity) VALUES (" ..
toChar.invID .. ", '" .. item.uniqueID .. "', " .. item.quantity .. ")")
end
return lia.db.transaction(queries):next(function()
lia.log.add("Items transferred successfully")
hook.Run("OnItemsTransferred", fromChar, toChar, items)
end):catch(function(err)
lia.error("Item transfer failed: " .. tostring(err))
hook.Run("OnTransferFailed", fromChar, toChar, items, err)
end)
end
```

---

### escapeIdentifier

**Purpose**

Escapes database identifiers (table names, column names) to prevent SQL injection

**When Called**

Internally by database functions when building SQL queries with dynamic identifiers

**Parameters**

* `id` (*string*): Identifier to escape (table name, column name, etc.)

**Returns**

* Escaped identifier string wrapped in backticks

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Escape a column name
local escapedColumn = lia.db.escapeIdentifier("user_name")
-- Returns: `user_name`
```

**Medium Complexity:**
```lua
-- Medium: Escape multiple identifiers
local function buildSelectQuery(tableName, columns)
local escapedTable = lia.db.escapeIdentifier(tableName)
local escapedColumns = {}
for _, column in ipairs(columns) do
table.insert(escapedColumns, lia.db.escapeIdentifier(column))
end
return "SELECT " .. table.concat(escapedColumns, ", ") .. " FROM " .. escapedTable
end
```

**High Complexity:**
```lua
-- High: Escape with validation and error handling
local function safeEscapeIdentifiers(identifiers)
local escaped = {}
for _, id in ipairs(identifiers) do
if type(id) == "string" and id:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
table.insert(escaped, lia.db.escapeIdentifier(id))
else
lia.log.add("Invalid identifier: " .. tostring(id))
return nil
end
end
return escaped
end
```

---

### upsert

**Purpose**

Inserts a new record or updates an existing one based on primary key conflicts

**When Called**

When synchronizing data that may already exist, like configuration updates or data imports

**Parameters**

* `value` (*table*): Key-value pairs representing the data to upsert
* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'characters')

**Returns**

* Deferred promise object with results and lastID

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Upsert configuration
lia.db.upsert({
schema = "default",
key = "serverName",
value = "My Server"
}, "config"):next(function(results, lastID)
print("Configuration upserted")
end)
```

**Medium Complexity:**
```lua
-- Medium: Upsert with validation and logging
local function syncPlayerData(player)
local playerData = {
steamID = player:SteamID(),
steamName = player:Name(),
lastJoin = os.date("%Y-%m-%d %H:%M:%S"),
userGroup = player:GetUserGroup()
}
return lia.db.upsert(playerData, "players"):next(function(results, lastID)
lia.log.add("Player data synchronized: " .. player:Name())
hook.Run("OnPlayerDataSynced", player, lastID)
end):catch(function(err)
lia.error("Failed to sync player data: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Upsert with conflict resolution and validation
local function upsertWithValidation(data, dbTable, validationRules)
local validation = validateData(data, validationRules)
if not validation.valid then
return deferred.new():reject("Validation failed: " .. validation.error)
end
return lia.db.upsert(data, dbTable):next(function(results, lastID)
local action = lastID and "inserted" or "updated"
lia.log.add("Record " .. action .. " in " .. dbTable)
-- Update cache if applicable
if lia.char.cache and dbTable == "characters" then
lia.char.cache[data.id or lastID] = data
end
hook.Run("OnRecordUpserted", dbTable, data, action)
return {success = true, action = action, id = lastID}
end):catch(function(err)
lia.error("Upsert failed: " .. tostring(err))
return {success = false, error = err}
end)
end
```

---

### delete

**Purpose**

Deletes records from a database table based on specified conditions

**When Called**

When removing data like deleted characters, expired items, or cleanup operations

**Parameters**

* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'character')
* `condition` (*table/string, optional*): WHERE clause conditions for the deletion

**Returns**

* Deferred promise object with results and lastID

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Delete character by ID
lia.db.delete("characters", {id = 1}):next(function(results, lastID)
print("Character deleted")
end)
```

**Medium Complexity:**
```lua
-- Medium: Delete with validation and logging
local function deleteCharacter(charID)
return lia.db.delete("characters", {id = charID}):next(function(results, lastID)
lia.log.add("Character " .. charID .. " deleted")
hook.Run("OnCharacterDeleted", charID)
-- Clean up related data
lia.db.delete("items", {invID = charID})
lia.db.delete("inventories", {charID = charID})
end):catch(function(err)
lia.error("Failed to delete character: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Delete with cascade and transaction safety
local function deleteCharacterWithCascade(charID)
return lia.db.transaction({
"DELETE FROM lia_items WHERE invID IN (SELECT invID FROM lia_inventories WHERE charID = " .. charID .. ")",
"DELETE FROM lia_inventories WHERE charID = " .. charID,
"DELETE FROM lia_chardata WHERE charID = " .. charID,
"DELETE FROM lia_characters WHERE id = " .. charID
}):next(function()
lia.log.add("Character " .. charID .. " and all related data deleted")
-- Update cache
if lia.char.cache then
lia.char.cache[charID] = nil
end
hook.Run("OnCharacterDeleted", charID)
return {success = true, charID = charID}
end):catch(function(err)
lia.error("Failed to delete character with cascade: " .. tostring(err))
return {success = false, error = err}
end)
end
```

---

### createTable

**Purpose**

Creates a new database table with specified schema and primary key

**When Called**

When setting up custom tables for modules or extending the database schema

**Parameters**

* `dbName` (*string*): Table name without 'lia_' prefix
* `primaryKey` (*string, optional*): Primary key column name
* `schema` (*table*): Array of column definitions with name, type, not_null, and default properties

**Returns**

* Deferred promise object resolving to true on success

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Create a basic table
lia.db.createTable("custom_data", "id", {
{name = "id", type = "INTEGER", not_null = true},
{name = "data", type = "TEXT"}
}):next(function(success)
print("Table created successfully")
end)
```

**Medium Complexity:**
```lua
-- Medium: Create table with validation
local function createPlayerStatsTable()
local schema = {
{name = "id", type = "INTEGER", not_null = true},
{name = "steamID", type = "VARCHAR(255)", not_null = true},
{name = "kills", type = "INTEGER", default = 0},
{name = "deaths", type = "INTEGER", default = 0},
{name = "score", type = "INTEGER", default = 0},
{name = "lastUpdated", type = "DATETIME", default = "CURRENT_TIMESTAMP"}
}
return lia.db.createTable("player_stats", "id", schema):next(function(success)
if success then
lia.log.add("Player stats table created")
hook.Run("OnPlayerStatsTableCreated")
end
end):catch(function(err)
lia.error("Failed to create player stats table: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Create table with validation and error handling
local function createModuleTable(moduleName, tableConfig)
local function validateSchema(schema)
for _, column in ipairs(schema) do
if not column.name or not column.type then
return false, "Invalid column definition"
end
end
return true
end
local valid, error = validateSchema(tableConfig.schema)
if not valid then
return deferred.new():reject("Schema validation failed: " .. error)
end
return lia.db.tableExists("lia_" .. moduleName .. "_" .. tableConfig.name):next(function(exists)
if exists then
lia.log.add("Table already exists: " .. moduleName .. "_" .. tableConfig.name)
return true
end
return lia.db.createTable(moduleName .. "_" .. tableConfig.name,
tableConfig.primaryKey, tableConfig.schema):next(function(success)
if success then
lia.log.add("Module table created: " .. moduleName .. "_" .. tableConfig.name)
hook.Run("OnModuleTableCreated", moduleName, tableConfig.name)
end
return success
end)
end)
end
```

---

### createColumn

**Purpose**

Adds a new column to an existing database table

**When Called**

When extending table schemas, adding new fields, or during database migrations

**Parameters**

* `tableName` (*string*): Table name without 'lia_' prefix
* `columnName` (*string*): Name of the new column to add
* `columnType` (*string*): SQL data type for the column
* `defaultValue` (*any, optional*): Default value for the column

**Returns**

* Deferred promise object resolving to true on success, false if column already exists

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add a new column
lia.db.createColumn("characters", "level", "INTEGER", 1):next(function(success)
if success then
print("Level column added")
else
print("Column already exists")
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Add column with validation
local function addPlayerStatsColumn()
return lia.db.createColumn("players", "totalPlayTime", "FLOAT", 0):next(function(success)
if success then
lia.log.add("Added totalPlayTime column to players table")
hook.Run("OnColumnAdded", "players", "totalPlayTime")
else
lia.log.add("totalPlayTime column already exists")
end
end):catch(function(err)
lia.error("Failed to add column: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Add column with validation and error handling
local function migrateCharacterTable()
local newColumns = {
{name = "level", type = "INTEGER", default = 1},
{name = "experience", type = "INTEGER", default = 0},
{name = "lastLevelUp", type = "DATETIME", default = "CURRENT_TIMESTAMP"}
}
local function addNextColumn(index)
if index > #newColumns then
lia.log.add("Character table migration completed")
return deferred.new():resolve()
end
local column = newColumns[index]
return lia.db.createColumn("characters", column.name, column.type, column.default):next(function(success)
if success then
lia.log.add("Added column: " .. column.name)
end
return addNextColumn(index + 1)
end):catch(function(err)
lia.error("Failed to add column " .. column.name .. ": " .. tostring(err))
return addNextColumn(index + 1)
end)
end
return addNextColumn(1)
end
```

---

### removeTable

**Purpose**

Removes a database table and all its data from the database

**When Called**

When cleaning up unused tables, removing modules, or during database maintenance

**Parameters**

* `tableName` (*string*): Table name without 'lia_' prefix

**Returns**

* Deferred promise object resolving to true on success, false if table doesn't exist

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Remove a table
lia.db.removeTable("old_data"):next(function(success)
if success then
print("Table removed")
else
print("Table doesn't exist")
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Remove table with validation
local function cleanupOldModule(moduleName)
return lia.db.removeTable(moduleName .. "_data"):next(function(success)
if success then
lia.log.add("Removed table for module: " .. moduleName)
hook.Run("OnModuleTableRemoved", moduleName)
else
lia.log.add("Table for module " .. moduleName .. " doesn't exist")
end
end):catch(function(err)
lia.error("Failed to remove table: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Remove table with backup and validation
local function removeTableWithBackup(tableName)
return lia.db.tableExists("lia_" .. tableName):next(function(exists)
if not exists then
lia.log.add("Table " .. tableName .. " doesn't exist")
return false
end
-- Create backup before removal
return lia.db.createSnapshot(tableName):next(function(snapshot)
lia.log.add("Created backup: " .. snapshot.file)
return lia.db.removeTable(tableName):next(function(success)
if success then
lia.log.add("Table " .. tableName .. " removed successfully")
hook.Run("OnTableRemoved", tableName, snapshot)
end
return success
end)
end):catch(function(err)
lia.error("Failed to backup table " .. tableName .. ": " .. tostring(err))
return false
end)
end)
end
```

---

### removeColumn

**Purpose**

Removes a column from an existing database table using table recreation

**When Called**

When removing unused columns, cleaning up schemas, or during database migrations

**Parameters**

* `tableName` (*string*): Table name without 'lia_' prefix
* `columnName` (*string*): Name of the column to remove

**Returns**

* Deferred promise object resolving to true on success, false if column doesn't exist

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Remove a column
lia.db.removeColumn("characters", "old_field"):next(function(success)
if success then
print("Column removed")
else
print("Column doesn't exist")
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Remove column with validation
local function cleanupOldColumn(tableName, columnName)
return lia.db.removeColumn(tableName, columnName):next(function(success)
if success then
lia.log.add("Removed column " .. columnName .. " from " .. tableName)
hook.Run("OnColumnRemoved", tableName, columnName)
else
lia.log.add("Column " .. columnName .. " doesn't exist in " .. tableName)
end
end):catch(function(err)
lia.error("Failed to remove column: " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Remove column with backup and validation
local function removeColumnWithBackup(tableName, columnName)
return lia.db.tableExists("lia_" .. tableName):next(function(tableExists)
if not tableExists then
lia.error("Table " .. tableName .. " doesn't exist")
return false
end
return lia.db.fieldExists("lia_" .. tableName, columnName):next(function(columnExists)
if not columnExists then
lia.log.add("Column " .. columnName .. " doesn't exist")
return false
end
-- Create backup before removal
return lia.db.createSnapshot(tableName):next(function(snapshot)
lia.log.add("Created backup before column removal: " .. snapshot.file)
return lia.db.removeColumn(tableName, columnName):next(function(success)
if success then
lia.log.add("Column " .. columnName .. " removed from " .. tableName)
hook.Run("OnColumnRemoved", tableName, columnName, snapshot)
end
return success
end)
end):catch(function(err)
lia.error("Failed to backup table before column removal: " .. tostring(err))
return false
end)
end)
end)
end
```

---

### getCharacterTable

**Purpose**

Retrieves the column information for the lia_characters table

**When Called**

When analyzing character table structure, generating reports, or during schema validation

**Parameters**

* `callback` (*function*): Function to call with the column information array

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get character table columns
lia.db.getCharacterTable(function(columns)
print("Character table has " .. #columns .. " columns")
for _, column in ipairs(columns) do
print("- " .. column)
end
end)
```

**Medium Complexity:**
```lua
-- Medium: Get columns with analysis
local function analyzeCharacterTable()
lia.db.getCharacterTable(function(columns)
local requiredColumns = {"id", "steamID", "name", "model", "faction", "money"}
local missingColumns = {}
for _, required in ipairs(requiredColumns) do
if not table.HasValue(columns, required) then
table.insert(missingColumns, required)
end
end
if #missingColumns > 0 then
lia.log.add("Missing character columns: " .. table.concat(missingColumns, ", "))
else
lia.log.add("All required character columns present")
end
end)
end
```

**High Complexity:**
```lua
-- High: Get columns with validation and error handling
local function validateCharacterSchema()
return lia.db.waitForTablesToLoad():next(function()
lia.db.getCharacterTable(function(columns)
if not columns or #columns == 0 then
lia.error("Failed to get character table columns")
return
end
local schemaValidation = {
required = {"id", "steamID", "name", "model", "faction", "money"},
optional = {"desc", "attribs", "schema", "createTime", "lastJoinTime", "recognition", "fakenames"}
}
local validationResults = {
valid = true,
missing = {},
extra = {}
}
-- Check for missing required columns
for _, required in ipairs(schemaValidation.required) do
if not table.HasValue(columns, required) then
table.insert(validationResults.missing, required)
validationResults.valid = false
end
end
-- Check for extra columns
for _, column in ipairs(columns) do
if not table.HasValue(schemaValidation.required, column) and
not table.HasValue(schemaValidation.optional, column) then
table.insert(validationResults.extra, column)
end
end
if validationResults.valid then
lia.log.add("Character table schema validation passed")
else
lia.log.add("Character table schema issues found")
if #validationResults.missing > 0 then
lia.log.add("Missing columns: " .. table.concat(validationResults.missing, ", "))
end
if #validationResults.extra > 0 then
lia.log.add("Extra columns: " .. table.concat(validationResults.extra, ", "))
end
end
hook.Run("OnCharacterSchemaValidated", validationResults)
end)
end):catch(function(err)
lia.error("Character schema validation failed: " .. tostring(err))
end)
end
```

---

### createSnapshot

**Purpose**

Creates a backup snapshot of a database table and saves it to a JSON file

**When Called**

When backing up data before major operations, creating restore points, or archiving data

**Parameters**

* `tableName` (*string*): Table name without 'lia_' prefix

**Returns**

* Deferred promise object resolving to snapshot information (file, path, records)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Create a snapshot
lia.db.createSnapshot("characters"):next(function(snapshot)
print("Snapshot created: " .. snapshot.file)
print("Records backed up: " .. snapshot.records)
end)
```

**Medium Complexity:**
```lua
-- Medium: Create snapshot with validation
local function backupTable(tableName)
return lia.db.createSnapshot(tableName):next(function(snapshot)
lia.log.add("Backup created: " .. snapshot.file .. " (" .. snapshot.records .. " records)")
hook.Run("OnTableBackedUp", tableName, snapshot)
return snapshot
end):catch(function(err)
lia.error("Failed to backup table " .. tableName .. ": " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Create snapshot with validation and error handling
local function createBackupWithValidation(tableName)
return lia.db.tableExists("lia_" .. tableName):next(function(exists)
if not exists then
return deferred.new():reject("Table " .. tableName .. " doesn't exist")
end
return lia.db.createSnapshot(tableName):next(function(snapshot)
-- Validate snapshot data
if snapshot.records == 0 then
lia.log.add("Snapshot created but table is empty")
end
-- Create backup metadata
local metadata = {
table = tableName,
timestamp = snapshot.timestamp,
records = snapshot.records,
file = snapshot.file,
path = snapshot.path,
server = GetHostName(),
version = lia.version or "unknown"
}
-- Save metadata
local metadataFile = "lilia/snapshots/" .. snapshot.file .. ".meta"
file.Write(metadataFile, util.TableToJSON(metadata, true))
lia.log.add("Backup completed: " .. snapshot.file .. " (" .. snapshot.records .. " records)")
hook.Run("OnBackupCreated", metadata)
return metadata
end):catch(function(err)
lia.error("Backup failed for " .. tableName .. ": " .. tostring(err))
return {success = false, error = err}
end)
end)
end
```

---

### loadSnapshot

**Purpose**

Restores a database table from a previously created snapshot file

**When Called**

When restoring data from backups, recovering from errors, or migrating data

**Parameters**

* `fileName` (*string*): Name of the snapshot file to load

**Returns**

* Deferred promise object resolving to restore information (table, records, timestamp)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Load a snapshot
lia.db.loadSnapshot("snapshot_characters_1234567890.json"):next(function(result)
print("Restored " .. result.records .. " records to " .. result.table)
end)
```

**Medium Complexity:**
```lua
-- Medium: Load snapshot with validation
local function restoreTable(fileName)
return lia.db.loadSnapshot(fileName):next(function(result)
lia.log.add("Restored " .. result.records .. " records to " .. result.table)
hook.Run("OnTableRestored", result.table, result.records)
return result
end):catch(function(err)
lia.error("Failed to restore from " .. fileName .. ": " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Load snapshot with validation and error handling
local function restoreWithValidation(fileName)
return lia.db.loadSnapshot(fileName):next(function(result)
-- Validate restore results
if result.records == 0 then
lia.log.add("Restore completed but no records were loaded")
end
-- Verify table exists and has data
return lia.db.count(result.table):next(function(count)
if count ~= result.records then
lia.log.add("Record count mismatch: expected " .. result.records .. ", got " .. count)
end
-- Create restore log entry
local restoreLog = {
fileName = fileName,
table = result.table,
records = result.records,
timestamp = result.timestamp,
restoredAt = os.time(),
success = true
}
lia.log.add("Restore completed successfully: " .. fileName)
hook.Run("OnRestoreCompleted", restoreLog)
return restoreLog
end)
end):catch(function(err)
lia.error("Restore failed: " .. tostring(err))
-- Log failed restore attempt
local failedLog = {
fileName = fileName,
error = tostring(err),
failedAt = os.time(),
success = false
}
hook.Run("OnRestoreFailed", failedLog)
return failedLog
end)
end
```

---

### lia.GM:RegisterPreparedStatements

**Purpose**

Restores a database table from a previously created snapshot file

**When Called**

When restoring data from backups, recovering from errors, or migrating data

**Parameters**

* `fileName` (*string*): Name of the snapshot file to load

**Returns**

* Deferred promise object resolving to restore information (table, records, timestamp)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Load a snapshot
lia.db.loadSnapshot("snapshot_characters_1234567890.json"):next(function(result)
print("Restored " .. result.records .. " records to " .. result.table)
end)
```

**Medium Complexity:**
```lua
-- Medium: Load snapshot with validation
local function restoreTable(fileName)
return lia.db.loadSnapshot(fileName):next(function(result)
lia.log.add("Restored " .. result.records .. " records to " .. result.table)
hook.Run("OnTableRestored", result.table, result.records)
return result
end):catch(function(err)
lia.error("Failed to restore from " .. fileName .. ": " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Load snapshot with validation and error handling
local function restoreWithValidation(fileName)
return lia.db.loadSnapshot(fileName):next(function(result)
-- Validate restore results
if result.records == 0 then
lia.log.add("Restore completed but no records were loaded")
end
-- Verify table exists and has data
return lia.db.count(result.table):next(function(count)
if count ~= result.records then
lia.log.add("Record count mismatch: expected " .. result.records .. ", got " .. count)
end
-- Create restore log entry
local restoreLog = {
fileName = fileName,
table = result.table,
records = result.records,
timestamp = result.timestamp,
restoredAt = os.time(),
success = true
}
lia.log.add("Restore completed successfully: " .. fileName)
hook.Run("OnRestoreCompleted", restoreLog)
return restoreLog
end)
end):catch(function(err)
lia.error("Restore failed: " .. tostring(err))
-- Log failed restore attempt
local failedLog = {
fileName = fileName,
error = tostring(err),
failedAt = os.time(),
success = false
}
hook.Run("OnRestoreFailed", failedLog)
return failedLog
end)
end
```

---

### lia.GM:SetupDatabase

**Purpose**

Restores a database table from a previously created snapshot file

**When Called**

When restoring data from backups, recovering from errors, or migrating data

**Parameters**

* `fileName` (*string*): Name of the snapshot file to load

**Returns**

* Deferred promise object resolving to restore information (table, records, timestamp)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Load a snapshot
lia.db.loadSnapshot("snapshot_characters_1234567890.json"):next(function(result)
print("Restored " .. result.records .. " records to " .. result.table)
end)
```

**Medium Complexity:**
```lua
-- Medium: Load snapshot with validation
local function restoreTable(fileName)
return lia.db.loadSnapshot(fileName):next(function(result)
lia.log.add("Restored " .. result.records .. " records to " .. result.table)
hook.Run("OnTableRestored", result.table, result.records)
return result
end):catch(function(err)
lia.error("Failed to restore from " .. fileName .. ": " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Load snapshot with validation and error handling
local function restoreWithValidation(fileName)
return lia.db.loadSnapshot(fileName):next(function(result)
-- Validate restore results
if result.records == 0 then
lia.log.add("Restore completed but no records were loaded")
end
-- Verify table exists and has data
return lia.db.count(result.table):next(function(count)
if count ~= result.records then
lia.log.add("Record count mismatch: expected " .. result.records .. ", got " .. count)
end
-- Create restore log entry
local restoreLog = {
fileName = fileName,
table = result.table,
records = result.records,
timestamp = result.timestamp,
restoredAt = os.time(),
success = true
}
lia.log.add("Restore completed successfully: " .. fileName)
hook.Run("OnRestoreCompleted", restoreLog)
return restoreLog
end)
end):catch(function(err)
lia.error("Restore failed: " .. tostring(err))
-- Log failed restore attempt
local failedLog = {
fileName = fileName,
error = tostring(err),
failedAt = os.time(),
success = false
}
hook.Run("OnRestoreFailed", failedLog)
return failedLog
end)
end
```

---

### lia.GM:DatabaseConnected

**Purpose**

Restores a database table from a previously created snapshot file

**When Called**

When restoring data from backups, recovering from errors, or migrating data

**Parameters**

* `fileName` (*string*): Name of the snapshot file to load

**Returns**

* Deferred promise object resolving to restore information (table, records, timestamp)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Load a snapshot
lia.db.loadSnapshot("snapshot_characters_1234567890.json"):next(function(result)
print("Restored " .. result.records .. " records to " .. result.table)
end)
```

**Medium Complexity:**
```lua
-- Medium: Load snapshot with validation
local function restoreTable(fileName)
return lia.db.loadSnapshot(fileName):next(function(result)
lia.log.add("Restored " .. result.records .. " records to " .. result.table)
hook.Run("OnTableRestored", result.table, result.records)
return result
end):catch(function(err)
lia.error("Failed to restore from " .. fileName .. ": " .. tostring(err))
end)
end
```

**High Complexity:**
```lua
-- High: Load snapshot with validation and error handling
local function restoreWithValidation(fileName)
return lia.db.loadSnapshot(fileName):next(function(result)
-- Validate restore results
if result.records == 0 then
lia.log.add("Restore completed but no records were loaded")
end
-- Verify table exists and has data
return lia.db.count(result.table):next(function(count)
if count ~= result.records then
lia.log.add("Record count mismatch: expected " .. result.records .. ", got " .. count)
end
-- Create restore log entry
local restoreLog = {
fileName = fileName,
table = result.table,
records = result.records,
timestamp = result.timestamp,
restoredAt = os.time(),
success = true
}
lia.log.add("Restore completed successfully: " .. fileName)
hook.Run("OnRestoreCompleted", restoreLog)
return restoreLog
end)
end):catch(function(err)
lia.error("Restore failed: " .. tostring(err))
-- Log failed restore attempt
local failedLog = {
fileName = fileName,
error = tostring(err),
failedAt = os.time(),
success = false
}
hook.Run("OnRestoreFailed", failedLog)
return failedLog
end)
end
```

---

