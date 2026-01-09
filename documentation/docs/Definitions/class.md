# Class Definitions

Character class definition system for the Lilia framework.

---

Overview

The class system provides comprehensive functionality for defining character classes within the Lilia framework.
Classes represent specific roles or professions that characters can assume within factions, creating a
hierarchical structure where factions serve as parent containers for classes.

**Faction-Class Relationship:**

- **Factions** are the main organizational units (Citizens, Police, Medical, etc.)

- **Classes** are sub-divisions within factions (Officer, Detective, Captain within Police)

- Each character belongs to exactly ONE faction and ONE class within that faction

- Classes inherit all properties from their parent faction by default

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

Classes are defined using the CLASS table structure, which includes properties for identification,
visual representation, gameplay mechanics, and access control. The system includes callback methods
that are automatically invoked during key character lifecycle events, enabling dynamic behavior and
customization.

Classes can have player limits, whitelist requirements, specialized loadouts, and attribute
modifications that affect gameplay. The system supports modifying player health, armor, movement
speeds, model scale, weapons, and NPC relationships, providing a flexible foundation for role-based
gameplay systems.

**Access Control:**
Classes use the `isWhitelisted` property to require whitelist access, and the `OnCanBe` callback
method to implement custom permission logic. The `OnCanBe` callback is called when a player attempts
to join a class and can check attributes, permissions, or any other conditions before allowing access.

In addition to the CLASS table properties, classes can also modify character variables such as
classwhitelists to control which classes a character has access to.

---

### name

#### 📋 Purpose
Sets the display name of the character class

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.name = "Police Officer"

```

---

### desc

#### 📋 Purpose
Sets the description of the character class

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.desc = "A law enforcement officer responsible for maintaining order"

```

---

### requirements

#### 📋 Purpose
Provides human-readable requirements or notes displayed in character screens

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.requirements = {
        "req_police_clearance",
        "req_training_complete"
    }

```

---

### faction

#### 📋 Purpose
Sets the faction ID this class belongs to

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.faction = FACTION_POLICE

```

---

### team

#### 📋 Purpose
Groups related classes together for door access, allowing multiple classes to share permissions

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.team = "law"
    CLASS.team = "medical"

```

---

### limit

#### 📋 Purpose
Sets the maximum number of players allowed in this class

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.limit = 5  -- Maximum 5 players
    CLASS.limit = 0  -- Unlimited players

```

---

### commands

#### 📋 Purpose
Grants class members access to specific console/lia commands

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.commands = {
        kick = true,
        give = true
    }

```

---

### model

#### 📋 Purpose
Sets the player model for this class

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.model = "models/player/barney.mdl"

```

```lua

```

---

### logo

#### 📋 Purpose
Supplies a custom emblem for UI components (scoreboard tabs, F1 menu, etc.)

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.logo = "materials/ui/class/police_logo.png"

```

---

### skin

#### 📋 Purpose
Sets the default skin index used by UI previews

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.skin = 1

```

---

### bodyGroups

#### 📋 Purpose
Defines bodygroup overrides used by UI previews and optional loadouts

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.bodyGroups = {
        {id = 2, value = 1}
    }

```

---

### subMaterials

#### 📋 Purpose
Overrides sub-material entries used by preview panels

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.subMaterials = {
        "models/player/police_submaterial",
        "models/player/police_submaterial2"
    }

```

---

### isWhitelisted

#### 📋 Purpose
Sets whether this class requires whitelist access

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.isWhitelisted = true  -- Requires whitelist permission to join

```

```lua

```

---

### isDefault

#### 📋 Purpose
Sets whether this is the default class for the faction

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.isDefault = true

```

---

### canInviteToFaction

#### 📋 Purpose
Allows this class to invite players into the faction using the interaction menu

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.canInviteToFaction = true

```

---

### canInviteToClass

#### 📋 Purpose
Allows this class to invite players into the same class using the interaction menu

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.canInviteToClass = true

```

---

### scoreboardHidden

#### 📋 Purpose
Hides this class from the scoreboard display

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.scoreboardHidden = true  -- Class will not appear in scoreboard categories

```

---

### pay

#### 📋 Purpose
Sets the salary amount for this class

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.pay = 100  -- $100 salary

```

---

### uniqueID

#### 📋 Purpose
Unique identifier for the class (INTERNAL - set automatically when registered)

#### ⏰ When Called
Set automatically during class registration
Note: This property is internal and should not be modified directly

#### 💡 Example Usage

```lua
    -- This is set automatically when you register the class
    lia.class.register("police_officer", {
        name = "Police Officer",
        -- uniqueID will be "police_officer"
    })

```

---

### index

#### 📋 Purpose
Numeric index of the class in the class list (set automatically)

#### ⏰ When Called
Set automatically during class registration

#### 💡 Example Usage

```lua
    -- This is set automatically when you register the class
    lia.class.register("police_officer", {
        name = "Police Officer",
        -- index will be assigned based on registration order
    })

```

---

### Color

#### 📋 Purpose
Sets the team/class color for UI elements and identification

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.Color = Color(0, 100, 255)  -- Blue color for police

```

---

### color

#### 📋 Purpose
Sets the accent color used by scoreboard entries and class info panels

#### ⏰ When Called
During class definition

#### 💡 Example Usage

```lua
    CLASS.color = Color(0, 120, 255)  -- UI accent color

```

---

### health

#### 📋 Purpose
Sets the maximum health for players in this class

#### ⏰ When Called
During class definition (applied when player joins class)

#### 💡 Example Usage

```lua
    CLASS.health = 150  -- Police officers have 150 max health

```

---

### armor

#### 📋 Purpose
Sets the armor value for players in this class

#### ⏰ When Called
During class definition (applied when player joins class)

#### 💡 Example Usage

```lua
    CLASS.armor = 50  -- Police officers have 50 armor

```

---

### weapons

#### 📋 Purpose
Sets weapons to give to players when they join this class

#### ⏰ When Called
During class definition (applied when player spawns)

#### 💡 Example Usage

```lua
    CLASS.weapons = {"weapon_pistol", "weapon_stunstick"}  -- Table of weapons
    CLASS.weapons = "weapon_crowbar"  -- Single weapon string

```

---

### scale

#### 📋 Purpose
Sets the model scale for players in this class

#### ⏰ When Called
During class definition (applied when player joins class)

#### 💡 Example Usage

```lua
    CLASS.scale = 1.1  -- Slightly larger model

```

---

### runSpeed

#### 📋 Purpose
Sets the running speed for players in this class

#### ⏰ When Called
During class definition (applied when player joins class)

#### 💡 Example Usage

```lua
    CLASS.runSpeed = 300  -- Absolute run speed
    CLASS.runSpeedMultiplier = true
    CLASS.runSpeed = 1.2  -- 20% faster than default

```

---

### walkSpeed

#### 📋 Purpose
Sets the walking speed for players in this class

#### ⏰ When Called
During class definition (applied when player joins class)

#### 💡 Example Usage

```lua
    CLASS.walkSpeed = 150  -- Absolute walk speed
    CLASS.walkSpeedMultiplier = true
    CLASS.walkSpeed = 1.1  -- 10% faster than default

```

---

### jumpPower

#### 📋 Purpose
Sets the jump power for players in this class

#### ⏰ When Called
During class definition (applied when player joins class)

#### 💡 Example Usage

```lua
    CLASS.jumpPower = 200  -- Absolute jump power
    CLASS.jumpPowerMultiplier = true
    CLASS.jumpPower = 1.3  -- 30% higher jump

```

---

### NPCRelations

#### 📋 Purpose
Sets NPC relationship overrides for this class (inherits from faction)

#### ⏰ When Called
During class definition (applied when player joins class)

#### 💡 Example Usage

```lua
    CLASS.NPCRelations = {
        ["npc_metropolice"] = D_LI,  -- Police are liked by metropolice
        ["npc_citizen"]     = D_NU   -- Neutral to citizens
    }

```

---

### bloodcolor

#### 📋 Purpose
Sets the blood color for players in this class

#### ⏰ When Called
During class definition (applied when player joins class)

#### 💡 Example Usage

```lua
    CLASS.bloodcolor = BLOOD_COLOR_RED  -- Red blood
    CLASS.bloodcolor = BLOOD_COLOR_YELLOW  -- Yellow blood for aliens

```

---

### runSpeedMultiplier

#### 📋 Purpose
Whether runSpeed should be treated as a multiplier instead of absolute value

#### ⏰ When Called
During class definition (used with runSpeed property)

#### 💡 Example Usage

```lua
    CLASS.runSpeedMultiplier = true
    CLASS.runSpeed = 1.2  -- 20% faster than default

```

---

### walkSpeedMultiplier

#### 📋 Purpose
Whether walkSpeed should be treated as a multiplier instead of absolute value

#### ⏰ When Called
During class definition (used with walkSpeed property)

#### 💡 Example Usage

```lua
    CLASS.walkSpeedMultiplier = true
    CLASS.walkSpeed = 1.1  -- 10% faster than default

```

---

### jumpPowerMultiplier

#### 📋 Purpose
Whether jumpPower should be treated as a multiplier instead of absolute value

#### ⏰ When Called
During class definition (used with jumpPower property)

#### 💡 Example Usage

```lua
    CLASS.jumpPowerMultiplier = true
    CLASS.jumpPower = 1.3  -- 30% higher jump

```

---

### OnCanBe

#### 📋 Purpose
Check if a player can join this class

#### ⏰ When Called
When a player attempts to join this class

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player trying to join |

#### ↩️ Returns
* true to allow, false to deny

#### 💡 Example Usage

```lua
    function CLASS:OnCanBe(client)
        local char = client:getChar()
        if char then
            -- Check character attributes
            if char:getAttrib("str", 0) < 10 then
                client:notify("You need at least 10 strength to join this class.")
                return false
            end
            -- Check permissions (use framework permission system)
            if not client:hasFlags("P") then  -- Example permission flag
                client:notify("You don't have permission to join this class.")
                return false
            end
            -- Check custom conditions
            if char:getData("banned_from_class", false) then
                client:notify("You are banned from this class.")
                return false
            end
        end
        return true
    end

```

---

### OnSet

#### 📋 Purpose
Called when a player joins this class

#### ⏰ When Called
When a player is assigned to this class

#### 🌐 Realm
Server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player joining the class |

#### 💡 Example Usage

```lua
    function CLASS:OnSet(client)
        client:notify("Welcome to " .. self.name)
    end

```

---

### OnTransferred

#### 📋 Purpose
Called when switching from another class to this class

#### ⏰ When Called
When a player switches classes and this becomes the new class

#### 🌐 Realm
Server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player switching classes |
| `oldClass` | **table** | The previous class data |

#### 💡 Example Usage

```lua
    function CLASS:OnTransferred(client, oldClass)
        if oldClass then
            client:notify("Switched from " .. oldClass.name .. " to " .. self.name)
        end
    end

```

---

### OnSpawn

#### 📋 Purpose
Called when a player spawns with this class

#### ⏰ When Called
When a player spawns with this class

#### 🌐 Realm
Server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player spawning |

#### 💡 Example Usage

```lua
    function CLASS:OnSpawn(client)
        client:Give("weapon_stunstick")
        client:SetHealth(150)
        client:SetArmor(50)
    end

```

---

### OnLeave

#### 📋 Purpose
Called when leaving this class

#### ⏰ When Called
When a player leaves this class

#### 🌐 Realm
Server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player leaving |

#### 💡 Example Usage

```lua
    function CLASS:OnLeave(client)
        client:StripWeapon("weapon_stunstick")
    end

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Class Example

Below is a comprehensive example showing how to define a complete class with all available properties and methods. This example creates a "Police Officer" class that demonstrates typical usage of the class system.

```lua
    CLASS.name = "Police Officer"

    CLASS.desc = "A law enforcement officer responsible for maintaining order"

    CLASS.requirements = {
        "req_police_clearance",
        "req_training_complete"
    }

    CLASS.faction = FACTION_POLICE

    CLASS.team = "law"
    CLASS.team = "medical"

    CLASS.limit = 5  -- Maximum 5 players
    CLASS.limit = 0  -- Unlimited players

    CLASS.commands = {
        kick = true,
        give = true
    }

    CLASS.model = "models/player/barney.mdl"

```

```lua
    CLASS.logo = "materials/ui/class/police_logo.png"

    CLASS.skin = 1

    CLASS.bodyGroups = {
        {id = 2, value = 1}
    }

    CLASS.subMaterials = {
        "models/player/police_submaterial",
        "models/player/police_submaterial2"
    }

    CLASS.isWhitelisted = true  -- Requires whitelist permission to join

```

```lua
    CLASS.isDefault = true

    CLASS.canInviteToFaction = true

    CLASS.canInviteToClass = true

    CLASS.scoreboardHidden = true  -- Class will not appear in scoreboard categories

    CLASS.pay = 100  -- $100 salary

    -- This is set automatically when you register the class
    lia.class.register("police_officer", {
        name = "Police Officer",
        -- uniqueID will be "police_officer"
    })

    -- This is set automatically when you register the class
    lia.class.register("police_officer", {
        name = "Police Officer",
        -- index will be assigned based on registration order
    })

    CLASS.Color = Color(0, 100, 255)  -- Blue color for police

    CLASS.color = Color(0, 120, 255)  -- UI accent color

    CLASS.health = 150  -- Police officers have 150 max health

    CLASS.armor = 50  -- Police officers have 50 armor

    CLASS.weapons = {"weapon_pistol", "weapon_stunstick"}  -- Table of weapons
    CLASS.weapons = "weapon_crowbar"  -- Single weapon string

    CLASS.scale = 1.1  -- Slightly larger model

    CLASS.runSpeed = 300  -- Absolute run speed
    CLASS.runSpeedMultiplier = true
    CLASS.runSpeed = 1.2  -- 20% faster than default

    CLASS.walkSpeed = 150  -- Absolute walk speed
    CLASS.walkSpeedMultiplier = true
    CLASS.walkSpeed = 1.1  -- 10% faster than default

    CLASS.jumpPower = 200  -- Absolute jump power
    CLASS.jumpPowerMultiplier = true
    CLASS.jumpPower = 1.3  -- 30% higher jump

    CLASS.NPCRelations = {
        ["npc_metropolice"] = D_LI,  -- Police are liked by metropolice
        ["npc_citizen"]     = D_NU   -- Neutral to citizens
    }

    CLASS.bloodcolor = BLOOD_COLOR_RED  -- Red blood
    CLASS.bloodcolor = BLOOD_COLOR_YELLOW  -- Yellow blood for aliens

    CLASS.runSpeedMultiplier = true
    CLASS.runSpeed = 1.2  -- 20% faster than default

    CLASS.walkSpeedMultiplier = true
    CLASS.walkSpeed = 1.1  -- 10% faster than default

    CLASS.jumpPowerMultiplier = true
    CLASS.jumpPower = 1.3  -- 30% higher jump

    function CLASS:OnCanBe(client)
        local char = client:getChar()
        if char then
            -- Check character attributes
            if char:getAttrib("str", 0) < 10 then
                client:notify("You need at least 10 strength to join this class.")
                return false
            end
            -- Check permissions (use framework permission system)
            if not client:hasFlags("P") then  -- Example permission flag
                client:notify("You don't have permission to join this class.")
                return false
            end
            -- Check custom conditions
            if char:getData("banned_from_class", false) then
                client:notify("You are banned from this class.")
                return false
            end
        end
        return true
    end

    function CLASS:OnSet(client)
        client:notify("Welcome to " .. self.name)
    end

    function CLASS:OnTransferred(client, oldClass)
        if oldClass then
            client:notify("Switched from " .. oldClass.name .. " to " .. self.name)
        end
    end

    function CLASS:OnSpawn(client)
        client:Give("weapon_stunstick")
        client:SetHealth(150)
        client:SetArmor(50)
    end

    function CLASS:OnLeave(client)
        client:StripWeapon("weapon_stunstick")
    end

    CLASS.name = "Police Officer"
    CLASS.desc = "A law enforcement officer responsible for maintaining order and protecting citizens"
    CLASS.faction = FACTION_CITY
    -- Access Control
    CLASS.limit = 8  -- Maximum 8 officers
    CLASS.isWhitelisted = true  -- Requires whitelist
    CLASS.isDefault = false  -- Not the default class for the faction
    -- Visual Properties
    CLASS.model = "models/player/police.mdl"
    CLASS.Color = Color(0, 100, 255)  -- Blue color for police
    CLASS.scale = 1.0  -- Normal model scale
    CLASS.bloodcolor = BLOOD_COLOR_RED
    -- Gameplay Properties
    CLASS.health = 120  -- Higher health than default
    CLASS.armor = 50    -- Standard police armor
    CLASS.pay = 150     -- $150 salary per paycheck
    -- Weapons (given when spawning)
    CLASS.weapons = {
        "weapon_pistol",
        "weapon_stunstick",
        "weapon_police_baton"
    }
    -- Movement Properties
    CLASS.runSpeed = 280  -- Slightly slower than default for tactical movement
    CLASS.walkSpeed = 150  -- Standard walking speed
    CLASS.jumpPower = 200  -- Standard jump power
    -- NPC Relationships (overrides faction settings)
    CLASS.NPCRelations = {
        ["npc_metropolice"] = D_LI,  -- Liked by metropolice
        ["npc_citizen"]     = D_NU,  -- Neutral to citizens
        ["npc_rebel"]       = D_HT   -- Hated by rebels
    }
    -- Callback Methods
    function CLASS:OnCanBe(client)
        local char = client:getChar()
        if char then
            -- Check if character has required attributes
            if char:getAttrib("str", 0) < 10 then
                client:notify("You need at least 10 strength to become a police officer.")
                return false
            end
            -- Check if character has criminal record
            if char:getData("criminal_record", false) then
                client:notify("You cannot become a police officer with a criminal record.")
                return false
            end
            -- Check for police-specific permissions
            if not client:hasFlags("P") then
                client:notify("You don't have permission to become a police officer.")
                return false
            end
        end
        return true
    end
    function CLASS:OnSet(client)
        client:notify("Welcome to the City Police Department, Officer!")
        -- Could add police radio equipment here
    end
    function CLASS:OnSpawn(client)
        -- Set up police-specific spawn behavior
        client:Give("weapon_police_radio")
        client:Give("item_police_badge")
        -- Apply police-specific effects
        client:SetHealth(self.health)
        client:SetArmor(self.armor)
    end
    function CLASS:OnTransferred(client, oldClass)
        if oldClass then
            client:notify("You have been transferred from " .. oldClass.name .. " to Police Officer.")
        end
        -- Update police database records
        -- Could trigger promotion/demotion logic here
    end
    function CLASS:OnLeave(client)
        -- Clean up police-specific items and effects
        client:StripWeapon("weapon_police_radio")
        client:StripWeapon("weapon_police_badge")
        client:notify("You are no longer a police officer.")
    end

```

---

