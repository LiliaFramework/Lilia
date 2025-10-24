# Ammo Item Definition

Ammunition item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the ammo item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Pistol Ammo"
```

---

### model

**Purpose**

Sets the 3D model for the ammo item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_c17/SuitCase001a.mdl"
```

---

### width

**Purpose**

Sets the inventory width of the ammo item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width
```

---

### height

**Purpose**

Sets the inventory height of the ammo item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height
```

---

### ammo

**Purpose**

Sets the ammo type for the item

**When Called**

During item definition (used in use functions)

**Example Usage**

```lua
ITEM.ammo = "pistol"  -- Pistol ammunition type
ITEM.ammo = "smg1"    -- SMG ammunition type
```

---

### category

**Purpose**

Sets the category for the ammo item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "itemCatAmmunition"
```

---

