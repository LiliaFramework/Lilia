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

Triggered when a player leaves the class. Useful for resetting models or other class-specific attributes.

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

Called when a player successfully joins the class. Initialize class-specific settings here.

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

Invoked when a class member spawns. Use this for spawn-specific setup like health, armor, or weapons.

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
end
```

---

### OnTransferred

```lua
function CLASS:OnTransferred(client, oldClass)
```

**Description:**

Executes actions when a player is transferred into this class (e.g., by an admin or system transfer). The previous class index is provided as an argument.

**Parameters:**

* `client` (`Player`) – The player who was transferred.
* `oldClass` (`number`) – The class index the player previously belonged to.


**Realm:**

* Server


**Example Usage:**

```lua
function CLASS:OnTransferred(client, oldClass)
    local char = client:getChar()
    if char and self.model then
        -- Give the player the model defined for this class
        char:setModel(self.model)
    end
    print("Transferred from class", oldClass)
end
```
