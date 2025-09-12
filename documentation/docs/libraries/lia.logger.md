# Logger Library

This page documents the functions for working with logging and log management.

---

## Overview

The logger library (`lia.log`) provides a comprehensive system for managing logs, log types, and log storage in the Lilia framework, serving as the central logging infrastructure for debugging, monitoring, and auditing all framework operations. This library handles sophisticated log management with support for multiple log levels, structured logging formats, and intelligent log filtering to provide detailed insights into system behavior and player activities. The system features advanced log categorization with automatic classification based on event types, severity levels, and contextual information to enable efficient log analysis and troubleshooting. It includes comprehensive log storage with support for multiple storage backends including databases, files, and external logging services, with automatic log rotation and archival systems to manage storage efficiently. The library provides robust log retrieval functionality with powerful search capabilities, filtering options, and export tools for administrative analysis and compliance reporting. Additional features include real-time log monitoring, alert systems for critical events, performance metrics collection, and integration with external monitoring tools, making it essential for maintaining server stability, investigating issues, and ensuring compliance with administrative and legal requirements.

---

### lia.log.addType

**Purpose**

Adds a new log type to the logging system.

**Parameters**

* `logType` (*string*): The log type name.
* `logData` (*table*): The log data table containing color, description, etc.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a new log type
local function addLogType(logType, logData)
    lia.log.addType(logType, logData)
end

-- Use in a function
local function createAdminLogType()
    lia.log.addType("admin", {
        name = "Admin Actions",
        color = Color(255, 0, 0),
        description = "Administrative actions and commands"
    })
    print("Admin log type created")
end

-- Use in a function
local function createPlayerLogType()
    lia.log.addType("player", {
        name = "Player Actions",
        color = Color(0, 255, 0),
        description = "Player actions and events"
    })
    print("Player log type created")
end

-- Use in a function
local function createSystemLogType()
    lia.log.addType("system", {
        name = "System Events",
        color = Color(0, 0, 255),
        description = "System events and errors"
    })
    print("System log type created")
end
```

---

### lia.log.getString

**Purpose**

Gets a formatted log string.

**Parameters**

* `logType` (*string*): The log type.
* `message` (*string*): The log message.
* `data` (*table*): Optional log data.

**Returns**

* `logString` (*string*): The formatted log string.

**Realm**

Shared.

**Example Usage**

```lua
-- Get formatted log string
local function getLogString(logType, message, data)
    return lia.log.getString(logType, message, data)
end

-- Use in a function
local function formatLogMessage(logType, message, data)
    local logString = lia.log.getString(logType, message, data)
    print("Formatted log: " .. logString)
    return logString
end

-- Use in a function
local function createAdminLogMessage(action, client)
    local message = "Admin " .. client:Name() .. " performed: " .. action
    local data = {
        admin = client:SteamID(),
        action = action,
        time = os.time()
    }
    return lia.log.getString("admin", message, data)
end

-- Use in a function
local function createPlayerLogMessage(action, client)
    local message = "Player " .. client:Name() .. " performed: " .. action
    local data = {
        player = client:SteamID(),
        action = action,
        time = os.time()
    }
    return lia.log.getString("player", message, data)
end
```

---

### lia.log.add

**Purpose**

Adds a log entry to the logging system.

**Parameters**

* `logType` (*string*): The log type.
* `message` (*string*): The log message.
* `data` (*table*): Optional log data.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add a log entry
local function addLog(logType, message, data)
    lia.log.add(logType, message, data)
end

-- Use in a function
local function logAdminAction(client, action)
    local message = "Admin " .. client:Name() .. " performed: " .. action
    local data = {
        admin = client:SteamID(),
        action = action,
        time = os.time()
    }
    lia.log.add("admin", message, data)
    print("Admin action logged: " .. action)
end

-- Use in a function
local function logPlayerAction(client, action)
    local message = "Player " .. client:Name() .. " performed: " .. action
    local data = {
        player = client:SteamID(),
        action = action,
        time = os.time()
    }
    lia.log.add("player", message, data)
    print("Player action logged: " .. action)
end

-- Use in a function
local function logSystemEvent(event, details)
    local message = "System event: " .. event .. " - " .. details
    local data = {
        event = event,
        details = details,
        time = os.time()
    }
    lia.log.add("system", message, data)
    print("System event logged: " .. event)
end
```











