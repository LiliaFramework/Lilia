# Weapons Item Definition

Weapon item system for the Lilia framework.

---

Overview

Weapon items are equippable weapons that can be given to players.
They support ammo tracking, weapon categories, and visual indicators.

PLACEMENT:
- Place in: ModuleFolder/items/weapons/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/weapons/ItemHere.lua (for schema-specific items)

USAGE:
- Weapon items are equipped by using them
- They give the weapon specified in ITEM.class
- Items remain in inventory when equipped
- Can be unequipped to remove weapons
- Weapons drop on death if ITEM.DropOnDeath is true

---

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the weapon name
    ITEM.name = "Pistol"

```

---

### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the weapon description
    ITEM.desc = "A standard 9mm pistol with moderate damage"

```

---

### category

#### 📋 Purpose
Sets the category for inventory sorting and organization

#### 💡 Example Usage

```lua
    -- Set inventory category
    ITEM.category = "weapons"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the weapon model
    ITEM.model = "models/weapons/w_pistol.mdl"

```

---

### class

#### 📋 Purpose
Sets the weapon entity class that gets given to players

#### 💡 Example Usage

```lua
    -- Set the weapon class
    ITEM.class = "weapon_pistol"

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
    ITEM.height = 2

```

---

### isWeapon

#### 📋 Purpose
Marks this item as a weapon for special handling

#### 💡 Example Usage

```lua
    -- Mark as weapon item
    ITEM.isWeapon = true

```

---

### RequiredSkillLevels

#### 📋 Purpose
Sets required skill levels to equip this weapon

#### 💡 Example Usage

```lua
    -- Set required skill levels
    ITEM.RequiredSkillLevels = {
        ["guns"] = 5
    }

```

---

### DropOnDeath

#### 📋 Purpose
Determines whether weapon drops on player death

#### 💡 Example Usage

```lua
    -- Make weapon drop on death
    ITEM.DropOnDeath = true

```

---

