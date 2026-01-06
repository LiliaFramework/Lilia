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

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the URL item name
    ITEM.name = "Website Link"

```

---

### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the URL item description
    ITEM.desc = "Opens the Lilia framework documentation website"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the URL item model
    ITEM.model = "models/props_lab/clipboard.mdl"

```

---

### url

#### 📋 Purpose
Sets the URL that opens when the item is used

#### 💡 Example Usage

```lua
    -- Set the URL to open
    ITEM.url = "https://docs.getlilia.com"

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
            -- Set the URL item name
            ITEM.name = "Website Link"

            -- Set the URL item description
            ITEM.desc = "Opens the Lilia framework documentation website"

            -- Set the URL item model
            ITEM.model = "models/props_lab/clipboard.mdl"

            -- Set the URL to open
            ITEM.url = "https://docs.getlilia.com"

    -- Basic item identification
        ITEM.name = "Website Link"                   -- Display name shown to players
        ITEM.desc = "Opens the Lilia framework documentation website"  -- Description text
        ITEM.model = "models/props_lab/clipboard.mdl"  -- 3D model for the item
        ITEM.width = 1                               -- Inventory width (1 slot)
        ITEM.height = 1                              -- Inventory height (1 slot)
        ITEM.url = "https://docs.getlilia.com"       -- URL that opens when item is used

```

---

