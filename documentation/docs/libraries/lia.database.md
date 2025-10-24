# Database Library

Comprehensive database management system with SQLite support for the Lilia framework.

---

## Overview

The database library provides comprehensive database management functionality for the Lilia framework.

It handles all database operations including connection management, table creation and modification,

data insertion, updates, queries, and schema management. The library supports SQLite as the primary

database engine with extensible module support for other database systems. It includes advanced features

such as prepared statements, transactions, bulk operations, data type conversion, and database

snapshots for backup and restore operations. The library ensures data persistence across server

restarts and provides robust error handling with deferred promise-based operations for asynchronous

database queries. It manages core gamemode tables for players, characters, inventories, items,

configuration, logs, and administrative data while supporting dynamic schema modifications.

---

### connect

**Purpose**

Establishes a connection to the database using the configured database module

**When Called**

During server startup, module initialization, or when reconnecting to database

**Parameters**

* `callback` (*function, optional*): Function to call after successful connection
* `reconnect` (*boolean, optional*): Force reconnection even if already connected

---

### wipeTables

**Purpose**

Removes all Lilia database tables and their data from the database

**When Called**

During database reset operations, development testing, or administrative cleanup

**Parameters**

* `callback` (*function, optional*): Function to call after all tables are wiped
* `lia.db.loadTables()` (*unknown*): - Reload empty tables

---

### loadTables

**Purpose**

Creates all core Lilia database tables if they don't exist and initializes the database schema

**When Called**

During server startup after database connection, or when initializing a new database

---

### waitForTablesToLoad

**Purpose**

Returns a deferred promise that resolves when database tables have finished loading

**When Called**

Before performing database operations that require tables to be loaded

---

### convertDataType

**Purpose**

Converts Lua values to SQL-compatible format with proper escaping and type handling

**When Called**

Internally by database functions when preparing data for SQL queries

**Parameters**

* `value` (*any*): The value to convert to SQL format
* `noEscape` (*boolean, optional*): Skip escaping for raw SQL values

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

---

### count

**Purpose**

Counts the number of records in a database table matching specified conditions

**When Called**

When checking record counts for statistics, validation, or pagination

**Parameters**

* `dbTable` (*string*): Table name without 'lia_' prefix
* `condition` (*table/string, optional*): WHERE clause conditions for counting

---

### addDatabaseFields

**Purpose**

Dynamically adds new columns to the lia_characters table based on character variables

**When Called**

During database initialization to ensure character table has all required fields

**Parameters**

* `lia.db.loadTables()` (*unknown*): - This automatically calls addDatabaseFields()

---

### exists

**Purpose**

Checks if any records exist in a database table matching specified conditions

**When Called**

When validating data existence before operations or for conditional logic

**Parameters**

* `dbTable` (*string*): Table name without 'lia_' prefix
* `condition` (*table/string, optional*): WHERE clause conditions for checking existence

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

---

### bulkInsert

**Purpose**

Inserts multiple records into a database table in a single operation for better performance

**When Called**

When inserting large amounts of data like inventory items, logs, or batch operations

**Parameters**

* `dbTable` (*string*): Table name without 'lia_' prefix
* `rows` (*table*): Array of tables containing the data to insert

---

### bulkUpsert

**Purpose**

Performs bulk INSERT OR REPLACE operations for updating existing records or inserting new ones

**When Called**

When synchronizing data that may already exist, like configuration updates or data imports

**Parameters**

* `dbTable` (*string*): Table name without 'lia_' prefix
* `rows` (*table*): Array of tables containing the data to upsert

---

### insertOrIgnore

**Purpose**

Inserts a record into a database table, ignoring the operation if it would cause a constraint violation

**When Called**

When inserting data that may already exist, like unique configurations or duplicate-safe operations

**Parameters**

* `value` (*table*): Key-value pairs representing the data to insert
* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'characters')

---

### tableExists

**Purpose**

Checks if a database table exists in the current database

**When Called**

When validating table existence before operations or during schema validation

**Parameters**

* `tbl` (*string*): Table name to check for existence

---

### fieldExists

**Purpose**

Checks if a specific field/column exists in a database table

**When Called**

When validating column existence before operations or during schema migrations

**Parameters**

* `tbl` (*string*): Table name to check
* `field` (*string*): Field/column name to check for existence

---

### getTables

**Purpose**

Retrieves a list of all Lilia database tables in the current database

**When Called**

When auditing database structure, generating reports, or managing tables

**Parameters**

* `print("` (*unknown*): " .. tableName)

---

### transaction

**Purpose**

Executes multiple database queries as a single atomic transaction with rollback on failure

**When Called**

When performing complex operations that must succeed or fail together

**Parameters**

* `queries` (*table*): Array of SQL query strings to execute in sequence

---

### escapeIdentifier

**Purpose**

Escapes database identifiers (table names, column names) to prevent SQL injection

**When Called**

Internally by database functions when building SQL queries with dynamic identifiers

**Parameters**

* `id` (*string*): Identifier to escape (table name, column name, etc.)

---

### upsert

**Purpose**

Inserts a new record or updates an existing one based on primary key conflicts

**When Called**

When synchronizing data that may already exist, like configuration updates or data imports

**Parameters**

* `value` (*table*): Key-value pairs representing the data to upsert
* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'characters')

---

### delete

**Purpose**

Deletes records from a database table based on specified conditions

**When Called**

When removing data like deleted characters, expired items, or cleanup operations

**Parameters**

* `dbTable` (*string, optional*): Table name without 'lia_' prefix (defaults to 'character')
* `condition` (*table/string, optional*): WHERE clause conditions for the deletion

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

---

### removeTable

**Purpose**

Removes a database table and all its data from the database

**When Called**

When cleaning up unused tables, removing modules, or during database maintenance

**Parameters**

* `tableName` (*string*): Table name without 'lia_' prefix

---

### removeColumn

**Purpose**

Removes a column from an existing database table using table recreation

**When Called**

When removing unused columns, cleaning up schemas, or during database migrations

**Parameters**

* `tableName` (*string*): Table name without 'lia_' prefix
* `columnName` (*string*): Name of the column to remove

---

### getCharacterTable

**Purpose**

Retrieves the column information for the lia_characters table

**When Called**

When analyzing character table structure, generating reports, or during schema validation

**Parameters**

* `callback` (*function*): Function to call with the column information array
* `print("` (*unknown*): " .. column)

---

### createSnapshot

**Purpose**

Creates a backup snapshot of a database table and saves it to a JSON file

**When Called**

When backing up data before major operations, creating restore points, or archiving data

**Parameters**

* `tableName` (*string*): Table name without 'lia_' prefix

---

### loadSnapshot

**Purpose**

Restores a database table from a previously created snapshot file

**When Called**

When restoring data from backups, recovering from errors, or migrating data

**Parameters**

* `fileName` (*string*): Name of the snapshot file to load

---

### lia.GM:RegisterPreparedStatements

**Purpose**

Restores a database table from a previously created snapshot file

**When Called**

When restoring data from backups, recovering from errors, or migrating data

**Parameters**

* `fileName` (*string*): Name of the snapshot file to load

---

### lia.GM:SetupDatabase

**Purpose**

Restores a database table from a previously created snapshot file

**When Called**

When restoring data from backups, recovering from errors, or migrating data

**Parameters**

* `fileName` (*string*): Name of the snapshot file to load

---

### lia.GM:DatabaseConnected

**Purpose**

Restores a database table from a previously created snapshot file

**When Called**

When restoring data from backups, recovering from errors, or migrating data

**Parameters**

* `fileName` (*string*): Name of the snapshot file to load

---

