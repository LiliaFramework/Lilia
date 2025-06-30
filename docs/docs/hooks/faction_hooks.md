# Faction Hooks


This document describes all `FACTION` function hooks defined within the codebase. Use these to customize default naming, descriptions, and lifecycle events when characters are created, spawned, or transferred within a faction.


---


## Overview


These hooks belong to tables under `schema/factions` and are most often used to set up characters when they first join the faction.

Each faction can implement these shared- and server-side hooks to control how characters are initialized, described, and handled as they move through creation, spawning, and transfers. All hooks are optional; if you omit a hook, default behavior applies.

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
    return "CT-" .. math.random(111111, 999999)
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
    return "A police officer"
end
```


---


### OnCharCreated


```lua
function FACTION:OnCharCreated(client, character)
end
```


**Description:**


Executes actions when a new character is created and assigned to this faction. Ideal for initializing inventories or character data.


**Parameters:**


* `client` (`Player`) – The client that owns the new character.


* `character` (`Character`) – The character object that was created.


**Realm:**


* Server


**Example Usage:**


```lua
function FACTION:OnCharCreated(client, character)
    local inventory = character:getInv()
    inventory:add("fancy_suit")
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
    client:ChatPrint("You have spawned!")
end
```


---


### OnTransferred


```lua
function FACTION:OnTransferred(character)
end
```


**Description:**


Executes actions when an existing character is transferred into this faction (e.g., via admin or system transfer).


**Parameters:**


* `character` (`Character`) – The character that was moved into this faction.


**Realm:**


* Server


**Example Usage:**


```lua
function FACTION:OnTransferred(character)
    local randomModelIndex = math.random(1, #self.models)
    character:setModel(self.models[randomModelIndex])
end
```
