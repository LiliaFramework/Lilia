# Core Library

This page documents general utilities used throughout Lilia. All functions on
this page live in `gamemode/core/libraries/loader.lua`.

---

## Overview

The core library exposes shared helper functions used across multiple modules. Its main jobs include realm-aware file inclusion and small convenience utilities for coloured console output, deprecation warnings, and standardised punishments.

---

### lia.include

**Purpose**

Includes a Lua file in the appropriate realm. When run on the server, any
client or shared files are automatically sent to players. Throws a Lua error if
`path` is missing.

**Parameters**

* `path` (*string*): Path to the Lua file. *Required.*
* `realm` (*string*): Override for the inclusion realm (`"server"`,
  `"client"`, or `"shared"`). When omitted, the realm is inferred from the
  filename prefix (`sv_`, `sh_`, `cl_`) or defaults to `"shared"`.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Force include as client
lia.include("lilia/gamemode/core/libraries/keybind.lua", "client")
```

---

### lia.includeDir

**Purpose**

Includes all Lua files in a directory. Can automatically prepend the active
schema or gamemode path, walk subfolders, and force a realm for every file.

**Parameters**

* `dir` (*string*): Directory path.
* `raw` (*boolean*): If `true`, uses `dir` as-is. Otherwise, the path is
  relative to the active schema or to `lilia/gamemode`. *Optional.* Defaults to
  `false`.
* `deep` (*boolean*): Recursively include subfolders when `true`. *Optional.*
  Defaults to `false`.
* `realm` (*string*): Realm override applied to every included file. *Optional.*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Load all server files in a folder and its subfolders
lia.includeDir("lilia/gamemode/modules/administration", true, true, "server")
```

---

### lia.includeGroupedDir

**Purpose**

Includes Lua files grouped by folder. The function can walk subdirectories and
determine the realm of each file from its prefix (`sh_`, `sv_`, `cl_`) unless a
realm is forced.

**Parameters**

* `dir` (*string*): Directory path.
* `raw` (*boolean*): Use `dir` as a literal path. Otherwise, it is relative to
  the active schema or gamemode. *Optional.* Defaults to `false`.
* `recursive` (*boolean*): Recurse into subdirectories when `true`. *Optional.*
  Defaults to `false`.
* `forceRealm` (*string*): Force all files to load in this realm. *Optional.*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.includeGroupedDir("modules", false, true)
```

---

### lia.error

**Purpose**

Prints a coloured console message prefixed with "[Lilia] [Error]". This does
not halt script execution; it is purely for logging.

**Parameters**

* `msg` (*string*): Error text.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.error("Something went wrong")
```

---

### lia.deprecated

**Purpose**

Displays a colour-coded deprecation warning and optionally runs a fallback
function.

**Parameters**

* `methodName` (*string*): Name of the deprecated method.
* `callback` (*function*): Function to run after printing the warning. Executed
  only when supplied. *Optional.*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.deprecated("OldFunction", function()
    print("Called fallback")
end)
```

---

### lia.updater

**Purpose**

Prints a console message prefixed with "[Lilia] [Updater]" in cyan.

**Parameters**

* `msg` (*string*): Message text.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.updater("Loading additional content…")
```

---

### lia.information

**Purpose**

Prints an informational console message prefixed with "[Lilia] [Information]".

**Parameters**

* `msg` (*string*): Console text.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.information("Server started successfully")
```

---

### lia.admin

**Purpose**

Prints an admin-level console message prefixed with "[Lilia] [Admin]".

**Parameters**

* `msg` (*string*): Text to display.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.admin("Player JohnDoe has been promoted to admin.")
```

---

### lia.bootstrap

**Purpose**

Logs a bootstrap message with a coloured section tag. Messages are prefixed
with "[Lilia] [Bootstrap]" followed by the section in brackets.

**Parameters**

* `section` (*string*): Bootstrap stage.

* `msg` (*string*): Descriptive message.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.bootstrap("Database", "Connection established")
```

---

### lia.notifyAdmin

**Purpose**

Broadcasts a chat notification to every valid player who has the
`canSeeAltingNotifications` privilege.

**Parameters**

* `notification` (*string*): Text to broadcast.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.notifyAdmin("Possible alt account detected")
```

---

### lia.printLog

**Purpose**

Prints a colour-coded log entry to the console prefixed with "[LOG]" and the
log category.

**Parameters**

* `category` (*string*): Log category name.
* `logString` (*string*): Text to log.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.printLog("Gameplay", "Third round started")
```

---

### lia.applyPunishment

**Purpose**

Applies standardised kick and/or ban commands for a player infraction using
`lia.administrator.execCommand`.

**Parameters**

* `client` (*Player*): Player to punish.
* `infraction` (*string*): Reason for the punishment.
* `kick` (*boolean*): Whether to kick the player.
* `ban` (*boolean*): Whether to ban the player.
* `time` (*number*): Ban duration in minutes. *Optional.* Defaults to `0`
  (permanent).
* `kickKey` (*string*): Localisation key for the kick reason. *Optional.*
  Defaults to `"kickedForInfraction"`.
* `banKey` (*string*): Localisation key for the ban reason. *Optional.* Defaults
  to `"bannedForInfraction"`.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.applyPunishment(ply, "Cheating", true, true, 0)
```

---

### lia.includeEntities

**Purpose**

Loads and registers entities, weapons, tools, and effects from a base
directory. Handles both folder- and file-based definitions, automatically
including `init.lua`, `shared.lua`, and `cl_init.lua` files, stripping realm
prefixes (`sh_`, `sv_`, `cl_`), and registering with the appropriate GMod
systems.

**Parameters**

* `path` (*string*): Base directory containing `entities`, `weapons`, `tools`,
  and/or `effects` subfolders.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.includeEntities("lilia/gamemode/entities")
```

---
