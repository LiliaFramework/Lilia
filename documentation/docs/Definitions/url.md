# URL Item Definition

URL item system for the Lilia framework.

---

Overview

URL items open web URLs when used by players.
They are simple items with a single use function.

PLACEMENT:
- Place in: ModuleFolder/items/url/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/url/ItemHere.lua (for schema-specific items)

USAGE:
- URL items are used by clicking them
- They open the URL specified in ITEM.url
- URLs open in the player's default browser
- Items are not consumed when used
- Can be used multiple times

---

<a id="name"></a>
### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the URL item name
    ITEM.name = "Website Link"

```

---

<a id="desc"></a>
### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the URL item description
    ITEM.desc = "Opens the Lilia framework documentation website"

```

---

<a id="model"></a>
### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the URL item model
    ITEM.model = "models/props_lab/clipboard.mdl"

```

---

<a id="url"></a>
### url

#### 📋 Purpose
Sets the URL that opens when the item is used

#### 💡 Example Usage

```lua
    -- Set the URL to open
    ITEM.url = "https://docs.getlilia.com"

```

---

