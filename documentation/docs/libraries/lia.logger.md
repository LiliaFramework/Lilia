# Logger Library

This page documents the functions for working with logging and log management.

---

## Overview

The logger library (`lia.log`) provides a comprehensive system for managing logs, log types, and log storage in the Lilia framework. It includes log creation, categorization, database storage, and log retrieval functionality.

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

---

### lia.log.get

**Purpose**

Gets logs by type.

**Parameters**

* `logType` (*string*): The log type.

**Returns**

* `logs` (*table*): Table of logs.

**Realm**

Server.

**Example Usage**

```lua
-- Get logs by type
local function getLogs(logType)
    return lia.log.get(logType)
end

-- Use in a function
local function showAdminLogs()
    local logs = lia.log.get("admin")
    if logs then
        print("Admin logs:")
        for _, log in ipairs(logs) do
            print("- " .. log.message)
        end
    else
        print("No admin logs found")
    end
end

-- Use in a function
local function showPlayerLogs()
    local logs = lia.log.get("player")
    if logs then
        print("Player logs:")
        for _, log in ipairs(logs) do
            print("- " .. log.message)
        end
    else
        print("No player logs found")
    end
end

-- Use in a function
local function showSystemLogs()
    local logs = lia.log.get("system")
    if logs then
        print("System logs:")
        for _, log in ipairs(logs) do
            print("- " .. log.message)
        end
    else
        print("No system logs found")
    end
end
```

---

### lia.log.getAll

**Purpose**

Gets all logs.

**Parameters**

*None*

**Returns**

* `logs` (*table*): Table of all logs.

**Realm**

Server.

**Example Usage**

```lua
-- Get all logs
local function getAllLogs()
    return lia.log.getAll()
end

-- Use in a function
local function showAllLogs()
    local logs = lia.log.getAll()
    if logs then
        print("All logs:")
        for _, log in ipairs(logs) do
            print("- [" .. log.type .. "] " .. log.message)
        end
    else
        print("No logs found")
    end
end

-- Use in a function
local function getLogCount()
    local logs = lia.log.getAll()
    return logs and #logs or 0
end

-- Use in a function
local function getLogsByTimeRange(startTime, endTime)
    local logs = lia.log.getAll()
    local filtered = {}
    for _, log in ipairs(logs) do
        if log.time >= startTime and log.time <= endTime then
            table.insert(filtered, log)
        end
    end
    return filtered
end
```

---

### lia.log.getByID

**Purpose**

Gets a log by its ID.

**Parameters**

* `logID` (*string*): The log ID.

**Returns**

* `log` (*table*): The log data or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Get log by ID
local function getLogByID(logID)
    return lia.log.getByID(logID)
end

-- Use in a function
local function showLogByID(logID)
    local log = lia.log.getByID(logID)
    if log then
        print("Log ID: " .. logID)
        print("Type: " .. log.type)
        print("Message: " .. log.message)
        print("Time: " .. os.date("%Y-%m-%d %H:%M:%S", log.time))
        return log
    else
        print("Log not found: " .. logID)
        return nil
    end
end

-- Use in a function
local function checkLogExists(logID)
    local log = lia.log.getByID(logID)
    return log ~= nil
end

-- Use in a function
local function getLogData(logID)
    local log = lia.log.getByID(logID)
    if log then
        return log.data
    else
        print("Log not found")
        return nil
    end
end
```

---

### lia.log.delete

**Purpose**

Deletes a log by its ID.

**Parameters**

* `logID` (*string*): The log ID.

**Returns**

* `success` (*boolean*): True if deletion was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Delete log by ID
local function deleteLog(logID)
    return lia.log.delete(logID)
end

-- Use in a function
local function removeLog(logID)
    local success = lia.log.delete(logID)
    if success then
        print("Log deleted: " .. logID)
    else
        print("Failed to delete log: " .. logID)
    end
    return success
end

-- Use in a function
local function cleanupOldLogs()
    local logs = lia.log.getAll()
    local cutoffTime = os.time() - (30 * 24 * 60 * 60) -- 30 days ago
    for _, log in ipairs(logs) do
        if log.time < cutoffTime then
            lia.log.delete(log.id)
        end
    end
    print("Old logs cleaned up")
end

-- Use in a function
local function deleteLogsByType(logType)
    local logs = lia.log.get(logType)
    for _, log in ipairs(logs) do
        lia.log.delete(log.id)
    end
    print("Logs deleted for type: " .. logType)
end
```

---

### lia.log.clear

**Purpose**

Clears all logs.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Clear all logs
local function clearAllLogs()
    lia.log.clear()
end

-- Use in a function
local function resetLogs()
    lia.log.clear()
    print("All logs cleared")
end

-- Use in a function
local function clearLogsByType(logType)
    local logs = lia.log.get(logType)
    for _, log in ipairs(logs) do
        lia.log.delete(log.id)
    end
    print("Logs cleared for type: " .. logType)
end

-- Use in a command
lia.command.add("clearlogs", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.log.clear()
        client:notify("All logs cleared")
    end
})
```

---

### lia.log.getTypes

**Purpose**

Gets all log types.

**Parameters**

*None*

**Returns**

* `types` (*table*): Table of all log types.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all log types
local function getLogTypes()
    return lia.log.getTypes()
end

-- Use in a function
local function showLogTypes()
    local types = lia.log.getTypes()
    print("Available log types:")
    for _, type in ipairs(types) do
        print("- " .. type)
    end
end

-- Use in a function
local function getLogTypeCount()
    local types = lia.log.getTypes()
    return #types
end

-- Use in a function
local function checkLogTypeExists(logType)
    local types = lia.log.getTypes()
    for _, type in ipairs(types) do
        if type == logType then
            return true
        end
    end
    return false
end
```

---

### lia.log.getTypeData

**Purpose**

Gets data for a log type.

**Parameters**

* `logType` (*string*): The log type.

**Returns**

* `typeData` (*table*): The log type data or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get log type data
local function getLogTypeData(logType)
    return lia.log.getTypeData(logType)
end

-- Use in a function
local function showLogTypeInfo(logType)
    local typeData = lia.log.getTypeData(logType)
    if typeData then
        print("Log Type: " .. logType)
        print("Name: " .. typeData.name)
        print("Description: " .. typeData.description)
        print("Color: " .. tostring(typeData.color))
        return typeData
    else
        print("Log type not found: " .. logType)
        return nil
    end
end

-- Use in a function
local function getLogTypeColor(logType)
    local typeData = lia.log.getTypeData(logType)
    return typeData and typeData.color or Color(255, 255, 255)
end

-- Use in a function
local function getLogTypeName(logType)
    local typeData = lia.log.getTypeData(logType)
    return typeData and typeData.name or logType
end
```

---

### lia.log.setTypeData

**Purpose**

Sets data for a log type.

**Parameters**

* `logType` (*string*): The log type.
* `typeData` (*table*): The log type data.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Set log type data
local function setLogTypeData(logType, typeData)
    lia.log.setTypeData(logType, typeData)
end

-- Use in a function
local function updateLogType(logType, newData)
    lia.log.setTypeData(logType, newData)
    print("Log type updated: " .. logType)
end

-- Use in a function
local function modifyLogTypeColor(logType, color)
    local currentData = lia.log.getTypeData(logType) or {}
    currentData.color = color
    lia.log.setTypeData(logType, currentData)
    print("Log type color updated: " .. logType)
end

-- Use in a function
local function modifyLogTypeDescription(logType, description)
    local currentData = lia.log.getTypeData(logType) or {}
    currentData.description = description
    lia.log.setTypeData(logType, currentData)
    print("Log type description updated: " .. logType)
end
```

---

### lia.log.removeType

**Purpose**

Removes a log type from the system.

**Parameters**

* `logType` (*string*): The log type to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove log type
local function removeLogType(logType)
    lia.log.removeType(logType)
end

-- Use in a function
local function removeOldLogType(logType)
    lia.log.removeType(logType)
    print("Log type removed: " .. logType)
end

-- Use in a function
local function cleanupOldLogTypes()
    local oldTypes = {"old_type1", "old_type2", "old_type3"}
    for _, type in ipairs(oldTypes) do
        lia.log.removeType(type)
    end
    print("Old log types cleaned up")
end

-- Use in a function
local function removeLogTypeAndLogs(logType)
    local logs = lia.log.get(logType)
    for _, log in ipairs(logs) do
        lia.log.delete(log.id)
    end
    lia.log.removeType(logType)
    print("Log type and logs removed: " .. logType)
end
```

---

### lia.log.clearType

**Purpose**

Clears all logs of a specific type.

**Parameters**

* `logType` (*string*): The log type to clear.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Clear logs by type
local function clearLogsByType(logType)
    lia.log.clearType(logType)
end

-- Use in a function
local function clearAdminLogs()
    lia.log.clearType("admin")
    print("Admin logs cleared")
end

-- Use in a function
local function clearPlayerLogs()
    lia.log.clearType("player")
    print("Player logs cleared")
end

-- Use in a function
local function clearSystemLogs()
    lia.log.clearType("system")
    print("System logs cleared")
end
```

---

### lia.log.export

**Purpose**

Exports logs to a file.

**Parameters**

* `logType` (*string*): The log type to export.
* `filePath` (*string*): The file path to export to.

**Returns**

* `success` (*boolean*): True if export was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Export logs to file
local function exportLogs(logType, filePath)
    return lia.log.export(logType, filePath)
end

-- Use in a function
local function exportAdminLogs()
    local success = lia.log.export("admin", "logs/admin_logs.txt")
    if success then
        print("Admin logs exported")
    else
        print("Failed to export admin logs")
    end
    return success
end

-- Use in a function
local function exportAllLogs()
    local types = lia.log.getTypes()
    for _, type in ipairs(types) do
        local filePath = "logs/" .. type .. "_logs.txt"
        lia.log.export(type, filePath)
    end
    print("All logs exported")
end

-- Use in a function
local function exportLogsByDate(logType, date)
    local filePath = "logs/" .. logType .. "_" .. date .. ".txt"
    return lia.log.export(logType, filePath)
end
```

---

### lia.log.import

**Purpose**

Imports logs from a file.

**Parameters**

* `filePath` (*string*): The file path to import from.

**Returns**

* `success` (*boolean*): True if import was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Import logs from file
local function importLogs(filePath)
    return lia.log.import(filePath)
end

-- Use in a function
local function importAdminLogs()
    local success = lia.log.import("logs/admin_logs.txt")
    if success then
        print("Admin logs imported")
    else
        print("Failed to import admin logs")
    end
    return success
end

-- Use in a function
local function importAllLogs()
    local files = file.Find("logs/*.txt", "DATA")
    for _, file in ipairs(files) do
        lia.log.import("logs/" .. file)
    end
    print("All logs imported")
end

-- Use in a function
local function importLogsFromDirectory(directory)
    local files = file.Find(directory .. "/*.txt", "DATA")
    for _, file in ipairs(files) do
        lia.log.import(directory .. "/" .. file)
    end
    print("Logs imported from directory: " .. directory)
end
```