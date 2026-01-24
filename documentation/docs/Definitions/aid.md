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

<a id="name"></a>
### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the aid item name
    ITEM.name = "Medical Kit"

```

---

<a id="desc"></a>
### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the aid item description
    ITEM.desc = "A medical kit that restores health"

```

---

<a id="model"></a>
### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the aid item model
    ITEM.model = "models/items/medkit.mdl"

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

<a id="health"></a>
### health

#### 📋 Purpose
Sets the amount of health restored when used

#### 💡 Example Usage

```lua
    -- Set health restoration amount
    ITEM.health = 25

```

---

<a id="armor"></a>
### armor

#### 📋 Purpose
Sets the amount of armor restored when used

#### 💡 Example Usage

```lua
    -- Set armor restoration amount
    ITEM.armor = 10

```

---

<a id="stamina"></a>
### stamina

#### 📋 Purpose
Sets the amount of stamina restored when used

#### 💡 Example Usage

```lua
    -- Set stamina restoration amount
    ITEM.stamina = 50

```

---

