# Outfit Item Definition

Outfit item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Police Uniform"

```

---

### desc

**Purpose**

Sets the description of the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A standard police uniform"

```

---

### category

**Purpose**

Sets the category for the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "outfit"

```

---

### model

**Purpose**

Sets the 3D model for the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_c17/BriefCase001a.mdl"

```

---

### width

**Purpose**

Sets the inventory width of the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the outfit item

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
ITEM.outfitCategory = "model"  -- Prevents multiple items of same category

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

### isOutfit

**Purpose**

Marks the item as an outfit

**When Called**

During item definition

**Example Usage**

```lua
ITEM.isOutfit = true

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Police Uniform"                        -- Display name shown to players
ITEM.desc = "A standard police uniform"             -- Description text
ITEM.category = "outfit"                            -- Category for inventory sorting
ITEM.model = "models/props_c17/BriefCase001a.mdl"   -- 3D model for the item
ITEM.width = 1                                      -- Inventory width (1 slot)
ITEM.height = 1                                     -- Inventory height (1 slot)
ITEM.outfitCategory = "model"                       -- Outfit category for conflict checking

```

---

