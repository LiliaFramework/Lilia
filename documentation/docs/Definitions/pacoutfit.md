# PAC Outfit Item Definition

PAC outfit item system for the Lilia framework.

---

Overview

PAC outfit items are wearable items that use PAC (Player Accessory Creator) for visual effects.
They require the PAC addon and provide visual indicators when equipped.

PLACEMENT:
- Place in: ModuleFolder/items/pacoutfit/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/pacoutfit/ItemHere.lua (for schema-specific items)

USAGE:
- PAC outfit items are equipped by using them
- They add PAC3 parts to the player
- Items remain in inventory when equipped
- Can be unequipped to remove PAC3 parts
- Requires PAC3 addon to function properly

---

<a id="name"></a>
### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the outfit name
    ITEM.name = "Cool Sunglasses"

```

---

<a id="desc"></a>
### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the outfit description
    ITEM.desc = "Stylish sunglasses that look great"

```

---

<a id="category"></a>
### category

#### 📋 Purpose
Sets the category for inventory sorting

#### 💡 Example Usage

```lua
    -- Set inventory category
    ITEM.category = "outfit"

```

---

<a id="model"></a>
### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the item model
    ITEM.model = "models/Gibs/HGIBS.mdl"

```

---

<a id="width"></a>
### width

#### 📋 Purpose
Sets the inventory width in slots

#### 💡 Example Usage

```lua
    -- Set inventory width
    ITEM.width = 1

```

---

<a id="height"></a>
### height

#### 📋 Purpose
Sets the inventory height in slots

#### 💡 Example Usage

```lua
    -- Set inventory height
    ITEM.height = 1

```

---

<a id="outfitcategory"></a>
### outfitCategory

#### 📋 Purpose
Sets the category to prevent conflicting PAC outfits

#### 💡 Example Usage

```lua
    -- Set outfit category to prevent conflicts
    ITEM.outfitCategory = "hat"

```

---

<a id="pacdata"></a>
### pacData

#### 📋 Purpose
Defines PAC3 outfit data for visual effects

#### 💡 Example Usage

```lua
    -- Define PAC3 outfit parts
    ITEM.pacData = {
        [1] = {
            ["children"] = {},
            ["self"] = {
                Skin = 0,
                UniqueID = "sunglasses_example",
                Size = 1,
                Bone = "head",
                Model = "models/captainbigbutt/skeyler/accessories/glasses01.mdl",
                ClassName = "model"
            }
        }
    }

```

---

