<style>
details > summary {
    position: relative;
    display: flex;
    align-items: center;
    min-height: 70px;
    padding-right: 180px;
}

details > summary .summary-main {
    min-width: 0;
}

details > summary .source-link-button--summary {
    position: absolute;
    right: 56px;
    top: 50%;
    transform: translateY(-50%);
    white-space: nowrap;
    z-index: 2;
}
</style>

# Database

Database helpers for Lilia storage module setup, schema creation, SQL value conversion, table queries, migrations, transactions, and snapshot import/export.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The database library centralizes server-side persistence under `lia.db`. It initializes the active storage module, queues queries until the database is connected, creates core Lilia tables, adds missing character and warning fields, provides convenience helpers for selecting, inserting, updating, deleting, counting, and checking records, and supports administrative schema and snapshot utilities.
</div>

---

<details class="realm-server" id="function-liadbconnect">
<summary><span class="summary-main"><a id="lia.db.connect"></a>lia.db.connect(callback, reconnect)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L194" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbconnect"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Connects the configured database module, marks the database as connected, assigns the module query and escape functions, and flushes queued queries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional function called after the database module finishes connecting.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">reconnect</span> <span class="optional">optional</span> When true, allows the connection routine to run even if the database was previously marked as connected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.connect(function()
      lia.db.loadTables()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbwipetables">
<summary><span class="summary-main"><a id="lia.db.wipeTables"></a>lia.db.wipeTables(callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L237" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbwipetables"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Drops every SQLite table whose name starts with `lia_`, logs the wiped tables, and then runs an optional callback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional function called after all matching tables have been dropped.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.wipeTables(function()
      lia.db.loadTables()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbloadtables">
<summary><span class="summary-main"><a id="lia.db.loadTables"></a>lia.db.loadTables()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L282" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbloadtables"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates the core Lilia database tables, adds missing database fields, marks tables as loaded, runs database load hooks, and schedules configuration, interaction, and item synchronization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.loadTables()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbwaitfortablestoload">
<summary><span class="summary-main"><a id="lia.db.waitForTablesToLoad"></a>lia.db.waitForTablesToLoad()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L473" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbwaitfortablestoload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns a deferred object that resolves immediately if tables are already loaded, or resolves when `OnDatabaseLoaded` runs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves after database tables are available.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.waitForTablesToLoad():next(function()
      print("Tables are ready")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbconvertdatatype">
<summary><span class="summary-main"><a id="lia.db.convertDataType"></a>lia.db.convertDataType(value, noEscape)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L553" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbconvertdatatype"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Converts Lua values into SQL-safe literal values used when constructing database queries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The value to convert. Strings and tables are escaped unless `noEscape` is true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noEscape</span> <span class="optional">optional</span> When true, string and table values are returned without SQL escaping or quoting.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> The converted SQL literal, numeric boolean value, NULL literal, or original numeric value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local value = lia.db.convertDataType({enabled = true})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbinserttable">
<summary><span class="summary-main"><a id="lia.db.insertTable"></a>lia.db.insertTable(value, Key, Key, callback, dbTable)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L602" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbinserttable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts a row into a `lia_` database table and resolves with the query results and last inserted row ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">value</span> Key-value pairs to insert into the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Key</span> value pairs to insert into the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Key</span> value pairs to insert into the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional function called with `results` and `lastID` after the insert query completes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> <span class="optional">optional</span> Table suffix to insert into. Defaults to `characters`, producing `lia_characters`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with a table containing `results` and `lastID`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.insertTable({steamID = client:SteamID(), steamName = client:Name()}, nil, "players")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbupdatetable">
<summary><span class="summary-main"><a id="lia.db.updateTable"></a>lia.db.updateTable(value, Key, Key, callback, dbTable, condition)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L644" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbupdatetable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Updates rows in a `lia_` database table using the supplied values and optional condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">value</span> Key-value pairs to assign in the update statement.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Key</span> value pairs to assign in the update statement.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Key</span> value pairs to assign in the update statement.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional function called with `results` and `lastID` after the update query completes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> <span class="optional">optional</span> Table suffix to update. Defaults to `characters`, producing `lia_characters`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">condition</span> <span class="optional">optional</span> Optional WHERE clause as a raw string or a table of field comparisons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with a table containing `results` and `lastID`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.updateTable({lastOnline = os.time()}, nil, "players", {steamID = client:SteamID()})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbselect">
<summary><span class="summary-main"><a id="lia.db.select"></a>lia.db.select(fields, dbTable, condition, limit)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L686" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbselect"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Selects rows from a `lia_` database table with optional conditions and result limiting.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">fields</span> Field list to select, or `*` for all fields.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> <span class="optional">optional</span> Table suffix to select from. Defaults to `characters`, producing `lia_characters`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">condition</span> <span class="optional">optional</span> Optional WHERE clause as a raw string or a table of field comparisons.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">limit</span> <span class="optional">optional</span> Optional SQL LIMIT value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with a table containing `results` and `lastID`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.select({"id", "name"}, "characters", {steamID = client:SteamID()}, 1)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbselectwithcondition">
<summary><span class="summary-main"><a id="lia.db.selectWithCondition"></a>lia.db.selectWithCondition(fields, dbTable, conditions, limit, orderBy)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L739" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbselectwithcondition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Selects rows from a `lia_` database table using optional conditions, ordering, and result limiting.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">fields</span> Field list to select, or `*` for all fields.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> <span class="optional">optional</span> Table suffix to select from. Defaults to `characters`, producing `lia_characters`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">conditions</span> <span class="optional">optional</span> Optional WHERE clause as a raw string or a table of field comparisons.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">limit</span> <span class="optional">optional</span> Optional SQL LIMIT value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">orderBy</span> <span class="optional">optional</span> Optional SQL ORDER BY expression.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with a table containing `results` and `lastID`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.selectWithCondition("*", "logs", {category = "admin"}, 25, "timestamp DESC")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbcount">
<summary><span class="summary-main"><a id="lia.db.count"></a>lia.db.count(dbTable, condition)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L807" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbcount"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Counts rows in a `lia_` database table that match an optional condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table suffix to count from, producing `lia_<dbTable>`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">condition</span> <span class="optional">optional</span> Optional WHERE clause as a raw string or a table of field comparisons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with the numeric row count.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.count("characters", {steamID = client:SteamID()}):next(function(total)
      print(total)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbadddatabasefields">
<summary><span class="summary-main"><a id="lia.db.addDatabaseFields"></a>lia.db.addDatabaseFields()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L839" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbadddatabasefields"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adds missing database columns for character variables defined in `lia.char.vars` and ensures the warnings table has a severity column.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.addDatabaseFields()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbensureindexes">
<summary><span class="summary-main"><a id="lia.db.ensureIndexes"></a>lia.db.ensureIndexes()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L886" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbensureindexes"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates indexes for the highest-traffic lookup paths used during player join and character switching.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.waitForTablesToLoad():next(function()
      lia.db.ensureIndexes()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbexists">
<summary><span class="summary-main"><a id="lia.db.exists"></a>lia.db.exists(dbTable, condition)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L918" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbexists"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether at least one row exists in a `lia_` database table for the supplied condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table suffix to check, producing `lia_<dbTable>`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">condition</span> <span class="optional">optional</span> Optional WHERE clause as a raw string or a table of field comparisons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with true when at least one matching row exists, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.exists("players", {steamID = client:SteamID()}):next(function(found)
      print(found)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbselectone">
<summary><span class="summary-main"><a id="lia.db.selectOne"></a>lia.db.selectOne(fields, dbTable, condition)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L950" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbselectone"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Selects the first row from a `lia_` database table that matches an optional condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">fields</span> Field list to select, or `*` for all fields.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table suffix to select from, producing `lia_<dbTable>`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">condition</span> <span class="optional">optional</span> Optional WHERE clause as a raw string or a table of field comparisons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with the first result row, or nil when no row matches.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.selectOne("*", "players", {steamID = client:SteamID()}):next(function(row)
      PrintTable(row or {})
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbbulkinsert">
<summary><span class="summary-main"><a id="lia.db.bulkInsert"></a>lia.db.bulkInsert(dbTable, rows)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L998" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbbulkinsert"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts multiple rows into a `lia_` database table with one multi-value INSERT query.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table suffix to insert into, producing `lia_<dbTable>`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">rows</span> Array of row tables to insert. Column names are taken from the first row.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves when the bulk insert finishes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.bulkInsert("logs", {
      {category = "server", message = "Started"},
      {category = "server", message = "Loaded"}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbbulkupsert">
<summary><span class="summary-main"><a id="lia.db.bulkUpsert"></a>lia.db.bulkUpsert(dbTable, rows)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1049" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbbulkupsert"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts or replaces multiple rows in a `lia_` database table with one multi-value INSERT OR REPLACE query.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> Table suffix to upsert into, producing `lia_<dbTable>`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">rows</span> Array of row tables to upsert. Column names are taken from the first row.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves when the bulk upsert finishes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.bulkUpsert("invdata", {
      {invID = 1, key = "width", value = "6"},
      {invID = 1, key = "height", value = "4"}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbinsertorignore">
<summary><span class="summary-main"><a id="lia.db.insertOrIgnore"></a>lia.db.insertOrIgnore(value, Key, Key, dbTable)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1097" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbinsertorignore"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts a row into a `lia_` database table only when it does not conflict with existing constraints.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">value</span> Key-value pairs to insert into the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Key</span> value pairs to insert into the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Key</span> value pairs to insert into the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> <span class="optional">optional</span> Table suffix to insert into. Defaults to `characters`, producing `lia_characters`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with a table containing `results` and `lastID`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.insertOrIgnore({usergroup = "admin", privileges = "{}"}, "admin")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbtableexists">
<summary><span class="summary-main"><a id="lia.db.tableExists"></a>lia.db.tableExists(tbl)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1139" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbtableexists"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a table exists in SQLite by its exact table name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tbl</span> Exact table name to check, such as `lia_characters`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with true when the table exists, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.tableExists("lia_characters"):next(function(exists)
      print(exists)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbfieldexists">
<summary><span class="summary-main"><a id="lia.db.fieldExists"></a>lia.db.fieldExists(tbl, field)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1171" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbfieldexists"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a column exists in a table using SQLite table information.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tbl</span> Exact table name to inspect, such as `lia_characters`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">field</span> Column name to find.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with true when the column exists, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.fieldExists("lia_characters", "money"):next(function(exists)
      print(exists)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbgettables">
<summary><span class="summary-main"><a id="lia.db.getTables"></a>lia.db.getTables()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1204" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbgettables"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all SQLite table names that start with `lia_`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with an array of matching table names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.getTables():next(function(tables)
      PrintTable(tables)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbtransaction">
<summary><span class="summary-main"><a id="lia.db.transaction"></a>lia.db.transaction(queries)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1240" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbtransaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs a list of SQL queries inside a transaction, committing when all queries pass and rolling back if any query fails.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">queries</span> Ordered array of SQL query strings to run.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves after COMMIT succeeds, or rejects after ROLLBACK on failure.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.transaction({
      "UPDATE lia_players SET userGroup = 'admin' WHERE steamID = 'STEAM_0:1:1'",
      "INSERT INTO lia_logs (category, message) VALUES ('admin', 'Promoted user')"
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbescapeidentifier">
<summary><span class="summary-main"><a id="lia.db.escapeIdentifier"></a>lia.db.escapeIdentifier(id)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1280" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbescapeidentifier"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Escapes a SQL identifier with backticks and doubles embedded backticks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">id</span> Identifier value to convert into a safely quoted SQL identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Backtick-quoted SQL identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local field = lia.db.escapeIdentifier("steamID")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbupsert">
<summary><span class="summary-main"><a id="lia.db.upsert"></a>lia.db.upsert(value, Key, Key, dbTable)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1307" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbupsert"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inserts or replaces a row in a `lia_` database table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">value</span> Key-value pairs to insert or replace in the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Key</span> value pairs to insert or replace in the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Key</span> value pairs to insert or replace in the target table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> <span class="optional">optional</span> Table suffix to upsert into. Defaults to `characters`, producing `lia_characters`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with a table containing `results` and `lastID`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.upsert({id = 1, name = "Example"}, "characters")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbdelete">
<summary><span class="summary-main"><a id="lia.db.delete"></a>lia.db.delete(dbTable, condition)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1342" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbdelete"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Deletes rows from a `lia_` database table using an optional condition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbTable</span> <span class="optional">optional</span> Table suffix to delete from. Defaults to `character`, producing `lia_character`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">condition</span> <span class="optional">optional</span> Optional WHERE clause as a raw string or a table of field comparisons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with a table containing `results` and `lastID`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.delete("characters", {id = 5})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbcreatetable">
<summary><span class="summary-main"><a id="lia.db.createTable"></a>lia.db.createTable(dbName, primaryKey, schema)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1384" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbcreatetable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a `lia_` prefixed table from a schema definition when it does not already exist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dbName</span> Table suffix to create, producing `lia_<dbName>`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">primaryKey</span> <span class="optional">optional</span> Optional primary key column name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">schema</span> Array of column definitions with `name`, `type`, optional `not_null`, and optional `default` fields.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with true when the create-table query completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.createTable("example", "id", {
      {name = "id", type = "integer", not_null = true},
      {name = "value", type = "text", default = ""}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbcreatecolumn">
<summary><span class="summary-main"><a id="lia.db.createColumn"></a>lia.db.createColumn(tableName, columnName, columnType, defaultValue)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1440" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbcreatecolumn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adds a column to a `lia_` prefixed table when the column does not already exist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tableName</span> Table suffix to alter, producing `lia_<tableName>`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">columnName</span> Column name to add.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">columnType</span> SQL column type to add.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">defaultValue</span> <span class="optional">optional</span> Optional default value for the new column.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with true when the column is added, or false when it already exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.createColumn("warnings", "notes", "text", "")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbremovetable">
<summary><span class="summary-main"><a id="lia.db.removeTable"></a>lia.db.removeTable(tableName)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1487" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbremovetable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Drops a `lia_` prefixed table when it exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tableName</span> Table suffix to remove, producing `lia_<tableName>`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with true when the table is dropped, or false when it does not exist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.removeTable("example")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbremovecolumn">
<summary><span class="summary-main"><a id="lia.db.removeColumn"></a>lia.db.removeColumn(tableName, columnName)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1525" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbremovecolumn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes a column from a `lia_` prefixed table by rebuilding the table without that column.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tableName</span> Table suffix to alter, producing `lia_<tableName>`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">columnName</span> Column name to remove.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with true when the column is removed, false when the table or column does not exist, or rejects when removal is not possible.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.removeColumn("warnings", "notes")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbgetcharactertable">
<summary><span class="summary-main"><a id="lia.db.getCharacterTable"></a>lia.db.getCharacterTable(callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1595" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbgetcharactertable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves the column names from the `lia_characters` table and passes them to a callback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> Function called with an array of character table column names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.getCharacterTable(function(columns)
      PrintTable(columns)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbcreatesnapshot">
<summary><span class="summary-main"><a id="lia.db.createSnapshot"></a>lia.db.createSnapshot(tableName)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1630" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbcreatesnapshot"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Saves all rows from a `lia_` prefixed table to a JSON snapshot file under `data/lilia/snapshots`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">tableName</span> Table suffix to snapshot, producing `lia_<tableName>`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with snapshot file name, path, and record count.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.createSnapshot("characters"):next(function(snapshot)
      print(snapshot.path)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadbloadsnapshot">
<summary><span class="summary-main"><a id="lia.db.loadSnapshot"></a>lia.db.loadSnapshot(fileName)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L1686" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadbloadsnapshot"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads a JSON snapshot from `data/lilia/snapshots`, clears the target table, and restores the snapshot rows in batches.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fileName</span> Snapshot file name to load from `lilia/snapshots`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with restored table name, record count, and snapshot timestamp.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.db.loadSnapshot("snapshot_characters_1700000000.json")
</code></pre>
</div>

</div>
</details>

---

<h2 style="margin-bottom: 5px;">Hooks</h2>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Library-specific hooks documented for this library.</p>
</div>

---

<details class="realm-server" id="function-ondatabaseloaded">
<summary><span class="summary-main"><a id="OnDatabaseLoaded"></a>OnDatabaseLoaded()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ondatabaseloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after core database tables finish loading, database fields are checked, `lia.db.tablesLoaded` is set, and follow-up configuration, interaction, and item synchronization timers are scheduled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Database</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnDatabaseLoaded", "liaExampleOnDatabaseLoaded", function()
      lia.db.selectOne("*", "players", nil, 1):next(function(row)
          PrintTable(row or {})
      end)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onloadtables">
<summary><span class="summary-main"><a id="OnLoadTables"></a>OnLoadTables()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/database.lua#L36" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onloadtables"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs immediately after the core table creation query is submitted by `lia.db.loadTables`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Database</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnLoadTables", "liaExampleOnLoadTables", function()
      print("Database table creation query was submitted.")
  end)
</code></pre>
</div>

</div>
</details>

---

