# Grenade Item Definition

Grenade item system for the Lilia framework.

---

### Purpose:

**Purpose**

Sets the display name of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Fragmentation Grenade"

```

---

### Purpose:

**Purpose**

Sets the description of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A deadly fragmentation grenade"

```

---

### Purpose:

**Purpose**

Sets the category for the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "itemCatGrenades"

```

---

### Purpose:

**Purpose**

Sets the 3D model for the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"

```

---

### Purpose:

**Purpose**

Sets the weapon class name for the grenade

**When Called**

During item definition (used in Use function)

**Example Usage**

```lua
ITEM.class = "weapon_frag"

```

---

### Purpose:

**Purpose**

Sets the inventory width of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### Purpose:

**Purpose**

Sets the inventory height of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### Purpose:

**Purpose**

Sets whether the grenade drops when player dies

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
ITEM.name = "Fragmentation Grenade"                    -- Display name shown to players
ITEM.desc = "A deadly fragmentation grenade"           -- Description text
ITEM.category = "itemCatGrenades"                      -- Category for inventory sorting
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"     -- 3D model for the grenade
ITEM.class = "weapon_frag"                             -- Weapon class to give when used
ITEM.width = 1                                         -- Inventory width (1 slot)
ITEM.height = 1                                        -- Inventory height (1 slot)

```

---

