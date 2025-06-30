# Class Hooks


This document describes all `CLASS` function hooks defined within the codebase. Use these to customize behavior before and after class changes and spawns.


---


## Overview


Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

These hooks live on the class tables created under `schema/classes` and only run there rather than acting as global gamemode hooks.




---


### OnCanBe


```lua
function CLASS:OnCanBe(client) → boolean
```


**Description:**


Determines whether a player is permitted to switch to this class. Evaluated before the class change occurs.


**Parameters:**


* `client` (`Player`) – The player attempting to switch to the class.


**Returns:**


* `boolean` – `true` to allow the switch; `false` to deny.


**Example Usage:**


```lua
function CLASS:OnCanBe(client)
    return client:isStaff() or client:getChar():hasFlags("Z")
end
```


---


### OnLeave


```lua
function CLASS:OnLeave(client)
```


**Description:**


Triggered when a player leaves the class. Useful for resetting models or other class-specific attributes.


**Parameters:**


* `client` (`Player`) – The player who has left the class.


**Realm:**


* Server


**Example Usage:**


```lua
function CLASS:OnLeave(client)
    local character = client:getChar()
    character:setModel("models/player/alyx.mdl")
end
```


---


### OnSet


```lua
function CLASS:OnSet(client)
```


**Description:**


Called when a player successfully joins the class. Initialize class-specific settings here.


**Parameters:**


* `client` (`Player`) – The player who has joined the class.


**Realm:**


* Server


**Example Usage:**


```lua
function CLASS:OnSet(client)
    client:setModel("models/police.mdl")
end
```


---


### OnSpawn


```lua
function CLASS:OnSpawn(client)
```


**Description:**


Invoked when a class member spawns. Use this for spawn-specific setup like health, armor, or weapons.


**Parameters:**


* `client` (`Player`) – The player who has just spawned.


**Realm:**


* Server


**Example Usage:**


```lua
function CLASS:OnSpawn(client)
    client:SetMaxHealth(500)
    client:SetHealth(500)
end
```


---


### OnTransferred


```lua
function CLASS:OnTransferred(character)
```


**Description:**


Executes actions when a character is transferred into this class (e.g., by an admin or system transfer).


**Parameters:**


* `character` (`Character`) – The character that was transferred.


**Realm:**


* Server


**Example Usage:**


```lua
function CLASS:OnTransferred(character)
    local randomModelIndex = math.random(1, #self.models)
    character:setModel(self.models[randomModelIndex])
end
```
