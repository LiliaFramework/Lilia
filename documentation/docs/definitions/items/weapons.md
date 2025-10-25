# Weapons Item Definition

Weapon item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Pistol"

```

---

### desc

**Purpose**

Sets the description of the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A standard issue pistol"

```

---

### category

**Purpose**

Sets the category for the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "weapons"

```

---

### model

**Purpose**

Sets the 3D model for the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/weapons/w_pistol.mdl"

```

---

### class

**Purpose**

Sets the weapon class name

**When Called**

During item definition (used in equip/unequip functions)

**Example Usage**

```lua
ITEM.class = "weapon_pistol"

```

---

### width

**Purpose**

Sets the inventory width of the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 2  -- Takes 2 slot width

```

---

### height

**Purpose**

Sets the inventory height of the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 2  -- Takes 2 slot height

```

---

### isWeapon

**Purpose**

Marks the item as a weapon

**When Called**

During item definition

**Example Usage**

```lua
ITEM.isWeapon = true

```

---

### RequiredSkillLevels

**Purpose**

Sets required skill levels for the weapon

**When Called**

During item definition

**Example Usage**

```lua
ITEM.RequiredSkillLevels = {}  -- No skill requirements

```

---

### DropOnDeath

**Purpose**

Sets whether the weapon drops when player dies

**When Called**

During item definition

**Example Usage**

```lua
ITEM.DropOnDeath = true  -- Drops on death

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Pistol"                              -- Display name shown to players
ITEM.desc = "A standard issue pistol"             -- Description text
ITEM.category = "weapons"                         -- Category for inventory sorting
ITEM.model = "models/weapons/w_pistol.mdl"        -- 3D model for the weapon
ITEM.class = "weapon_pistol"                      -- Weapon class to give when equipped
ITEM.width = 2                                    -- Inventory width (2 slots)
ITEM.height = 2                                   -- Inventory height (2 slots)

```

---

