# Flags Library

This page documents the functions for working with player flags and permissions.

---

## Overview

The flags library (`lia.flag`) provides a comprehensive system for managing player flags, permissions, and special abilities in the Lilia framework, serving as the core authorization and privilege management system for all player capabilities. This library handles sophisticated flag registration with support for hierarchical permission structures, conditional flags based on player state, and dynamic flag assignment based on gameplay achievements or administrative decisions. The system features advanced permission checking mechanisms with efficient lookup algorithms, caching strategies, and real-time validation to ensure optimal performance even with complex permission hierarchies. It includes comprehensive flag management functionality with bulk operations, inheritance systems, and automatic cleanup for temporary or expired flags. The library provides integration with all framework systems including commands, inventory access, faction permissions, and administrative tools, ensuring consistent authorization across all player interactions. Additional features include flag auditing and logging systems, permission debugging tools, and administrative interfaces for managing player privileges, making it essential for maintaining server security, implementing roleplay restrictions, and creating balanced gameplay experiences.

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








