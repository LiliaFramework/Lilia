# Faction Definitions

Character faction definition system for the Lilia framework.

---

Overview

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

**Purpose**

Sets the display name of the character faction

**When Called**

During faction definition

**Example Usage**

```lua
FACTION.name = "Police Department"

```

---

### desc

**Purpose**

Sets the description of the character faction

**When Called**

During faction definition

**Example Usage**

```lua
FACTION.desc = "Law enforcement officers responsible for maintaining order and protecting citizens"

```

---

### color

**Purpose**

Sets the team/faction color for UI elements and identification

**When Called**

During faction definition

**Example Usage**

```lua
FACTION.color = Color(0, 100, 255)  -- Blue color for police

```

---

### models

**Purpose**

Sets the player models available for this faction

**When Called**

During faction definition

**Example Usage**

```lua
FACTION.models = {"models/player/police.mdl", "models/player/swat.mdl"}
-- Advanced: Complex model data with bodygroups
FACTION.models = {
    male = {
        {"models/player/police_male.mdl", "Male Officer", {1, 2, 3}},
        {"models/player/swat_male.mdl", "Male SWAT", {0, 1, 2, 3}}
    },
    female = {
        {"models/player/police_female.mdl", "Female Officer", {1, 2}},
        {"models/player/swat_female.mdl", "Female SWAT", {0, 1, 2}}
    }
}

```

---

### weapons

**Purpose**

Sets weapons to give to players when they join this faction

**When Called**

During faction definition (applied when player spawns)

**Example Usage**

```lua
FACTION.weapons = {"weapon_pistol", "weapon_stunstick"}  -- Table of weapons
FACTION.weapons = "weapon_crowbar"  -- Single weapon string

```

---

### isDefault

**Purpose**

Sets whether this is a default faction that new characters can join

**When Called**

During faction definition

**Example Usage**

```lua
FACTION.isDefault = true  -- Players can create characters in this faction
FACTION.isDefault = false  -- Requires special permission or whitelist

```

---

### uniqueID

**Purpose**

Unique identifier for the faction (INTERNAL - set automatically when registered)

**When Called**

Set automatically during faction registration
Note: This property is internal and should not be modified directly
Auto-Assignment: If not explicitly defined, the uniqueID is automatically set to the faction file name (without .lua extension)

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

**Purpose**

Numeric index of the faction in the faction list (set automatically or manually)

**When Called**

Set automatically during faction registration, or manually specified

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

**Purpose**

Sets the maximum health for players in this faction

**When Called**

During faction definition (applied when player joins faction)

**Example Usage**

```lua
FACTION.health = 120  -- Police officers have 120 max health

```

---

### armor

**Purpose**

Sets the armor value for players in this faction

**When Called**

During faction definition (applied when player joins faction)

**Example Usage**

```lua
FACTION.armor = 50  -- Standard police armor

```

---

### scale

**Purpose**

Sets the model scale for players in this faction

**When Called**

During faction definition (applied when player joins faction)

**Example Usage**

```lua
FACTION.scale = 1.1  -- Slightly larger model

```

---

### runSpeed

**Purpose**

Sets the running speed for players in this faction

**When Called**

During faction definition (applied when player joins faction)

**Example Usage**

```lua
FACTION.runSpeed = 300  -- Absolute run speed
FACTION.runSpeedMultiplier = true
FACTION.runSpeed = 1.2  -- 20% faster than default

```

---

### walkSpeed

**Purpose**

Sets the walking speed for players in this faction

**When Called**

During faction definition (applied when player joins faction)

**Example Usage**

```lua
FACTION.walkSpeed = 150  -- Absolute walk speed
FACTION.walkSpeedMultiplier = true
FACTION.walkSpeed = 1.1  -- 10% faster than default

```

---

### jumpPower

**Purpose**

Sets the jump power for players in this faction

**When Called**

During faction definition (applied when player joins faction)

**Example Usage**

```lua
FACTION.jumpPower = 200  -- Absolute jump power
FACTION.jumpPowerMultiplier = true
FACTION.jumpPower = 1.3  -- 30% higher jump

```

---

### NPCRelations

**Purpose**

Sets NPC relationship overrides for this faction

**When Called**

During faction definition (applied when player joins faction)

**Example Usage**

```lua
FACTION.NPCRelations = {
    ["npc_metropolice"] = D_LI,    -- Police are liked by metropolice
    ["npc_citizen"]     = D_NU     -- Neutral to citizens
}

```

---

### bloodcolor

**Purpose**

Sets the blood color for players in this faction

**When Called**

During faction definition (applied when player joins faction)

**Example Usage**

```lua
FACTION.bloodcolor = BLOOD_COLOR_RED  -- Red blood
FACTION.bloodcolor = BLOOD_COLOR_YELLOW  -- Yellow blood for aliens

```

---

### runSpeedMultiplier

**Purpose**

Whether runSpeed should be treated as a multiplier instead of absolute value

**When Called**

During faction definition (used with runSpeed property)

**Example Usage**

```lua
FACTION.runSpeedMultiplier = true
FACTION.runSpeed = 1.2  -- 20% faster than default

```

---

### walkSpeedMultiplier

**Purpose**

Whether walkSpeed should be treated as a multiplier instead of absolute value

**When Called**

During faction definition (used with walkSpeed property)

**Example Usage**

```lua
FACTION.walkSpeedMultiplier = true
FACTION.walkSpeed = 1.1  -- 10% faster than default

```

---

### jumpPowerMultiplier

**Purpose**

Whether jumpPower should be treated as a multiplier instead of absolute value

**When Called**

During faction definition (used with jumpPower property)

**Example Usage**

```lua
FACTION.jumpPowerMultiplier = true
FACTION.jumpPower = 1.3  -- 30% higher jump

```

---

### items

**Purpose**

Sets items to give to characters when they are created in this faction

**When Called**

During faction definition (applied when character is created)

**Example Usage**

```lua
FACTION.items = {"item_police_badge", "item_handcuffs"}  -- Starting items for police

```

---

### oneCharOnly

**Purpose**

Sets whether players can only have one character in this faction

**When Called**

During faction definition

**Example Usage**

```lua
FACTION.oneCharOnly = true  -- Players can only have one character in this faction
FACTION.oneCharOnly = false  -- Players can have multiple characters in this faction

```

---

### limit

**Purpose**

Sets the maximum number of players allowed in this faction

**When Called**

During faction definition

**Example Usage**

```lua
FACTION.limit = 8  -- Maximum 8 players in this faction
FACTION.limit = 0  -- Unlimited players
FACTION.limit = 0.1  -- 10% of total server players

```

---

### NameTemplate

**Purpose**

Sets a function to generate default character names for this faction

**When Called**

During faction definition

**Example Usage**

```lua
function FACTION:NameTemplate(info, client)
    local index = math.random(1000, 9999)
    return "CP-" .. index  -- Returns "CP-1234" style names for Civil Protection
end

```

---

### GetDefaultName

**Purpose**

Sets a method to get the default character name for this faction

**When Called**

During faction definition

**Example Usage**

```lua
function FACTION:GetDefaultName(client)
    return "Citizen " .. math.random(1000, 9999)
end

```

---

### GetDefaultDesc

**Purpose**

Sets a method to get the default character description for this faction

**When Called**

During faction definition

**Example Usage**

```lua
function FACTION:GetDefaultDesc(client)
    return "A citizen of the city"
end

```

---

### OnCheckLimitReached

**Purpose**

Custom callback to check if faction player limit is reached

**When Called**

When a player tries to join a faction that might be at capacity

**Parameters**

* `character` (*Character*): The character trying to join
* `client` (*Player*): The player whose character is joining

**Returns**

* true if limit reached, false if not

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

**Purpose**

Called when a player transfers to this faction

**When Called**

When a player changes factions and this becomes their new faction

**Realm**

Server

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

**Purpose**

Called when a player spawns with this faction

**When Called**

When a player spawns with this faction

**Realm**

Server

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

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Faction Example

Below is a comprehensive example showing how to define a complete faction with all available properties and methods.

```lua
FACTION.name = "Police Department"

FACTION.desc = "Law enforcement officers responsible for maintaining order and protecting citizens"

FACTION.color = Color(0, 100, 255)  -- Blue color for police

FACTION.models = {"models/player/police.mdl", "models/player/swat.mdl"}
-- Advanced: Complex model data with bodygroups
FACTION.models = {
    male = {
        {"models/player/police_male.mdl", "Male Officer", {1, 2, 3}},
        {"models/player/swat_male.mdl", "Male SWAT", {0, 1, 2, 3}}
    },
    female = {
        {"models/player/police_female.mdl", "Female Officer", {1, 2}},
        {"models/player/swat_female.mdl", "Female SWAT", {0, 1, 2}}
    }
}

FACTION.weapons = {"weapon_pistol", "weapon_stunstick"}  -- Table of weapons
FACTION.weapons = "weapon_crowbar"  -- Single weapon string

FACTION.isDefault = true  -- Players can create characters in this faction
FACTION.isDefault = false  -- Requires special permission or whitelist

-- This is set automatically when you register the faction
lia.faction.register("police", {
    name = "Police Department",
    -- uniqueID will be "police"
})
-- For faction files, uniqueID is set to the filename
-- File: factions/police.lua -> uniqueID = "police"
-- File: factions/sh_police.lua -> uniqueID = "police" (sh_ prefix removed)
-- File: factions/citizen.lua -> uniqueID = "citizen"

-- This is set automatically when you register the faction
lia.faction.register("police", {
    name = "Police Department",
    -- index will be assigned based on registration order
})
-- Or manually specify the team index
FACTION.index = 2  -- Will use team index 2

FACTION.health = 120  -- Police officers have 120 max health

FACTION.armor = 50  -- Standard police armor

FACTION.scale = 1.1  -- Slightly larger model

FACTION.runSpeed = 300  -- Absolute run speed
FACTION.runSpeedMultiplier = true
FACTION.runSpeed = 1.2  -- 20% faster than default

FACTION.walkSpeed = 150  -- Absolute walk speed
FACTION.walkSpeedMultiplier = true
FACTION.walkSpeed = 1.1  -- 10% faster than default

FACTION.jumpPower = 200  -- Absolute jump power
FACTION.jumpPowerMultiplier = true
FACTION.jumpPower = 1.3  -- 30% higher jump

FACTION.NPCRelations = {
    ["npc_metropolice"] = D_LI,    -- Police are liked by metropolice
    ["npc_citizen"]     = D_NU     -- Neutral to citizens
}

FACTION.bloodcolor = BLOOD_COLOR_RED  -- Red blood
FACTION.bloodcolor = BLOOD_COLOR_YELLOW  -- Yellow blood for aliens

FACTION.runSpeedMultiplier = true
FACTION.runSpeed = 1.2  -- 20% faster than default

FACTION.walkSpeedMultiplier = true
FACTION.walkSpeed = 1.1  -- 10% faster than default

FACTION.jumpPowerMultiplier = true
FACTION.jumpPower = 1.3  -- 30% higher jump

FACTION.items = {"item_police_badge", "item_handcuffs"}  -- Starting items for police

FACTION.oneCharOnly = true  -- Players can only have one character in this faction
FACTION.oneCharOnly = false  -- Players can have multiple characters in this faction

FACTION.limit = 8  -- Maximum 8 players in this faction
FACTION.limit = 0  -- Unlimited players
FACTION.limit = 0.1  -- 10% of total server players

function FACTION:NameTemplate(info, client)
    local index = math.random(1000, 9999)
    return "CP-" .. index  -- Returns "CP-1234" style names for Civil Protection
end

function FACTION:GetDefaultName(client)
    return "Citizen " .. math.random(1000, 9999)
end

function FACTION:GetDefaultDesc(client)
    return "A citizen of the city"
end

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

function FACTION:OnTransferred(client)
    client:notify("Welcome to the " .. self.name)
    -- Set up faction-specific data
    -- Could trigger department assignment or training
end

function FACTION:OnSpawn(client)
    -- Apply faction-specific spawn effects
    client:Give("weapon_stunstick")
    client:SetHealth(self.health or 100)
    client:SetArmor(self.armor or 0)
end

FACTION.name = "Police Department"
FACTION.desc = "Law enforcement officers responsible for maintaining order and protecting citizens"
FACTION.color = Color(0, 100, 255)  -- Blue color for police
-- Access Control
FACTION.isDefault = false     -- Requires whitelist or special permission
FACTION.oneCharOnly = true    -- Players can only have one police character
FACTION.limit = 12            -- Maximum 12 police officers
FACTION.index = FACTION_POLICE  -- Team index for this faction
-- FACTION.uniqueID is automatically set to the filename (e.g., "police" for police.lua)
-- Name Generation
function FACTION:NameTemplate(info, client)
    local badgeNumber = math.random(1000, 9999)
    return "Officer " .. badgeNumber
end
function FACTION:GetDefaultName(client)
    return "Police Officer " .. math.random(1000, 9999)
end
function FACTION:GetDefaultDesc(client)
    return "A law enforcement officer of the City Police Department"
end
function FACTION:OnCheckLimitReached(character, client)
    -- Allow admins to bypass police limits
    if client:hasFlags("L") then
        return false
    end
    -- Check if character has police training
    if not character:getData("police_training", false) then
        client:notify("You need police training to join this faction.")
        return true
    end
    -- Use default limit checking for others
    local maxPlayers = self.limit or 0
    if self.limit > 0 and self.limit < 1 then
        maxPlayers = math.Round(player.GetCount() * self.limit)
    end
    return team.NumPlayers(self.index) >= maxPlayers
end
-- Visual Properties
FACTION.models = {
    male = {
        {"models/player/police_male.mdl", "Male Officer", {1, 2}},
        {"models/player/swat_male.mdl", "Male SWAT", {0, 1, 2, 3}}
    },
    female = {
        {"models/player/police_female.mdl", "Female Officer", {1}},
        {"models/player/swat_female.mdl", "Female SWAT", {0, 1, 2}}
    }
}
FACTION.scale = 1.0         -- Normal model scale
FACTION.bloodcolor = BLOOD_COLOR_RED
-- Gameplay Properties
FACTION.health = 120    -- Higher health than default citizens
FACTION.armor = 50      -- Standard police armor
-- Weapons (given when spawning)
FACTION.weapons = {
    "weapon_pistol",
    "weapon_stunstick",
    "weapon_police_baton"
}
-- Starting Items (given when character is created)
FACTION.items = {
    "item_police_badge",
    "item_handcuffs",
    "item_police_radio"
}
-- Movement Properties
FACTION.runSpeed = 280     -- Slightly slower than default for tactical movement
FACTION.walkSpeed = 150    -- Standard walking speed
FACTION.jumpPower = 200    -- Standard jump power
FACTION.runSpeedMultiplier = false  -- Use absolute speed values
FACTION.walkSpeedMultiplier = false  -- Use absolute speed values
FACTION.jumpPowerMultiplier = false  -- Use absolute jump power values
-- NPC Relationships
FACTION.NPCRelations = {
    ["npc_metropolice"] = D_LI,    -- Liked by metropolice
    ["npc_citizen"]     = D_NU,    -- Neutral to citizens
    ["npc_rebel"]       = D_HT     -- Hated by rebels
}
-- Callback Methods
function FACTION:OnTransferred(client)
    client:notify("Welcome to the City Police Department!")
    -- Set up police-specific data
    local char = client:getChar()
    if char then
        char:setData("department", "patrol")
        char:setData("badge_number", math.random(1000, 9999))
    end
    -- Log the transfer for administrative purposes
    lia.log.add(client, "faction_transfer", {
        old_faction = client:getChar():getFaction(),
        new_faction = self.uniqueID
    })
end
function FACTION:OnSpawn(client)
    -- Set up police-specific spawn behavior
    client:Give("weapon_police_radio")
    client:Give("item_police_badge")
    -- Apply police-specific effects
    client:SetHealth(self.health or 100)
    client:SetArmor(self.armor or 0)
    -- Set up police radio frequency
    client:setData("police_frequency", "city_police")
    -- Apply wanted status immunity
    client:setData("immunity_level", 1)
end

```

---

