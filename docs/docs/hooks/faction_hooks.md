# Faction Hooks

This document describes all `FACTION` function hooks defined within the codebase. Use these to customize default naming, descriptions, and lifecycle events when characters are created, spawned, or transferred within a faction.

---

## Overview

These hooks belong to tables under `schema/factions` and are most often used to set up characters when they first join the faction.

Each faction can implement these shared- and server-side hooks to control how characters are initialized, described, and handled as they move through creation, spawning, and transfers. All hooks are optional; if you omit a hook, default behavior applies.

### NameTemplate

```lua
function FACTION:NameTemplate(client)
    -- return string name, bool override
end
```

**Description:**

Allows you to supply a custom character name before any prefix or default logic is used. If you return `true` as the second value, the returned name is used directly.

**Parameters:**

* `client` (`Player`) – The player creating the character.

**Returns:**

* `string`, `boolean` – The generated name and whether to skip default processing.

**Realm:**

* Shared

**Example Usage:**

```lua
function FACTION:NameTemplate(client)
    -- Use the player's Steam name and add a tag.
    local name = string.format("%s [Recruit]", client:SteamName())
    return name, true -- skip any automatic naming
end
```


### GetDefaultName

```lua
function FACTION:GetDefaultName(client)
    -- return string
end
```

**Description:**

Retrieves the default name for a newly created character in this faction.

**Parameters:**

* `client` (`Player`) – The client for whom the default name is being generated.


**Realm:**

* Shared


**Example Usage:**

```lua
function FACTION:GetDefaultName(client)
    -- Generate a simple numeric identifier.
    local id = math.random(1000, 9999)
    return string.format("Recruit #%04d", id)
end
```

---

### GetDefaultDesc

```lua
function FACTION:GetDefaultDesc(client, faction)
    -- return string
end
```

**Description:**

Retrieves the default description for a newly created character in this faction.

**Parameters:**

* `client` (`Player`) – The client for whom the default description is being generated.


* `faction` (`number`) – The faction ID of this faction.


**Realm:**

* Shared


**Example Usage:**

```lua
function FACTION:GetDefaultDesc(client, faction)
    -- Provide a short backstory or description.
    return "A newly recruited officer"
end
```

---


### OnSpawn

```lua
function FACTION:OnSpawn(client)
end
```

**Description:**

Invoked when a faction member spawns into the world. Use this for per-spawn setup such as notifications or custom status.

**Parameters:**

* `client` (`Player`) – The player who has just spawned.


**Realm:**

* Server


**Example Usage:**

```lua
function FACTION:OnSpawn(client)
    -- Restore full health and greet the player.
    client:SetHealth(client:GetMaxHealth())
    client:ChatPrint("Welcome back to duty!")
end
```

---

### OnTransferred

```lua
function FACTION:OnTransferred(client, oldFaction)
end
```

**Description:**

Executes actions when a player is transferred into this faction (e.g., by an admin or scripted transfer). The previous faction is provided so you can perform cleanup or messaging.

**Parameters:**

* `client` (`Player`) – The player that was moved into this faction.
* `oldFaction` (`number`) – The index of the faction the player came from.


**Realm:**

* Server


**Example Usage:**

```lua
function FACTION:OnTransferred(client, oldFaction)
    -- Give the character a random faction model.
    local char = client:getChar()
    if char then
        local randomModelIndex = math.random(1, #self.models)
        char:setModel(self.models[randomModelIndex])
    end
    print("Transferred from faction", oldFaction)
end
```

---

### OnCheckLimitReached

```lua
function FACTION:OnCheckLimitReached(character, client)
    -- return boolean
end
```

**Description:**

Called when the game checks whether this faction has reached its player limit. Returning `true` prevents the character from joining.

**Parameters:**

* `character` (`Character`) – The character attempting to join the faction.
* `client` (`Player`) – The player owning that character.

**Realm:**

* Shared

**Returns:**

* `boolean` – Whether the faction limit is considered reached.

**Example Usage:**

```lua
function FACTION:OnCheckLimitReached(character, client)
    -- Allow admins to bypass the limit.
    if client:IsAdmin() then
        return false
    end

    local maxMembers = 10
    return lia.faction.getPlayerCount(self.index) >= maxMembers
end
```

