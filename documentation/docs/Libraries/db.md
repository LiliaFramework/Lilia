# Database Library

Comprehensive database management system with SQLite support for the Lilia framework.

---

Overview

The database library provides comprehensive database management functionality for the Lilia framework. It handles all database operations including connection management, table creation and modification, data insertion, updates, queries, and schema management. The library supports SQLite as the primary database engine with extensible module support for other database systems. It includes advanced features such as prepared statements, transactions, bulk operations, data type conversion, and database snapshots for backup and restore operations. The library ensures data persistence across server restarts and provides robust error handling with deferred promise-based operations for asynchronous database queries. It manages core gamemode tables for players, characters, inventories, items, configuration, logs, and administrative data while supporting dynamic schema modifications.

---

<details class="realm-shared">
<summary><a id=lia.db.connect></a>lia.db.connect(callback, reconnect)</summary>
<a id="liadbconnect"></a>
<p>Establishes a connection to the database using the configured database module and initializes the query system.</p>
<p>Called during gamemode initialization to set up the database connection, or when reconnecting to the database.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Optional callback function to execute when the connection is established.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">reconnect</span> Optional flag to force reconnection even if already connected.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.connect(function()
        print("Database connected successfully!")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.wipeTables></a>lia.db.wipeTables(callback)</summary>
<a id="liadbwipetables"></a>
<p>Completely removes all Lilia-related database tables from the database.</p>
<p>Called when performing a complete data wipe/reset of the gamemode's database.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Optional callback function to execute when all tables have been wiped.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.wipeTables(function()
        print("All Lilia tables have been wiped!")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.loadTables></a>lia.db.loadTables()</summary>
<a id="liadbloadtables"></a>
<p>Creates all core Lilia database tables if they don't exist, including tables for players, characters, inventories, items, configuration, logs, and administrative data.</p>
<p>Called during gamemode initialization to set up the database schema and prepare the database for use.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.loadTables()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.waitForTablesToLoad></a>lia.db.waitForTablesToLoad()</summary>
<a id="liadbwaitfortablestoload"></a>
<p>Returns a deferred promise that resolves when all database tables have finished loading.</p>
<p>Called when code needs to wait for database tables to be fully initialized before proceeding with database operations.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves when tables are loaded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.waitForTablesToLoad():next(function()
        -- Database tables are now ready
        lia.db.select("*", "characters"):next(function(results)
            print("Characters loaded:", #results)
        end)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.convertDataType></a>lia.db.convertDataType(value, noEscape)</summary>
<a id="liadbconvertdatatype"></a>
<p>Converts Lua data types to SQL-compatible string formats for database queries.</p>
<p>Automatically called when building SQL queries to ensure proper data type conversion.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> The value to convert (string, number, boolean, table, nil).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noEscape</span> Optional flag to skip SQL escaping for strings and tables.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> The converted value as a SQL-compatible string.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local sqlValue = lia.db.convertDataType("John's Name")
    -- Returns: "'John''s Name'" (properly escaped)
    local sqlValue2 = lia.db.convertDataType({health = 100})
    -- Returns: "'{\"health\":100}'" (JSON encoded and escaped)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.insertTable></a>lia.db.insertTable(value, callback, dbTable)</summary>
<a id="liadbinserttable"></a>
<p>Inserts a new row into the specified database table with the provided data.</p>
<p>Called when adding new records to database tables such as characters, items, or player data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">value</span> Table containing column-value pairs to insert.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Optional callback function called with (results, lastID) when the query completes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Optional table name (defaults to "characters" if not specified).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.insertTable({
        steamID = "STEAM_0:1:12345678",
        name = "John Doe",
        money = "1000"
    }, function(results, lastID)
        print("Character created with ID:", lastID)
    end, "characters"):next(function(result)
        print("Insert completed, last ID:", result.lastID)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.updateTable></a>lia.db.updateTable(value, callback, dbTable, condition)</summary>
<a id="liadbupdatetable"></a>
<p>Updates existing rows in the specified database table with the provided data.</p>
<p>Called when modifying existing records in database tables such as updating character data or player information.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">value</span> Table containing column-value pairs to update.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Optional callback function called with (results, lastID) when the query completes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Optional table name without "lia_" prefix (defaults to "characters" if not specified).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">condition</span> Optional WHERE condition to specify which rows to update.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Update character money
    lia.db.updateTable({
        money = "500"
    }, nil, "characters", {id = 123}):next(function()
        print("Character money updated")
    end)
    -- Update with string condition
    lia.db.updateTable({
        lastJoin = os.date("%Y-%m-%d %H:%M:%S")
    }, nil, "players", "steamID = 'STEAM_0:1:12345678'")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.select></a>lia.db.select(fields, dbTable, condition, limit)</summary>
<a id="liadbselect"></a>
<p>Selects data from the specified database table with optional conditions and limits.</p>
<p>Called when retrieving data from database tables such as fetching character information or player data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|table</a></span> <span class="parameter">fields</span> Fields to select - either "*" for all fields, a string field name, or table of field names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix (defaults to "characters" if not specified).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">condition</span> Optional WHERE condition to filter results.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">limit</span> Optional LIMIT clause to restrict number of results.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Select all characters
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
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.selectWithCondition></a>lia.db.selectWithCondition(fields, dbTable, conditions, limit, orderBy)</summary>
<a id="liadbselectwithcondition"></a>
<p>Selects data from the specified database table with complex conditions and optional ordering.</p>
<p>Called when needing advanced query conditions with operator support and ordering.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|table</a></span> <span class="parameter">fields</span> Fields to select - either "*" for all fields, a string field name, or table of field names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">conditions</span> WHERE conditions - can be a string or table with field-operator-value structures.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">limit</span> Optional LIMIT clause to restrict number of results.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">orderBy</span> Optional ORDER BY clause for sorting results.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Select with complex conditions and ordering
    lia.db.selectWithCondition("*", "characters", {
        money = {operator = "&gt;", value = 1000},
        faction = "citizen"
    }, 10, "name ASC"):next(function(result)
        print("Found", #result.results, "rich citizens")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.count></a>lia.db.count(dbTable, condition)</summary>
<a id="liadbcount"></a>
<p>Counts the number of rows in the specified database table that match the given condition.</p>
<p>Called when needing to determine how many records exist in a table, such as counting characters or items.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">condition</span> Optional WHERE condition to filter which rows to count.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with the count as a number.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Count all characters
    lia.db.count("characters"):next(function(count)
        print("Total characters:", count)
    end)
    -- Count characters for a specific player
    lia.db.count("characters", {steamID = "STEAM_0:1:12345678"}):next(function(count)
        print("Player has", count, "characters")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.addDatabaseFields></a>lia.db.addDatabaseFields()</summary>
<a id="liadbadddatabasefields"></a>
<p>Dynamically adds missing database fields to the characters table based on character variable definitions.</p>
<p>Called during database initialization to ensure all character variables have corresponding database columns.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.addDatabaseFields()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.exists></a>lia.db.exists(dbTable, condition)</summary>
<a id="liadbexists"></a>
<p>Checks if any records exist in the specified table that match the given condition.</p>
<p>Called to verify the existence of records before performing operations.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">condition</span> WHERE condition to check for record existence.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if records exist, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.exists("characters", {steamID = "STEAM_0:1:12345678"}):next(function(exists)
        if exists then
            print("Player has characters")
        else
            print("Player has no characters")
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.selectOne></a>lia.db.selectOne(fields, dbTable, condition)</summary>
<a id="liadbselectone"></a>
<p>Selects a single row from the specified database table that matches the given condition.</p>
<p>Called when retrieving a specific record from database tables, such as finding a character by ID.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|table</a></span> <span class="parameter">fields</span> Fields to select - either "*" for all fields, a string field name, or table of field names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">condition</span> Optional WHERE condition to filter results.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with the first matching row as a table, or nil if no rows found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Get character by ID
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
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.bulkInsert></a>lia.db.bulkInsert(dbTable, rows)</summary>
<a id="liadbbulkinsert"></a>
<p>Inserts multiple rows into the specified database table in a single query for improved performance.</p>
<p>Called when inserting large amounts of data at once, such as bulk importing items or characters.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">rows</span> Array of row data tables, where each table contains column-value pairs.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves when the bulk insert completes.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local items = {
        {uniqueID = "item1", invID = 1, quantity = 5},
        {uniqueID = "item2", invID = 1, quantity = 3},
        {uniqueID = "item3", invID = 2, quantity = 1}
    }
    lia.db.bulkInsert("items", items):next(function()
        print("Bulk insert completed")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.bulkUpsert></a>lia.db.bulkUpsert(dbTable, rows)</summary>
<a id="liadbbulkupsert"></a>
<p>Performs bulk insert or replace operations on multiple rows in a single query.</p>
<p>Called when bulk updating/inserting data where existing records should be replaced.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">rows</span> Array of row data tables to insert or replace.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves when the bulk upsert completes.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local data = {
        {id = 1, name = "Item 1", value = 100},
        {id = 2, name = "Item 2", value = 200}
    }
    lia.db.bulkUpsert("custom_items", data):next(function()
        print("Bulk upsert completed")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.insertOrIgnore></a>lia.db.insertOrIgnore(value, dbTable)</summary>
<a id="liadbinsertorignore"></a>
<p>Inserts a new row into the database table, but ignores the operation if a conflict occurs (such as duplicate keys).</p>
<p>Called when inserting data that might already exist, where duplicates should be silently ignored.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">value</span> Table containing column-value pairs to insert.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Optional table name without "lia_" prefix (defaults to "characters").</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.insertOrIgnore({
        steamID = "STEAM_0:1:12345678",
        name = "Player Name"
    }, "players"):next(function(result)
        print("Player record inserted or already exists")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.tableExists></a>lia.db.tableExists(tbl)</summary>
<a id="liadbtableexists"></a>
<p>Checks if a database table with the specified name exists.</p>
<p>Called before performing operations on tables to verify they exist, or when checking schema state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">tbl</span> The table name to check for existence.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if the table exists, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.tableExists("lia_characters"):next(function(exists)
        if exists then
            print("Characters table exists")
        else
            print("Characters table does not exist")
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.fieldExists></a>lia.db.fieldExists(tbl, field)</summary>
<a id="liadbfieldexists"></a>
<p>Checks if a column/field with the specified name exists in the given database table.</p>
<p>Called before accessing table columns to verify they exist, or when checking schema modifications.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">tbl</span> The table name to check (should include "lia_" prefix).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">field</span> The field/column name to check for existence.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if the field exists, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.fieldExists("lia_characters", "custom_field"):next(function(exists)
        if exists then
            print("Custom field exists")
        else
            print("Custom field does not exist")
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.getTables></a>lia.db.getTables()</summary>
<a id="liadbgettables"></a>
<p>Retrieves a list of all Lilia database tables (tables starting with "lia_").</p>
<p>Called when needing to enumerate all database tables, such as for maintenance operations or schema inspection.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with an array of table names.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.getTables():next(function(tables)
        print("Lilia tables:")
        for _, tableName in ipairs(tables) do
            print("-", tableName)
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.transaction></a>lia.db.transaction(queries)</summary>
<a id="liadbtransaction"></a>
<p>Executes multiple database queries as an atomic transaction - either all queries succeed or all are rolled back.</p>
<p>Called when performing multiple related database operations that must be atomic, such as transferring items between inventories.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">queries</span> Array of SQL query strings to execute in sequence.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves when the transaction completes successfully, or rejects if any query fails.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local queries = {
        "UPDATE lia_characters SET money = money - 100 WHERE id = 1",
        "UPDATE lia_characters SET money = money + 100 WHERE id = 2",
        "INSERT INTO lia_logs (message) VALUES ('Money transfer completed')"
    }
    lia.db.transaction(queries):next(function()
        print("Transaction completed successfully")
    end):catch(function(err)
        print("Transaction failed:", err)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.escapeIdentifier></a>lia.db.escapeIdentifier(id)</summary>
<a id="liadbescapeidentifier"></a>
<p>Escapes SQL identifiers (table and column names) by wrapping them in backticks and escaping any backticks within.</p>
<p>Automatically called when building SQL queries to safely handle identifiers that might contain special characters.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">id</span> The identifier (table name, column name, etc.) to escape.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> The escaped identifier wrapped in backticks.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local escaped = lia.db.escapeIdentifier("user_name")
    -- Returns: "`user_name`"
    local escaped2 = lia.db.escapeIdentifier("table`with`ticks")
    -- Returns: "`table``with``ticks`"
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.upsert></a>lia.db.upsert(value, dbTable)</summary>
<a id="liadbupsert"></a>
<p>Inserts a new row into the database table, or replaces the existing row if it already exists (SQLite UPSERT operation).</p>
<p>Called when you want to ensure a record exists with specific data, regardless of whether it was previously created.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">value</span> Table containing column-value pairs to insert or update.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Optional table name without "lia_" prefix (defaults to "characters" if not specified).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Ensure a character exists with this data
    lia.db.upsert({
        id = 123,
        steamID = "STEAM_0:1:12345678",
        name = "John Doe",
        money = "1000"
    }, "characters"):next(function(result)
        print("Character upserted, last ID:", result.lastID)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.delete></a>lia.db.delete(dbTable, condition)</summary>
<a id="liadbdelete"></a>
<p>Deletes rows from the specified database table that match the given condition.</p>
<p>Called when removing records from database tables, such as deleting characters or cleaning up old data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix (defaults to "character" if not specified).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">condition</span> WHERE condition to specify which rows to delete.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Delete a specific character
    lia.db.delete("characters", {id = 123}):next(function()
        print("Character deleted")
    end)
    -- Delete all characters for a player
    lia.db.delete("characters", {steamID = "STEAM_0:1:12345678"}):next(function()
        print("All player characters deleted")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.createTable></a>lia.db.createTable(dbName, primaryKey, schema)</summary>
<a id="liadbcreatetable"></a>
<p>Creates a new database table with the specified schema definition.</p>
<p>Called when creating custom tables for modules or extending the database schema.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dbName</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">primaryKey</span> Optional name of the primary key column.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">schema</span> Array of column definitions with name, type, not_null, and default properties.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true when the table is created.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local schema = {
        {name = "id", type = "integer", not_null = true},
        {name = "name", type = "string", not_null = true},
        {name = "value", type = "integer", default = 0}
    }
    lia.db.createTable("custom_data", "id", schema):next(function()
        print("Custom table created")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.createColumn></a>lia.db.createColumn(tableName, columnName, columnType, defaultValue)</summary>
<a id="liadbcreatecolumn"></a>
<p>Adds a new column to an existing database table.</p>
<p>Called when extending database schema by adding new fields to existing tables.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">tableName</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">columnName</span> Name of the new column to add.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">columnType</span> SQL data type for the column (e.g., "VARCHAR(255)", "INTEGER", "TEXT").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">defaultValue</span> Optional default value for the new column.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if column was added, false if it already exists.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.createColumn("characters", "custom_field", "VARCHAR(100)", "default_value"):next(function(success)
        if success then
            print("Column added successfully")
        else
            print("Column already exists")
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.removeTable></a>lia.db.removeTable(tableName)</summary>
<a id="liadbremovetable"></a>
<p>Removes a database table from the database.</p>
<p>Called when cleaning up or removing custom tables from the database schema.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">tableName</span> Table name without "lia_" prefix.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if table was removed, false if it doesn't exist.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.removeTable("custom_data"):next(function(success)
        if success then
            print("Table removed successfully")
        else
            print("Table does not exist")
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.removeColumn></a>lia.db.removeColumn(tableName, columnName)</summary>
<a id="liadbremovecolumn"></a>
<p>Removes a column from an existing database table by recreating the table without the specified column.</p>
<p>Called when removing fields from database tables during schema cleanup or refactoring.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">tableName</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">columnName</span> Name of the column to remove.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if column was removed, false if table/column doesn't exist.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.removeColumn("characters", "old_field"):next(function(success)
        if success then
            print("Column removed successfully")
        else
            print("Column or table does not exist")
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.getCharacterTable></a>lia.db.getCharacterTable(callback)</summary>
<a id="liadbgetcharactertable"></a>
<p>Retrieves the column information/schema for the characters table.</p>
<p>Called when needing to inspect the structure of the characters table for schema operations.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Function to call with the array of column names.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.getCharacterTable(function(columns)
        print("Character table columns:")
        for _, column in ipairs(columns) do
            print("-", column)
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.createSnapshot></a>lia.db.createSnapshot(tableName)</summary>
<a id="liadbcreatesnapshot"></a>
<p>Creates a backup snapshot of all data in the specified table and saves it to a JSON file.</p>
<p>Called for backup purposes before major data operations or schema changes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">tableName</span> Table name without "lia_" prefix.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with snapshot info {file = filename, path = filepath, records = count}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.createSnapshot("characters"):next(function(snapshot)
        print("Snapshot created:", snapshot.file, "with", snapshot.records, "records")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.db.loadSnapshot></a>lia.db.loadSnapshot(fileName)</summary>
<a id="liadbloadsnapshot"></a>
<p>Loads data from a snapshot file and restores it to the corresponding database table.</p>
<p>Called to restore database tables from backup snapshots.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">fileName</span> Name of the snapshot file to load.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with restore info {table = tableName, records = count, timestamp = timestamp}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.db.loadSnapshot("snapshot_characters_1640995200.json"):next(function(result)
        print("Restored", result.records, "records to", result.table)
    end)
</code></pre>
</details>

---

