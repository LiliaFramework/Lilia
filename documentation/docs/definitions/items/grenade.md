# Grenade Item Definition

Grenade item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Fragmentation Grenade"

```

---

### desc

**Purpose**

Sets the description of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A deadly fragmentation grenade"

```

---

### category

**Purpose**

Sets the category for the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "itemCatGrenades"

```

---

### model

**Purpose**

Sets the 3D model for the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"

```

---

### class

**Purpose**

Sets the weapon class name for the grenade

**When Called**

During item definition (used in Use function)

**Example Usage**

```lua
ITEM.class = "weapon_frag"

```

---

### width

**Purpose**

Sets the inventory width of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the grenade item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### DropOnDeath

**Purpose**

Sets whether the grenade drops when player dies

**When Called**

During item definition

**Example Usage**

```lua
ITEM.DropOnDeath = true  -- Drops on death

```

---

