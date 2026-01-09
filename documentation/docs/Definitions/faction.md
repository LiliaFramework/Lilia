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

#### 📋 Purpose
Sets the display name of the character faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    FACTION.name = "Police Department"

```

---

### desc

#### 📋 Purpose
Sets the description of the character faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    FACTION.desc = "Law enforcement officers responsible for maintaining order and protecting citizens"

```

---

### color

#### 📋 Purpose
Sets the team/faction color for UI elements and identification

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    FACTION.color = Color(0, 100, 255)  -- Blue color for police

```

---

### models

#### 📋 Purpose
Sets the player models available for this faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

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

#### 📋 Purpose
Sets weapons to give to players when they join this faction

#### ⏰ When Called
During faction definition (applied when player spawns)

#### 💡 Example Usage

```lua
    FACTION.weapons = {"weapon_pistol", "weapon_stunstick"}  -- Table of weapons
    FACTION.weapons = "weapon_crowbar"  -- Single weapon string

```

---

### isDefault

#### 📋 Purpose
Sets whether this is a default faction that new characters can join

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    FACTION.isDefault = true  -- Players can create characters in this faction
    FACTION.isDefault = false  -- Requires special permission or whitelist

```

---

### uniqueID

#### 📋 Purpose
Unique identifier for the faction (INTERNAL - set automatically when registered)

#### ⏰ When Called
Set automatically during faction registration
Note: This property is internal and should not be modified directly
Auto-Assignment: If not explicitly defined, the uniqueID is automatically set to the faction file name (without .lua extension)

#### 💡 Example Usage

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

#### 📋 Purpose
Numeric index of the faction in the faction list (set automatically or manually)

#### ⏰ When Called
Set automatically during faction registration, or manually specified

#### 💡 Example Usage

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

#### 📋 Purpose
Sets the maximum health for players in this faction

#### ⏰ When Called
During faction definition (applied when player joins faction)

#### 💡 Example Usage

```lua
    FACTION.health = 120  -- Police officers have 120 max health

```

---

### armor

#### 📋 Purpose
Sets the armor value for players in this faction

#### ⏰ When Called
During faction definition (applied when player joins faction)

#### 💡 Example Usage

```lua
    FACTION.armor = 50  -- Standard police armor

```

---

### scale

#### 📋 Purpose
Sets the model scale for players in this faction

#### ⏰ When Called
During faction definition (applied when player joins faction)

#### 💡 Example Usage

```lua
    FACTION.scale = 1.1  -- Slightly larger model

```

---

### runSpeed

#### 📋 Purpose
Sets the running speed for players in this faction

#### ⏰ When Called
During faction definition (applied when player joins faction)

#### 💡 Example Usage

```lua
    FACTION.runSpeed = 300  -- Absolute run speed
    FACTION.runSpeedMultiplier = true
    FACTION.runSpeed = 1.2  -- 20% faster than default

```

---

### walkSpeed

#### 📋 Purpose
Sets the walking speed for players in this faction

#### ⏰ When Called
During faction definition (applied when player joins faction)

#### 💡 Example Usage

```lua
    FACTION.walkSpeed = 150  -- Absolute walk speed
    FACTION.walkSpeedMultiplier = true
    FACTION.walkSpeed = 1.1  -- 10% faster than default

```

---

### jumpPower

#### 📋 Purpose
Sets the jump power for players in this faction

#### ⏰ When Called
During faction definition (applied when player joins faction)

#### 💡 Example Usage

```lua
    FACTION.jumpPower = 200  -- Absolute jump power
    FACTION.jumpPowerMultiplier = true
    FACTION.jumpPower = 1.3  -- 30% higher jump

```

---

### NPCRelations

#### 📋 Purpose
Sets NPC relationship overrides for this faction

#### ⏰ When Called
During faction definition (applied when player joins faction)

#### 💡 Example Usage

```lua
    FACTION.NPCRelations = {
        ["npc_metropolice"] = D_LI,    -- Police are liked by metropolice
        ["npc_citizen"]     = D_NU     -- Neutral to citizens
    }

```

---

### bloodcolor

#### 📋 Purpose
Sets the blood color for players in this faction

#### ⏰ When Called
During faction definition (applied when player joins faction)

#### 💡 Example Usage

```lua
    FACTION.bloodcolor = BLOOD_COLOR_RED  -- Red blood
    FACTION.bloodcolor = BLOOD_COLOR_YELLOW  -- Yellow blood for aliens

```

---

### runSpeedMultiplier

#### 📋 Purpose
Whether runSpeed should be treated as a multiplier instead of absolute value

#### ⏰ When Called
During faction definition (used with runSpeed property)

#### 💡 Example Usage

```lua
    FACTION.runSpeedMultiplier = true
    FACTION.runSpeed = 1.2  -- 20% faster than default

```

---

### walkSpeedMultiplier

#### 📋 Purpose
Whether walkSpeed should be treated as a multiplier instead of absolute value

#### ⏰ When Called
During faction definition (used with walkSpeed property)

#### 💡 Example Usage

```lua
    FACTION.walkSpeedMultiplier = true
    FACTION.walkSpeed = 1.1  -- 10% faster than default

```

---

### jumpPowerMultiplier

#### 📋 Purpose
Whether jumpPower should be treated as a multiplier instead of absolute value

#### ⏰ When Called
During faction definition (used with jumpPower property)

#### 💡 Example Usage

```lua
    FACTION.jumpPowerMultiplier = true
    FACTION.jumpPower = 1.3  -- 30% higher jump

```

---

### items

#### 📋 Purpose
Sets items to give to characters when they are created in this faction

#### ⏰ When Called
During faction definition (applied when character is created)

#### 💡 Example Usage

```lua
    FACTION.items = {"item_police_badge", "item_handcuffs"}  -- Starting items for police

```

---

### oneCharOnly

#### 📋 Purpose
Sets whether players can only have one character in this faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    FACTION.oneCharOnly = true  -- Players can only have one character in this faction
    FACTION.oneCharOnly = false  -- Players can have multiple characters in this faction

```

---

### limit

#### 📋 Purpose
Sets the maximum number of players allowed in this faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    FACTION.limit = 8  -- Maximum 8 players in this faction
    FACTION.limit = 0  -- Unlimited players
    FACTION.limit = 0.1  -- 10% of total server players

```

---

### pay

#### 📋 Purpose
Sets the default salary/paycheck amount for characters in this faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    FACTION.pay = 100  -- $100 salary per paycheck
    FACTION.pay = 0    -- No salary

```

---

### scoreboardHidden

#### 📋 Purpose
Controls whether this faction appears in scoreboard categories

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    FACTION.scoreboardHidden = true   -- Faction will not appear in scoreboard categories
    FACTION.scoreboardHidden = false  -- Faction will appear in scoreboard (default)

```

---

### mainMenuPosition

#### 📋 Purpose
Overrides the main menu position for characters in this faction

#### ⏰ When Called
During faction definition (used by GM:GetMainMenuPosition)

#### 💡 Example Usage

```lua
    FACTION.mainMenuPosition = Vector(0, 0, 64)
    FACTION.mainMenuPosition = {
        gm_construct = {
            position = Vector(0, 0, 64),
            angles = Angle(0, 0, 0)
        }
    }

```

---

### commands

#### 📋 Purpose
Grants faction members implicit access to specific commands

#### ⏰ When Called
During faction definition (evaluated by lia.command.hasAccess)

#### 💡 Example Usage

```lua
    FACTION.commands = {
        lia_faction_chat = true
    }

```

---

### RecognizesGlobally

#### 📋 Purpose
Marks the faction so its members are always globally recognized

#### ⏰ When Called
During faction definition (read by the recognition module)

#### 💡 Example Usage

```lua
    FACTION.RecognizesGlobally = true

```

---

### isGloballyRecognized

#### 📋 Purpose
Treats the faction as globally recognizable to others

#### ⏰ When Called
During faction definition (evaluated in the recognition module)

#### 💡 Example Usage

```lua
    FACTION.isGloballyRecognized = true

```

---

### MemberToMemberAutoRecognition

#### 📋 Purpose
Allows members of this faction to auto-recognize each other

#### ⏰ When Called
During faction definition (part of the recognition checks)

#### 💡 Example Usage

```lua
    FACTION.MemberToMemberAutoRecognition = true

```

---

### NameTemplate

#### 📋 Purpose
Sets a function to generate default character names for this faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    function FACTION:NameTemplate(info, client)
        local index = math.random(1000, 9999)
        return "CP-" .. index  -- Returns "CP-1234" style names for Civil Protection
    end

```

---

### GetDefaultName

#### 📋 Purpose
Sets a method to get the default character name for this faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    function FACTION:GetDefaultName(client)
        return "Citizen " .. math.random(1000, 9999)
    end

```

---

### GetDefaultDesc

#### 📋 Purpose
Sets a method to get the default character description for this faction

#### ⏰ When Called
During faction definition

#### 💡 Example Usage

```lua
    function FACTION:GetDefaultDesc(client)
        return "A citizen of the city"
    end

```

---

### OnCheckLimitReached

#### 📋 Purpose
Custom callback to check if faction player limit is reached

#### ⏰ When Called
When a player tries to join a faction that might be at capacity

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **Character** | The character trying to join |
| `client` | **Player** | The player whose character is joining |

#### ↩️ Returns
* true if limit reached, false if not

#### 💡 Example Usage

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

#### 📋 Purpose
Called when a player transfers to this faction

#### ⏰ When Called
When a player changes factions and this becomes their new faction

#### 🌐 Realm
Server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player transferring to this faction |

#### 💡 Example Usage

```lua
    function FACTION:OnTransferred(client)
        client:notify("Welcome to the " .. self.name)
        -- Set up faction-specific data
        -- Could trigger department assignment or training
    end

```

---

### OnSpawn

#### 📋 Purpose
Called when a player spawns with this faction

#### ⏰ When Called
When a player spawns with this faction

#### 🌐 Realm
Server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player spawning |

#### 💡 Example Usage

```lua
    function FACTION:OnSpawn(client)
        -- Apply faction-specific spawn effects
        client:Give("weapon_stunstick")
        client:SetHealth(self.health or 100)
        client:SetArmor(self.armor or 0)
    end

```

---