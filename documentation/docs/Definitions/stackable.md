# Stackable Item Definition

Stackable item system for the Lilia framework.

---

Overview

Stackable items can be combined together and have quantity limits.
They display quantity visually and support splitting functionality.

PLACEMENT:
- Place in: ModuleFolder/items/stackable/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/stackable/ItemHere.lua (for schema-specific items)

USAGE:
- Stackable items can be combined with other stacks
- They can be split into smaller quantities
- Visual indicators show quantity in inventory
- Items are consumed when used
- Maximum quantity is controlled by ITEM.maxQuantity

---

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the item name
    ITEM.name = "Wood Planks"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the item model
    ITEM.model = "models/props_debris/wood_board04a.mdl"

```

---

### width

#### 📋 Purpose
Sets the inventory width in slots

#### 💡 Example Usage

```lua
    -- Set inventory width
    ITEM.width = 2

```

---

### height

#### 📋 Purpose
Sets the inventory height in slots

#### 💡 Example Usage

```lua
    -- Set inventory height
    ITEM.height = 1

```

---

### isStackable

#### 📋 Purpose
Enables stacking functionality for this item

#### 💡 Example Usage

```lua
    -- Enable stacking
    ITEM.isStackable = true

```

---

### maxQuantity

#### 📋 Purpose
Sets the maximum quantity that can be stacked together

#### 💡 Example Usage

```lua
    -- Set maximum stack size
    ITEM.maxQuantity = 20

```

---

### canSplit

#### 📋 Purpose
Allows players to split stacks into smaller amounts

#### 💡 Example Usage

```lua
    -- Allow splitting stacks
    ITEM.canSplit = true

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
    -- Set the item name
    ITEM.name = "Wood Planks"

    -- Set the item model
    ITEM.model = "models/props_debris/wood_board04a.mdl"

    -- Set inventory width
    ITEM.width = 2

    -- Set inventory height
    ITEM.height = 1

    -- Enable stacking
    ITEM.isStackable = true

    -- Set maximum stack size
    ITEM.maxQuantity = 20

    -- Allow splitting stacks
    ITEM.canSplit = true

```

```lua
    -- Basic item identification
        ITEM.name = "Wood Planks"                    -- Display name shown to players
        ITEM.desc = "Stackable wooden planks for building"  -- Description text
        ITEM.model = "models/props_debris/wood_board04a.mdl"  -- 3D model for the item
        ITEM.width = 2                               -- Inventory width (2 slots)
        ITEM.height = 1                              -- Inventory height (1 slot)
        ITEM.isStackable = true                      -- Enables stacking functionality
        ITEM.maxQuantity = 20                        -- Maximum quantity that can be stacked
        ITEM.canSplit = true                         -- Allows splitting stacks into smaller amounts

```

---

