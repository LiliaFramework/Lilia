# Books Item Definition

Literature item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the book item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Medical Journal"

```

---

### desc

**Purpose**

Sets the description of the book item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A medical journal containing important information"

```

---

### category

**Purpose**

Sets the category for the book item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "itemCatLiterature"

```

---

### model

**Purpose**

Sets the 3D model for the book item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"

```

---

### contents

**Purpose**

Sets the HTML content to display when reading the book

**When Called**

During item definition (used in Read function)

**Example Usage**

```lua
ITEM.contents = "<h1>Chapter 1</h1><p>This is the content...</p>"

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
        ITEM.name = "Medical Journal"

        ITEM.desc = "A medical journal containing important information"

        ITEM.category = "itemCatLiterature"

        ITEM.model = "models/props_lab/bindergraylabel01b.mdl"

        ITEM.contents = "<h1>Chapter 1</h1><p>This is the content...</p>"

-- Basic item identification
ITEM.name = "Medical Journal"                                    -- Display name shown to players
ITEM.desc = "A medical journal containing important information" -- Description text
ITEM.category = "itemCatLiterature"                              -- Category for inventory sorting
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"           -- 3D model for the book
ITEM.contents = "<h1>Chapter 1: Basic Medicine</h1><p>This journal contains essential medical knowledge...</p>"  -- HTML content displayed when reading

```

---

