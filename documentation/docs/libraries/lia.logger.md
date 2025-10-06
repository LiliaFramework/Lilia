# Logger Library

This page documents the functions for working with logging and log management.

---

## Overview

The logger library (`lia.log`) provides a comprehensive system for managing logs, log types, and log storage in the Lilia framework, serving as the central logging infrastructure for debugging, monitoring, and auditing all framework operations. This library handles sophisticated log management with support for multiple log levels, structured logging formats, and intelligent log filtering to provide detailed insights into system behavior and player activities. The system features advanced log categorization with automatic classification based on event types, severity levels, and contextual information to enable efficient log analysis and troubleshooting. It includes comprehensive log storage with support for multiple storage backends including databases, files, and external logging services, with automatic log rotation and archival systems to manage storage efficiently. The library provides robust log retrieval functionality with powerful search capabilities, filtering options, and export tools for administrative analysis and compliance reporting. Additional features include real-time log monitoring, alert systems for critical events, performance metrics collection, and integration with external monitoring tools, making it essential for maintaining server stability, investigating issues, and ensuring compliance with administrative and legal requirements.

---

### addType

**Purpose**

Adds a new log type to the logging system.

**Parameters**

* `logType` (*string*): The log type name.
* `func` (*function*): The function that generates the log message.
* `category` (*string*): The category for this log type.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a new log type
local function addLogType(logType, func, category)
    lia.log.addType(logType, func, category)
end

-- Use in a function
local function createAdminLogType()
    lia.log.addType("admin", function(client, action)
        return "Admin " .. client:Name() .. " performed: " .. action
    end, "Admin Actions")
    print("Admin log type created")
end

-- Use in a function
local function createPlayerLogType()
    lia.log.addType("player", function(client, action)
        return "Player " .. client:Name() .. " performed: " .. action
    end, "Player Actions")
    print("Player log type created")
end

-- Use in a function
local function createSystemLogType()
    lia.log.addType("system", function(client, event, details)
        return "System event: " .. event .. " - " .. details
    end, "System Events")
    print("System log type created")
end
```

---

### getString

**Purpose**

Gets a formatted log string for a specific log type.

**Parameters**

* `client` (*Player*): The client associated with the log entry.
* `logType` (*string*): The log type.
* `...` (*any*): Additional arguments passed to the log type function.

**Returns**

* `logString` (*string*): The formatted log string.
* `category` (*string*): The log category.

**Realm**

Shared.

**Example Usage**

```lua
-- Get formatted log string
local function getLogString(client, logType, ...)
    return lia.log.getString(client, logType, ...)
end

-- Use in a function
local function formatLogMessage(client, logType, ...)
    local logString, category = lia.log.getString(client, logType, ...)
    print("Formatted log: " .. logString .. " (Category: " .. category .. ")")
    return logString, category
end

-- Use in a function
local function createAdminLogMessage(client, action)
    local logString, category = lia.log.getString(client, "admin", action)
    return logString, category
end

-- Use in a function
local function createPlayerLogMessage(client, action)
    local logString, category = lia.log.getString(client, "player", action)
    return logString, category
end
```

---

### add

**Purpose**

Adds a log entry to the logging system.

**Parameters**

* `client` (*Player*): The client associated with the log entry.
* `logType` (*string*): The log type.
* `...` (*any*): Additional arguments passed to the log type function.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add a log entry
local function addLog(client, logType, ...)
    lia.log.add(client, logType, ...)
end

-- Use in a function
local function logAdminAction(client, action)
    lia.log.add(client, "admin", action)
    print("Admin action logged: " .. action)
end

-- Use in a function
local function logPlayerAction(client, action)
    lia.log.add(client, "player", action)
    print("Player action logged: " .. action)
end

-- Use in a function
local function logSystemEvent(event, details)
    lia.log.add(nil, "system", event, details)
    print("System event logged: " .. event)
end
```











