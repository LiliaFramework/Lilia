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

Allows you to supply a custom character name before any prefix or default logic is used. The engine also checks for `nameTemplate` (lower-case `n`) for backwards compatibility. If you return `true` as the second value, the returned name is used directly and no further processing occurs.

**Parameters:**

* `client` (`Player`) – The player creating the character.

**Returns:**

* `string`, `boolean` – The generated name and whether to skip default processing.

**Realm:**

* Shared

**Example Usage:**

```lua
function FACTION:NameTemplate(client)
    -- Prefix a random callsign with the faction name.
    local id = math.random(100, 999)
    return string.format("%s-%03d", self.name, id), true
end
```


### GetDefaultName

```lua
function FACTION:GetDefaultName(client)
    -- return string name
end
```

**Description:**

Retrieves the default name for a newly created character in this faction. The
returned string is used as the base name before any prefix or other logic is
applied.

**Parameters:**

* `client` (`Player`) – The client for whom the default name is being generated.

**Returns:**

* `string` – The generated name.

**Realm:**

* Shared

**Example Usage:**

```lua
function FACTION:GetDefaultName(client)
    -- Base the callsign on the player's account ID for consistency.
    return "Recruit-" .. client:AccountID()
end
```

---

### OnSpawn

```lua
function FACTION:OnSpawn(client)
end
```

Runs each time a faction member spawns while `FactionOnLoadout` is processing. Use
this to configure per-player attributes, grant equipment or send notifications.

**Parameters:**

* `client` (`Player`) – The player who has just spawned.

**Realm:**

* Server

**Example Usage:**

```lua
function FACTION:OnSpawn(client)
    -- Restore stats and hand out default weapons.
    client:SetHealth(client:GetMaxHealth())
    client:SetArmor(self.armor or 0)

    for _, wep in ipairs(self.weapons or {}) do
        client:Give(wep)
    end
end
```

---

### GetDefaultDesc

```lua
function FACTION:GetDefaultDesc(client)
    -- return string desc
end
```

**Description:**

Retrieves the default description for a newly created character in this faction.
The returned text becomes the character's description if no other value is
provided.

**Parameters:**

* `client` (`Player`) – The client for whom the default description is being generated.

**Returns:**

* `string` – The description text.

**Realm:**

* Shared

**Example Usage:**

```lua
function FACTION:GetDefaultDesc(client)
    -- Provide a short biography for new members.
    local callsign = self:GetDefaultName(client)
    return string.format("%s recently enlisted and is eager for duty.", callsign)
end
```

---



### OnTransferred

```lua
function FACTION:OnTransferred(client, oldFaction)
end
```

**Description:**

Executes after a player has been moved into this faction (whether by an admin or scripted transfer). The previous faction index is provided so you can clean up state or notify the player.

**Parameters:**

* `client` (`Player`) – The player that was moved into this faction.
* `oldFaction` (`number`) – The index of the faction the player came from.


**Realm:**

* Server


**Example Usage:**

```lua
function FACTION:OnTransferred(client, oldFaction)
    -- Swap the player's model and notify them of the transfer.
    local char = client:getChar()
    if char and istable(self.models) then
        char:setModel(self.models[math.random(#self.models)])
    end

    client:notify(string.format("Joined %s from faction #%d", self.name, oldFaction))
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

Called when the game checks whether this faction has reached its player limit. Return `true` to block the player from joining, or `false`/`nil` to allow them.

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

