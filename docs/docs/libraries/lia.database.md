# Database Library

This page documents functions for connecting to the database.

---

## Overview

The database library sets up the SQL connection used by the framework. It defines helpers for creating tables, performing queries, and waiting for asynchronous operations to finish.

---

### lia.db.connect(callback, reconnect)

**Description:**

Establishes a connection to the configured database module. If the database

is not already connected or if reconnect is true, it will initiate a new connection

or re-establish one.

**Parameters:**

* callback (function) – The function to call when the database connection is established.


* reconnect (boolean) – Whether to reconnect using an existing database object or not.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.connect
    lia.db.connect(function()
        print("Database connected")
    end)
```

---

### lia.db.wipeTables(callback)

**Description:**

Wipes all Lilia data tables from the database, dropping the specified

tables. This action is irreversible and will remove all stored data.

**Parameters:**

* callback (function) – The function to call when the wipe operation is completed.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.wipeTables
    lia.db.wipeTables(function()
        print("Tables wiped")
    end)
```

---

### lia.db.loadTables()

**Description:**

Creates the required database tables if they do not already exist for
storing Lilia data. This includes tables such as `lia_players`,
`lia_characters`, and the `lia_data` table used by `lia.data`.
This ensures the schema is properly set up.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.loadTables
    lia.db.loadTables()
```

---

### lia.db.waitForTablesToLoad()

**Description:**

Returns a deferred object that resolves once the database tables are fully loaded.

This allows asynchronous code to wait for table creation before proceeding.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* deferred – Resolves when the tables are loaded.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.waitForTablesToLoad
    lia.db.waitForTablesToLoad():next(function()
        print("Tables loaded")
    end)
```

---

### lia.db.convertDataType(value, noEscape)

**Description:**

Converts a Lua value into a string suitable for database insertion,

handling strings, tables, and NULL values. Escaping is optionally applied

unless noEscape is set.

**Parameters:**

* value (any) – The value to be converted.


* noEscape (boolean) – If true, the returned string is not escaped.


**Realm:**

* Shared


**Returns:**

* string – The converted data type as a string.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.convertDataType
    local str = lia.db.convertDataType({name = "Lilia"})
```

---

### lia.db.insertTable(value, callback, dbTable)

**Description:**

Inserts a new row into the specified database table with the given key-value pairs.

The callback is invoked after the insert query is complete.

**Parameters:**

* value (table) – Key-value pairs representing the columns and values to insert.


* callback (function) – The function to call when the insert operation is complete.


* dbTable (string) – The name of the table (without the 'lia_' prefix).


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.insertTable
    lia.db.insertTable({name = "Test"}, function(id)
        print("Inserted", id)
    end, "characters")
```

---

### lia.db.updateTable(value, callback, dbTable, condition)

**Description:**

Updates one or more rows in the specified database table according to the

provided condition. The callback is invoked once the update query finishes.

**Parameters:**

* value (table) – Key-value pairs representing columns to update and their new values.


* callback (function) – The function to call after the update query is complete.


* dbTable (string) – The name of the table (without the 'lia_' prefix).


* condition (string) – The SQL condition to determine which rows to update.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.updateTable
    lia.db.updateTable({name = "Updated"}, function()
        print("Row updated")
    end, "characters", "id = 1")
```

---

### lia.db.select(fields, dbTable, condition, limit)

**Description:**

Retrieves rows from the specified database table, optionally filtered by

a condition and limited to a specified number of results. Returns a deferred

object that resolves with the query results.

**Parameters:**

* fields (table|string) – The columns to select, either as a table or a comma-separated string.


* dbTable (string) – The name of the table (without the 'lia_' prefix).


* condition (string) – The SQL condition to filter results.


* limit (number) – Maximum number of rows to return.


**Realm:**

* Shared


**Returns:**

* deferred – Resolves with query results and last insert ID.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.select
    lia.db.select("*", "characters", "id = 1"):next(function(rows)
        PrintTable(rows)
    end)
```

---

### lia.db.upsert(value, dbTable)

**Description:**

Inserts or updates a row in the specified database table. If a row with

the same unique key exists, it updates it; otherwise, it inserts a new row.

Returns a deferred object that resolves when the operation completes.

**Parameters:**

* value (table) – Key-value pairs representing the columns and values.


* dbTable (string) – The name of the table (without the 'lia_' prefix).


**Realm:**

* Shared


**Returns:**

* deferred – Resolves to a table of results and last insert ID.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.upsert
    lia.db.upsert({id = 1, name = "John"}, "characters")
```

---

### lia.db.delete(dbTable, condition)

**Description:**

Deletes rows from the specified database table that match the provided condition.

If no condition is specified, all rows are deleted. Returns a deferred object.

**Parameters:**

* dbTable (string) – The name of the table (without the 'lia_' prefix).


* condition (string) – The SQL condition that determines which rows to delete.


**Realm:**

* Shared


**Returns:**

* deferred – Resolves to the results of the deletion.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.delete
    lia.db.delete("characters", "id = 1"):next(function()
        print("Row deleted")
    end)
```

---

### lia.db.GetCharacterTable(callback)

**Description:**

Fetches a list of column names from the ``lia_characters`` table.

This is useful for debugging or database maintenance tasks.

**Parameters:**

* callback (function) – Function executed with the table of column names.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.GetCharacterTable
    lia.db.GetCharacterTable(function(columns) PrintTable(columns) end)
```
