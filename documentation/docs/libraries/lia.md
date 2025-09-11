# Core Loader Library

This page documents the functions for working with the core loader system and framework initialization.

---

## Overview

The core loader library (`lia`) provides the fundamental loading and initialization system for the Lilia framework, serving as the foundational infrastructure that orchestrates the entire framework's startup process and manages all core functionality throughout the server lifecycle. This library handles sophisticated framework initialization with support for dependency resolution, module loading order management, and comprehensive error handling that ensures reliable and consistent framework startup across different server configurations. The system features advanced module management with support for dynamic module discovery, automatic dependency resolution, and intelligent loading sequences that enable flexible and extensible framework architecture. It includes comprehensive entity registration with support for automatic entity discovery, entity validation, and seamless integration with Garry's Mod's entity system that ensures proper entity functionality and performance optimization. The library provides robust logging infrastructure with support for multiple log levels, structured logging, and comprehensive error reporting that enables effective debugging and system monitoring throughout the framework's operation. Additional features include integration with the framework's compatibility system for seamless updates, performance optimization for complex loading scenarios, and comprehensive administrative tools that enable effective framework management and provide powerful system control capabilities, making it essential for maintaining stable and efficient framework operation while providing the flexibility needed for complex server configurations and dynamic module management.

---

### lia.include

**Purpose**

Includes a Lua file with proper realm handling.

**Parameters**

* `path` (*string*): The path to the Lua file to include.
* `realm` (*string*, optional): The realm to load the file in ("shared", "client", "server").

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Include a shared library
lia.include("lilia/gamemode/core/libraries/util.lua", "shared")

-- Include a client-side file
lia.include("lilia/gamemode/core/derma/panels.lua", "client")

-- Include a server-side file
lia.include("lilia/gamemode/core/server/commands.lua", "server")
```

---

### lia.includeDir

**Purpose**

Recursively includes all Lua files in a directory.

**Parameters**

* `dir` (*string*): The directory path to scan.
* `raw` (*boolean*): Whether to use the raw path without schema prefix.
* `deep` (*boolean*): Whether to include subdirectories recursively.
* `realm` (*string*, optional): The realm to load files in.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Include all files in a directory
lia.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)

-- Include only top-level files
lia.includeDir("lilia/gamemode/core/libraries", true, false, "shared")
```

---

### lia.includeGroupedDir

**Purpose**

Includes files in a directory with automatic realm detection based on filename prefixes.

**Parameters**

* `dir` (*string*): The directory path to scan.
* `raw` (*boolean*): Whether to use the raw path without schema prefix.
* `recursive` (*boolean*): Whether to include subdirectories recursively.
* `forceRealm` (*string*, optional): Force a specific realm for all files.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Include with automatic realm detection
lia.includeGroupedDir("lilia/gamemode/core/derma", true, true)

-- Force all files to be client-side
lia.includeGroupedDir("lilia/gamemode/core/derma", true, true, "client")
```

---

### lia.includeEntities

**Purpose**

Handles the registration of entities, weapons, tools, and effects from a directory structure.

**Parameters**

* `path` (*string*): The base path to scan for entity files.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Include all entities from a directory
lia.includeEntities("lilia/gamemode/entities")

-- Include custom weapons
lia.includeEntities("lilia/gamemode/weapons")
```

---

### lia.error

**Purpose**

Prints an error message to the console.

**Parameters**

* `msg` (*string*): The error message to display.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Log an error message
lia.error("Failed to load library: " .. libraryName)

-- Log with context
lia.error("Database connection failed: " .. tostring(error))
```

---

### lia.warning

**Purpose**

Prints a warning message to the console.

**Parameters**

* `msg` (*string*): The warning message to display.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Log a warning
lia.warning("Deprecated function used: " .. functionName)

-- Log configuration warning
lia.warning("Invalid configuration value for: " .. configKey)
```

---

### lia.information

**Purpose**

Prints an information message to the console.

**Parameters**

* `msg` (*string*): The information message to display.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Log information
lia.information("Library loaded successfully: " .. libraryName)

-- Log status update
lia.information("Database connection established")
```

---

### lia.admin

**Purpose**

Prints an admin message to the console.

**Parameters**

* `msg` (*string*): The admin message to display.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Log admin action
lia.admin("Player " .. player:Name() .. " was banned")

-- Log admin command
lia.admin("Admin " .. admin:Name() .. " executed command: " .. command)
```

---

### lia.bootstrap

**Purpose**

Prints a bootstrap message to the console.

**Parameters**

* `section` (*string*): The bootstrap section name.
* `msg` (*string*): The bootstrap message to display.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Log bootstrap progress
lia.bootstrap("Core", "Loading core libraries...")

-- Log section completion
lia.bootstrap("Entities", "Entity registration complete")
```

---

### lia.deprecated

**Purpose**

Handles deprecated method warnings.

**Parameters**

* `methodName` (*string*): The name of the deprecated method.
* `callback` (*function*, optional): Callback function to execute.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Mark a function as deprecated
lia.deprecated("oldFunction", function()
    return newFunction()
end)

-- Simple deprecation warning
lia.deprecated("deprecatedMethod")
```

---

### lia.updater

**Purpose**

Prints an updater message to the console.

**Parameters**

* `msg` (*string*): The updater message to display.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Log update progress
lia.updater("Checking for updates...")

-- Log update completion
lia.updater("Update completed successfully")
```

---

### lia.notifyAdmin

**Purpose**

Notifies all administrators about a specific notification.

**Parameters**

* `notification` (*string*): The notification message to send.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Notify admins of an event
lia.notifyAdmin("Server restart in 5 minutes")

-- Notify admins of player action
lia.notifyAdmin("Player " .. player:Name() .. " attempted to exploit")
```

---

### lia.printLog

**Purpose**

Prints a formatted log message.

**Parameters**

* `category` (*string*): The log category.
* `logString` (*string*): The log message.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Log with category
lia.printLog("Database", "Connection established")

-- Log player action
lia.printLog("Player", player:Name() .. " joined the server")
```

---

### lia.applyPunishment

**Purpose**

Applies punishment to a client based on infraction.

**Parameters**

* `client` (*Player*): The client to punish.
* `infraction` (*string*): The infraction description.
* `kick` (*boolean*): Whether to kick the client.
* `ban` (*boolean*): Whether to ban the client.
* `time` (*number*, optional): Ban duration in minutes.
* `kickKey` (*string*, optional): Language key for kick message.
* `banKey` (*string*, optional): Language key for ban message.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Kick a player
lia.applyPunishment(client, "Cheating", true, false)

-- Ban a player for 60 minutes
lia.applyPunishment(client, "Exploiting", false, true, 60)

-- Ban with custom messages
lia.applyPunishment(client, "Hacking", false, true, 0, nil, "ban_hacking")
```
