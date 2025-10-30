# Books Item Definition

Literature item system for the Lilia framework.

---

### name

**Example Usage**

```lua
ITEM.name = "Medical Journal"

```

---

### desc

**Example Usage**

```lua
ITEM.desc = "A medical journal containing important information"

```

---

### category

**Example Usage**

```lua
ITEM.category = "itemCatLiterature"

```

---

### model

**Example Usage**

```lua
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"

```

---

### contents

**Example Usage**

```lua
ITEM.contents = "<h1>Chapter 1</h1><p>This is the content...</p>"

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Medical Journal"                                    -- Display name shown to players
ITEM.desc = "A medical journal containing important information" -- Description text
ITEM.category = "itemCatLiterature"                              -- Category for inventory sorting
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"           -- 3D model for the book
ITEM.contents = "<h1>Chapter 1: Basic Medicine</h1><p>This journal contains essential medical knowledge...</p>"  -- HTML content displayed when reading

```

---

