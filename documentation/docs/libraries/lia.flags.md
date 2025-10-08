# Flags Library

This page documents the functions for working with character flags and permissions.

---

## Overview

The flags library (`lia.flag`) provides a comprehensive system for managing character flags, permissions, and special abilities in the Lilia framework, serving as the core authorization and privilege management system for all character capabilities. This library handles sophisticated flag registration with support for hierarchical permission structures, conditional flags based on player state, and dynamic flag assignment based on gameplay achievements or administrative decisions. The system features advanced permission checking mechanisms with efficient lookup algorithms, caching strategies, and real-time validation to ensure optimal performance even with complex permission hierarchies. It includes comprehensive flag management functionality with bulk operations, inheritance systems, and automatic cleanup for temporary or expired flags. The library provides integration with all framework systems including commands, inventory access, faction permissions, and administrative tools, ensuring consistent authorization across all character interactions. Additional features include flag auditing and logging systems, permission debugging tools, and administrative interfaces for managing player privileges, making it essential for maintaining server security, implementing roleplay restrictions, and creating balanced gameplay experiences.

---

### add

**Purpose**

Registers a new flag with the flag system.

**Parameters**

* `flag` (*string*): The flag identifier.
* `desc` (*string*): The flag description.
* `callback` (*function*, optional): Optional callback function called when flag is given/removed.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a new flag
local function registerFlag(flag, desc, callback)
    lia.flag.add(flag, desc, callback)
end

-- Register a basic flag
lia.flag.add("admin", "Administrator privileges")

-- Register a flag with callback
lia.flag.add("vip", "VIP member benefits", function(client, isGiven)
    if isGiven then
        client:notify("VIP privileges granted!")
    else
        client:notify("VIP privileges removed")
    end
end)

-- Register multiple flags
local function registerCustomFlags()
    lia.flag.add("moderator", "Moderation capabilities")
    lia.flag.add("donator", "Donator benefits")
    lia.flag.add("beta_tester", "Beta testing access")
end

-- Register a flag that gives a weapon
lia.flag.add("physgun", "Physgun access", function(client, isGiven)
    if isGiven then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    else
        client:StripWeapon("weapon_physgun")
    end
end)
```

---

### onSpawn

**Purpose**

Processes flag callbacks when a player spawns, executing any registered flag actions for the player's current flags.

**Parameters**

* `client` (*Player*): The player that spawned.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Process flag callbacks on spawn
local function processSpawnFlags(client)
    lia.flag.onSpawn(client)
end

-- Use in a hook
hook.Add("PlayerSpawn", "HandleFlags", function(client)
    lia.flag.onSpawn(client)
end)

-- Use in a function
local function spawnWithFlags(client)
    lia.flag.onSpawn(client)
    print("Flag callbacks processed for " .. client:Name())
end

-- Use in a function
local function checkSpawnFlags(client)
    lia.flag.onSpawn(client)
    -- Check if player has specific flags after processing
    if client:getChar() and client:getChar():hasFlags("admin") then
        client:notify("Admin privileges active")
    end
end
```








