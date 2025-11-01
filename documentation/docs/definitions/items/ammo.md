# Ammo Item Definition

Ammunition item system for the Lilia framework.

---

### name

**Example Usage**

```lua
ITEM.name = "Pistol Ammo"

```

---

### model

**Example Usage**

```lua
ITEM.model = "models/props_c17/SuitCase001a.mdl"

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

### ammo

**Example Usage**

```lua
ITEM.ammo = "pistol"  -- Pistol ammunition type
ITEM.ammo = "smg1"    -- SMG ammunition type

```

---

### category

**Example Usage**

```lua
ITEM.category = "itemCatAmmunition"

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Pistol Ammo"                    -- Display name shown to players
ITEM.model = "models/items/boxsrounds.mdl"   -- 3D model for the ammo box
ITEM.width = 1                               -- Inventory width (1 slot)
ITEM.height = 1                              -- Inventory height (1 slot)
ITEM.ammo = "pistol"                         -- Ammo type (matches weapon ammo type)
ITEM.category = "itemCatAmmunition"          -- Category for inventory sorting

```

---

