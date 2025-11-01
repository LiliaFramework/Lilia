# Stackable Item Definition

Stackable item system for the Lilia framework.

---

### Purpose:

**Purpose**

Sets the display name of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Ammo Box"

```

---

### Purpose:

**Purpose**

Sets the 3D model for the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_junk/cardboard_box001a.mdl"

```

---

### Purpose:

**Purpose**

Sets the inventory width of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### Purpose:

**Purpose**

Sets the inventory height of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### Purpose:

**Purpose**

Marks the item as stackable

**When Called**

During item definition

**Example Usage**

```lua
ITEM.isStackable = true

```

---

### Purpose:

**Purpose**

Sets the maximum quantity for the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.maxQuantity = 10  -- Maximum 10 items per stack

```

---

### Purpose:

**Purpose**

Sets whether the item can be split

**When Called**

During item definition

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

