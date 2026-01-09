# Outfit Item Definition

Outfit item system for the Lilia framework.

---

Overview

Outfit items are wearable items that can change player appearance, models, skins, bodygroups,
and provide attribute boosts. They support PAC integration and visual indicators.

PLACEMENT:
- Place in: ModuleFolder/items/outfit/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/outfit/ItemHere.lua (for schema-specific items)

USAGE:
- Outfit items are equipped by using them
- They change the player's model and appearance
- Items remain in inventory when equipped
- Can be unequipped to restore original appearance
- Outfit categories prevent conflicts between items

---

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the outfit name
    ITEM.name = "Police Uniform"

```

---

### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the outfit description
    ITEM.desc = "Standard police officer uniform with vest"

```

---

### category

#### 📋 Purpose
Sets the category for inventory sorting

#### 💡 Example Usage

```lua
    -- Set inventory category
    ITEM.category = "outfit"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the outfit model
    ITEM.model = "models/props_c17/BriefCase001a.mdl"

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

### outfitCategory

#### 📋 Purpose
Sets the category to prevent conflicting outfits

#### 💡 Example Usage

```lua
    -- Set outfit category to prevent conflicts
    ITEM.outfitCategory = "model"

```

---

### pacData

#### 📋 Purpose
Defines PAC3 outfit data for visual effects

#### 💡 Example Usage

```lua
    -- Define PAC3 outfit parts (optional)
    ITEM.pacData = {}

```

---

### isOutfit

#### 📋 Purpose
Marks this item as an outfit

#### 💡 Example Usage

```lua
    -- Mark as outfit item
    ITEM.isOutfit = true

```

---

### paintOver

#### 📋 Purpose
Draws a green indicator square on equipped outfits in the inventory

#### ⏰ When Called
Called in function ITEM:paintOver

#### 🌐 Realm
Client

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **unknown** | The item instance being drawn |
| `w` | **unknown** | Width of the item slot |
| `h` | **unknown** | Height of the item slot |

#### ↩️ Returns
* nil

#### 💡 Example Usage

```lua
    -- Automatically called when rendering equipped outfit in inventory
    -- Shows green square in bottom-right corner when equipped

```

---

