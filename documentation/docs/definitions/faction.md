# Faction Definitions

Character faction definition system for the Lilia framework.

---

## Overview

The faction system provides comprehensive functionality for defining character factions within the Lilia framework.
Factions represent the main organizational units that characters belong to, serving as parent containers for classes.
Each character belongs to exactly ONE faction and can have multiple classes within that faction.

**Faction-Class Relationship:**
- **Factions** are the main organizational units (Citizens, Police, Medical, Staff)
- **Classes** are sub-divisions within factions (Officer, Detective, Captain within Police)
- Each character belongs to exactly ONE faction but can switch between classes within that faction
- **CLASS settings overpower FACTION settings** - any property defined in a class takes precedence
over the same property in the parent faction.

**Example Hierarchy:**
```
Faction: Police Department
├── Class: Police Officer (inherits police models, weapons, color)
├── Class: Police Detective (inherits police properties, overrides with detective-specific items)
├── Class: Police Captain (inherits police properties, overrides with command-specific permissions)
└── Class: SWAT Officer (inherits police properties, overrides with tactical gear)
```

Factions are defined using the FACTION table structure, which includes properties for identification,
visual representation, gameplay mechanics, and access control. The system includes callback methods
that are automatically invoked during key character lifecycle events, enabling dynamic behavior and
customization.

Factions can have player limits, whitelist requirements, specialized loadouts, and attribute
modifications that affect gameplay. The system supports modifying player health, armor, movement
speeds, model scale, weapons, and NPC relationships, providing a flexible foundation for role-based
gameplay systems.

**Player Management:**
Factions support player limits (absolute or percentage-based), character restrictions (one character
per player), custom name generation templates, and custom limit checking logic for advanced access
control scenarios.

**Access Control:**
Factions use the `isDefault` property to determine if they are accessible to all players, and can
implement custom permission logic through whitelist systems and the framework's permission system.

In addition to the FACTION table properties, factions can also modify character variables such as
classwhitelists to control which classes a character has access to within the faction.

---

### name

**Example Usage**

```lua
FACTION.name = "Police Department"

```

---

### desc

**Example Usage**

```lua
FACTION.desc = "Law enforcement officers responsible for maintaining order and protecting citizens"

```

---

### color

**Example Usage**

```lua
FACTION.color = Color(0, 100, 255)  -- Blue color for police

```

---

### models

**Example Usage**

```lua
FACTION.models = {"models/player/police.mdl", "models/player/swat.mdl"}
    -- Advanced: Complex model data with bodygroups
    FACTION.models = {
        "male" = {
            {"models/player/police_male.mdl", "Male Officer", {1, 2, 3}},
                {"models/player/swat_male.mdl", "Male SWAT", {0, 1, 2, 3}}
                    },
                    "female" = {
                        {"models/player/police_female.mdl", "Female Officer", {1, 2}},
                            {"models/player/swat_female.mdl", "Female SWAT", {0, 1, 2}}
                            }
                        }

```

---

### weapons

**Example Usage**

```lua
FACTION.weapons = {"weapon_pistol", "weapon_stunstick"}  -- Table of weapons
    FACTION.weapons = "weapon_crowbar"  -- Single weapon string

```

---

### isDefault

**Example Usage**

```lua
FACTION.isDefault = true  -- Players can create characters in this faction
FACTION.isDefault = false  -- Requires special permission or whitelist

```

---

### uniqueID

**Example Usage**

```lua
-- This is set automatically when you register the faction
lia.faction.register("police", {
    name = "Police Department",
    -- uniqueID will be "police"
    })
    -- For faction files, uniqueID is set to the filename
    -- File: factions/police.lua -> uniqueID = "police"
    -- File: factions/sh_police.lua -> uniqueID = "police" (sh_ prefix removed)
    -- File: factions/citizen.lua -> uniqueID = "citizen"

```

---

### index

**Example Usage**

```lua
-- This is set automatically when you register the faction
lia.faction.register("police", {
    name = "Police Department",
    -- index will be assigned based on registration order
    })
    -- Or manually specify the team index
    FACTION.index = 2  -- Will use team index 2

```

---

### health

**Example Usage**

```lua
FACTION.health = 120  -- Police officers have 120 max health

```

---

### armor

**Example Usage**

```lua
FACTION.armor = 50  -- Standard police armor

```

---

### scale

**Example Usage**

```lua
FACTION.scale = 1.1  -- Slightly larger model

```

---

### runSpeed

**Example Usage**

```lua
FACTION.runSpeed = 300  -- Absolute run speed
FACTION.runSpeedMultiplier = true
FACTION.runSpeed = 1.2  -- 20% faster than default

```

---

### walkSpeed

**Example Usage**

```lua
FACTION.walkSpeed = 150  -- Absolute walk speed
FACTION.walkSpeedMultiplier = true
FACTION.walkSpeed = 1.1  -- 10% faster than default

```

---

### jumpPower

**Example Usage**

```lua
FACTION.jumpPower = 200  -- Absolute jump power
FACTION.jumpPowerMultiplier = true
FACTION.jumpPower = 1.3  -- 30% higher jump

```

---

### NPCRelations

**Example Usage**

```lua
FACTION.NPCRelations = {
    ["npc_metropolice"] = D_LI,  -- Police are liked by metropolice
    ["npc_citizen"] = D_NU       -- Neutral to citizens
}

```

---

### bloodcolor

**Example Usage**

```lua
FACTION.bloodcolor = BLOOD_COLOR_RED  -- Red blood
FACTION.bloodcolor = BLOOD_COLOR_YELLOW  -- Yellow blood for aliens

```

---

### runSpeedMultiplier

**Example Usage**

```lua
FACTION.runSpeedMultiplier = true
FACTION.runSpeed = 1.2  -- 20% faster than default

```

---

### walkSpeedMultiplier

**Example Usage**

```lua
FACTION.walkSpeedMultiplier = true
FACTION.walkSpeed = 1.1  -- 10% faster than default

```

---

### jumpPowerMultiplier

**Example Usage**

```lua
FACTION.jumpPowerMultiplier = true
FACTION.jumpPower = 1.3  -- 30% higher jump

```

---

### items

**Example Usage**

```lua
FACTION.items = {"item_police_badge", "item_handcuffs"}  -- Starting items for police

```

---

### oneCharOnly

**Example Usage**

```lua
FACTION.oneCharOnly = true  -- Players can only have one character in this faction
FACTION.oneCharOnly = false  -- Players can have multiple characters in this faction

```

---

### limit

**Example Usage**

```lua
FACTION.limit = 8  -- Maximum 8 players in this faction
FACTION.limit = 0  -- Unlimited players
FACTION.limit = 0.1  -- 10% of total server players

```

---

### NameTemplate

**Example Usage**

```lua
function FACTION:NameTemplate(info, client)
    local index = math.random(1000, 9999)
    return "CP-" .. index  -- Returns "CP-1234" style names for Civil Protection
end

```

---

### GetDefaultName

**Example Usage**

```lua
function FACTION:GetDefaultName(client)
    return "Citizen " .. math.random(1000, 9999)
end

```

---

### GetDefaultDesc

**Example Usage**

```lua
function FACTION:GetDefaultDesc(client)
    return "A citizen of the city"
end

```

---

### OnCheckLimitReached

**Parameters**

* `character` (*Character*): The character trying to join
* `client` (*Player*): The player whose character is joining

**Example Usage**

```lua
function FACTION:OnCheckLimitReached(character, client)
    -- Custom logic for checking faction limits
    -- For example, check player permissions, character attributes, etc.
    -- Check if player has special permission to bypass limits
    if client:hasFlags("L") then
        return false  -- Allow admins to bypass limits
    end
    -- Use default limit checking
    return self:CheckFactionLimitReached(character, client)
end

```

---

### OnTransferred

**Parameters**

* `client` (*Player*): The player transferring to this faction

**Example Usage**

```lua
function FACTION:OnTransferred(client)
    client:notify("Welcome to the " .. self.name)
    -- Set up faction-specific data
    -- Could trigger department assignment or training
end

```

---

### OnSpawn

**Parameters**

* `client` (*Player*): The player spawning

**Example Usage**

```lua
function FACTION:OnSpawn(client)
    -- Apply faction-specific spawn effects
    client:Give("weapon_stunstick")
    client:SetHealth(self.health or 100)
    client:SetArmor(self.armor or 0)
end

```

---

