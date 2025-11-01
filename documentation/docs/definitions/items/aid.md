# Aid Item Definition

Medical aid item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the aid item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Medical Kit"

```

---

### desc

**Purpose**

Sets the description of the aid item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A medical kit that restores health"

```

---

### model

**Purpose**

Sets the 3D model for the aid item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/weapons/w_package.mdl"

```

---

### width

**Purpose**

Sets the inventory width of the aid item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the aid item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### health

**Purpose**

Sets the amount of health restored by the aid item

**When Called**

During item definition (used in use functions)

**Example Usage**

```lua
ITEM.health = 25  -- Restores 25 health points

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
        ITEM.name = "Medical Kit"

        ITEM.desc = "A medical kit that restores health"

        ITEM.model = "models/weapons/w_package.mdl"

        ITEM.width = 1  -- Takes 1 slot width

        ITEM.height = 1  -- Takes 1 slot height

        ITEM.health = 25  -- Restores 25 health points

-- Basic item identification
ITEM.name = "Medical Kit"                    -- Display name shown to players
ITEM.desc = "A medical kit that restores 25 health points"  -- Description text
ITEM.model = "models/items/medkit.mdl"       -- 3D model for the item
ITEM.width = 1                               -- Inventory width (1 slot)
ITEM.height = 1                              -- Inventory height (1 slot)
ITEM.health = 25                             -- Health amount restored when used

```

---

