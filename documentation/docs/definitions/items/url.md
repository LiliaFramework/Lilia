# URL Item Definition

URL item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the URL item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Website Link"

```

---

### desc

**Purpose**

Sets the description of the URL item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A link to an external website"

```

---

### model

**Purpose**

Sets the 3D model for the URL item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_interiors/pot01a.mdl"

```

---

### url

**Purpose**

Sets the URL to open when the item is used

**When Called**

During item definition (used in use function)

**Example Usage**

```lua
ITEM.url = "https://example.com"

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
        ITEM.name = "Website Link"

        ITEM.desc = "A link to an external website"

        ITEM.model = "models/props_interiors/pot01a.mdl"

        ITEM.url = "https://example.com"

-- Basic item identification
    ITEM.name = "Website Link"                        -- Display name shown to players
    ITEM.desc = "A link to an external website"       -- Description text
    ITEM.model = "models/props_interiors/pot01a.mdl"  -- 3D model for the item
    ITEM.url = "https://example.com"                  -- URL to open when used

```

---

