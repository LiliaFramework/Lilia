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

### health

**Purpose**

Sets the health value for the item when it's dropped as an entity in the world

**When Called**

During item definition (used when item is spawned as entity)
Notes:
- Defaults to 100 if not specified
- When the item entity takes damage, its health decreases
- Item is destroyed when health reaches 0
- Only applies if ITEM.CanBeDestroyed is true (controlled by config)

**Example Usage**

```lua
ITEM.health = 250  -- Item can take 250 damage before being destroyed

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

        ITEM.health = 250  -- Item can take 250 damage before being destroyed

        ITEM.isStackable = true

        ITEM.maxQuantity = 10  -- Maximum 10 items per stack

        ITEM.canSplit = true  -- Allows splitting the stack

-- Basic item identification
    ITEM.name = "Ammo Box"                  -- Display name shown to players
    ITEM.model = "models/props_junk/cardboard_box001a.mdl"  -- 3D model for the item
    ITEM.width = 1                          -- Inventory width (1 slot)
    ITEM.height = 1                         -- Inventory height (1 slot)
    ITEM.health = 100                       -- Health when dropped (default: 100)
    ITEM.isStackable = true                 -- Enables stacking functionality
    ITEM.maxQuantity = 10                   -- Maximum items per stack

```

---

