# Grenade Item Definition

Grenade item system for the Lilia framework.

---

Overview

Grenade items are weapons that can be equipped and used by players.
They drop on death and prevent duplicate grenades.

PLACEMENT:
- Place in: ModuleFolder/items/grenade/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/grenade/ItemHere.lua (for schema-specific items)

USAGE:
- Grenades are used by equipping them
- They give the weapon specified in ITEM.class
- Items are consumed when equipped
- Weapons can be thrown and will explode
- Grenades drop on death if ITEM.DropOnDeath is true

---

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the grenade name
    ITEM.name = "Frag Grenade"

```

---

### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the grenade description
    ITEM.desc = "A high-explosive fragmentation grenade"

```

---

### category

#### 📋 Purpose
Sets the category for inventory sorting

#### 💡 Example Usage

```lua
    -- Set inventory category
    ITEM.category = "itemCatGrenades"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the grenade model
    ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"

```

---

### class

#### 📋 Purpose
Sets the weapon entity class that gets given to players

#### 💡 Example Usage

```lua
    -- Set the grenade weapon class
    ITEM.class = "weapon_frag"

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

### DropOnDeath

#### 📋 Purpose
Determines whether grenade drops on player death

#### 💡 Example Usage

```lua
    -- Make grenade drop on death
    ITEM.DropOnDeath = true

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
    -- Set the grenade name
    ITEM.name = "Frag Grenade"

    -- Set the grenade description
    ITEM.desc = "A high-explosive fragmentation grenade"

    -- Set inventory category
    ITEM.category = "itemCatGrenades"

    -- Set the grenade model
    ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"

    -- Set the grenade weapon class
    ITEM.class = "weapon_frag"

    -- Set inventory width
    ITEM.width = 1

    -- Set inventory height
    ITEM.height = 1

    -- Make grenade drop on death
    ITEM.DropOnDeath = true

```

```lua
    -- Basic item identification
        ITEM.name = "Frag Grenade"                   -- Display name shown to players
        ITEM.desc = "A high-explosive fragmentation grenade"  -- Description text
        ITEM.category = "itemCatGrenades"            -- Category for inventory sorting
        ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"  -- 3D model for the grenade
        ITEM.class = "weapon_frag"                   -- Weapon class to give to player
        ITEM.width = 1                               -- Inventory width (1 slot)
        ITEM.height = 1                              -- Inventory height (1 slot)
        ITEM.DropOnDeath = true                      -- Grenade drops when player dies

```

---

