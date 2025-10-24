# Entities Item Definition

Entity placement item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the entity item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Chair"

```

---

### model

**Purpose**

Sets the 3D model for the entity item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_c17/FurnitureChair001a.mdl"

```

---

### desc

**Purpose**

Sets the description of the entity item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A comfortable chair for sitting"

```

---

### category

**Purpose**

Sets the category for the entity item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "entities"

```

---

### entityid

**Purpose**

Sets the entity class name to spawn

**When Called**

During item definition (used in Place function)

**Example Usage**

```lua
ITEM.entityid = "prop_physics"

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Chair"                                          -- Display name shown to players
ITEM.model = "models/props_c17/FurnitureChair001a.mdl"       -- 3D model for the item
ITEM.desc = "A comfortable chair for sitting"                -- Description text
ITEM.category = "entities"                                   -- Category for inventory sorting
ITEM.entityid = "prop_physics"                               -- Entity class to spawn when placed

```

---

