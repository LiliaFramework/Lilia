# Flags Library

This page documents the functions for working with player flags and permissions.

---

## Overview

The flags library (`lia.flag`) provides a comprehensive system for managing player flags, permissions, and special abilities in the Lilia framework. It includes flag registration, checking, and management functionality.

---

### lia.flag.add

**Purpose**

Adds a flag to a player.

**Parameters**

* `client` (*Player*): The player to add the flag to.
* `flag` (*string*): The flag to add.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add a flag to a player
local function addFlag(client, flag)
    lia.flag.add(client, flag)
end

-- Use in a function
local function giveAdminFlag(client)
    lia.flag.add(client, "admin")
    client:notify("Admin flag added")
end

-- Use in a command
lia.command.add("addflag", {
    arguments = {
        {name = "player", type = "string"},
        {name = "flag", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            lia.flag.add(target, arguments[2])
            client:notify("Flag added to " .. target:Name())
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a function
local function giveSpecialFlags(client)
    lia.flag.add(client, "vip")
    lia.flag.add(client, "donator")
    lia.flag.add(client, "beta_tester")
    client:notify("Special flags added")
end
```

---

### lia.flag.onSpawn

**Purpose**

Handles flag-related actions when a player spawns.

**Parameters**

* `client` (*Player*): The player that spawned.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Handle flag spawn actions
local function onPlayerSpawn(client)
    lia.flag.onSpawn(client)
end

-- Use in a hook
hook.Add("PlayerSpawn", "HandleFlags", function(client)
    lia.flag.onSpawn(client)
end)

-- Use in a function
local function spawnWithFlags(client)
    lia.flag.onSpawn(client)
    print("Flags processed for " .. client:Name())
end

-- Use in a function
local function checkSpawnFlags(client)
    lia.flag.onSpawn(client)
    if client:hasFlag("admin") then
        client:notify("Admin privileges active")
    end
end
```

---

### lia.flag.remove

**Purpose**

Removes a flag from a player.

**Parameters**

* `client` (*Player*): The player to remove the flag from.
* `flag` (*string*): The flag to remove.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Remove a flag from a player
local function removeFlag(client, flag)
    lia.flag.remove(client, flag)
end

-- Use in a function
local function removeAdminFlag(client)
    lia.flag.remove(client, "admin")
    client:notify("Admin flag removed")
end

-- Use in a command
lia.command.add("removeflag", {
    arguments = {
        {name = "player", type = "string"},
        {name = "flag", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            lia.flag.remove(target, arguments[2])
            client:notify("Flag removed from " .. target:Name())
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a function
local function clearAllFlags(client)
    local flags = {"admin", "vip", "donator", "beta_tester"}
    for _, flag in ipairs(flags) do
        lia.flag.remove(client, flag)
    end
    client:notify("All flags removed")
end
```

---

### lia.flag.has

**Purpose**

Checks if a player has a specific flag.

**Parameters**

* `client` (*Player*): The player to check.
* `flag` (*string*): The flag to check for.

**Returns**

* `hasFlag` (*boolean*): True if the player has the flag.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if player has flag
local function hasFlag(client, flag)
    return lia.flag.has(client, flag)
end

-- Use in a function
local function checkAdminStatus(client)
    if lia.flag.has(client, "admin") then
        print(client:Name() .. " is an admin")
        return true
    else
        print(client:Name() .. " is not an admin")
        return false
    end
end

-- Use in a function
local function checkVIPStatus(client)
    if lia.flag.has(client, "vip") then
        client:notify("VIP privileges active")
        return true
    else
        client:notify("You are not a VIP")
        return false
    end
end

-- Use in a command
lia.command.add("checkflag", {
    arguments = {
        {name = "player", type = "string"},
        {name = "flag", type = "string"}
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            local hasFlag = lia.flag.has(target, arguments[2])
            client:notify(target:Name() .. " " .. (hasFlag and "has" or "does not have") .. " the " .. arguments[2] .. " flag")
        else
            client:notify("Player not found")
        end
    end
})
```

---

### lia.flag.getAll

**Purpose**

Gets all flags for a player.

**Parameters**

* `client` (*Player*): The player to get flags for.

**Returns**

* `flags` (*table*): Table of player flags.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all player flags
local function getAllFlags(client)
    return lia.flag.getAll(client)
end

-- Use in a function
local function showPlayerFlags(client)
    local flags = lia.flag.getAll(client)
    if flags and #flags > 0 then
        print("Flags for " .. client:Name() .. ":")
        for _, flag in ipairs(flags) do
            print("- " .. flag)
        end
    else
        print(client:Name() .. " has no flags")
    end
end

-- Use in a function
local function getFlagCount(client)
    local flags = lia.flag.getAll(client)
    return flags and #flags or 0
end

-- Use in a command
lia.command.add("listflags", {
    arguments = {
        {name = "player", type = "string"}
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            local flags = lia.flag.getAll(target)
            if flags and #flags > 0 then
                client:notify("Flags: " .. table.concat(flags, ", "))
            else
                client:notify("No flags found")
            end
        else
            client:notify("Player not found")
        end
    end
})
```

---

### lia.flag.clear

**Purpose**

Clears all flags from a player.

**Parameters**

* `client` (*Player*): The player to clear flags from.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Clear all player flags
local function clearFlags(client)
    lia.flag.clear(client)
end

-- Use in a function
local function resetPlayerFlags(client)
    lia.flag.clear(client)
    client:notify("All flags cleared")
end

-- Use in a command
lia.command.add("clearflags", {
    arguments = {
        {name = "player", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            lia.flag.clear(target)
            client:notify("All flags cleared from " .. target:Name())
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a function
local function resetAllPlayerFlags()
    for _, client in ipairs(player.GetAll()) do
        lia.flag.clear(client)
    end
    print("All player flags cleared")
end
```

---

### lia.flag.register

**Purpose**

Registers a new flag type.

**Parameters**

* `flagName` (*string*): The name of the flag.
* `flagData` (*table*): The flag data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a flag type
local function registerFlag(flagName, flagData)
    lia.flag.register(flagName, flagData)
end

-- Use in a function
local function createVIPFlag()
    lia.flag.register("vip", {
        name = "VIP",
        description = "VIP player privileges",
        color = Color(255, 215, 0)
    })
    print("VIP flag registered")
end

-- Use in a function
local function createDonatorFlag()
    lia.flag.register("donator", {
        name = "Donator",
        description = "Donator privileges",
        color = Color(0, 255, 0)
    })
    print("Donator flag registered")
end

-- Use in a function
local function createBetaTesterFlag()
    lia.flag.register("beta_tester", {
        name = "Beta Tester",
        description = "Beta testing privileges",
        color = Color(255, 0, 255)
    })
    print("Beta tester flag registered")
end
```

---

### lia.flag.get

**Purpose**

Gets flag data by name.

**Parameters**

* `flagName` (*string*): The flag name.

**Returns**

* `flagData` (*table*): The flag data table or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get flag data
local function getFlagData(flagName)
    return lia.flag.get(flagName)
end

-- Use in a function
local function showFlagInfo(flagName)
    local flagData = lia.flag.get(flagName)
    if flagData then
        print("Flag: " .. flagData.name)
        print("Description: " .. flagData.description)
        print("Color: " .. tostring(flagData.color))
    else
        print("Flag not found: " .. flagName)
    end
end

-- Use in a function
local function checkFlagExists(flagName)
    local flagData = lia.flag.get(flagName)
    return flagData ~= nil
end

-- Use in a command
lia.command.add("flaginfo", {
    arguments = {
        {name = "flag", type = "string"}
    },
    onRun = function(client, arguments)
        local flagData = lia.flag.get(arguments[1])
        if flagData then
            client:notify("Flag: " .. flagData.name .. " - " .. flagData.description)
        else
            client:notify("Flag not found")
        end
    end
})
```

---

### lia.flag.list

**Purpose**

Gets a list of all registered flags.

**Parameters**

*None*

**Returns**

* `flags` (*table*): Table of all registered flags.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all flags
local function getAllFlags()
    return lia.flag.list()
end

-- Use in a function
local function showAllFlags()
    local flags = lia.flag.list()
    print("Available flags:")
    for _, flag in ipairs(flags) do
        print("- " .. flag)
    end
end

-- Use in a function
local function getFlagCount()
    local flags = lia.flag.list()
    return #flags
end

-- Use in a command
lia.command.add("listallflags", {
    onRun = function(client, arguments)
        local flags = lia.flag.list()
        if flags and #flags > 0 then
            client:notify("Available flags: " .. table.concat(flags, ", "))
        else
            client:notify("No flags registered")
        end
    end
})
```

---

### lia.flag.remove

**Purpose**

Removes a flag type from the system.

**Parameters**

* `flagName` (*string*): The flag name to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove a flag type
local function removeFlagType(flagName)
    lia.flag.remove(flagName)
end

-- Use in a function
local function removeOldFlag(flagName)
    lia.flag.remove(flagName)
    print("Flag type removed: " .. flagName)
end

-- Use in a function
local function cleanupFlags()
    local oldFlags = {"old_flag1", "old_flag2", "old_flag3"}
    for _, flag in ipairs(oldFlags) do
        lia.flag.remove(flag)
    end
    print("Old flags cleaned up")
end

-- Use in a command
lia.command.add("removeflagtype", {
    arguments = {
        {name = "flag", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.flag.remove(arguments[1])
        client:notify("Flag type removed: " .. arguments[1])
    end
})
```

---

### lia.flag.clear

**Purpose**

Clears all flag types from the system.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Clear all flag types
local function clearAllFlagTypes()
    lia.flag.clear()
end

-- Use in a function
local function resetFlagSystem()
    lia.flag.clear()
    print("Flag system reset")
end

-- Use in a function
local function reloadFlags()
    lia.flag.clear()
    -- Re-register default flags
    lia.flag.register("admin", {name = "Admin", description = "Administrator privileges"})
    lia.flag.register("vip", {name = "VIP", description = "VIP privileges"})
    print("Flags reloaded")
end

-- Use in a command
lia.command.add("clearallflags", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.flag.clear()
        client:notify("All flag types cleared")
    end
})
```