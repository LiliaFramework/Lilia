# PAC Outfit Item Definition

PAC outfit item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Hat"

```

---

### desc

**Purpose**

Sets the description of the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A stylish hat"

```

---

### category

**Purpose**

Sets the category for the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "outfit"

```

---

### model

**Purpose**

Sets the 3D model for the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/Gibs/HGIBS.mdl"

```

---

### width

**Purpose**

Sets the inventory width of the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### outfitCategory

**Purpose**

Sets the outfit category for conflict checking

**When Called**

During item definition

**Example Usage**

```lua
ITEM.outfitCategory = "hat"  -- Prevents multiple items of same category

```

---

### pacData

**Purpose**

Sets the PAC data for the outfit

**When Called**

During item definition

**Example Usage**

```lua
ITEM.pacData = {}  -- PAC attachment data

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Hat"                               -- Display name shown to players
ITEM.desc = "A stylish hat"                     -- Description text
ITEM.category = "outfit"                        -- Category for inventory sorting
ITEM.model = "models/Gibs/HGIBS.mdl"            -- 3D model for the item
ITEM.width = 1                                  -- Inventory width (1 slot)
ITEM.height = 1                                 -- Inventory height (1 slot)
ITEM.outfitCategory = "hat"                     -- Outfit category for conflict checking

```

---

