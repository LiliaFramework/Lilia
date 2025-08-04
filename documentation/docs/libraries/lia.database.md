# Database Library

This page documents functions for connecting to the database.

---

## Overview

The database library sets up the SQL connection used by the framework. It defines helpers for creating tables, performing queries, and waiting for asynchronous operations to finish.

---

### lia.db.connect

**Purpose**

Establishes a connection to the configured database module. If the database is not already connected, or if `reconnect` is `true`, it creates or re-establishes a connection.

**Parameters**

* `callback` (*function*): Function called when the connection is established.

* `reconnect` (*boolean*): Reconnect using an existing database object.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.connect(function()
    print("Database connected")
end)
```

---

### lia.db.wipeTables

**Purpose**

Drops all Lilia tables from the database. **Irreversible** – all stored data is removed.

**Parameters**

* `callback` (*function*): Function called when the wipe completes.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.wipeTables(function()
    print("Tables wiped")
end)
```

---

### lia.db.loadTables

**Purpose**

Creates required tables if they do not already exist. Ensures the schema is set up.

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.loadTables()
```

---

### lia.db.waitForTablesToLoad

**Purpose**

Returns a deferred that resolves once tables are fully created. Useful for awaiting setup in async code.

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *deferred*: Resolves when tables are ready.

**Example Usage**

```lua
lia.db.waitForTablesToLoad():next(function()
    print("Tables loaded")
end)
```

---

### lia.db.convertDataType

**Purpose**

Converts a Lua value into a string appropriate for SQL insertion, handling escaping unless `noEscape` is `true`.

**Parameters**

* `value` (*any*): Value to convert.

* `noEscape` (*boolean*): Skip escaping when `true`.

**Realm**

`Shared`

**Returns**

* *string | number*: SQL-ready representation.

**Example Usage**

```lua
local str = lia.db.convertDataType({ name = "Lilia" })
```

---

### lia.db.insertTable

**Purpose**

Inserts a row into a table using key-value pairs.

**Parameters**

* `value` (*table*): Column/value pairs.

* `callback` (*function*): Function called after the insert.

* `dbTable` (*string*): Table name **without** the `lia_` prefix.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.insertTable({ name = "Test" }, function(id)
    print("Inserted", id)
end, "characters")
```

---

### lia.db.updateTable

**Purpose**

Updates one or more rows according to a condition.

**Parameters**

* `value` (*table*): Columns to update and new values.

* `callback` (*function*): Function called after update.

* `dbTable` (*string*): Table name **without** `lia_`.

* `condition` (*string*): SQL `WHERE` clause.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.updateTable({ name = "Updated" }, function()
    print("Row updated")
end, "characters", "id = 1")
```

---

### lia.db.select

**Purpose**

Selects rows, optionally filtered and limited, returning a deferred.

**Parameters**

* `fields` (*table | string*): Columns to select.

* `dbTable` (*string*): Table name without `lia_`.

* `condition` (*string*): SQL condition (`WHERE`).

* `limit` (*number*): Maximum number of rows.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves with results and last insert ID.

**Example Usage**

```lua
lia.db.select("*", "characters", "id = 1"):next(function(rows)
    PrintTable(rows)
end)
```

---

### lia.db.upsert

**Purpose**

Inserts or updates a row depending on unique-key conflict. Returns a deferred.

**Parameters**

* `value` (*table*): Columns and values.

* `dbTable` (*string*): Table name without `lia_`.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves when done.

**Example Usage**

```lua
lia.db.upsert({ id = 1, name = "John" }, "characters")
```

---

### lia.db.delete

**Purpose**

Deletes rows matching a condition; deletes all rows if no condition.

**Parameters**

* `dbTable` (*string*): Table name without `lia_`.

* `condition` (*string*): SQL condition.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves with deletion result.

**Example Usage**

```lua
lia.db.delete("characters", "id = 1"):next(function()
    print("Row deleted")
end)
```

---

### lia.db.GetCharacterTable

**Purpose**

Fetches the column names of `lia_characters` for debugging/maintenance.

**Parameters**

* `callback` (*function*): Receives the list of columns.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.GetCharacterTable(function(cols)
    PrintTable(cols)
end)
```

---

### lia.db.count

**Purpose**

Counts rows in a table, optionally filtered.

**Parameters**

* `dbTable` (*string*): Table name without `lia_`.

* `condition` (*string*): Optional SQL condition.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to the row count.

**Example Usage**

```lua
lia.db.count("characters", "faction = 1"):next(function(n)
    print("Character count:", n)
end)
```

---

### lia.db.addDatabaseFields

**Purpose**

Ensures every registered character variable has a matching column in the

`lia_characters` table, adding any that are missing. It can be invoked

multiple times; existing columns will be ignored.

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- After creating custom character variables
lia.db.addDatabaseFields()
```

---

### lia.db.exists

**Purpose**

Checks if any row satisfies a condition.

**Parameters**

* `dbTable` (*string*): Table name without `lia_`.

* `condition` (*string*): SQL condition.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to `true` or `false`.

**Example Usage**

```lua
lia.db.exists("characters", "id = 5"):next(function(found)
    print("Character exists:", found)
end)
```

---

### lia.db.selectOne

**Purpose**

Fetches the first row that matches a condition.

**Parameters**

* `fields` (*table | string*): Columns.

* `dbTable` (*string*): Table name without `lia_`.

* `condition` (*string*): SQL condition.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves with the row or `nil`.

**Example Usage**

```lua
lia.db.selectOne("*", "characters", "id = 1"):next(function(row)
    if row then
        print("Found character:", row._name)
    end
end)
```

---

### lia.db.bulkInsert

**Purpose**

Inserts multiple rows in a single query.

**Parameters**

* `dbTable` (*string*): Table name without `lia_`.

* `rows` (*table*): Array of row tables.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves when done.

**Example Usage**

```lua
lia.db.bulkInsert("items", {
    { _invID = 1, _uniqueID = "pistol", _x = 0, _y = 0, _quantity = 1 },
    { _invID = 1, _uniqueID = "ammo",   _x = 1, _y = 0, _quantity = 30 },
})
```

---

### lia.db.bulkUpsert

**Purpose**

Inserts multiple rows and updates them if they already exist.

**Parameters**

* `dbTable` (*string*): Table name without `lia_`.

* `rows` (*table*): Array of row tables.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves when done.

**Example Usage**

```lua
lia.db.bulkUpsert("items", {
    { _invID = 1, _uniqueID = "pistol", _x = 0, _y = 0, _quantity = 1 },
    { _invID = 1, _uniqueID = "ammo",   _x = 1, _y = 0, _quantity = 30 },
})
```

---

### lia.db.insertOrIgnore

**Purpose**

Attempts to insert a row; silently ignores unique-key violation.

**Parameters**

* `value` (*table*): Row data.

* `dbTable` (*string*): Table name without `lia_`.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves with results and last insert ID.

**Example Usage**

```lua
lia.db.insertOrIgnore({ id = 1, name = "Bob" }, "characters"):next(function(r)
    print("Insert ID:", r.lastID)
end)
```

---

### lia.db.transaction

**Purpose**

Runs multiple queries inside a transaction, rolling back if any fail.

**Parameters**

* `queries` (*table*): Array of SQL strings.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves when transaction completes.

**Example Usage**

```lua
lia.db.transaction({
    "INSERT INTO lia_logs (_message) VALUES ('start')",
    "INSERT INTO lia_logs (_message) VALUES ('end')",
}):next(function()
    print("Transaction complete")
end)
```

---

### lia.db.escapeIdentifier

**Purpose**

Escapes an identifier (column/table name) for SQL.

**Parameters**

* `id` (*string*): Identifier.

**Realm**

`Shared`

**Returns**

* *string*: Escaped identifier.

**Example Usage**

```lua
local col = lia.db.escapeIdentifier("desc")
print(col)
```

---

### lia.db.prepare

**Purpose**

Registers a prepared statement (MySQLOO only).

**Parameters**

* `key` (*string*): Statement identifier.

* `query` (*string*): SQL with placeholders.

* `types` (*table*): Array of MySQLOO type constants.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.prepare(
    "updateName",
    "UPDATE lia_characters SET _name = ? WHERE _id = ?",
    { MYSQLOO_STRING, MYSQLOO_INTEGER }
)
```

---

### lia.db.preparedCall

**Purpose**

Executes a prepared statement registered with `lia.db.prepare`. *(MySQLOO only)*

**Parameters**

* `key` (*string*): Statement identifier.

* `callback` (*function*): Receives results and last insert ID.

* … (*variant*): Placeholder arguments.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.preparedCall("updateName", nil, "Alice", 1)
```

---

### lia.db.query

**Purpose**

Executes a raw SQL string. If no callback is provided, returns a deferred.

**Parameters**

* `query` (*string*): SQL query.

* `callback` (*function*): Optional results callback.

**Realm**

`Server`

**Returns**

* *deferred | nil*: Deferred when no callback.

**Example Usage**

```lua
lia.db.query("SELECT 1"):next(function(res)
    PrintTable(res.results)
end)
```

---

### lia.db.escape

**Purpose**

Escapes a string for safe inclusion in SQL queries.

**Parameters**

* `value` (*string*): Raw string.

**Realm**

`Shared`

**Returns**

* *string*: Escaped string.

**Example Usage**

```lua
local safe = lia.db.escape(userInput)
```

---

### lia.db.queue

**Purpose**

Returns the number of queued SQL queries. *(MySQLOO only)*

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *number*: Count of queued queries.

**Example Usage**

```lua
print("Queue size:", lia.db.queue())
```

---

### lia.db.abort

**Purpose**

Cancels all running queries on every connection. *(MySQLOO only)*

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.db.abort()
```

---

### lia.db.getObject

**Purpose**

Returns the least busy database object and its pool index. *(MySQLOO only)*

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *database*, *number*: Connection object and pool index.

**Example Usage**

```lua
local db = lia.db.getObject()
```

---

### lia.db.tableExists

**Purpose**

Checks whether a table with the provided name exists in the connected database.

**Parameters**

* `tbl` (*string*): Name of the table to check.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to `true` or `false`.

**Example Usage**

```lua
lia.db.tableExists("characters"):next(function(exists)
    print("Characters table present:", exists)
end)
```

---

### lia.db.fieldExists

**Purpose**

Determines whether a specific column is present in a table.

**Parameters**

* `tbl` (*string*): Table name.

* `field` (*string*): Column name to check.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to `true` when the field exists.

**Example Usage**

```lua
lia.db.fieldExists("characters", "name"):next(function(hasField)
    print("Name column exists:", hasField)
end)
```

---
