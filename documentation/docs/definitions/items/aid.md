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

