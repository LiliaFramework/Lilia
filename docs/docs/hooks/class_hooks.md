# Class Hooks

This document lists every available `CLASS` hook. Place these functions on a class table to run custom logic whenever a player joins, leaves, or spawns with that class.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

These hooks live on the class tables created under `schema/classes` and only run there rather than acting as global gamemode hooks.

Define them inside your class definition files (`schema/classes/*.lua`).

---

### OnCanBe

```lua
function CLASS:OnCanBe(client) → boolean
```

**Description:**

Determines whether a player is permitted to switch to this class. It is called
by `lia.class.canBe` after whitelist, faction, and limit checks but before the
class change happens.

**Parameters:**

* `client` (`Player`) – The player attempting to switch to the class.


**Returns:**

* `boolean` – `true` to allow the switch; `false` to deny.

**Realm:**

* Server


**Example Usage:**

```lua
function CLASS:OnCanBe(client)
    -- Example: only allow admins or players that own the "V" flag
    local char = client:getChar()
    if client:IsAdmin() then return true end
    return char and char:hasFlags("V") or false
end
```

---

### OnLeave

```lua
function CLASS:OnLeave(client)
```

**Description:**

Runs after `OnTransferred` for the class the player is leaving. Use it to clean
up any class‑specific state such as reverting models, resetting values, or
removing temporary items.

**Parameters:**

* `client` (`Player`) – The player who has left the class.


**Realm:**

* Server

**Returns:**

* None


**Example Usage:**

```lua
function CLASS:OnLeave(client)
    -- Remove class specific weapons and revert model/attributes
    client:StripWeapon("weapon_pistol")

    local char = client:getChar()
    if char and self.model then
        char:setModel(char:getData("model", char:getModel()))
    end

    -- Reset any modified speeds
    client:SetWalkSpeed(lia.config.get("WalkSpeed"))
    client:SetRunSpeed(lia.config.get("RunSpeed"))
end
```

---

### OnSet

```lua
function CLASS:OnSet(client)
```

**Description:**

Called immediately after a player is assigned to this class. Use it to grant
weapons, set models, or perform other setup. When switching from another class
`OnTransferred` will run next.

**Parameters:**

* `client` (`Player`) – The player who has joined the class.


**Realm:**

* Server

**Returns:**

* None


**Example Usage:**

```lua
function CLASS:OnSet(client)
    -- Give the player their uniform and starter pistol
    local char = client:getChar()
    if self.model and char then
        char:setModel(self.model)
    end

    client:Give("weapon_pistol")
    client:SetArmor(self.armor or 0)
    client:SetHealth(self.health or client:Health())
end
```

---

### OnSpawn

```lua
function CLASS:OnSpawn(client)
```

**Description:**

Runs each time a member of the class respawns. Use it to set up spawn
attributes like health, armor, default weapons or movement speeds.

**Parameters:**

* `client` (`Player`) – The player who has just spawned.


**Realm:**

* Server

**Returns:**

* None


**Example Usage:**

```lua
function CLASS:OnSpawn(client)
    -- Apply base stats whenever a member spawns
    client:SetMaxHealth(self.health or 150)
    client:SetHealth(self.health or 150)
    client:SetArmor(self.armor or 50)

    -- Give default weapons
    for _, wep in ipairs(self.weapons or {}) do
        client:Give(wep)
    end

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
(for example via an admin command). The class index the player previously
belonged to is provided so you can migrate data or adjust loadouts.

**Parameters:**

* `client` (`Player`) – The player who was transferred.
* `oldClass` (`number`) – The class index the player previously belonged to.


**Realm:**

* Server

**Returns:**

* None


**Example Usage:**

```lua
function CLASS:OnTransferred(client, oldClass)
    local char = client:getChar()

    -- Apply the class model when transferring from another class
    if char and self.model then
        char:setModel(self.model)
    end

    -- Record the player's previous class for later use
    char:setData("previousClass", oldClass)
end
```
