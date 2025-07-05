# Class Hooks

This document lists every available `CLASS` hook. Place these functions on a class table to run custom logic whenever a player joins, leaves, or spawns with that class.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

These hooks live on the class tables created under `schema/classes` and are only
called for instances of that specific class.  Define them inside your class
definition files (`schema/classes/*.lua`).

---

### OnCanBe

```lua
function CLASS:OnCanBe(client) → boolean?
```

**Description:**

Determines whether a player is permitted to switch to this class.  It is invoked
by `lia.class.canBe` after whitelist, faction, and limit checks but before the
class change actually happens.

**Parameters:**

* `client` (`Player`) – The player attempting to switch to the class.


**Returns:**

* `boolean?` – Return `false` to deny. Returning `true` or no value allows the
  switch.

**Realm:**

* Server


**Example Usage:**

```lua
function CLASS:OnCanBe(client)
    -- Only allow admins or players that own the "V" flag.
    if client:IsAdmin() then
        return true
    end

    local char = client:getChar()
    if char and char:hasFlags("V") then
        return true
    end

    -- Returning false prevents the switch.
    return false
end
```

---

### OnLeave

```lua
function CLASS:OnLeave(client)
```

**Description:**

Called on the player's previous class after the switch has completed.  It runs
after the new class has executed `OnSet` (and `OnTransferred` if applicable).
Use it to clean up any class‑specific state such as reverting models, resetting
values, or removing temporary items.

**Parameters:**

* `client` (`Player`) – The player who has left the class.


**Realm:**

* Server

**Returns:**

* None


**Example Usage:**

```lua
function CLASS:OnLeave(client)
    -- Strip any class specific weapons.
    client:StripWeapon("weapon_pistol")

    local char = client:getChar()
    if char and self.model then
        -- Restore the character's previous model.
        char:setModel(char:getData("model", char:getModel()))
    end

    -- Reset custom movement speeds back to defaults.
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

Called right after a character joins this class.  Use it to equip loadout items,
set the model, or perform any other initialization.  When switching from another
class, `OnTransferred` will run immediately afterward.  This hook runs before
`OnLeave` is executed on the previous class.

**Parameters:**

* `client` (`Player`) – The player who has joined the class.


**Realm:**

* Server

**Returns:**

* None


**Example Usage:**

```lua
function CLASS:OnSet(client)
    local char = client:getChar()

    -- Apply the class model and give a starter pistol.
    if char and self.model then
        char:setModel(self.model)
    end

    client:Give("weapon_pistol")

    -- Optional starting health/armor values.
    if self.health then
        client:SetHealth(self.health)
        client:SetMaxHealth(self.health)
    end
    if self.armor then
        client:SetArmor(self.armor)
    end
end
```

---

### OnSpawn

```lua
function CLASS:OnSpawn(client)
```

**Description:**

Runs every time a member of the class respawns.  The hook is triggered from the
`ClassOnLoadout` gamemode event, so it is ideal for giving items or tweaking
stats such as health, armor, or movement speeds.

**Parameters:**

* `client` (`Player`) – The player who has just spawned.


**Realm:**

* Server

**Returns:**

* None


**Example Usage:**

```lua
function CLASS:OnSpawn(client)
    -- Apply base stats whenever a member spawns.
    client:SetMaxHealth(self.health or 150)
    client:SetHealth(self.health or 150)
    client:SetArmor(self.armor or 50)

    -- Give the class's default weapons.
    for _, wep in ipairs(self.weapons or {}) do
        client:Give(wep)
    end

    -- Apply movement settings.
    if self.runSpeed then
        client:SetRunSpeed(self.runSpeed)
    end
    if self.walkSpeed then
        client:SetWalkSpeed(self.walkSpeed)
    end
end
```

---

### OnTransferred

```lua
function CLASS:OnTransferred(client, oldClass)
```

**Description:**

Fires when a player is transferred into this class from a different one (for
example via an admin command).  It runs immediately after `OnSet`.  The previous
class index is provided so you can migrate data or adjust loadouts.

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

    -- Apply the class model when transferring from another class.
    if char and self.model then
        char:setModel(self.model)
    end

    -- Keep track of the player's previous class for later use.
    char:setData("previousClass", oldClass)
end
```
