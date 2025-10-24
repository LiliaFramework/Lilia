# Faction Properties and Methods

Character faction definition system for the Lilia framework.

---

## Overview

The faction system provides comprehensive functionality for defining character factions

within the Lilia framework. Factions represent the main organizational units that

characters belong to, serving as parent containers for classes. Each character belongs

to exactly ONE faction and can have multiple classes within that faction.



**Faction-Class Relationship:**

- **Factions** are the main organizational units (Citizens, Police, Medical, Staff)

- **Classes** are sub-divisions within factions (Officer, Detective, Captain within Police)

- Each character belongs to exactly ONE faction but can switch between classes within that faction

- **CLASS settings overpower FACTION settings** - any property defined in a class

takes precedence over the same property in the parent faction



**Example Hierarchy:**

```

Faction: Police Department

├── Class: Police Officer (inherits police models, weapons, color)

├── Class: Police Detective (inherits police properties, overrides with detective-specific items)

├── Class: Police Captain (inherits police properties, overrides with command-specific permissions)

└── Class: SWAT Officer (inherits police properties, overrides with tactical gear)

```



Factions are defined using the FACTION table structure, which includes properties for

identification, visual representation, gameplay mechanics, and access control. The

system includes callback methods that are automatically invoked during key character

lifecycle events, enabling dynamic behavior and customization.



Factions can have player limits, whitelist requirements, specialized loadouts, and

attribute modifications that affect gameplay. The system supports modifying player

health, armor, movement speeds, model scale, weapons, and NPC relationships,

providing a flexible foundation for role-based gameplay systems.



**Player Management:** Factions support player limits (absolute or percentage-based),

character restrictions (one character per player), custom name generation templates,

and custom limit checking logic for advanced access control scenarios.



**Access Control:** Factions use the `isDefault` property to determine if they are

accessible to all players, and can implement custom permission logic through

whitelist systems and the framework's permission system.



In addition to the FACTION table properties, factions can also modify character variables

such as classwhitelists to control which classes a character has access to within the faction.

---

### name

**Purpose**

Sets the display name of the character faction

**When Called**

During faction definition

---

### desc

**Purpose**

Sets the description of the character faction

**When Called**

During faction definition

---

### color

**Purpose**

Sets the team/faction color for UI elements and identification

**When Called**

During faction definition

---

### models

**Purpose**

Sets the player models available for this faction

**When Called**

During faction definition

---

### weapons

**Purpose**

Sets weapons to give to players when they join this faction

**When Called**

During faction definition (applied when player spawns)

---

### isDefault

**Purpose**

Sets whether this is a default faction that new characters can join

**When Called**

During faction definition

---

### uniqueID

**Purpose**

Unique identifier for the faction (INTERNAL - set automatically when registered)

**When Called**

Set automatically during faction registration

---

### index

**Purpose**

Numeric index of the faction in the faction list (set automatically or manually)

**When Called**

Set automatically during faction registration, or manually specified

---

### health

**Purpose**

Sets the maximum health for players in this faction

**When Called**

During faction definition (applied when player joins faction)

---

### armor

**Purpose**

Sets the armor value for players in this faction

**When Called**

During faction definition (applied when player joins faction)

---

### scale

**Purpose**

Sets the model scale for players in this faction

**When Called**

During faction definition (applied when player joins faction)

---

### runSpeed

**Purpose**

Sets the running speed for players in this faction

**When Called**

During faction definition (applied when player joins faction)

---

### walkSpeed

**Purpose**

Sets the walking speed for players in this faction

**When Called**

During faction definition (applied when player joins faction)

---

### jumpPower

**Purpose**

Sets the jump power for players in this faction

**When Called**

During faction definition (applied when player joins faction)

---

### NPCRelations

**Purpose**

Sets NPC relationship overrides for this faction

**When Called**

During faction definition (applied when player joins faction)

---

### bloodcolor

**Purpose**

Sets the blood color for players in this faction

**When Called**

During faction definition (applied when player joins faction)

---

### runSpeedMultiplier

**Purpose**

Whether runSpeed should be treated as a multiplier instead of absolute value

**When Called**

During faction definition (used with runSpeed property)

---

### walkSpeedMultiplier

**Purpose**

Whether walkSpeed should be treated as a multiplier instead of absolute value

**When Called**

During faction definition (used with walkSpeed property)

---

### jumpPowerMultiplier

**Purpose**

Whether jumpPower should be treated as a multiplier instead of absolute value

**When Called**

During faction definition (used with jumpPower property)

---

### items

**Purpose**

Sets items to give to characters when they are created in this faction

**When Called**

During faction definition (applied when character is created)

---

### oneCharOnly

**Purpose**

Sets whether players can only have one character in this faction

**When Called**

During faction definition

---

### limit

**Purpose**

Sets the maximum number of players allowed in this faction

**When Called**

During faction definition

---

### NameTemplate

**Purpose**

Sets a function to generate default character names for this faction

**When Called**

During faction definition

---

### GetDefaultName

**Purpose**

Sets a method to get the default character name for this faction

**When Called**

During faction definition

---

### GetDefaultDesc

**Purpose**

Sets a method to get the default character description for this faction

**When Called**

During faction definition

---

### OnCheckLimitReached

**Purpose**

Custom callback to check if faction player limit is reached

**When Called**

When a player tries to join a faction that might be at capacity

**Parameters**

* `character` (*Character*): The character trying to join
* `client` (*Player*): The player whose character is joining

---

### OnTransferred

**Purpose**

Called when a player transfers to this faction

**When Called**

When a player changes factions and this becomes their new faction

**Parameters**

* `client` (*Player*): The player transferring to this faction

---

### OnSpawn

**Purpose**

Called when a player spawns with this faction

**When Called**

When a player spawns with this faction

**Parameters**

* `client` (*Player*): The player spawning

---

