# Logger Library

Comprehensive logging and audit trail system for the Lilia framework.

---

Overview

The logger library provides comprehensive logging functionality for the Lilia framework, enabling detailed tracking and recording of player actions, administrative activities, and system events. It operates on the server side and automatically categorizes log entries into predefined categories such as character management, combat, world interactions, chat communications, item transactions, administrative actions, and security events. The library stores all log entries in a database table with timestamps, player information, and categorized messages. It supports dynamic log type registration and provides hooks for external systems to process log events. The logger ensures accountability and provides administrators with detailed audit trails for server management and moderation.

---

### lia.log.addType

#### 📋 Purpose
Registers a new log type with a custom formatting function and category

#### ⏰ When Called
When modules or external systems need to add custom log types

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `logType` | **string** | Unique identifier for the log type |
| `func` | **function** | Function that formats the log message, receives client and additional parameters |
| `category` | **string** | Category name for organizing log entries |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add a basic custom log type
    lia.log.addType("customAction", function(client, action)
        return client:Name() .. " performed " .. action
    end, "Custom")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add log type with validation and localization
    lia.log.addType("moduleEvent", function(client, moduleName, event, data)
        if not IsValid(client) then return "System: " .. moduleName .. " - " .. event end
        return L("logModuleEvent", client:Name(), moduleName, event, data or "")
    end, "Modules")

```

#### ⚙️ High Complexity
```lua
    -- High: Add complex log type with multiple parameters and error handling
    lia.log.addType("advancedAction", function(client, target, action, amount, reason)
        local clientName = IsValid(client) and client:Name() or "Console"
        local targetName = IsValid(target) and target:Name() or tostring(target)
        local timestamp = os.date("%H:%M:%S")
        return string.format("[%s] %s %s %s (Amount: %s, Reason: %s)",
            timestamp, clientName, action, targetName, amount or "N/A", reason or "None")
    end, "Advanced")

```

---

### lia.log.getString

#### 📋 Purpose
Generates a formatted log string from a log type and parameters

#### ⏰ When Called
Internally by lia.log.add() or when manually retrieving log messages

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who triggered the log event (can be nil for system events) |
| `logType` | **string** | The log type identifier to format |

#### ↩️ Returns
* result (string)
The formatted log message, or nil if log type doesn't exist or function fails
category (string)
The category of the log type, or nil if log type doesn't exist

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get a basic log string
    local message, category = lia.log.getString(client, "charCreate", character)
    if message then
        print("Log: " .. message)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get log string with multiple parameters
    local message, category = lia.log.getString(client, "itemTransfer", itemName, fromID, toID)
    if message then
        hook.Run("CustomLogHandler", message, category)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get log string with error handling and validation
    local function safeGetLogString(client, logType, ...)
        local success, message, category = pcall(lia.log.getString, client, logType, ...)
        if success and message then
            return message, category
        else
            return "Failed to generate log: " .. tostring(logType), "Error"
        end
    end
    local message, category = safeGetLogString(client, "adminAction", target, action, reason)

```

---

### lia.log.add

#### 📋 Purpose
Adds a log entry to the database and displays it in the server console

#### ⏰ When Called
When any significant player action or system event occurs that needs logging

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who triggered the log event (can be nil for system events) |
| `logType` | **string** | The log type identifier to use for formatting |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Log a basic player action
    lia.log.add(client, "charCreate", character)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Log with multiple parameters and validation
    if IsValid(target) then
        lia.log.add(client, "itemTransfer", itemName, fromID, toID)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Log with conditional parameters and error handling
    local function logAdminAction(client, target, action, reason, amount)
        local logType = "adminAction"
        local params = {target, action}
        if reason then table.insert(params, reason) end
        if amount then table.insert(params, amount) end
        lia.log.add(client, logType, unpack(params))
    end
    logAdminAction(client, target, "kick", "Rule violation", nil)

```

---

