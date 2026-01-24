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

<a id="name"></a>
### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the outfit name
    ITEM.name = "Police Uniform"

```

---

<a id="desc"></a>
### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the outfit description
    ITEM.desc = "Standard police officer uniform with vest"

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
    -- Set the outfit model
    ITEM.model = "models/props_c17/BriefCase001a.mdl"

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
Sets the category to prevent conflicting outfits

#### 💡 Example Usage

```lua
    -- Set outfit category to prevent conflicts
    ITEM.outfitCategory = "model"

```

---

<a id="pacdata"></a>
### pacData

#### 📋 Purpose
Defines PAC3 outfit data for visual effects

#### 💡 Example Usage

```lua
    -- Define PAC3 outfit parts (optional)
    ITEM.pacData = {}

```

---

<a id="isoutfit"></a>
### isOutfit

#### 📋 Purpose
Marks this item as an outfit

#### 💡 Example Usage

```lua
    -- Mark as outfit item
    ITEM.isOutfit = true

```

---

<a id="paintover"></a>
### paintOver

#### 📋 Purpose
Draws a green indicator square on equipped outfits in the inventory

#### ⏰ When Called
Called in function ITEM:paintOver

#### 🌐 Realm
Client

<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">item</span> The item instance being drawn</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">w</span> Width of the item slot</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">h</span> Height of the item slot</p>

#### 💡 Example Usage

```lua
    -- Automatically called when rendering equipped outfit in inventory
    -- Shows green square in bottom-right corner when equipped

```

---

