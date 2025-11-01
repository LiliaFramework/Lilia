# Stackable Item Definition

Stackable item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Ammo Box"

```

---

### model

**Purpose**

Sets the 3D model for the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_junk/cardboard_box001a.mdl"

```

---

### width

**Purpose**

Sets the inventory width of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### isStackable

**Purpose**

Marks the item as stackable

**When Called**

During item definition

**Example Usage**

```lua
ITEM.isStackable = true

```

---

### maxQuantity

**Purpose**

Sets the maximum quantity for the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.maxQuantity = 10  -- Maximum 10 items per stack

```

---

### canSplit

**Purpose**

Sets whether the item can be split

**When Called**

During item definition

**Example Usage**

```lua
ITEM.canSplit = true  -- Allows splitting the stack

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
        ITEM.name = "Ammo Box"

        ITEM.model = "models/props_junk/cardboard_box001a.mdl"

        ITEM.width = 1  -- Takes 1 slot width

        ITEM.height = 1  -- Takes 1 slot height

        ITEM.isStackable = true

        ITEM.maxQuantity = 10  -- Maximum 10 items per stack

        ITEM.canSplit = true  -- Allows splitting the stack

-- Basic item identification
ITEM.name = "Ammo Box"                                    -- Display name shown to players
ITEM.model = "models/props_junk/cardboard_box001a.mdl"   -- 3D model for the item
ITEM.width = 1                                            -- Inventory width (1 slot)
ITEM.height = 1                                           -- Inventory height (1 slot)
ITEM.isStackable = true                                   -- Enables stacking functionality
ITEM.maxQuantity = 10                                     -- Maximum items per stack

```

---

