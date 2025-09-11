# Class Hooks

This document describes all `CLASS` function hooks defined within the codebase.

Use these to customize class behavior when players join, leave, spawn, or are transferred between classes.

Each hook is defined on a class table and receives the table itself as `self` when invoked.

---

## Overview

Hooks belong to tables under `schema/classes`.

They are most often used to control access, initialize settings, and respond to class-related events.

All hooks are optional — if you omit a hook, default behaviour applies.

---

### OnCanBe

**Purpose**

Determines whether a player is allowed to switch to this class.

**Parameters**

* `client` (*Player*): The player attempting to switch.

**Realm**

**Server**

**Returns**

* `boolean?` (*boolean?*): Return `false` to deny the change.

**Example Usage**

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

**Purpose**

Runs on the previous class after a player successfully changes classes.

**Parameters**

* `client` (*Player*): The player who has left the class.

**Realm**

**Server**

**Returns**

* `nil` (*nil*): This function does not return a value.

**Example Usage**

```lua
function CLASS:OnLeave(client)
    -- Strip any class-specific weapons.
    client:StripWeapon("weapon_pistol")

    -- Restore the player's previous model before the class change.
    local char = client:getChar()
    if char and self.model then
        char:setModel(char:getData("model", char:getModel()))
    end

    -- Reset movement speeds back to the config defaults.
    client:SetWalkSpeed(lia.config.get("WalkSpeed"))
    client:SetRunSpeed(lia.config.get("RunSpeed"))
end
```

---

### OnSet

**Purpose**

Executes immediately after a player joins this class.

**Parameters**

* `client` (*Player*): The player who has joined the class.

**Realm**

**Server**

**Returns**

* `nil` (*nil*): This function does not return a value.

**Example Usage**

```lua
function CLASS:OnSet(client)
    local char = client:getChar()

    -- Apply the class model and give a starter pistol.
    if char and self.model then
        char:setModel(self.model)
    end
    client:Give("weapon_pistol")

    -- Initialize base stats from the class definition.
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

**Purpose**

Runs each time a member of this class respawns.

**Parameters**

* `client` (*Player*): The player who has just spawned.

**Realm**

**Server**

**Returns**

* `nil` (*nil*): This function does not return a value.

**Example Usage**

```lua
function CLASS:OnSpawn(client)
    -- Apply the class load-out and stats every respawn.
    client:SetMaxHealth(self.health or 150)
    client:SetHealth(client:GetMaxHealth())
    client:SetArmor(self.armor or 50)

    for _, wep in ipairs(self.weapons or {}) do
        client:Give(wep)
    end

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

**Purpose**

Fires when a player is moved into this class from another.

**Parameters**

* `client` (*Player*): The player who was transferred.

* `oldClass` (*number*): Index of the previous class.

**Realm**

**Server**

**Returns**

* `nil` (*nil*): This function does not return a value.

**Example Usage**

```lua
function CLASS:OnTransferred(client, oldClass)
    local char = client:getChar()
    if char and self.model then
        -- Swap the model to match the new class.
        char:setModel(self.model)
    end

    -- Record the previous class so we can switch back later if needed.
    char:setData("previousClass", oldClass)
end
```

---
