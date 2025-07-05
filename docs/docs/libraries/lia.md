# Lia Core Library

This page documents general utilities used throughout Lilia.

---

## Overview

The lia core library exposes shared helper functions used across multiple modules. It primarily handles file inclusion logic and other small utilities.

---

### lia.include

**Description:**

Includes a Lua file. If no realm is supplied the function attempts to infer it from the file name ("sv_", "sh_", or "cl_" prefixes). The file is then included on the appropriate side and sent to clients when necessary.

**Parameters:**

* `fileName` (`string`) – The path to the Lua file.


* state    (string) – The realm state ("server", "client", "shared", etc.).


**Realm:**

* Depends on the file realm.


**Returns:**

* None


**Example Usage:**

```lua
-- Load a shared utility file from the gamemode
lia.include("lilia/gamemode/core/libraries/util.lua")
```

---

### lia.includeDir

**Description:**

Includes all Lua files in a directory. When `fromLua` is false the path is resolved relative to the active schema or, if none is loaded, the base gamemode. The function can optionally traverse subfolders.

**Parameters:**

* `directory` (`string`) – The directory path to include.


* fromLua   (boolean) – Whether to use the raw Lua directory path.


* `recursive` (`boolean`) – Whether to include files recursively.


* realm     (string) – The realm state to use ("client", "server", "shared").


**Realm:**

* Depends on file inclusion.


**Returns:**

* None


**Example Usage:**

```lua
-- Recursively load all server files within a module
lia.includeDir("lilia/gamemode/core/modules/admin", true, true, "server")
```

---

### lia.includeGroupedDir

**Description:**

Recursively includes all Lua files inside a directory while preserving alphabetical order within each folder. The realm is inferred from each filename unless `forceRealm` is provided.

**Parameters:**

* dir        (string) – Directory path to load files from (relative if raw is false).


* raw        (boolean) – If true, uses dir as the literal filesystem path.


* recursive  (boolean) – Whether to traverse subdirectories recursively.


* `forceRealm` (`string`) – Optional override for the realm of all included files ("client", "server", or "shared").


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
-- Load every module inside the core folder
lia.includeGroupedDir("core/modules", false, true)
```

---

### lia.error

**Description:**

Prints a colored error message prefixed with "[Lilia]" to the console.

**Parameters:**

* `msg` (`string`) – Error text to display.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.error
    lia.error("Invalid configuration detected")
```

---

### lia.deprecated

**Description:**

Notifies that a method is deprecated and optionally runs a callback.

**Parameters:**

* `methodName` (`string`) – Name of the deprecated method.


* callback   (function) – Optional function executed after warning.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.deprecated
    lia.deprecated("OldFunction", function() print("Called fallback") end)
```

---

### lia.updater

**Description:**

Prints an updater message in cyan to the console with the Lilia prefix.

**Parameters:**

* `msg` (`string`) – Update text to display.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.updater
    lia.updater("Loading additional content...")
```

---

### lia.information

**Description:**

Prints an informational message with the Lilia prefix.

**Parameters:**

* `msg` (`string`) – Text to print to the console.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.information
    lia.information("Server started successfully")
```

---

### lia.bootstrap

**Description:**

Logs a bootstrap message with a colored section tag for clarity.

**Parameters:**

* `section` (`string`) – Category or stage of bootstrap.


* msg     (string) – Message describing the bootstrap step.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.bootstrap
    lia.bootstrap("Database", "Connection established")
```
### lia.notifyAdmin

**Description:**

Sends a chat message to all staff members who can view alting notifications.

**Parameters:**

* `notification` (`string`) – Text to broadcast.

**Realm:**

* Shared

**Returns:**

* None

**Example Usage:**

```lua
-- Alert staff about suspicious activity
lia.notifyAdmin("Possible alt account detected")
```

---

### lia.printLog

**Description:**

Prints a color-coded log entry to the console. The message is prefixed with
`[LOG][<category>]` for easy filtering.

**Parameters:**

* `category` (`string`) – Name of the log category.
* `logString` (`string`) – Message to log.

**Realm:**

* Shared

**Returns:**

* None

**Example Usage:**

```lua
lia.printLog("Gameplay", "Third round started")
```

---

### lia.applyPunishment

**Description:**

Applies standardized kick or ban commands for a player infraction.

**Parameters:**

* `client` (`Player`) – The player to punish.
* `infraction` (`string`) – Reason for punishment.
* `kick` (`boolean`) – Whether to kick the player.
* `ban` (`boolean`) – Whether to ban the player.
* `time` (`number`) – Ban duration in minutes.
* `kickKey` (`string`) – Localization key for the kick reason.
* `banKey` (`string`) – Localization key for the ban reason.

**Realm:**

* Shared

**Returns:**

* None

**Example Usage:**

```lua
-- Ban a cheater permanently and remove them from the server
lia.applyPunishment(ply, "Cheating", true, true, 0)
```

---


### lia.includeEntities

**Description:**

Recursively loads entity-related files from the given directory. Each subfolder
may contain `init.lua`, `shared.lua`, or `cl_init.lua`. Entities, weapons,
tools, and effects are automatically registered after inclusion.

**Parameters:**

* `path` (`string`) – The directory path containing entity files.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.includeEntities
    lia.includeEntities("lilia/entities")
```
