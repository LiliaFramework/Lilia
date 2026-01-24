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

<a id="name"></a>
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

<a id="desc"></a>
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

<a id="requirements"></a>
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

<a id="faction"></a>
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

<a id="team"></a>
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

<a id="limit"></a>
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

<a id="commands"></a>
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

<a id="model"></a>
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

<a id="logo"></a>
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

<a id="skin"></a>
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

<a id="bodygroups"></a>
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

<a id="submaterials"></a>
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

<a id="iswhitelisted"></a>
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

<a id="isdefault"></a>
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

<a id="caninvitetofaction"></a>
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

<a id="caninvitetoclass"></a>
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

<a id="scoreboardhidden"></a>
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

<a id="pay"></a>
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

<a id="uniqueid"></a>
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

<a id="index"></a>
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

<a id="color"></a>
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

<a id="color"></a>
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

<a id="health"></a>
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

<a id="armor"></a>
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

<a id="weapons"></a>
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

<a id="scale"></a>
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

<a id="runspeed"></a>
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

<a id="walkspeed"></a>
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

<a id="jumppower"></a>
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

<a id="npcrelations"></a>
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

<a id="bloodcolor"></a>
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

<a id="runspeedmultiplier"></a>
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

<a id="walkspeedmultiplier"></a>
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

<a id="jumppowermultiplier"></a>
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

<a id="oncanbe"></a>
### OnCanBe

#### 📋 Purpose
Check if a player can join this class

#### ⏰ When Called
When a player attempts to join this class

<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player trying to join</p>

<p><h3>Returns:</h3>
true to allow, false to deny</p>

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

<a id="onset"></a>
### OnSet

#### 📋 Purpose
Called when a player joins this class

#### ⏰ When Called
When a player is assigned to this class

#### 🌐 Realm
Server

<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player joining the class</p>

#### 💡 Example Usage

```lua
    function CLASS:OnSet(client)
        client:notify("Welcome to " .. self.name)
    end

```

---

<a id="ontransferred"></a>
### OnTransferred

#### 📋 Purpose
Called when switching from another class to this class

#### ⏰ When Called
When a player switches classes and this becomes the new class

#### 🌐 Realm
Server

<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player switching classes</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">oldClass</span> The previous class data</p>

#### 💡 Example Usage

```lua
    function CLASS:OnTransferred(client, oldClass)
        if oldClass then
            client:notify("Switched from " .. oldClass.name .. " to " .. self.name)
        end
    end

```

---

<a id="onspawn"></a>
### OnSpawn

#### 📋 Purpose
Called when a player spawns with this class

#### ⏰ When Called
When a player spawns with this class

#### 🌐 Realm
Server

<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player spawning</p>

#### 💡 Example Usage

```lua
    function CLASS:OnSpawn(client)
        client:Give("weapon_stunstick")
        client:SetHealth(150)
        client:SetArmor(50)
    end

```

---

<a id="onleave"></a>
### OnLeave

#### 📋 Purpose
Called when leaving this class

#### ⏰ When Called
When a player leaves this class

#### 🌐 Realm
Server

<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player leaving</p>

#### 💡 Example Usage

```lua
    function CLASS:OnLeave(client)
        client:StripWeapon("weapon_stunstick")
    end

```

---

