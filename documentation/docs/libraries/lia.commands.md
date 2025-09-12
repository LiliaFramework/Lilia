# Commands Library

This page documents the functions for working with commands and command management.

---

## Overview

The commands library (`lia.command`) provides a comprehensive system for creating, managing, and executing server commands in the Lilia framework, serving as the core command infrastructure that enables powerful administrative and gameplay functionality through structured command interfaces. This library handles sophisticated command management with support for complex command registration, advanced argument parsing, and dynamic command execution that enables rich administrative capabilities and player interaction systems. The system features advanced access control with support for permission-based command execution, role-based command restrictions, and hierarchical command privileges that ensure secure and organized command management throughout the server. It includes comprehensive argument parsing with support for typed arguments, optional parameters, and complex command syntax that enables intuitive and powerful command interfaces for both administrators and players. The library provides robust command execution with support for error handling, command validation, and comprehensive logging that ensures reliable command processing and maintains system integrity. Additional features include integration with the framework's permission system for command access control, performance optimization for high-frequency command usage, and comprehensive administrative tools that enable effective command management and provide powerful server control capabilities, making it essential for creating sophisticated server management systems and engaging player interaction features that enhance the overall gameplay experience.

---

### lia.command.buildSyntaxFromArguments

**Purpose**

Builds a syntax string from command arguments for display purposes.

**Parameters**

* `arguments` (*table*): Table of argument definitions.

**Returns**

* `syntax` (*string*): The formatted syntax string.

**Realm**

Shared.

**Example Usage**

```lua
-- Build syntax from arguments
local arguments = {
    {name = "player", type = "string"},
    {name = "amount", type = "number"}
}
local syntax = lia.command.buildSyntaxFromArguments(arguments)
print("Syntax:", syntax) -- Output: "<player> <amount>"

-- Use in command help
local function showCommandHelp(commandName)
    local command = lia.command.get(commandName)
    if command then
        local syntax = lia.command.buildSyntaxFromArguments(command.arguments or {})
        print("Usage: " .. commandName .. " " .. syntax)
    end
end

-- Use in command registration
lia.command.add("giveitem", {
    arguments = {
        {name = "player", type = "string"},
        {name = "item", type = "string"},
        {name = "amount", type = "number", default = 1}
    },
    onRun = function(client, arguments)
        -- Command logic here
    end
})
```

---

### lia.command.add

**Purpose**

Adds a new command to the command system.

**Parameters**

* `name` (*string*): The name of the command.
* `data` (*table*): The command data table containing arguments, onRun, etc.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a simple command
lia.command.add("hello", {
    onRun = function(client, arguments)
        client:notify("Hello, " .. client:Name() .. "!")
    end
})

-- Add a command with arguments
lia.command.add("giveitem", {
    arguments = {
        {name = "player", type = "string"},
        {name = "item", type = "string"},
        {name = "amount", type = "number", default = 1}
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            local item = lia.item.get(arguments[2])
            if item then
                target:getChar():getInv():add(item, arguments[3])
                client:notify("Gave " .. arguments[3] .. " " .. item.name .. " to " .. target:Name())
            end
        end
    end
})

-- Add a command with access control
lia.command.add("kick", {
    arguments = {
        {name = "player", type = "string"},
        {name = "reason", type = "string", default = "No reason provided"}
    },
    privilege = "Kick Players",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            target:Kick(arguments[2])
            client:notify("Kicked " .. target:Name())
        end
    end
})
```

---

### lia.command.hasAccess

**Purpose**

Checks if a client has access to a command.

**Parameters**

* `client` (*Player*): The client to check.
* `command` (*table*): The command data table.

**Returns**

* `hasAccess` (*boolean*): True if the client has access.

**Realm**

Server.

**Example Usage**

```lua
-- Check if client has access to a command
local function canUseCommand(client, commandName)
    local command = lia.command.get(commandName)
    if command then
        return lia.command.hasAccess(client, command)
    end
    return false
end

-- Use in command execution
lia.command.add("adminonly", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        if not lia.command.hasAccess(client, lia.command.get("adminonly")) then
            client:notify("You don't have permission to use this command")
            return
        end
        -- Command logic here
    end
})

-- Use in a function
local function checkCommandAccess(client, commandName)
    local command = lia.command.get(commandName)
    if command and lia.command.hasAccess(client, command) then
        return true
    else
        client:notify("Access denied")
        return false
    end
end
```

---

### lia.command.extractArgs

**Purpose**

Extracts arguments from a command string.

**Parameters**

* `text` (*string*): The command text to parse.

**Returns**

* `args` (*table*): Table of extracted arguments.

**Realm**

Shared.

**Example Usage**

```lua
-- Extract arguments from command text
local text = "giveitem john weapon_ak47 1"
local args = lia.command.extractArgs(text)
print("Arguments:", table.concat(args, ", "))

-- Use in command processing
local function processCommand(text)
    local args = lia.command.extractArgs(text)
    local commandName = args[1]
    table.remove(args, 1) -- Remove command name
    
    local command = lia.command.get(commandName)
    if command then
        -- Process command with arguments
    end
end

-- Use in chat command parsing
local function parseChatCommand(text)
    if text:sub(1, 1) == "/" then
        local args = lia.command.extractArgs(text:sub(2))
        return args
    end
    return nil
end
```

---

### lia.command.run

**Purpose**

Runs a command with the given arguments.

**Parameters**

* `client` (*Player*): The client running the command.
* `commandName` (*string*): The name of the command to run.
* `arguments` (*table*): The arguments for the command.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Run a command programmatically
local function runCommand(client, commandName, ...)
    local args = {...}
    lia.command.run(client, commandName, args)
end

-- Use in a function
local function executeAdminCommand(client, commandName, target, reason)
    if lia.command.hasAccess(client, lia.command.get(commandName)) then
        lia.command.run(client, commandName, {target, reason})
    else
        client:notify("Access denied")
    end
end

-- Use in a timer
timer.Create("AutoCommand", 60, 0, function()
    for _, client in ipairs(player.GetAll()) do
        if client:IsValid() then
            lia.command.run(client, "checkstatus", {})
        end
    end
end)
```

---

### lia.command.parse

**Purpose**

Parses a command string and executes it.

**Parameters**

* `client` (*Player*): The client running the command.
* `text` (*string*): The command text to parse.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Parse and execute a command
local function executeCommand(client, text)
    lia.command.parse(client, text)
end

-- Use in chat hook
hook.Add("PlayerSay", "CommandParser", function(client, text, teamChat)
    if text:sub(1, 1) == "/" then
        lia.command.parse(client, text:sub(2))
        return ""
    end
end)

-- Use in console command
concommand.Add("lia_command", function(client, command, args)
    local text = table.concat(args, " ")
    lia.command.parse(client, text)
end)
```

---

### lia.command.openArgumentPrompt

**Purpose**

Opens an argument prompt for a command.

**Parameters**

* `client` (*Player*): The client to show the prompt to.
* `commandName` (*string*): The name of the command.
* `arguments` (*table*): The arguments for the command.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Open argument prompt for a command
local function promptForArguments(client, commandName)
    local command = lia.command.get(commandName)
    if command and command.arguments then
        lia.command.openArgumentPrompt(client, commandName, command.arguments)
    end
end

-- Use in a menu
local function createCommandMenu()
    local menu = vgui.Create("DFrame")
    local button = vgui.Create("DButton", menu)
    
    button.DoClick = function()
        lia.command.openArgumentPrompt(LocalPlayer(), "giveitem", {
            {name = "player", type = "string"},
            {name = "item", type = "string"},
            {name = "amount", type = "number"}
        })
    end
end
```

---

### lia.command.send

**Purpose**

Sends a command to the server.

**Parameters**

* `commandName` (*string*): The name of the command to send.
* `arguments` (*table*): The arguments for the command.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Send a command to the server
local function sendCommand(commandName, ...)
    local args = {...}
    lia.command.send(commandName, args)
end

-- Use in a button
local function createCommandButton(commandName, args)
    local button = vgui.Create("DButton")
    button.DoClick = function()
        lia.command.send(commandName, args)
    end
    return button
end

-- Use in a function
local function giveItemToPlayer(playerName, itemName, amount)
    lia.command.send("giveitem", {playerName, itemName, amount})
end
```

---

## Definitions

# Command Fields

This document describes the table passed to `lia.command.add`.  Each key in the

table customizes how the command behaves, who can run it and how it appears in

admin utilities.

All fields are optional unless noted otherwise.

---

## Overview

When you register a command with `lia.command.add`, you provide a table of

fields controlling its name, permissions and execution.  Except for

`onRun`, every field is optional.

The command name itself is the first argument to `lia.command.add` and is stored in lowercase.

---

## Field Summary

| Field | Type | Default | Description |
|---|---|---|---|
| `alias` | `string` or `table` | `nil` | Alternative names for the command. |
| `adminOnly` | `boolean` | `false` | Restrict to admins (registers a CAMI privilege). |
| `superAdminOnly` | `boolean` | `false` | Restrict to superadmins (registers a CAMI privilege). |
| `privilege` | `string` | `nil` | Custom CAMI privilege name (defaults to command name). |
| `arguments` | `table` | `{}` | Ordered argument definitions used to build help text. |
| `desc` | `string` | `""` | Short description shown in command lists and menus. |
| `AdminStick` | `table` | `nil` | Defines how the command appears in admin utilities. |
| `onRun(client, args)` | `function(client, table)` | **required** | Function executed when the command is invoked. |

---

## Field Details

### Aliases & Permissions

#### `alias`

**Type:**

`string` or `table`

**Description:**

One or more alternative command names that trigger the same behavior.

Aliases are automatically lower-cased and behave exactly like the main command name.

**Example Usage:**

```lua
-- as a single string
alias = "chargiveflag"

-- or multiple aliases
alias = {"chargiveflag", "giveflag"}
```

**Note:** When using aliases with `adminOnly` or `superAdminOnly`, privileges are automatically registered for each alias. For example, if a command has `adminOnly = true` and alias `"testcmd"`, the privilege `command_testcmd` will be registered and required to use that alias.

---

#### `adminOnly`

**Type:**

`boolean`

**Description:**

If `true`, only players with the generated CAMI privilege may run the command. The privilege name is automatically registered as `Commands - <privilege>`.

**Example Usage:**

```lua
adminOnly = true
```

---

#### `superAdminOnly`

**Type:**

`boolean`

**Description:**

If `true`, only superadmins with the automatically registered privilege `Commands - <privilege>` can use the command.

**Example Usage:**

```lua
superAdminOnly = true
```

---

#### `privilege`

**Type:**

`string`

**Description:**

Custom CAMI privilege name checked when running the command. If omitted, `adminOnly` or `superAdminOnly` register `Commands - <command name>`.

**Example Usage:**

```lua
privilege = "Manage Doors"
```

---

### Arguments & Description

#### `arguments`

**Type:**

`table`

**Description:**

Ordered list defining each command argument. Every entry may contain:

* `name` – Argument name shown to the user.
* `type` – One of `player`, `bool`, `table`, or `string`.
* `optional` – Set to `true` if the argument is optional.
* `description` – Optional human-readable help text.
* `options` – Table or function returning options for `table` type.
* `filter` – Function to filter players for `player` type.

The displayed syntax string is generated automatically from these definitions.

**Example Usage:**

```lua
arguments = {
    {name = "target", type = "player"},
    {name = "reason", type = "string", optional = true}
}
```

---

#### `desc`

**Type:**

`string`

**Description:**

Short description of what the command does, displayed in command lists and menus.

**Example Usage:**

```lua
desc = "Purchase a door if it is available and you can afford it."
```

---

### AdminStick Integration

#### `AdminStick`

**Type:**

`table`

**Description:**

Defines how the command appears in admin utility menus. Common keys:

All keys are optional; if omitted the command simply will not appear in the Admin Stick menu.

* `Name` (string) – Text shown on the menu button.

* `Category` (string) – Top-level grouping.

* `SubCategory` (string) – Secondary grouping under the main category.

* `Icon` (string) – 16×16 icon path.

* `TargetClass` (string) – Limit the command to a specific entity class when using the Admin Stick.

Custom categories and subcategories can be added through the Administration module using
`addAdminStickCategory(key, data)` and `addAdminStickSubCategory(category, key, data)`.

**Example Usage:**

```lua
AdminStick = {
    Name        = "Restock Vendor",
    Category    = "Vendors",
    SubCategory = "Management",
    Icon        = "icon16/box.png",
    TargetClass = "lia_vendor"
}
```

---

### Execution Hook

#### `onRun`

**Type:**

`function(client, table)`

**Description:**

Function called when the command is executed. `args` is a table of parsed arguments. Return a string to send a message back to the caller, or return nothing for silent execution.

Strings starting with `@` are interpreted as localization keys for `notifyLocalized`.

**Example Usage:**

```lua
onRun = function(client, arguments)
    local target = lia.util.findPlayer(client, arguments[1])
    if target then
        target:Kill()
    end
end
```

---

### Full Command Example

```lua
lia.command.add("restockvendor", {
    superAdminOnly = true,                -- restrict to super administrators
    privilege = "Manage Vendors",        -- custom privilege checked before run
    desc = "Restock the vendor you are looking at.", -- shown in command lists
    arguments = {{name = "target", type = "player"}}, -- argument definition
    alias = {"vendorrestock"},           -- other names that trigger the command
    AdminStick = {
        Name        = "Restock Vendor",  -- text on the Admin Stick button
        Category    = "Vendors",        -- top-level category
        SubCategory = "Management",     -- subcategory in the menu
        Icon        = "icon16/box.png",  -- icon displayed next to the entry
        TargetClass = "lia_vendor"       -- only usable when aiming at this class
    },
    onRun = function(client, args)
        -- grab the entity the admin is looking at
        local vendor = client:getTracedEntity()
        if IsValid(vendor) and vendor:GetClass() == "lia_vendor" then
            -- reset all purchasable item stock counts
            for id, itemData in pairs(vendor.items) do
                if itemData[2] and itemData[4] then
                    vendor.items[id][2] = itemData[4]
                end
            end
            client:notifyLocalized("vendorRestocked")
        else
            client:notifyLocalized("NotLookingAtValidVendor")
        end
    end
})
```

---

```lua
lia.command.add("goto", {
    adminOnly = true,                    -- only admins may run this command
    arguments = {{name = "target", type = "player"}}, -- argument definition
    desc = "Teleport to the specified player.", -- short description
    onRun = function(client, args)
        -- look up the target player from the first argument
        local target = lia.util.findPlayer(client, args[1])
        if not target then
            return "@targetNotFound"     -- localization key sent when player missing
        end
        client:SetPos(target:GetPos())   -- move to the target's position
    end
})
```