# Entities Item Definition

Entity placement item system for the Lilia framework.

---

Overview

Entity items allow players to place down entities in the world.
They support data restoration and various entity properties.

PLACEMENT:
- Place in: ModuleFolder/items/entities/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/entities/ItemHere.lua (for schema-specific items)

USAGE:
- Entity items are placed by using the item
- They spawn the entity specified in ITEM.entityid
- Entities are placed at the player's position
- Items are consumed when placed
- Entities can be picked up and returned to inventory

---

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the entity item name
    ITEM.name = "Vending Machine"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the item model (empty for entity placement)
    ITEM.model = "models/props_interiors/vendingmachinesoda01a.mdl"

```

---

### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the entity description
    ITEM.desc = "A functional vending machine that can be placed in the world"

```

---

### category

#### 📋 Purpose
Sets the category for inventory sorting

#### 💡 Example Usage

```lua
    -- Set inventory category
    ITEM.category = "entities"

```

---

### entityid

#### 📋 Purpose
Sets the entity class to spawn when the item is placed

#### 💡 Example Usage

```lua
    -- Set the entity class to spawn
    ITEM.entityid = "lia_vendingmachine"

```

---

