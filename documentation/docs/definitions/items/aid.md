# Aid Item Definition

Medical aid item system for the Lilia framework.

---

### name

**Example Usage**

```lua
ITEM.name = "Medical Kit"

```

---

### desc

**Example Usage**

```lua
ITEM.desc = "A medical kit that restores health"

```

---

### model

**Example Usage**

```lua
ITEM.model = "models/weapons/w_package.mdl"

```

---

### width

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### health

**Example Usage**

```lua
ITEM.health = 25  -- Restores 25 health points

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Medical Kit"                    -- Display name shown to players
ITEM.desc = "A medical kit that restores 25 health points"  -- Description text
ITEM.model = "models/items/medkit.mdl"       -- 3D model for the item
ITEM.width = 1                               -- Inventory width (1 slot)
ITEM.height = 1                              -- Inventory height (1 slot)
ITEM.health = 25                             -- Health amount restored when used

```

---

