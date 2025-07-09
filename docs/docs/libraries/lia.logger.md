# Logger Library

This page documents logging utilities.

---

## Overview

The logger library writes structured log entries to files, to the console, and to the `lia_logs` SQL table (gamemode, category, text, character ID, SteamID). Built-in log types live in `modules/administration/submodules/logging/logs.lua`; custom types can be added with `lia.log.addType`.

---

### lia.log.loadTables

**Purpose**

Initialises the logging system and converts any legacy text logs.

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
hook.Add("LiliaDatabaseInitialized", nil, function()
    lia.log.loadTables()
end)
```

---

### lia.log.addType

**Purpose**

Registers a log type by supplying a generator function and a category.

**Parameters**

* `logType` (*string*): Unique identifier.
* `func` (*function*): Builds the log string (`func(client, ...) → string`).
* `category` (*string*): Folder/category name used for log files.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
lia.log.addType(
    "mytype",
    function(client, action)
        return string.format("%s performed %s", client:Name(), action)
    end,
    "Actions"
)

lia.log.add(client, "mytype", "a backflip")
```

---

### lia.log.getString

**Purpose**

Returns the formatted log string (and its category) for a given type without writing anything.

**Parameters**

* `client` (*Player*): Player tied to the entry.
* `logType` (*string*): Log-type identifier.
* …: Additional arguments forwarded to the generator.

**Realm**

`Server`

**Returns**

* *string*, *string*: Log text and its category, or `nil`.

**Example**

```lua
local text, cat = lia.log.getString(client, "mytype", "test")
print(cat .. ": " .. text)
```

---

### lia.log.add

**Purpose**

Creates a log entry, fires `OnServerLog`, prints to console, writes to file, and inserts into `lia_logs`.

**Parameters**

* `client` (*Player*): Player associated with the event.
* `logType` (*string*): Log-type identifier.
* …: Extra values for the generator.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
hook.Add("PlayerDeath", "ExampleDeathLog", function(victim, attacker)
    lia.log.add(victim, "playerDeath", attacker)
end)
```

---

### lia.log.convertToDatabase

**Purpose**

Migrates legacy text logs into the database. Players cannot join during conversion. Optionally reloads the map afterward. The original log files are deleted after migration completes.

**Parameters**

* `changeMap` (*boolean*): Reload the map when finished.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
if not lia.log.isConverting then
    lia.log.convertToDatabase(false)
end
```
---