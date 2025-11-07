# Commands Library

Comprehensive command registration, parsing, and execution system for the Lilia framework.

---

Overview

The commands library provides comprehensive functionality for managing and executing commands in the Lilia framework. It handles command registration, argument parsing, access control, privilege management, and command execution across both server and client sides. The library supports complex argument types including players, booleans, strings, and tables, with automatic syntax generation and validation. It integrates with the administrator system for privilege-based access control and provides user interface elements for command discovery and argument prompting. The library ensures secure command execution with proper permission checks and logging capabilities.

---

### lia.command.buildSyntaxFromArguments

#### 📋 Purpose
Generates a human-readable syntax string from command argument definitions

#### ⏰ When Called
Automatically called by lia.command.add when registering commands

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `args` | **table** | Array of argument definition tables with type, name, and optional properties |

#### ↩️ Returns
* string - Formatted syntax string showing argument types and names

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Generate syntax for basic arguments
    local args = {
        {type = "string", name = "target"},
        {type = "player", name = "player"}
    }
    local syntax = lia.command.buildSyntaxFromArguments(args)
    -- Returns: "[string target] [player player]"

```

#### 📊 Medium Complexity
```lua
    -- Medium: Generate syntax with optional arguments
    local args = {
        {type = "string", name = "message"},
        {type = "bool", name = "silent", optional = true}
    }
    local syntax = lia.command.buildSyntaxFromArguments(args)
    -- Returns: "[string message] [bool silent optional]"

```

#### ⚙️ High Complexity
```lua
    -- High: Generate syntax for complex command with multiple argument types
    local args = {
        {type = "player", name = "target"},
        {type = "string", name = "reason"},
        {type = "number", name = "duration", optional = true},
        {type = "bool", name = "notify", optional = true}
    }
    local syntax = lia.command.buildSyntaxFromArguments(args)
    -- Returns: "[player target] [string reason] [number duration optional] [bool notify optional]"

```

---

### lia.command.add

#### 📋 Purpose
Registers a new command with the command system, handling privileges, aliases, and access control

#### ⏰ When Called
When registering commands during gamemode initialization or module loading

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `command` | **string** | The command name |
| `data` | **table** | Command configuration including onRun, arguments, privilege, etc. |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic command
    lia.command.add("hello", {
        onRun = function(client, arguments)
            client:notify("Hello, " .. client:Name() .. "!")
        end,
        desc = "Say hello"
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register command with arguments and admin privilege
    lia.command.add("kick", {
        arguments = {
            {type = "player", name = "target"},
            {type = "string", name = "reason", optional = true}
        },
        onRun = function(client, arguments)
            local target = arguments[1]
            local reason = arguments[2] or "No reason provided"
            target:Kick(reason)
            client:notify("Kicked " .. target:Name())
        end,
        adminOnly = true,
        desc = "Kick a player from the server"
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Register complex command with aliases, custom access check, and privilege
    lia.command.add("ban", {
        arguments = {
            {type = "player", name = "target"},
            {type = "string", name = "reason"},
            {type = "number", name = "duration", optional = true}
        },
        alias = {"tempban", "tban"},
        onRun = function(client, arguments)
            local target = arguments[1]
            local reason = arguments[2]
            local duration = arguments[3] or 0
            -- Ban logic here
        end,
        onCheckAccess = function(client, command, data)
            return client:IsSuperAdmin() or client:hasPrivilege("moderation")
        end,
        privilege = "moderation",
        desc = "Ban a player temporarily or permanently"
    })

```

---

### lia.command.hasAccess

#### 📋 Purpose
Checks if a client has access to execute a specific command based on privileges, faction, and class permissions

#### ⏰ When Called
Before command execution to verify player permissions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to use the command |
| `command` | **string** | Command name |
| `data` | **table, optional** | Command data table |

#### ↩️ Returns
* boolean, string - Access granted status and privilege name

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check basic command access
    local hasAccess, privilege = lia.command.hasAccess(client, "hello")
    if hasAccess then
        client:notify("You can use the hello command!")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check admin command access with custom privilege
    local hasAccess, privilege = lia.command.hasAccess(client, "kick")
    if not hasAccess then
        client:notifyError("You need " .. privilege .. " to use this command!")
        return
    end
    -- Execute kick command

```

#### ⚙️ High Complexity
```lua
    -- High: Check access with faction/class specific permissions
    local hasAccess, privilege = lia.command.hasAccess(client, "arrest")
    if hasAccess then
        local char = client:getChar()
        local faction = lia.faction.indices[char:getFaction()]
        if faction and faction.commands and faction.commands["arrest"] then
            client:notify("Faction command access granted!")
        elseif client:hasPrivilege(privilege) then
            client:notify("Privilege-based access granted!")
        end
    else
        client:notifyError("Access denied: " .. privilege)
    end

```

---

### lia.command.extractArgs

#### 📋 Purpose
Parses command text and extracts individual arguments, handling quoted strings and spaces

#### ⏰ When Called
When parsing command input to separate arguments for command execution

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | The command text to parse (excluding the command name) |

#### ↩️ Returns
* table - Array of extracted argument strings

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Extract basic arguments
    local args = lia.command.extractArgs("player1 Hello World")
    -- Returns: {"player1", "Hello", "World"}

```

#### 📊 Medium Complexity
```lua
    -- Medium: Extract arguments with quoted strings
    local args = lia.command.extractArgs('player1 "Hello World" true')
    -- Returns: {"player1", "Hello World", "true"}

```

#### ⚙️ High Complexity
```lua
    -- High: Extract complex arguments with mixed quotes and spaces
    local args = lia.command.extractArgs('"John Doe" "This is a long message with spaces" 123 true')
    -- Returns: {"John Doe", "This is a long message with spaces", "123", "true"}
    -- Process arguments for command
    local target = args[1]
    local message = args[2]
    local duration = tonumber(args[3])
    local silent = args[4] == "true"

```

---

### lia.command.run

#### 📋 Purpose
Executes a registered command for a client with proper error handling and result processing

#### ⏰ When Called
When a command needs to be executed after parsing and access validation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player executing the command |
| `command` | **string** | Command name |
| `arguments` | **table** | Command arguments |

#### ↩️ Returns
* void

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Execute a basic command
    lia.command.run(client, "hello", {})
    -- Executes the hello command for the client

```

#### 📊 Medium Complexity
```lua
    -- Medium: Execute command with arguments
    local args = {"player1", "Hello World"}
    lia.command.run(client, "pm", args)
    -- Executes PM command with target and message

```

#### ⚙️ High Complexity
```lua
    -- High: Execute command with error handling and logging
    local command = "kick"
    local args = {target:Name(), "Rule violation"}
    -- Check access first
    local hasAccess = lia.command.hasAccess(client, command)
    if hasAccess then
        lia.command.run(client, command, args)
        lia.log.add(client, "command", "/" .. command .. " " .. table.concat(args, " "))
    else
        client:notifyError("Access denied!")
    end

```

---

### lia.command.parse

#### 📋 Purpose
Parses command text input, validates arguments, and executes commands with proper error handling

#### ⏰ When Called
When processing player chat input or console commands that start with "/"

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player executing the command |
| `text` | **string** | Full command text |
| `realCommand` | **string, optional** | Pre-parsed command name |
| `Pre` | **unknown** | parsed command name |
| `Pre` | **unknown** | parsed command name |
| `arguments` | **table, optional** | Pre-parsed arguments |
| `Pre` | **unknown** | parsed arguments |
| `Pre` | **unknown** | parsed arguments |

#### ↩️ Returns
* boolean - True if command was processed, false if not a command

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Parse basic command from chat
    local success = lia.command.parse(client, "/hello")
    if success then
        -- Command was processed
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Parse command with arguments
    local success = lia.command.parse(client, "/kick player1 Rule violation")
    if success then
        -- Kick command was executed
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Parse command with argument validation and prompting
    local text = "/pm"
    local success = lia.command.parse(client, text)
    if success then
        -- If arguments are missing, client will be prompted
        -- If arguments are valid, PM command will execute
    else
        -- Not a command, treat as regular chat
        lia.chatbox.add(client, text)
    end

```

---

### lia.command.openArgumentPrompt

#### 📋 Purpose
Creates a GUI prompt for users to input missing command arguments with validation

#### ⏰ When Called
When a command is executed with missing required arguments

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmdKey` | **string** | Command name |
| `missing` | **table** | Array of missing argument names |
| `prefix` | **table** | Already provided arguments |

#### ↩️ Returns
* void

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open prompt for single missing argument
    lia.command.openArgumentPrompt("pm", {"target"}, {})
    -- Shows GUI to select target player for PM command

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open prompt with partial arguments
    lia.command.openArgumentPrompt("kick", {"reason"}, {"player1"})
    -- Shows GUI to enter reason, player1 already provided

```

#### ⚙️ High Complexity
```lua
    -- High: Open prompt for complex command with multiple argument types
    lia.command.openArgumentPrompt("ban", {"reason", "duration"}, {"player1"})
    -- Shows GUI with:
    -- - Reason text field
    -- - Duration number field
    -- - Submit button (enabled when all required fields filled)
    -- - Cancel button

```

---

### lia.ctrl:OnValueChange

#### 📋 Purpose
Creates a GUI prompt for users to input missing command arguments with validation

#### ⏰ When Called
When a command is executed with missing required arguments

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmdKey` | **string** | Command name |
| `missing` | **table** | Array of missing argument names |
| `prefix` | **table** | Already provided arguments |

#### ↩️ Returns
* void

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open prompt for single missing argument
    lia.command.openArgumentPrompt("pm", {"target"}, {})
    -- Shows GUI to select target player for PM command

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open prompt with partial arguments
    lia.command.openArgumentPrompt("kick", {"reason"}, {"player1"})
    -- Shows GUI to enter reason, player1 already provided

```

#### ⚙️ High Complexity
```lua
    -- High: Open prompt for complex command with multiple argument types
    lia.command.openArgumentPrompt("ban", {"reason", "duration"}, {"player1"})
    -- Shows GUI with:
    -- - Reason text field
    -- - Duration number field
    -- - Submit button (enabled when all required fields filled)
    -- - Cancel button

```

---

### lia.ctrl:OnTextChanged

#### 📋 Purpose
Creates a GUI prompt for users to input missing command arguments with validation

#### ⏰ When Called
When a command is executed with missing required arguments

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmdKey` | **string** | Command name |
| `missing` | **table** | Array of missing argument names |
| `prefix` | **table** | Already provided arguments |

#### ↩️ Returns
* void

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open prompt for single missing argument
    lia.command.openArgumentPrompt("pm", {"target"}, {})
    -- Shows GUI to select target player for PM command

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open prompt with partial arguments
    lia.command.openArgumentPrompt("kick", {"reason"}, {"player1"})
    -- Shows GUI to enter reason, player1 already provided

```

#### ⚙️ High Complexity
```lua
    -- High: Open prompt for complex command with multiple argument types
    lia.command.openArgumentPrompt("ban", {"reason", "duration"}, {"player1"})
    -- Shows GUI with:
    -- - Reason text field
    -- - Duration number field
    -- - Submit button (enabled when all required fields filled)
    -- - Cancel button

```

---

### lia.ctrl:OnChange

#### 📋 Purpose
Creates a GUI prompt for users to input missing command arguments with validation

#### ⏰ When Called
When a command is executed with missing required arguments

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmdKey` | **string** | Command name |
| `missing` | **table** | Array of missing argument names |
| `prefix` | **table** | Already provided arguments |

#### ↩️ Returns
* void

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open prompt for single missing argument
    lia.command.openArgumentPrompt("pm", {"target"}, {})
    -- Shows GUI to select target player for PM command

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open prompt with partial arguments
    lia.command.openArgumentPrompt("kick", {"reason"}, {"player1"})
    -- Shows GUI to enter reason, player1 already provided

```

#### ⚙️ High Complexity
```lua
    -- High: Open prompt for complex command with multiple argument types
    lia.command.openArgumentPrompt("ban", {"reason", "duration"}, {"player1"})
    -- Shows GUI with:
    -- - Reason text field
    -- - Duration number field
    -- - Submit button (enabled when all required fields filled)
    -- - Cancel button

```

---

### lia.ctrl:OnSelect

#### 📋 Purpose
Creates a GUI prompt for users to input missing command arguments with validation

#### ⏰ When Called
When a command is executed with missing required arguments

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmdKey` | **string** | Command name |
| `missing` | **table** | Array of missing argument names |
| `prefix` | **table** | Already provided arguments |

#### ↩️ Returns
* void

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open prompt for single missing argument
    lia.command.openArgumentPrompt("pm", {"target"}, {})
    -- Shows GUI to select target player for PM command

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open prompt with partial arguments
    lia.command.openArgumentPrompt("kick", {"reason"}, {"player1"})
    -- Shows GUI to enter reason, player1 already provided

```

#### ⚙️ High Complexity
```lua
    -- High: Open prompt for complex command with multiple argument types
    lia.command.openArgumentPrompt("ban", {"reason", "duration"}, {"player1"})
    -- Shows GUI with:
    -- - Reason text field
    -- - Duration number field
    -- - Submit button (enabled when all required fields filled)
    -- - Cancel button

```

---

### lia.command.send

#### 📋 Purpose
Sends a command execution request from client to server via network

#### ⏰ When Called
When client needs to execute a command on the server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `command` | **string** | Command name |

#### ↩️ Returns
* void

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send basic command
    lia.command.send("hello")
    -- Sends hello command to server

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send command with arguments
    lia.command.send("pm", "player1", "Hello there!")
    -- Sends PM command with target and message

```

#### ⚙️ High Complexity
```lua
    -- High: Send complex command with multiple arguments
    local target = "player1"
    local reason = "Rule violation"
    local duration = 300
    lia.command.send("ban", target, reason, duration)
    -- Sends ban command with all parameters

```

---

