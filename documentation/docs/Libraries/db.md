# Database Library

Comprehensive database management system with SQLite support for the Lilia framework.

---

Overview

The database library provides comprehensive database management functionality for the Lilia framework. It handles all database operations including connection management, table creation and modification, data insertion, updates, queries, and schema management. The library supports SQLite as the primary database engine with extensible module support for other database systems. It includes advanced features such as prepared statements, transactions, bulk operations, data type conversion, and database snapshots for backup and restore operations. The library ensures data persistence across server restarts and provides robust error handling with deferred promise-based operations for asynchronous database queries. It manages core gamemode tables for players, characters, inventories, items, configuration, logs, and administrative data while supporting dynamic schema modifications.

---

### lia.db.connect

#### 📋 Purpose
Establishes a connection to the database using the configured database module and initializes the query system.

#### ⏰ When Called
Called during gamemode initialization to set up the database connection, or when reconnecting to the database.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback` | **function** | Optional callback function to execute when the connection is established. |
| `reconnect` | **boolean** | Optional flag to force reconnection even if already connected. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.connect(function()
        print("Database connected successfully!")
    end)

```

---

### lia.db.wipeTables

#### 📋 Purpose
Completely removes all Lilia-related database tables from the database.

#### ⏰ When Called
Called when performing a complete data wipe/reset of the gamemode's database.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback` | **function** | Optional callback function to execute when all tables have been wiped. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.wipeTables(function()
        print("All Lilia tables have been wiped!")
    end)

```

---

### lia.db.loadTables

#### 📋 Purpose
Creates all core Lilia database tables if they don't exist, including tables for players, characters, inventories, items, configuration, logs, and administrative data.

#### ⏰ When Called
Called during gamemode initialization to set up the database schema and prepare the database for use.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.loadTables()

```

---

### lia.db.waitForTablesToLoad

#### 📋 Purpose
Returns a deferred promise that resolves when all database tables have finished loading.

#### ⏰ When Called
Called when code needs to wait for database tables to be fully initialized before proceeding with database operations.

#### ↩️ Returns
* Deferred
A promise that resolves when tables are loaded.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.waitForTablesToLoad():next(function()
        -- Database tables are now ready
        lia.db.select("*", "characters"):next(function(results)
            print("Characters loaded:", #results)
        end)
    end)

```

---

### lia.db.convertDataType

#### 📋 Purpose
Converts Lua data types to SQL-compatible string formats for database queries.

#### ⏰ When Called
Automatically called when building SQL queries to ensure proper data type conversion.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **any** | The value to convert (string, number, boolean, table, nil). |
| `noEscape` | **boolean** | Optional flag to skip SQL escaping for strings and tables. |

#### ↩️ Returns
* string
The converted value as a SQL-compatible string.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local sqlValue = lia.db.convertDataType("John's Name")
    -- Returns: "'John''s Name'" (properly escaped)
    local sqlValue2 = lia.db.convertDataType({health = 100})
    -- Returns: "'{\"health\":100}'" (JSON encoded and escaped)

```

---

### lia.db.insertTable

#### 📋 Purpose
Inserts a new row into the specified database table with the provided data.

#### ⏰ When Called
Called when adding new records to database tables such as characters, items, or player data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **table** | Table containing column-value pairs to insert. |
| `callback` | **function** | Optional callback function called with (results, lastID) when the query completes. |
| `dbTable` | **string** | Optional table name (defaults to "characters" if not specified). |

#### ↩️ Returns
* Deferred
A promise that resolves with {results = results, lastID = lastID}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.updateTable

#### 📋 Purpose
Updates existing rows in the specified database table with the provided data.

#### ⏰ When Called
Called when modifying existing records in database tables such as updating character data or player information.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **table** | Table containing column-value pairs to update. |
| `callback` | **function** | Optional callback function called with (results, lastID) when the query completes. |
| `dbTable` | **string** | Optional table name without "lia_" prefix (defaults to "characters" if not specified). |
| `condition` | **table|string** | Optional WHERE condition to specify which rows to update. |

#### ↩️ Returns
* Deferred
A promise that resolves with {results = results, lastID = lastID}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.select

#### 📋 Purpose
Selects data from the specified database table with optional conditions and limits.

#### ⏰ When Called
Called when retrieving data from database tables such as fetching character information or player data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fields` | **string|table** | Fields to select - either "*" for all fields, a string field name, or table of field names. |
| `dbTable` | **string** | Table name without "lia_" prefix (defaults to "characters" if not specified). |
| `condition` | **table|string** | Optional WHERE condition to filter results. |
| `limit` | **number** | Optional LIMIT clause to restrict number of results. |

#### ↩️ Returns
* Deferred
A promise that resolves with {results = results, lastID = lastID}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.selectWithCondition

#### 📋 Purpose
Selects data from the specified database table with complex conditions and optional ordering.

#### ⏰ When Called
Called when needing advanced query conditions with operator support and ordering.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fields` | **string|table** | Fields to select - either "*" for all fields, a string field name, or table of field names. |
| `dbTable` | **string** | Table name without "lia_" prefix. |
| `conditions` | **table|string** | WHERE conditions - can be a string or table with field-operator-value structures. |
| `limit` | **number** | Optional LIMIT clause to restrict number of results. |
| `orderBy` | **string** | Optional ORDER BY clause for sorting results. |

#### ↩️ Returns
* Deferred
A promise that resolves with {results = results, lastID = lastID}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Select with complex conditions and ordering
    lia.db.selectWithCondition("*", "characters", {
        money = {operator = ">", value = 1000},
        faction = "citizen"
    }, 10, "name ASC"):next(function(result)
        print("Found", #result.results, "rich citizens")
    end)

```

---

### lia.db.count

#### 📋 Purpose
Counts the number of rows in the specified database table that match the given condition.

#### ⏰ When Called
Called when needing to determine how many records exist in a table, such as counting characters or items.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbTable` | **string** | Table name without "lia_" prefix. |
| `condition` | **table|string** | Optional WHERE condition to filter which rows to count. |

#### ↩️ Returns
* Deferred
A promise that resolves with the count as a number.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.addDatabaseFields

#### 📋 Purpose
Dynamically adds missing database fields to the characters table based on character variable definitions.

#### ⏰ When Called
Called during database initialization to ensure all character variables have corresponding database columns.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.addDatabaseFields()

```

---

### lia.db.exists

#### 📋 Purpose
Checks if any records exist in the specified table that match the given condition.

#### ⏰ When Called
Called to verify the existence of records before performing operations.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbTable` | **string** | Table name without "lia_" prefix. |
| `condition` | **table|string** | WHERE condition to check for record existence. |

#### ↩️ Returns
* Deferred
A promise that resolves to true if records exist, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.exists("characters", {steamID = "STEAM_0:1:12345678"}):next(function(exists)
        if exists then
            print("Player has characters")
        else
            print("Player has no characters")
        end
    end)

```

---

### lia.db.selectOne

#### 📋 Purpose
Selects a single row from the specified database table that matches the given condition.

#### ⏰ When Called
Called when retrieving a specific record from database tables, such as finding a character by ID.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fields` | **string|table** | Fields to select - either "*" for all fields, a string field name, or table of field names. |
| `dbTable` | **string** | Table name without "lia_" prefix. |
| `condition` | **table|string** | Optional WHERE condition to filter results. |

#### ↩️ Returns
* Deferred
A promise that resolves with the first matching row as a table, or nil if no rows found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.bulkInsert

#### 📋 Purpose
Inserts multiple rows into the specified database table in a single query for improved performance.

#### ⏰ When Called
Called when inserting large amounts of data at once, such as bulk importing items or characters.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbTable` | **string** | Table name without "lia_" prefix. |
| `rows` | **table** | Array of row data tables, where each table contains column-value pairs. |

#### ↩️ Returns
* Deferred
A promise that resolves when the bulk insert completes.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.bulkUpsert

#### 📋 Purpose
Performs bulk insert or replace operations on multiple rows in a single query.

#### ⏰ When Called
Called when bulk updating/inserting data where existing records should be replaced.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbTable` | **string** | Table name without "lia_" prefix. |
| `rows` | **table** | Array of row data tables to insert or replace. |

#### ↩️ Returns
* Deferred
A promise that resolves when the bulk upsert completes.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local data = {
        {id = 1, name = "Item 1", value = 100},
        {id = 2, name = "Item 2", value = 200}
    }
    lia.db.bulkUpsert("custom_items", data):next(function()
        print("Bulk upsert completed")
    end)

```

---

### lia.db.insertOrIgnore

#### 📋 Purpose
Inserts a new row into the database table, but ignores the operation if a conflict occurs (such as duplicate keys).

#### ⏰ When Called
Called when inserting data that might already exist, where duplicates should be silently ignored.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **table** | Table containing column-value pairs to insert. |
| `dbTable` | **string** | Optional table name without "lia_" prefix (defaults to "characters"). |

#### ↩️ Returns
* Deferred
A promise that resolves with {results = results, lastID = lastID}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.insertOrIgnore({
        steamID = "STEAM_0:1:12345678",
        name = "Player Name"
    }, "players"):next(function(result)
        print("Player record inserted or already exists")
    end)

```

---

### lia.db.tableExists

#### 📋 Purpose
Checks if a database table with the specified name exists.

#### ⏰ When Called
Called before performing operations on tables to verify they exist, or when checking schema state.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tbl` | **string** | The table name to check for existence. |

#### ↩️ Returns
* Deferred
A promise that resolves to true if the table exists, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.tableExists("lia_characters"):next(function(exists)
        if exists then
            print("Characters table exists")
        else
            print("Characters table does not exist")
        end
    end)

```

---

### lia.db.fieldExists

#### 📋 Purpose
Checks if a column/field with the specified name exists in the given database table.

#### ⏰ When Called
Called before accessing table columns to verify they exist, or when checking schema modifications.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tbl` | **string** | The table name to check (should include "lia_" prefix). |
| `field` | **string** | The field/column name to check for existence. |

#### ↩️ Returns
* Deferred
A promise that resolves to true if the field exists, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.fieldExists("lia_characters", "custom_field"):next(function(exists)
        if exists then
            print("Custom field exists")
        else
            print("Custom field does not exist")
        end
    end)

```

---

### lia.db.getTables

#### 📋 Purpose
Retrieves a list of all Lilia database tables (tables starting with "lia_").

#### ⏰ When Called
Called when needing to enumerate all database tables, such as for maintenance operations or schema inspection.

#### ↩️ Returns
* Deferred
A promise that resolves with an array of table names.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.getTables():next(function(tables)
        print("Lilia tables:")
        for _, tableName in ipairs(tables) do
            print("-", tableName)
        end
    end)

```

---

### lia.db.transaction

#### 📋 Purpose
Executes multiple database queries as an atomic transaction - either all queries succeed or all are rolled back.

#### ⏰ When Called
Called when performing multiple related database operations that must be atomic, such as transferring items between inventories.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `queries` | **table** | Array of SQL query strings to execute in sequence. |

#### ↩️ Returns
* Deferred
A promise that resolves when the transaction completes successfully, or rejects if any query fails.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.escapeIdentifier

#### 📋 Purpose
Escapes SQL identifiers (table and column names) by wrapping them in backticks and escaping any backticks within.

#### ⏰ When Called
Automatically called when building SQL queries to safely handle identifiers that might contain special characters.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string** | The identifier (table name, column name, etc.) to escape. |

#### ↩️ Returns
* string
The escaped identifier wrapped in backticks.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local escaped = lia.db.escapeIdentifier("user_name")
    -- Returns: "`user_name`"
    local escaped2 = lia.db.escapeIdentifier("table`with`ticks")
    -- Returns: "`table``with``ticks`"

```

---

### lia.db.upsert

#### 📋 Purpose
Inserts a new row into the database table, or replaces the existing row if it already exists (SQLite UPSERT operation).

#### ⏰ When Called
Called when you want to ensure a record exists with specific data, regardless of whether it was previously created.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **table** | Table containing column-value pairs to insert or update. |
| `dbTable` | **string** | Optional table name without "lia_" prefix (defaults to "characters" if not specified). |

#### ↩️ Returns
* Deferred
A promise that resolves with {results = results, lastID = lastID}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.delete

#### 📋 Purpose
Deletes rows from the specified database table that match the given condition.

#### ⏰ When Called
Called when removing records from database tables, such as deleting characters or cleaning up old data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbTable` | **string** | Table name without "lia_" prefix (defaults to "character" if not specified). |
| `condition` | **table|string** | WHERE condition to specify which rows to delete. |

#### ↩️ Returns
* Deferred
A promise that resolves with {results = results, lastID = lastID}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.createTable

#### 📋 Purpose
Creates a new database table with the specified schema definition.

#### ⏰ When Called
Called when creating custom tables for modules or extending the database schema.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbName` | **string** | Table name without "lia_" prefix. |
| `primaryKey` | **string** | Optional name of the primary key column. |
| `schema` | **table** | Array of column definitions with name, type, not_null, and default properties. |

#### ↩️ Returns
* Deferred
A promise that resolves to true when the table is created.

#### 🌐 Realm
Shared

#### 💡 Example Usage

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

---

### lia.db.createColumn

#### 📋 Purpose
Adds a new column to an existing database table.

#### ⏰ When Called
Called when extending database schema by adding new fields to existing tables.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tableName` | **string** | Table name without "lia_" prefix. |
| `columnName` | **string** | Name of the new column to add. |
| `columnType` | **string** | SQL data type for the column (e.g., "VARCHAR(255)", "INTEGER", "TEXT"). |
| `defaultValue` | **any** | Optional default value for the new column. |

#### ↩️ Returns
* Deferred
A promise that resolves to true if column was added, false if it already exists.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.createColumn("characters", "custom_field", "VARCHAR(100)", "default_value"):next(function(success)
        if success then
            print("Column added successfully")
        else
            print("Column already exists")
        end
    end)

```

---

### lia.db.removeTable

#### 📋 Purpose
Removes a database table from the database.

#### ⏰ When Called
Called when cleaning up or removing custom tables from the database schema.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tableName` | **string** | Table name without "lia_" prefix. |

#### ↩️ Returns
* Deferred
A promise that resolves to true if table was removed, false if it doesn't exist.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.removeTable("custom_data"):next(function(success)
        if success then
            print("Table removed successfully")
        else
            print("Table does not exist")
        end
    end)

```

---

### lia.db.removeColumn

#### 📋 Purpose
Removes a column from an existing database table by recreating the table without the specified column.

#### ⏰ When Called
Called when removing fields from database tables during schema cleanup or refactoring.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tableName` | **string** | Table name without "lia_" prefix. |
| `columnName` | **string** | Name of the column to remove. |

#### ↩️ Returns
* Deferred
A promise that resolves to true if column was removed, false if table/column doesn't exist.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.removeColumn("characters", "old_field"):next(function(success)
        if success then
            print("Column removed successfully")
        else
            print("Column or table does not exist")
        end
    end)

```

---

### lia.db.getCharacterTable

#### 📋 Purpose
Retrieves the column information/schema for the characters table.

#### ⏰ When Called
Called when needing to inspect the structure of the characters table for schema operations.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback` | **function** | Function to call with the array of column names. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.getCharacterTable(function(columns)
        print("Character table columns:")
        for _, column in ipairs(columns) do
            print("-", column)
        end
    end)

```

---

### lia.db.createSnapshot

#### 📋 Purpose
Creates a backup snapshot of all data in the specified table and saves it to a JSON file.

#### ⏰ When Called
Called for backup purposes before major data operations or schema changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tableName` | **string** | Table name without "lia_" prefix. |

#### ↩️ Returns
* Deferred
A promise that resolves with snapshot info {file = filename, path = filepath, records = count}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.createSnapshot("characters"):next(function(snapshot)
        print("Snapshot created:", snapshot.file, "with", snapshot.records, "records")
    end)

```

---

### lia.db.loadSnapshot

#### 📋 Purpose
Loads data from a snapshot file and restores it to the corresponding database table.

#### ⏰ When Called
Called to restore database tables from backup snapshots.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fileName` | **string** | Name of the snapshot file to load. |

#### ↩️ Returns
* Deferred
A promise that resolves with restore info {table = tableName, records = count, timestamp = timestamp}.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.db.loadSnapshot("snapshot_characters_1640995200.json"):next(function(result)
        print("Restored", result.records, "records to", result.table)
    end)

```

---

