# Commands Library

This page documents the functions for working with commands and command management.

---

## Overview

The commands library (`lia.command`) provides a comprehensive system for creating, managing, and executing server commands in the Lilia framework. It includes command registration, access control, argument parsing, and command execution functionality.

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

### lia.command.findPlayer

**Purpose**

Finds a player by name or SteamID.

**Parameters**

* `client` (*Player*): The client requesting the search.
* `identifier` (*string*): The player identifier to search for.

**Returns**

* `player` (*Player*): The found player or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Find a player by name
local function findPlayerByName(client, name)
    return lia.command.findPlayer(client, name)
end

-- Use in a command
lia.command.add("teleport", {
    arguments = {
        {name = "player", type = "string"}
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            client:SetPos(target:GetPos())
            client:notify("Teleported to " .. target:Name())
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a function
local function teleportToPlayer(client, playerName)
    local target = lia.command.findPlayer(client, playerName)
    if target then
        client:SetPos(target:GetPos())
        return true
    end
    return false
end
```

---

### lia.command.get

**Purpose**

Gets a command by name.

**Parameters**

* `name` (*string*): The name of the command to get.

**Returns**

* `command` (*table*): The command data table or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a command
local function getCommand(name)
    return lia.command.get(name)
end

-- Use in a function
local function checkCommandExists(name)
    local command = lia.command.get(name)
    return command ~= nil
end

-- Use in command help
local function showCommandHelp(commandName)
    local command = lia.command.get(commandName)
    if command then
        print("Command: " .. commandName)
        print("Arguments: " .. (command.arguments and table.concat(command.arguments, " ") or "None"))
    end
end
```

---

### lia.command.list

**Purpose**

Gets a list of all registered commands.

**Parameters**

*None*

**Returns**

* `commands` (*table*): Table of all registered commands.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all commands
local function getAllCommands()
    return lia.command.list()
end

-- Use in a function
local function showAllCommands()
    local commands = lia.command.list()
    for name, command in pairs(commands) do
        print("Command: " .. name)
    end
end

-- Use in a command browser
local function createCommandBrowser()
    local commands = lia.command.list()
    local list = vgui.Create("DListView")
    
    for name, command in pairs(commands) do
        list:AddLine(name, command.privilege or "None")
    end
    
    return list
end
```

---

### lia.command.remove

**Purpose**

Removes a command from the command system.

**Parameters**

* `name` (*string*): The name of the command to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove a command
local function removeCommand(name)
    lia.command.remove(name)
end

-- Use in a function
local function cleanupCommands()
    local commandsToRemove = {"oldcommand1", "oldcommand2"}
    for _, name in ipairs(commandsToRemove) do
        lia.command.remove(name)
    end
end

-- Use in a command
lia.command.add("removecommand", {
    arguments = {
        {name = "command", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.command.remove(arguments[1])
        client:notify("Command removed: " .. arguments[1])
    end
})
```

---

### lia.command.clear

**Purpose**

Clears all registered commands.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Clear all commands
local function clearAllCommands()
    lia.command.clear()
end

-- Use in a function
local function resetCommands()
    lia.command.clear()
    -- Re-register default commands
    lia.command.add("hello", {
        onRun = function(client, arguments)
            client:notify("Hello!")
        end
    })
end

-- Use in a command
lia.command.add("resetcommands", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.command.clear()
        client:notify("All commands cleared")
    end
})
```