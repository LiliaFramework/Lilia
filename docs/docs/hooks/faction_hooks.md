# Faction Hooks

This document describes all `FACTION` function hooks defined within the codebase. Use these to customize default naming, descriptions, and lifecycle events when characters are created, spawned, or transferred within a faction.

Each hook is defined on a faction table and receives the table itself as `self` when invoked.

---

## Overview

These hooks belong to tables under `schema/factions` and are most often used to set up characters when they first join the faction.

Each faction can implement these shared- and server-side hooks to control how characters are initialized, described, and handled as they move through creation, spawning, and transfers. All hooks are optional; if you omit a hook, default behavior applies.


### NameTemplate

Description: Generates a custom character name before defaults are applied.

Parameters:
- `client` (Player): the player creating the character

Realm: Shared

Returns:
- `string`, `boolean`: generated name and whether to bypass default naming

Example Usage:
```lua
function FACTION:NameTemplate(client)
    -- Prefix a random callsign with the faction name.
    local id = math.random(100, 999)
    return string.format("%s-%03d", self.name, id), true
end
```


### GetDefaultName

Description: Retrieves the default character name for this faction.

Parameters:
- `client` (Player): the client requesting the name

Realm: Shared

Returns:
- `string`: the generated name

Example Usage:
```lua
function FACTION:GetDefaultName(client)
    -- Base the callsign on the player's account ID for consistency.
    return "Recruit-" .. client:AccountID()
end
```
---

### OnSpawn

Description: Executes whenever a faction member spawns during loadout.

Parameters:
- `client` (Player): the player who has just spawned

Realm: Server

Returns:
- `nil`: none

Example Usage:
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

Description: Provides the default description for a newly created character.

Parameters:
- `client` (Player): the client for whom the description is generated

Realm: Shared

Returns:
- `string`: the description text

Example Usage:
```lua
function FACTION:GetDefaultDesc(client)
    -- Use the name as part of a simple biography.
    local callsign = self:GetDefaultName(client)
    return string.format("%s recently enlisted and is eager for duty.", callsign)
end
```
---



### OnTransferred

Description: Runs after a player is moved into this faction from another.

Parameters:
- `client` (Player): the player that was transferred
- `oldFaction` (number): index of the previous faction

Realm: Server

Returns:
- `nil`: none

Example Usage:
```lua
function FACTION:OnTransferred(client, oldFaction)
    local char = client:getChar()
    if char and istable(self.models) then
        -- Choose a random uniform for the new faction.
        char:setModel(self.models[math.random(#self.models)])
    end

    -- Notify the player about the transfer.
    client:notify(string.format("Joined %s from faction #%d", self.name, oldFaction))
end
```
---

### OnCheckLimitReached

Description: Determines if the faction has reached its player limit.

Parameters:
- `character` (Character): the character attempting to join
- `client` (Player): the owner of that character

Realm: Shared

Returns:
- `boolean`: whether the limit is reached

Example Usage:
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
