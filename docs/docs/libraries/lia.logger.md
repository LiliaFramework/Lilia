# Logger Library

This page documents logging utilities.

---

## Overview

The logger library writes structured log entries to files and the console. It

tracks important gameplay events for later auditing or debugging. All entries are

also saved in the `lia_logs` database table which stores the current gamemode,

log category, message text, character ID and SteamID when available.

Built‑in log types reside in

`modules/administration/submodules/logging/logs.lua` and custom types can be

registered with `lia.log.addType`.

### Fields

* **lia.log.isConverting** (boolean) – Set to `true` while

  `lia.log.convertToDatabase` is running. The server blocks player connections

  during this time.

---

### lia.log.loadTables

**Description:**

Initializes the logging system. Creates the logs directory for the current

active gamemode under `lilia/logs`, ensures the `lia_logs` SQL table exists and

automatically converts any legacy text logs if no entries are present.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
-- Called after the database has finished loading
hook.Add("LiliaDatabaseInitialized", nil, function()
    lia.log.loadTables()
end)
```

---

### lia.log.addType

**Description:**

Registers a new log type by associating a log generating function and a category with the log type identifier.

The registered function will be used later to generate log messages for that type.

**Parameters:**

* `logType` (`string`) – The unique identifier for the log type.


* `func` (`function`) – A function that takes a client and additional parameters, returning a log string.


* `category` (`string`) – The category for the log type, used for organizing log files.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
-- Define a new log type that records a player's custom action
lia.log.addType("mytype", function(client, action)
    return string.format("%s performed %s", client:Name(), action)
end, "Actions")

-- Somewhere later in code
lia.log.add(client, "mytype", "a backflip")
```

---

### lia.log.getString

**Description:**

Invokes the function registered for the given log type and returns the formatted

log string along with its category. Additional arguments are forwarded to the log

function.

**Parameters:**

* `client` (`Player`) – The client for which the log is generated.


* `logType` (`string`) – The identifier for the log type.


* ... (vararg) – Additional parameters passed to the log function.


**Realm:**

* Server


**Returns:**

* string, string – The generated log string and its category if successful; otherwise, nil.


**Example Usage:**

```lua
-- Retrieve a formatted string without writing it to file
local text, category = lia.log.getString(client, "mytype", "test")
print(category .. ": " .. text)
```

---

### lia.log.add

**Description:**

Generates a log string using the registered log type function, then triggers the

`OnServerLog` hook with `client`, `logType`, the produced text and its category.

The entry is written to both a log file and the `lia_logs` SQL table.

**Parameters:**

* `client` (`Player`) – The client associated with the log event.


* `logType` (`string`) – The identifier for the log type.


* ... (vararg) – Additional parameters passed to the log type function.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
-- Log a player's death
hook.Add("PlayerDeath", "ExampleDeathLog", function(victim, attacker)
    lia.log.add(victim, "playerDeath", attacker)
end)
```

---

### lia.log.convertToDatabase

**Description:**

Moves legacy log files from `data/lilia/logs` (including all gamemode subfolders)

into the `lia_logs` database table. Each imported entry records the gamemode,

category, log text, character ID and SteamID when possible.

While the conversion is running `lia.log.isConverting` is set and players are

prevented from joining the server. If `changeMap` is true, the current level will

reload after conversion completes.

**Parameters:**

* `changeMap` (`boolean`) – Whether to reload the current map when finished.

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
-- Convert legacy logs without changing the map
if not lia.log.isConverting then
    lia.log.convertToDatabase(false)
end
```

---

### lia_log_legacy_count

**Description:**

Console command that prints how many legacy log lines exist inside

`data/lilia/logs` and how many are valid for import. Run this from the server

console to estimate conversion time.

**Parameters:**

* None

**Realm:**

* `Server` (`Console`)

**Returns:**

* None

**Example Usage:**

```bash
lia_log_legacy_count
```
