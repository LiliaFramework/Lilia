# Ammo Item Definition

Ammunition item system for the Lilia framework.

---

Overview

Ammo items are stackable consumables that provide ammunition for weapons.
They can be loaded in different quantities and have visual quantity indicators.

PLACEMENT:
- Place in: ModuleFolder/items/ammo/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/ammo/ItemHere.lua (for schema-specific items)

USAGE:
- Ammo items are consumed when used
- They give ammunition based on the ITEM.ammo type
- Ammo type must match weapon's ammo type
- Can be used to reload equipped weapons
- Items are removed from inventory after use

---

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the ammo name
    ITEM.name = "Pistol Ammo"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the ammo model
    ITEM.model = "models/items/boxsrounds.mdl"

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

### ammo

#### 📋 Purpose
Sets the ammunition type that matches weapon ammo type

#### 💡 Example Usage

```lua
    -- Set ammo type
    ITEM.ammo = "pistol"

```

---

### category

#### 📋 Purpose
Sets the category for inventory sorting

#### 💡 Example Usage

```lua
    -- Set inventory category
    ITEM.category = "itemCatAmmunition"

```

---

