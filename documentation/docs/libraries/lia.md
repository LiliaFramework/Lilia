# Core Library

This page documents general utilities used throughout Lilia.

---

## Overview

The core library exposes shared helper functions used across multiple modules. Its main jobs include realm-aware file inclusion and small convenience utilities for coloured console output, deprecation warnings, and standardised punishments.

---

### lia.include

**Purpose**

Includes a Lua file on the appropriate realm, sending it to clients when required.

**Parameters**

* `path` (*string*): Path to the Lua file.

* `realm` (*string*): Realm state (`"server"`, `"client"`, `"shared"`, etc.).

**Realm**

Depends on the file realm.

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.include("lilia/gamemode/core/libraries/util.lua")
```

---

### lia.includeDir

**Purpose**

Includes every Lua file in a directory, with optional recursion and realm override.

**Parameters**

* `dir` (*string*): Directory path.

* `raw` (*boolean*): Treat `dir` as a raw Lua path.

* `deep` (*boolean*): Include sub-folders when `true`.

* `realm` (*string*): Realm state override.

**Realm**

Depends on included files.

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.includeDir("lilia/gamemode/modules/administration", true, true, "server")
```

---

### lia.includeGroupedDir

**Purpose**

Recursively includes Lua files while preserving alphabetical order.

**Parameters**

* `dir` (*string*): Directory path.

* `raw` (*boolean*): Treat `dir` as a raw filesystem path.

* `recursive` (*boolean*): Traverse sub-directories.

* `forceRealm` (*string*): Realm override for all files.

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

Prints a coloured error message prefixed with “$Lilia$”.

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

Displays a deprecation warning and optionally runs a fallback callback.

**Parameters**

* `methodName` (*string*): Name of the deprecated method.

* `callback` (*function*): Fallback function. *Optional*.

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

Prints an updater message in cyan with the Lilia prefix.

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

Prints an informational message with the Lilia prefix.

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

### lia.bootstrap

**Purpose**

Logs a bootstrap message with a coloured section tag.

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

Broadcasts a chat message to all staff members permitted to view alt-account notifications.

**Parameters**

* `notification` (*string*): Text to broadcast.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.notifyAdmin("Possible alt account detected")
```

---

### lia.printLog

**Purpose**

Prints a colour-coded log entry to the console.

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

Applies standardised kick/ban commands for a player infraction.

**Parameters**

* `client` (*Player*): Player to punish.

* `infraction` (*string*): Reason.

* `kick` (*boolean*): Kick the player.

* `ban` (*boolean*): Ban the player.

* `time` (*number*): Ban duration (minutes).

* `kickKey` (*string*): Localisation key for kick reason.

* `banKey` (*string*): Localisation key for ban reason.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.applyPunishment(ply, "Cheating", true, true, 0)
```

---

### lia.includeEntities

**Purpose**

Recursively loads entity-related files from a directory.

**Parameters**

* `path` (*string*): Directory path containing entity files.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.includeEntities("lilia/gamemode/entities")
```

---
