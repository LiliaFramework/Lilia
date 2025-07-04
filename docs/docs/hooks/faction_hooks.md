# Faction Hooks

This document describes all `FACTION` function hooks defined within the codebase. Use these to customize default naming, descriptions, and lifecycle events when characters are created, spawned, or transferred within a faction.

Each hook is defined on a faction table and receives the table itself as `self` when invoked.

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

Allows you to supply a custom character name before any prefix or default logic is used. The engine also checks for `nameTemplate` (lower‑case **n**) for backwards compatibility. If you return `true` as the second value, the returned name is used directly.

**Parameters:**

* `client` (`Player`) – The player creating the character.

**Returns:**

* `string`, `boolean` – The generated name and whether to skip default processing.

**Realm:**

* Shared

**Example Usage:**

```lua
function FACTION:NameTemplate(client)
    -- Use the player's Steam name prefixed by the faction name.
    local base = client:SteamName()
    return string.format("[%s] %s", self.name, base), true
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
    -- Generate a simple callsign from the player's ID.
    return string.format("Recruit-%03d", math.random(11111, 99999))
end
```

---

### GetDefaultDesc

```lua
function FACTION:GetDefaultDesc(client)
    -- return string
end
```

**Description:**

Retrieves the default description for a newly created character in this faction.

**Parameters:**

* `client` (`Player`) – The client for whom the default description is being generated.

**Realm:**

* Shared

**Example Usage:**

```lua
function FACTION:GetDefaultDesc(client)
    -- Provide a short biography for new members.
    return "A newly enlisted soldier ready for duty."
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
    -- Restore health and equip the standard loadout.
    client:SetHealth(client:GetMaxHealth())
    client:Give("weapon_pistol")
    client:ChatPrint(L("welcomeDuty"))
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
    -- Swap the player's model to one of this faction's options.
    local char = client:getChar()
    if char and istable(self.models) then
        local idx = math.random(1, #self.models)
        char:setModel(self.models[idx])
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

    local maxMembers = self.limit or 10
    return lia.faction.getPlayerCount(self.index) >= maxMembers
end
```

