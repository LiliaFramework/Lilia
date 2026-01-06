# Aid Item Definition

Medical aid item system for the Lilia framework.

---

Overview

Aid items are consumable medical items that can restore health to players.
They can be used on the player themselves or on other players through targeting.

PLACEMENT:
- Place in: ModuleFolder/items/aid/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/aid/ItemHere.lua (for schema-specific items)

USAGE:
- Aid items are automatically consumed when used
- They restore health based on the ITEM.health value
- Can be used on self or other players
- Health restoration is instant and cannot be interrupted
- Items are removed from inventory after use

---

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the aid item name
    ITEM.name = "Medical Kit"

```

---

### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the aid item description
    ITEM.desc = "A medical kit that restores health"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the aid item model
    ITEM.model = "models/items/medkit.mdl"

```

---

### width

#### 📋 Purpose
Sets the inventory width in slots

#### 💡 Example Usage

```lua
    -- Set inventory width
    ITEM.width = 1

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

### health

#### 📋 Purpose
Sets the amount of health restored when used

#### 💡 Example Usage

```lua
    -- Set health restoration amount
    ITEM.health = 25

```

---

### armor

#### 📋 Purpose
Sets the amount of armor restored when used

#### 💡 Example Usage

```lua
    -- Set armor restoration amount
    ITEM.armor = 10

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
    -- Set the aid item name
    ITEM.name = "Medical Kit"

    -- Set the aid item description
    ITEM.desc = "A medical kit that restores health"

    -- Set the aid item model
    ITEM.model = "models/items/medkit.mdl"

    -- Set inventory width
    ITEM.width = 1

    -- Set inventory height
    ITEM.height = 1

    -- Set health restoration amount
    ITEM.health = 25

    -- Set armor restoration amount
    ITEM.armor = 10

```

```lua
    -- Basic item identification
        ITEM.name = "Medical Kit"                    -- Display name shown to players
        ITEM.desc = "A medical kit that restores 25 health points"  -- Description text
        ITEM.model = "models/items/medkit.mdl"       -- 3D model for the item
        ITEM.width = 1                               -- Inventory width (1 slot)
        ITEM.height = 1                              -- Inventory height (1 slot)
        ITEM.health = 25                             -- Health amount restored when used

```

---

