# Class Properties and Methods

Character class definition system for the Lilia framework.

---

## Overview

The class system provides comprehensive functionality for defining character classes

within the Lilia framework. Classes represent specific roles or professions that

characters can assume within factions, creating a hierarchical structure where

factions serve as parent containers for classes.



**Faction-Class Relationship:**

- **Factions** are the main organizational units (Citizens, Police, Medical, etc.)

- **Classes** are sub-divisions within factions (Officer, Detective, Captain within Police)

- Each character belongs to exactly ONE faction and ONE class within that faction

- Classes inherit all properties from their parent faction by default

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



Classes are defined using the CLASS table structure, which includes properties for

identification, visual representation, gameplay mechanics, and access control. The

system includes callback methods that are automatically invoked during key character

lifecycle events, enabling dynamic behavior and customization.



Classes can have player limits, whitelist requirements, specialized loadouts, and

attribute modifications that affect gameplay. The system supports modifying player

health, armor, movement speeds, model scale, weapons, and NPC relationships,

providing a flexible foundation for role-based gameplay systems.



**Access Control:** Classes use the `isWhitelisted` property to require whitelist access,

and the `OnCanBe` callback method to implement custom permission logic. The `OnCanBe`

callback is called when a player attempts to join a class and can check attributes,

permissions, or any other conditions before allowing access.



In addition to the CLASS table properties, classes can also modify character variables

such as classwhitelists to control which classes a character has access to.

---

### name

**Purpose**

Sets the display name of the character class

**When Called**

During class definition

---

### desc

**Purpose**

Sets the description of the character class

**When Called**

During class definition

---

### faction

**Purpose**

Sets the faction ID this class belongs to

**When Called**

During class definition

---

### limit

**Purpose**

Sets the maximum number of players allowed in this class

**When Called**

During class definition

---

### model

**Purpose**

Sets the player model for this class

**When Called**

During class definition

---

### isWhitelisted

**Purpose**

Sets whether this class requires whitelist access

**When Called**

During class definition

---

### isDefault

**Purpose**

Sets whether this is the default class for the faction

**When Called**

During class definition

---

### scoreboardHidden

**Purpose**

Hides this class from the scoreboard display

**When Called**

During class definition

---

### pay

**Purpose**

Sets the salary amount for this class

**When Called**

During class definition

---

### uniqueID

**Purpose**

Unique identifier for the class (INTERNAL - set automatically when registered)

**When Called**

Set automatically during class registration

---

### index

**Purpose**

Numeric index of the class in the class list (set automatically)

**When Called**

Set automatically during class registration

---

### Color

**Purpose**

Sets the team/class color for UI elements and identification

**When Called**

During class definition

---

### health

**Purpose**

Sets the maximum health for players in this class

**When Called**

During class definition (applied when player joins class)

---

### armor

**Purpose**

Sets the armor value for players in this class

**When Called**

During class definition (applied when player joins class)

---

### weapons

**Purpose**

Sets weapons to give to players when they join this class

**When Called**

During class definition (applied when player spawns)

---

### scale

**Purpose**

Sets the model scale for players in this class

**When Called**

During class definition (applied when player joins class)

---

### runSpeed

**Purpose**

Sets the running speed for players in this class

**When Called**

During class definition (applied when player joins class)

---

### walkSpeed

**Purpose**

Sets the walking speed for players in this class

**When Called**

During class definition (applied when player joins class)

---

### jumpPower

**Purpose**

Sets the jump power for players in this class

**When Called**

During class definition (applied when player joins class)

---

### NPCRelations

**Purpose**

Sets NPC relationship overrides for this class (inherits from faction)

**When Called**

During class definition (applied when player joins class)

---

### bloodcolor

**Purpose**

Sets the blood color for players in this class

**When Called**

During class definition (applied when player joins class)

---

### runSpeedMultiplier

**Purpose**

Whether runSpeed should be treated as a multiplier instead of absolute value

**When Called**

During class definition (used with runSpeed property)

---

### walkSpeedMultiplier

**Purpose**

Whether walkSpeed should be treated as a multiplier instead of absolute value

**When Called**

During class definition (used with walkSpeed property)

---

### jumpPowerMultiplier

**Purpose**

Whether jumpPower should be treated as a multiplier instead of absolute value

**When Called**

During class definition (used with jumpPower property)

---

### OnCanBe

**Purpose**

Check if a player can join this class

**When Called**

When a player attempts to join this class

**Parameters**

* `client` (*Player*): The player trying to join

---

### OnSet

**Purpose**

Called when a player joins this class

**When Called**

When a player is assigned to this class

**Parameters**

* `client` (*Player*): The player joining the class

---

### OnTransferred

**Purpose**

Called when switching from another class to this class

**When Called**

When a player switches classes and this becomes the new class

**Parameters**

* `client` (*Player*): The player switching classes
* `oldClass` (*table*): The previous class data

---

### OnSpawn

**Purpose**

Called when a player spawns with this class

**When Called**

When a player spawns with this class

**Parameters**

* `client` (*Player*): The player spawning

---

### OnLeave

**Purpose**

Called when leaving this class

**When Called**

When a player leaves this class

**Parameters**

* `client` (*Player*): The player leaving

---

