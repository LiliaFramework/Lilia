# Lia Core Library

This page documents general utilities used throughout Lilia.

---

## Overview

The lia core library exposes shared helper functions used across multiple modules. It primarily handles file inclusion logic and other small utilities.

---

### lia.include

**Purpose**

Includes a Lua file on the appropriate realm, sending it to clients when needed.

**Parameters**

* `fileName` (*string*): Path to the Lua file.
* `state` (*string*): Realm state ("server", "client", "shared", etc.).

**Realm**

Depends on the file realm.

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.include("lilia/gamemode/core/libraries/util.lua")
```

### lia.includeDir

**Purpose**

Includes all Lua files in a directory, optionally traversing subfolders.

**Parameters**

* `directory` (*string*): Directory path to include.
* `fromLua` (*boolean*): Use the raw Lua path when true.
* `recursive` (*boolean*): Include files recursively.
* `realm` (*string*): Realm state for inclusion.

**Realm**

Depends on file inclusion.

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.includeDir("lilia/gamemode/core/modules/admin", true, true, "server")
```
### lia.includeGroupedDir

**Purpose**

Recursively includes Lua files in a directory while preserving alphabetical order.

**Parameters**

* `dir` (*string*): Directory path to load files from.
* `raw` (*boolean*): Treat `dir` as a raw filesystem path.
* `recursive` (*boolean*): Traverse subdirectories recursively.
* `forceRealm` (*string*): Optional realm override for all files.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.includeGroupedDir("core/modules", false, true)
```
### lia.error

**Purpose**

Prints a colored error message prefixed with "[Lilia]".

**Parameters**

* `msg` (*string*): Error text to display.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.error("Something went wrong")
```
### lia.deprecated

**Purpose**

Displays a deprecation warning and optionally runs a callback.

**Parameters**

* `methodName` (*string*): Name of the deprecated method.
* `callback` (*function*): Optional function executed after warning.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.deprecated("OldFunction", function() print("Called fallback") end)
```

### lia.updater

**Purpose**

Prints an updater message in cyan with the Lilia prefix.

**Parameters**

* `msg` (*string*): Update text to display.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.updater("Loading additional content...")
```

---
### lia.information

**Purpose**

Prints an informational message with the Lilia prefix.

**Parameters**

* `msg` (*string*): Text to print to the console.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.information("Server started successfully")
```

### lia.bootstrap

**Purpose**

Logs a bootstrap message with a colored section tag.

**Parameters**

* `section` (*string*): Category or stage of bootstrap.
* `msg` (*string*): Message describing the bootstrap step.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.bootstrap("Database", "Connection established")
```

### lia.notifyAdmin

**Purpose**

Sends a chat message to all staff members who can view alting notifications.

**Parameters**

* `notification` (*string*): Text to broadcast.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.notifyAdmin("Possible alt account detected")
```

### lia.printLog

**Purpose**

Prints a color-coded log entry to the console.

**Parameters**

* `category` (*string*): Name of the log category.
* `logString` (*string*): Message to log.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.printLog("Gameplay", "Third round started")
```

### lia.applyPunishment

**Purpose**

Applies standardized kick or ban commands for a player infraction.

**Parameters**

* `client` (*Player*): The player to punish.
* `infraction` (*string*): Reason for punishment.
* `kick` (*boolean*): Whether to kick the player.
* `ban` (*boolean*): Whether to ban the player.
* `time` (*number*): Ban duration in minutes.
* `kickKey` (*string*): Localization key for the kick reason.
* `banKey` (*string*): Localization key for the ban reason.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.applyPunishment(ply, "Cheating", true, true, 0)
```

### lia.includeEntities

**Purpose**

Recursively loads entity-related files from the given directory.

**Parameters**

* `path` (*string*): Directory containing entity files.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.includeEntities("lilia/entities")
```


