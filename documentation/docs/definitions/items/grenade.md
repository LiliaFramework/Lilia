# Grenade Item Definition

Grenade item system for the Lilia framework.

---

### name

**Example Usage**

```lua
ITEM.name = "Fragmentation Grenade"

```

---

### desc

**Example Usage**

```lua
ITEM.desc = "A deadly fragmentation grenade"

```

---

### category

**Example Usage**

```lua
ITEM.category = "itemCatGrenades"

```

---

### model

**Example Usage**

```lua
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"

```

---

### class

**Example Usage**

```lua
ITEM.class = "weapon_frag"

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

### DropOnDeath

**Example Usage**

```lua
ITEM.DropOnDeath = true  -- Drops on death

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Fragmentation Grenade"                    -- Display name shown to players
ITEM.desc = "A deadly fragmentation grenade"           -- Description text
ITEM.category = "itemCatGrenades"                      -- Category for inventory sorting
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"     -- 3D model for the grenade
ITEM.class = "weapon_frag"                             -- Weapon class to give when used
ITEM.width = 1                                         -- Inventory width (1 slot)
ITEM.height = 1                                        -- Inventory height (1 slot)

```

---

