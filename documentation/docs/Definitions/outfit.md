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

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
    -- Set the outfit name
    ITEM.name = "Police Uniform"

    -- Set the outfit description
    ITEM.desc = "Standard police officer uniform with vest"

    -- Set inventory category
    ITEM.category = "outfit"

    -- Set the outfit model
    ITEM.model = "models/props_c17/BriefCase001a.mdl"

    -- Set inventory width
    ITEM.width = 1

    -- Set inventory height
    ITEM.height = 1

    -- Set outfit category to prevent conflicts
    ITEM.outfitCategory = "model"

    -- Define PAC3 outfit parts (optional)
    ITEM.pacData = {}

    -- Mark as outfit item
    ITEM.isOutfit = true

```

```lua
    -- Automatically called when rendering equipped outfit in inventory
    -- Shows green square in bottom-right corner when equipped

```

```lua
    -- Basic item identification
        ITEM.name = "Police Uniform"                 -- Display name shown to players
        ITEM.desc = "Standard police officer uniform with vest"  -- Description text
        ITEM.category = "outfit"                     -- Category for inventory sorting
        ITEM.model = "models/props_c17/BriefCase001a.mdl"  -- 3D model for the item
        ITEM.width = 1                               -- Inventory width (1 slot)
        ITEM.height = 1                              -- Inventory height (1 slot)
        ITEM.outfitCategory = "model"                -- Category to prevent conflicting outfits
        ITEM.pacData = {}                            -- PAC3 outfit data (empty for basic model replacement)
        ITEM.isOutfit = true                         -- Marks this as an outfit item
        ITEM.replacement = "models/player/police.mdl" -- Model to replace player's model with
        ITEM.attribBoosts = {                        -- Attribute bonuses when equipped
            ["endurance"] = 5,                        -- +5 endurance attribute
            ["luck"] = -2                             -- -2 luck attribute
        }

```

---

