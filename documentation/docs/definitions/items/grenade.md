# Grenade Item Definition

Grenade item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Fragmentation Grenade"

```

---

### desc

**Purpose**

Sets the description of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A deadly fragmentation grenade"

```

---

### category

**Purpose**

Sets the category for the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "itemCatGrenades"

```

---

### model

**Purpose**

Sets the 3D model for the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"

```

---

### class

**Purpose**

Sets the weapon class name for the grenade

**When Called**

During item definition (used in Use function)

**Example Usage**

```lua
ITEM.class = "weapon_frag"

```

---

### width

**Purpose**

Sets the inventory width of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### DropOnDeath

**Purpose**

Sets whether the grenade drops when player dies

**When Called**

During item definition

**Example Usage**

```lua
ITEM.DropOnDeath = true  -- Drops on death

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
        ITEM.name = "Fragmentation Grenade"

        ITEM.desc = "A deadly fragmentation grenade"

        ITEM.category = "itemCatGrenades"

        ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"

        ITEM.class = "weapon_frag"

        ITEM.width = 1  -- Takes 1 slot width

        ITEM.height = 1  -- Takes 1 slot height

        ITEM.DropOnDeath = true  -- Drops on death

-- Basic item identification
ITEM.name = "Fragmentation Grenade"                    -- Display name shown to players
ITEM.desc = "A deadly fragmentation grenade"           -- Description text
ITEM.category = "itemCatGrenades"                      -- Category for inventory sorting
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"     -- 3D model for the grenade
ITEM.class = "weapon_frag"                             -- Weapon class to give when used
ITEM.width = 1                                         -- Inventory width (1 slot)
ITEM.height = 1                                        -- Inventory height (1 slot)

```

---

