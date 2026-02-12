# Database

Comprehensive database management system with SQLite support for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The database library provides comprehensive database management functionality for the Lilia framework. It handles all database operations including connection management, table creation and modification, data insertion, updates, queries, and schema management. The library supports SQLite as the primary database engine with extensible module support for other database systems. It includes advanced features such as prepared statements, transactions, bulk operations, data type conversion, and database snapshots for backup and restore operations. The library ensures data persistence across server restarts and provides robust error handling with deferred promise-based operations for asynchronous database queries. It manages core gamemode tables for players, characters, inventories, items, configuration, logs, and administrative data while supporting dynamic schema modifications.
</div>

---

<details class="realm-shared" id="function-liadbconnect">
<summary><a id="lia.db.connect"></a>lia.db.connect(callback, reconnect)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbconnect"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Establishes a connection to the database using the configured database module and initializes the query system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during gamemode initialization to set up the database connection, or when reconnecting to the database.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> Optional callback function to execute when the connection is established.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">reconnect</span> Optional flag to force reconnection even if already connected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.connect(function()
      print("Database connected successfully!")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbwipetables">
<summary><a id="lia.db.wipeTables"></a>lia.db.wipeTables(callback)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbwipetables"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Completely removes all Lilia-related database tables from the database.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when performing a complete data wipe/reset of the gamemode's database.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> Optional callback function to execute when all tables have been wiped.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.wipeTables(function()
      print("All Lilia tables have been wiped!")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbloadtables">
<summary><a id="lia.db.loadTables"></a>lia.db.loadTables()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbloadtables"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates all core Lilia database tables if they don't exist, including tables for players, characters, inventories, items, configuration, logs, and administrative data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during gamemode initialization to set up the database schema and prepare the database for use.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.loadTables()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbwaitfortablestoload">
<summary><a id="lia.db.waitForTablesToLoad"></a>lia.db.waitForTablesToLoad()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbwaitfortablestoload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns a deferred promise that resolves when all database tables have finished loading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when code needs to wait for database tables to be fully initialized before proceeding with database operations.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves when tables are loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.waitForTablesToLoad():next(function()
      -- Database tables are now ready
      lia.db.select("*", "characters"):next(function(results)
          print("Characters loaded:", #results)
      end)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbconvertdatatype">
<summary><a id="lia.db.convertDataType"></a>lia.db.convertDataType(value, noEscape)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbconvertdatatype"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Converts Lua data types to SQL-compatible string formats for database queries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Automatically called when building SQL queries to ensure proper data type conversion.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The value to convert (string, number, boolean, table, nil).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noEscape</span> Optional flag to skip SQL escaping for strings and tables.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> The converted value as a SQL-compatible string.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local sqlValue = lia.db.convertDataType("John's Name")
  -- Returns: "'John''s Name'" (properly escaped)
  local sqlValue2 = lia.db.convertDataType({health = 100})
  -- Returns: "'{\"health\":100}'" (JSON encoded and escaped)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbinserttable">
<summary><a id="lia.db.insertTable"></a>lia.db.insertTable(value, callback, dbTable)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbinserttable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts a new row into the specified database table with the provided data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when adding new records to database tables such as characters, items, or player data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">value</span> Table containing column-value pairs to insert.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> Optional callback function called with (results, lastID) when the query completes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Optional table name (defaults to "characters" if not specified).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.insertTable({
      steamID = "STEAM_0:1:12345678",
      name = "John Doe",
      money = "1000"
  }, function(results, lastID)
      print("Character created with ID:", lastID)
  end, "characters"):next(function(result)
      print("Insert completed, last ID:", result.lastID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbupdatetable">
<summary><a id="lia.db.updateTable"></a>lia.db.updateTable(value, callback, dbTable, condition)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbupdatetable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Updates existing rows in the specified database table with the provided data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when modifying existing records in database tables such as updating character data or player information.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">value</span> Table containing column-value pairs to update.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> Optional callback function called with (results, lastID) when the query completes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Optional table name without "lia_" prefix (defaults to "characters" if not specified).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">condition</span> Optional WHERE condition to specify which rows to update.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Update character money
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
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbselect">
<summary><a id="lia.db.select"></a>lia.db.select(fields, dbTable, condition, limit)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbselect"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Selects data from the specified database table with optional conditions and limits.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when retrieving data from database tables such as fetching character information or player data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">fields</span> Fields to select - either "*" for all fields, a string field name, or table of field names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix (defaults to "characters" if not specified).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">condition</span> Optional WHERE condition to filter results.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">limit</span> Optional LIMIT clause to restrict number of results.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Select all characters
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
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbselectwithcondition">
<summary><a id="lia.db.selectWithCondition"></a>lia.db.selectWithCondition(fields, dbTable, conditions, limit, orderBy)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbselectwithcondition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Selects data from the specified database table with complex conditions and optional ordering.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing advanced query conditions with operator support and ordering.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">fields</span> Fields to select - either "*" for all fields, a string field name, or table of field names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">conditions</span> WHERE conditions - can be a string or table with field-operator-value structures.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">limit</span> Optional LIMIT clause to restrict number of results.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">orderBy</span> Optional ORDER BY clause for sorting results.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Select with complex conditions and ordering
  lia.db.selectWithCondition("*", "characters", {
      money = {operator = "&gt;", value = 1000},
      faction = "citizen"
  }, 10, "name ASC"):next(function(result)
      print("Found", #result.results, "rich citizens")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbcount">
<summary><a id="lia.db.count"></a>lia.db.count(dbTable, condition)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbcount"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Counts the number of rows in the specified database table that match the given condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing to determine how many records exist in a table, such as counting characters or items.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">condition</span> Optional WHERE condition to filter which rows to count.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with the count as a number.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Count all characters
  lia.db.count("characters"):next(function(count)
      print("Total characters:", count)
  end)
  -- Count characters for a specific player
  lia.db.count("characters", {steamID = "STEAM_0:1:12345678"}):next(function(count)
      print("Player has", count, "characters")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbadddatabasefields">
<summary><a id="lia.db.addDatabaseFields"></a>lia.db.addDatabaseFields()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbadddatabasefields"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Dynamically adds missing database fields to the characters table based on character variable definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during database initialization to ensure all character variables have corresponding database columns.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.addDatabaseFields()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbexists">
<summary><a id="lia.db.exists"></a>lia.db.exists(dbTable, condition)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbexists"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if any records exist in the specified table that match the given condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called to verify the existence of records before performing operations.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">condition</span> WHERE condition to check for record existence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if records exist, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.exists("characters", {steamID = "STEAM_0:1:12345678"}):next(function(exists)
      if exists then
          print("Player has characters")
      else
          print("Player has no characters")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbselectone">
<summary><a id="lia.db.selectOne"></a>lia.db.selectOne(fields, dbTable, condition)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbselectone"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Selects a single row from the specified database table that matches the given condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when retrieving a specific record from database tables, such as finding a character by ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">fields</span> Fields to select - either "*" for all fields, a string field name, or table of field names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">condition</span> Optional WHERE condition to filter results.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with the first matching row as a table, or nil if no rows found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Get character by ID
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
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbbulkinsert">
<summary><a id="lia.db.bulkInsert"></a>lia.db.bulkInsert(dbTable, rows)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbbulkinsert"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts multiple rows into the specified database table in a single query for improved performance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when inserting large amounts of data at once, such as bulk importing items or characters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">rows</span> Array of row data tables, where each table contains column-value pairs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves when the bulk insert completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local items = {
      {uniqueID = "item1", invID = 1, quantity = 5},
      {uniqueID = "item2", invID = 1, quantity = 3},
      {uniqueID = "item3", invID = 2, quantity = 1}
  }
  lia.db.bulkInsert("items", items):next(function()
      print("Bulk insert completed")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbbulkupsert">
<summary><a id="lia.db.bulkUpsert"></a>lia.db.bulkUpsert(dbTable, rows)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbbulkupsert"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Performs bulk insert or replace operations on multiple rows in a single query.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when bulk updating/inserting data where existing records should be replaced.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">rows</span> Array of row data tables to insert or replace.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves when the bulk upsert completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local data = {
      {id = 1, name = "Item 1", value = 100},
      {id = 2, name = "Item 2", value = 200}
  }
  lia.db.bulkUpsert("custom_items", data):next(function()
      print("Bulk upsert completed")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbinsertorignore">
<summary><a id="lia.db.insertOrIgnore"></a>lia.db.insertOrIgnore(value, dbTable)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbinsertorignore"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts a new row into the database table, but ignores the operation if a conflict occurs (such as duplicate keys).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when inserting data that might already exist, where duplicates should be silently ignored.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">value</span> Table containing column-value pairs to insert.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Optional table name without "lia_" prefix (defaults to "characters").</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.insertOrIgnore({
      steamID = "STEAM_0:1:12345678",
      name = "Player Name"
  }, "players"):next(function(result)
      print("Player record inserted or already exists")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbtableexists">
<summary><a id="lia.db.tableExists"></a>lia.db.tableExists(tbl)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbtableexists"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if a database table with the specified name exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called before performing operations on tables to verify they exist, or when checking schema state.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tbl</span> The table name to check for existence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if the table exists, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.tableExists("lia_characters"):next(function(exists)
      if exists then
          print("Characters table exists")
      else
          print("Characters table does not exist")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbfieldexists">
<summary><a id="lia.db.fieldExists"></a>lia.db.fieldExists(tbl, field)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbfieldexists"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if a column/field with the specified name exists in the given database table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called before accessing table columns to verify they exist, or when checking schema modifications.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tbl</span> The table name to check (should include "lia_" prefix).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">field</span> The field/column name to check for existence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if the field exists, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.fieldExists("lia_characters", "custom_field"):next(function(exists)
      if exists then
          print("Custom field exists")
      else
          print("Custom field does not exist")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbgettables">
<summary><a id="lia.db.getTables"></a>lia.db.getTables()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbgettables"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves a list of all Lilia database tables (tables starting with "lia_").</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing to enumerate all database tables, such as for maintenance operations or schema inspection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with an array of table names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.getTables():next(function(tables)
      print("Lilia tables:")
      for _, tableName in ipairs(tables) do
          print("-", tableName)
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbtransaction">
<summary><a id="lia.db.transaction"></a>lia.db.transaction(queries)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbtransaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Executes multiple database queries as an atomic transaction - either all queries succeed or all are rolled back.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when performing multiple related database operations that must be atomic, such as transferring items between inventories.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">queries</span> Array of SQL query strings to execute in sequence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves when the transaction completes successfully, or rejects if any query fails.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local queries = {
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
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbescapeidentifier">
<summary><a id="lia.db.escapeIdentifier"></a>lia.db.escapeIdentifier(id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbescapeidentifier"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Escapes SQL identifiers (table and column names) by wrapping them in backticks and escaping any backticks within.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Automatically called when building SQL queries to safely handle identifiers that might contain special characters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">id</span> The identifier (table name, column name, etc.) to escape.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> The escaped identifier wrapped in backticks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local escaped = lia.db.escapeIdentifier("user_name")
  -- Returns: "`user_name`"
  local escaped2 = lia.db.escapeIdentifier("table`with`ticks")
  -- Returns: "`table``with``ticks`"
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbupsert">
<summary><a id="lia.db.upsert"></a>lia.db.upsert(value, dbTable)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbupsert"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts a new row into the database table, or replaces the existing row if it already exists (SQLite UPSERT operation).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to ensure a record exists with specific data, regardless of whether it was previously created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">value</span> Table containing column-value pairs to insert or update.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Optional table name without "lia_" prefix (defaults to "characters" if not specified).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Ensure a character exists with this data
  lia.db.upsert({
      id = 123,
      steamID = "STEAM_0:1:12345678",
      name = "John Doe",
      money = "1000"
  }, "characters"):next(function(result)
      print("Character upserted, last ID:", result.lastID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbdelete">
<summary><a id="lia.db.delete"></a>lia.db.delete(dbTable, condition)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbdelete"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Deletes rows from the specified database table that match the given condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when removing records from database tables, such as deleting characters or cleaning up old data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table name without "lia_" prefix (defaults to "character" if not specified).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">condition</span> WHERE condition to specify which rows to delete.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with {results = results, lastID = lastID}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Delete a specific character
  lia.db.delete("characters", {id = 123}):next(function()
      print("Character deleted")
  end)
  -- Delete all characters for a player
  lia.db.delete("characters", {steamID = "STEAM_0:1:12345678"}):next(function()
      print("All player characters deleted")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbcreatetable">
<summary><a id="lia.db.createTable"></a>lia.db.createTable(dbName, primaryKey, schema)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbcreatetable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a new database table with the specified schema definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when creating custom tables for modules or extending the database schema.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbName</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">primaryKey</span> Optional name of the primary key column.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">schema</span> Array of column definitions with name, type, not_null, and default properties.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true when the table is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local schema = {
      {name = "id", type = "integer", not_null = true},
      {name = "name", type = "string", not_null = true},
      {name = "value", type = "integer", default = 0}
  }
  lia.db.createTable("custom_data", "id", schema):next(function()
      print("Custom table created")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbcreatecolumn">
<summary><a id="lia.db.createColumn"></a>lia.db.createColumn(tableName, columnName, columnType, defaultValue)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbcreatecolumn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adds a new column to an existing database table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when extending database schema by adding new fields to existing tables.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tableName</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">columnName</span> Name of the new column to add.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">columnType</span> SQL data type for the column (e.g., "VARCHAR(255)", "INTEGER", "TEXT").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">defaultValue</span> Optional default value for the new column.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if column was added, false if it already exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.createColumn("characters", "custom_field", "VARCHAR(100)", "default_value"):next(function(success)
      if success then
          print("Column added successfully")
      else
          print("Column already exists")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbremovetable">
<summary><a id="lia.db.removeTable"></a>lia.db.removeTable(tableName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbremovetable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes a database table from the database.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when cleaning up or removing custom tables from the database schema.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tableName</span> Table name without "lia_" prefix.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if table was removed, false if it doesn't exist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.removeTable("custom_data"):next(function(success)
      if success then
          print("Table removed successfully")
      else
          print("Table does not exist")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbremovecolumn">
<summary><a id="lia.db.removeColumn"></a>lia.db.removeColumn(tableName, columnName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbremovecolumn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes a column from an existing database table by recreating the table without the specified column.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when removing fields from database tables during schema cleanup or refactoring.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tableName</span> Table name without "lia_" prefix.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">columnName</span> Name of the column to remove.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves to true if column was removed, false if table/column doesn't exist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.removeColumn("characters", "old_field"):next(function(success)
      if success then
          print("Column removed successfully")
      else
          print("Column or table does not exist")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbgetcharactertable">
<summary><a id="lia.db.getCharacterTable"></a>lia.db.getCharacterTable(callback)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbgetcharactertable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves the column information/schema for the characters table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing to inspect the structure of the characters table for schema operations.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> Function to call with the array of column names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.getCharacterTable(function(columns)
      print("Character table columns:")
      for _, column in ipairs(columns) do
          print("-", column)
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbcreatesnapshot">
<summary><a id="lia.db.createSnapshot"></a>lia.db.createSnapshot(tableName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbcreatesnapshot"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a backup snapshot of all data in the specified table and saves it to a JSON file.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called for backup purposes before major data operations or schema changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tableName</span> Table name without "lia_" prefix.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with snapshot info {file = filename, path = filepath, records = count}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.createSnapshot("characters"):next(function(snapshot)
      print("Snapshot created:", snapshot.file, "with", snapshot.records, "records")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadbloadsnapshot">
<summary><a id="lia.db.loadSnapshot"></a>lia.db.loadSnapshot(fileName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbloadsnapshot"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads data from a snapshot file and restores it to the corresponding database table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called to restore database tables from backup snapshots.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fileName</span> Name of the snapshot file to load.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A promise that resolves with restore info {table = tableName, records = count, timestamp = timestamp}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.loadSnapshot("snapshot_characters_1640995200.json"):next(function(result)
      print("Restored", result.records, "records to", result.table)
  end)
</code></pre>
</div>

</div>
</details>

---

