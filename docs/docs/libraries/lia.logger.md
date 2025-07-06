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

---

### lia.log.loadTables

**Purpose**

Initializes the logging system and converts any legacy text logs.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: Nothing.

**Example**

```lua
hook.Add("LiliaDatabaseInitialized", nil, function()
    lia.log.loadTables()
end)
```

---

### lia.log.addType

**Purpose**

Registers a new log type with a generating function and category.

**Parameters**

* `logType` (*string*): Unique identifier for the log type.
* `func` (*function*): Generates the log string.
* `category` (*string*): Category name used for log files.

**Realm**

`Server`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.log.addType("mytype", function(client, action)
    return string.format("%s performed %s", client:Name(), action)
end, "Actions")

lia.log.add(client, "mytype", "a backflip")
```

---

### lia.log.getString

**Purpose**

Returns the formatted log string and its category for a given log type.

**Parameters**

* `client` (*Player*): Player for which the log is generated.
* `logType` (*string*): Identifier for the log type.
* ...: Additional parameters passed to the log function.

**Realm**

`Server`

**Returns**

* `string`, `string`: The log text and its category, or `nil`.

**Example**

```lua
local text, category = lia.log.getString(client, "mytype", "test")
print(category .. ": " .. text)
```

---

### lia.log.add

**Purpose**

Generates a log entry, triggers the `OnServerLog` hook and writes it to disk and the database.

**Parameters**

* `client` (*Player*): Player associated with the event.
* `logType` (*string*): Identifier of the log type.
* ...: Additional parameters for the log function.

**Realm**

`Server`

**Returns**

* `nil`: Nothing.

**Example**

```lua
hook.Add("PlayerDeath", "ExampleDeathLog", function(victim, attacker)
    lia.log.add(victim, "playerDeath", attacker)
end)
```

---

### lia.log.convertToDatabase

**Purpose**

Imports legacy log files into the database and optionally reloads the map.

**Parameters**

* `changeMap` (*boolean*): Reload the current map when finished.

**Realm**

`Server`

**Returns**

* `nil`: Nothing.

**Example**

```lua
if not lia.log.isConverting then
    lia.log.convertToDatabase(false)
end
```

### lia_log_legacy_count


**Purpose**

Prints how many legacy log lines are available for conversion.

**Parameters**

* None

**Realm**

`Server` (`Console`)

**Returns**

* `nil`: Nothing.

**Example**

```bash
lia_log_legacy_count
```


