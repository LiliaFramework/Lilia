# Stackable Item Definition

Stackable item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Ammo Box"

```

---

### model

**Purpose**

Sets the 3D model for the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_junk/cardboard_box001a.mdl"

```

---

### width

**Purpose**

Sets the inventory width of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### isStackable

**Purpose**

Marks the item as stackable

**When Called**

During item definition

**Example Usage**

```lua
ITEM.isStackable = true

```

---

### maxQuantity

**Purpose**

Sets the maximum quantity for the stackable item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.maxQuantity = 10  -- Maximum 10 items per stack

```

---

### canSplit

**Purpose**

Sets whether the item can be split

**When Called**

During item definition

**Example Usage**

```lua
ITEM.canSplit = true  -- Allows splitting the stack

```

---

