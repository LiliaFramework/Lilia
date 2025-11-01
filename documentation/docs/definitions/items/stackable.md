# Stackable Item Definition

Stackable item system for the Lilia framework.

---

### Purpose:

**Example Usage**

```lua
ITEM.name = "Ammo Box"

```

---

### Purpose:

**Example Usage**

```lua
ITEM.model = "models/props_junk/cardboard_box001a.mdl"

```

---

### Purpose:

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### Purpose:

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### Purpose:

**Example Usage**

```lua
ITEM.isStackable = true

```

---

### Purpose:

**Example Usage**

```lua
ITEM.maxQuantity = 10  -- Maximum 10 items per stack

```

---

### Purpose:

**Example Usage**

```lua
ITEM.canSplit = true  -- Allows splitting the stack

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Ammo Box"                                    -- Display name shown to players
ITEM.model = "models/props_junk/cardboard_box001a.mdl"   -- 3D model for the item
ITEM.width = 1                                            -- Inventory width (1 slot)
ITEM.height = 1                                           -- Inventory height (1 slot)
ITEM.isStackable = true                                   -- Enables stacking functionality
ITEM.maxQuantity = 10                                     -- Maximum items per stack

```

---

