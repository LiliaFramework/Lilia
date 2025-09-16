# Core Library

This page documents the functions for working with core logging and utility functions.

---

## Overview

The core library (`lia`) provides a comprehensive system for managing core logging, utility functions, and framework operations in the Lilia framework, serving as the foundational infrastructure that supports all other framework components with essential functionality. This library handles sophisticated logging management with support for multiple message levels, color-coded console output, and structured logging formats that provide clear visibility into system status, errors, and initialization progress throughout the server lifecycle. The system features advanced deprecation handling with backward compatibility support, warning systems, and migration assistance that ensures smooth framework updates and maintains code stability across different versions. It includes comprehensive bootstrap messaging with framework initialization tracking, progress monitoring, and startup sequence management that enables developers to monitor and debug the framework loading process. The library provides robust utility functions with support for common operations, debugging tools, and framework maintenance that improve development efficiency and system reliability. Additional features include integration with Garry's Mod's native functions, cross-platform compatibility utilities, and performance monitoring tools that ensure optimal framework operation across different server configurations and client setups, making it essential for maintaining code quality and providing consistent functionality throughout the entire framework ecosystem.

### error

**Purpose**

Prints an error message to the console with red color formatting.

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
-- Console output: [Lilia] [Error] Failed to load library: someLibrary

-- Log with context
lia.error("Database connection failed: " .. tostring(error))
-- Console output: [Lilia] [Error] Database connection failed: connection timeout
```

---

### warning

**Purpose**

Prints a warning message to the console with yellow color formatting.

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
-- Console output: [Lilia] [Warning] Deprecated function used: oldFunction

-- Log configuration warning
lia.warning("Invalid configuration value for: " .. configKey)
-- Console output: [Lilia] [Warning] Invalid configuration value for: maxPlayers
```

---

### information

**Purpose**

Prints an information message to the console with blue color formatting.

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
-- Console output: [Lilia] [Information] Library loaded successfully: util

-- Log status update
lia.information("Database connection established")
-- Console output: [Lilia] [Information] Database connection established
```

---

### admin

**Purpose**

Prints an admin message to the console with orange color formatting.

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
-- Console output: [Lilia] [Admin] Player JohnDoe was banned

-- Log admin command
lia.admin("Admin " .. admin:Name() .. " executed command: " .. command)
-- Console output: [Lilia] [Admin] Admin AdminUser executed command: ban
```

---

### bootstrap

**Purpose**

Prints a bootstrap message to the console with green color formatting for framework initialization tracking.

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
-- Console output: [Lilia] [Bootstrap] [Core] Loading core libraries...

-- Log section completion
lia.bootstrap("Entities", "Entity registration complete")
-- Console output: [Lilia] [Bootstrap] [Entities] Entity registration complete
```

---

### updater

**Purpose**

Prints an updater message to the console with cyan color formatting.

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
-- Console output: [Lilia] [Updater] Checking for updates...

-- Log update completion
lia.updater("Update completed successfully")
-- Console output: [Lilia] [Updater] Update completed successfully
```

---

### printLog

**Purpose**

Prints a formatted log message with category and green color formatting.

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
-- Console output: [LOG] [Category: Database] Connection established

-- Log player action
lia.printLog("Player", player:Name() .. " joined the server")
-- Console output: [LOG] [Category: Player] JohnDoe joined the server
```

### deprecated

**Purpose**

Handles deprecated method warnings with yellow color formatting and optional callback execution.

**Parameters**

* `methodName` (*string*): The name of the deprecated method.
* `callback` (*function*, optional): Callback function to execute after warning.

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
-- Console output: [Lilia] [Deprecated] The function 'oldFunction' is deprecated and will be removed in a future version.

-- Simple deprecation warning
lia.deprecated("deprecatedMethod")
-- Console output: [Lilia] [Deprecated] The function 'deprecatedMethod' is deprecated and will be removed in a future version.
```

