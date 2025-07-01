# Class Hooks

This document lists every available `CLASS` hook. Place these functions on a class table to run custom logic whenever a player joins, leaves, or spawns with that class.

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

Determines whether a player is permitted to switch to this class. It is called
by `lia.class.canBe` before the class change happens.

**Parameters:**

* `client` (`Player`) – The player attempting to switch to the class.


**Returns:**

* `boolean` – `true` to allow the switch; `false` to deny.


**Example Usage:**

```lua
function CLASS:OnCanBe(client)
    -- Only allow admins or players with the "V" flag
    return client:IsAdmin() or client:getChar():hasFlags("V")
end
```

---

### OnLeave

```lua
function CLASS:OnLeave(client)
```

**Description:**

Runs after `OnTransferred` and is passed the player that has just left the
class. Use it to clean up any class-specific state such as reverting models or
removing temporary items.

**Parameters:**

* `client` (`Player`) – The player who has left the class.


**Realm:**

* Server


**Example Usage:**

```lua
function CLASS:OnLeave(client)
    local character = client:getChar()
    if character and self.defaultModel then
        -- Restore the default model when leaving
        character:setModel(self.defaultModel)
    end
end
```

---

### OnSet

```lua
function CLASS:OnSet(client)
```

**Description:**

Called right after a player is moved into the class. Use it to grant weapons,
set models, or perform other one-time setup. If the player was transferred from
another class, `OnTransferred` will run afterwards.

**Parameters:**

* `client` (`Player`) – The player who has joined the class.


**Realm:**

* Server


**Example Usage:**

```lua
function CLASS:OnSet(client)
    -- Equip the player with the class uniform and a sidearm
    if self.model then client:SetModel(self.model) end
    client:Give("weapon_pistol")
end
```

---

### OnSpawn

```lua
function CLASS:OnSpawn(client)
```

**Description:**

Runs every time a member of the class spawns. This is the place for spawn
specific adjustments such as setting health values, giving starting weapons or
modifying movement speeds.

**Parameters:**

* `client` (`Player`) – The player who has just spawned.


**Realm:**

* Server


**Example Usage:**

```lua
function CLASS:OnSpawn(client)
    client:SetMaxHealth(self.health or 150)
    client:SetHealth(self.health or 150)
    client:SetArmor(self.armor or 50)

    -- Apply custom movement settings
    if self.runSpeed then client:SetRunSpeed(self.runSpeed) end
    if self.walkSpeed then client:SetWalkSpeed(self.walkSpeed) end
end
```

---

### OnTransferred

```lua
function CLASS:OnTransferred(client, oldClass)
```

**Description:**

Executes after `OnSet` when a player is moved from another class into this one
(for example by an admin command). The class index the player previously belonged
to is provided so you can migrate data or adjust loadouts.

**Parameters:**

* `client` (`Player`) – The player who was transferred.
* `oldClass` (`number`) – The class index the player previously belonged to.


**Realm:**

* Server


**Example Usage:**

```lua
function CLASS:OnTransferred(client, oldClass)
    local char = client:getChar()
    if char then
        local randomModelIndex = math.random(1, #self.models)
        char:setModel(self.models[randomModelIndex])
    end
    print("Transferred from class", oldClass)
end
```
