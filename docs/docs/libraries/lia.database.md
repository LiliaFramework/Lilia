# Database Library

This page documents functions for connecting to the database.

---

## Overview

The database library sets up the SQL connection used by the framework. It defines helpers for creating tables, performing queries, and waiting for asynchronous operations to finish.

---

### lia.db.connect

**Description:**

Establishes a connection to the configured database module. If the database

is not already connected or if reconnect is true, it will initiate a new connection

or re-establish one.

**Parameters:**

* `callback` (`function`) – The function to call when the database connection is established.


* `reconnect` (`boolean`) – Whether to reconnect using an existing database object or not.


**Realm:**

* Server


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

### lia.db.wipeTables

**Description:**

Wipes all Lilia data tables from the database, dropping the specified

tables. This action is irreversible and will remove all stored data.

**Parameters:**

* `callback` (`function`) – The function to call when the wipe operation is completed.


**Realm:**

* Server


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

### lia.db.loadTables

**Description:**

Creates the required database tables if they do not already exist for

storing Lilia data. This ensures the schema is properly set up.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.loadTables
    lia.db.loadTables()
```

---

### lia.db.waitForTablesToLoad

**Description:**

Returns a deferred object that resolves once the database tables are fully loaded.

This allows asynchronous code to wait for table creation before proceeding.

**Parameters:**

* None


**Realm:**

* Server


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

### lia.db.convertDataType

**Description:**

Converts a Lua value into a string suitable for database insertion,

handling strings, tables, and NULL values. Escaping is optionally applied

unless noEscape is set.

**Parameters:**

* `value` (`any`) – The value to be converted.


* `noEscape` (`boolean`) – If true, the returned string is not escaped.


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

### lia.db.insertTable

**Description:**

Inserts a new row into the specified database table with the given key-value pairs.

The callback is invoked after the insert query is complete.

**Parameters:**

* `value` (`table`) – Key-value pairs representing the columns and values to insert.


* `callback` (`function`) – The function to call when the insert operation is complete.


* `dbTable` (`string`) – The name of the table (without the 'lia_' prefix).


**Realm:**

* Server


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

### lia.db.updateTable

**Description:**

Updates one or more rows in the specified database table according to the

provided condition. The callback is invoked once the update query finishes.

**Parameters:**

* `value` (`table`) – Key-value pairs representing columns to update and their new values.


* `callback` (`function`) – The function to call after the update query is complete.


* `dbTable` (`string`) – The name of the table (without the 'lia_' prefix).


* `condition` (`string`) – The SQL condition to determine which rows to update.


**Realm:**

* Server


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

### lia.db.select

**Description:**

Retrieves rows from the specified database table, optionally filtered by

a condition and limited to a specified number of results. Returns a deferred

object that resolves with the query results.

**Parameters:**

* `fields` (`table|string`) – The columns to select, either as a table or a comma-separated string.


* `dbTable` (`string`) – The name of the table (without the 'lia_' prefix).


* `condition` (`string`) – The SQL condition to filter results.


* `limit` (`number`) – Maximum number of rows to return.


**Realm:**

* Server


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

### lia.db.upsert

**Description:**

Inserts or updates a row in the specified database table. If a row with

the same unique key exists, it updates it; otherwise, it inserts a new row.

Returns a deferred object that resolves when the operation completes.

**Parameters:**

* `value` (`table`) – Key-value pairs representing the columns and values.


* `dbTable` (`string`) – The name of the table (without the 'lia_' prefix).


**Realm:**

* Server


**Returns:**

* deferred – Resolves to a table of results and last insert ID.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.upsert
    lia.db.upsert({id = 1, name = "John"}, "characters")
```

---

### lia.db.delete

**Description:**

Deletes rows from the specified database table that match the provided condition.

If no condition is specified, all rows are deleted. Returns a deferred object.

**Parameters:**

* `dbTable` (`string`) – The name of the table (without the 'lia_' prefix).


* `condition` (`string`) – The SQL condition that determines which rows to delete.


**Realm:**

* Server


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

### lia.db.GetCharacterTable

**Description:**

Fetches a list of column names from the ``lia_characters`` table.

This is useful for debugging or database maintenance tasks.

**Parameters:**

* `callback` (`function`) – Function executed with the table of column names.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.db.GetCharacterTable
lia.db.GetCharacterTable(function(columns) PrintTable(columns) end)
```

---

### lia.db.count

**Description:**

Counts rows in the given table optionally filtered by a condition.

**Parameters:**

* `dbTable` (`string`) – Table name without the `lia_` prefix.

* `condition` (`string`) – Optional SQL condition.

**Realm:**

* Server

**Returns:**

* deferred – Resolves to the number of matching rows.

**Example Usage:**

```lua
    lia.db.count("characters", "faction = 1"):next(function(n)
        print("Character count:", n)
    end)
```

---

### lia.db.exists

**Description:**

Checks whether any rows satisfy the provided condition.

**Parameters:**

* `dbTable` (`string`) – Table name without the `lia_` prefix.

* `condition` (`string`) – SQL condition to filter results.

**Realm:**

* Server

**Returns:**

* deferred – Resolves to `true` if at least one row exists.

**Example Usage:**

```lua
    lia.db.exists("characters", "id = 5"):next(function(found)
        print("Character exists:", found)
    end)
```

---

### lia.db.selectOne

**Description:**

Fetches a single row from the given table.

**Parameters:**

* `fields` (`table|string`) – Columns to select.

* `dbTable` (`string`) – Table name without the `lia_` prefix.

* `condition` (`string`) – SQL condition to filter results.

**Realm:**

* Server

**Returns:**

* deferred – Resolves with the first result row or `nil`.

**Example Usage:**

```lua
    lia.db.selectOne("*", "characters", "id = 1"):next(function(row)
        if row then
            print("Found character:", row._name)
        end
    end)
```

---

### lia.db.bulkInsert

**Description:**

Inserts multiple rows in a single query.

**Parameters:**

* `dbTable` (`string`) – Table name without the `lia_` prefix.

* `rows` (`table`) – Array of row tables to insert.

**Realm:**

* Server

**Returns:**

* deferred – Resolves when insertion finishes.

**Example Usage:**

```lua
    lia.db.bulkInsert("items", {
        { _invID = 1, _uniqueID = "pistol", _x = 0, _y = 0, _quantity = 1 },
        { _invID = 1, _uniqueID = "ammo", _x = 1, _y = 0, _quantity = 30 },
    })
```

---

### lia.db.insertOrIgnore

**Description:**

Inserts a row but ignores it if a unique constraint fails.

**Parameters:**

* `value` (`table`) – Column/value pairs to insert.

* `dbTable` (`string`) – Table name without the `lia_` prefix.

**Realm:**

* Server

**Returns:**

* deferred – Resolves with query results and last insert ID.

**Example Usage:**

```lua
    lia.db.insertOrIgnore({ id = 1, name = "Bob" }, "characters"):next(function(r)
        print("Insert ID:", r.lastID)
    end)
```

---

### lia.db.transaction

**Description:**

Runs multiple queries inside a transaction, rolling back on error.

**Parameters:**

* `queries` (`table`) – Array of SQL strings to execute.

**Realm:**

* Server

**Returns:**

* deferred – Resolves when the transaction completes.

**Example Usage:**

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

**Description:**

Escapes an identifier for use in manual SQL queries.

**Parameters:**

* `id` (`string`) – Identifier to escape.

**Realm:**

* Shared

**Returns:**

* string – The escaped identifier.

**Example Usage:**

```lua
    local col = lia.db.escapeIdentifier("desc")
    print(col)
```

---

### lia.db.prepare

**Description:**

Registers a prepared statement. Only available when using MySQLOO.

**Parameters:**

* `key` (`string`) – Identifier for the prepared statement.

* `query` (`string`) – SQL query string with placeholders.

* `types` (`table`) – Array of MySQLOO type constants.

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
    lia.db.prepare(
        "updateName",
        "UPDATE lia_characters SET _name = ? WHERE _id = ?",
        { MYSQLOO_STRING, MYSQLOO_INTEGER }
    )
```

---

### lia.db.preparedCall

**Description:**

Executes a prepared statement previously registered with `lia.db.prepare`.

**Parameters:**

* `key` (`string`) – Name of the prepared statement.

* `callback` (`function`) – Called with results and last insert ID.

* ... (variant) – Arguments for the placeholders.

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
    lia.db.preparedCall("updateName", nil, "Alice", 1)
```
---

### lia.db.query

**Description:**

Executes a raw SQL statement using the active backend. When no callback is
supplied a deferred object is returned.

**Parameters:**

* `query` (`string`) – SQL query string to execute.

* `callback` (`function`) – Optional function called with results and last insert ID.

**Realm:**

* Server

**Returns:**

* deferred|nil – Deferred results when no callback is provided.

**Example Usage:**

```lua
    lia.db.query("SELECT 1"):next(function(res)
        PrintTable(res.results)
    end)
```

---

### lia.db.escape

**Description:**

Escapes a string for safe use in manual SQL queries.

**Parameters:**

* `value` (`string`) – String to escape.

**Realm:**

* Shared

**Returns:**

* string – The escaped string.

**Example Usage:**

```lua
    local safe = lia.db.escape(userInput)
```

---

### lia.db.queue

**Description:**

Returns the number of queued queries waiting to be executed.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* number – Total count of queued queries.

**Example Usage:**

```lua
    print("Queue size:", lia.db.queue())
```

---

### lia.db.abort

**Description:**

Cancels all running queries on every connection in the pool.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
    lia.db.abort()
```

---

### lia.db.getObject

**Description:**

Returns the least busy database object along with its index in the pool.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* database, number – The connection object and its pool index.

**Example Usage:**

```lua
    local db = lia.db.getObject()
```
