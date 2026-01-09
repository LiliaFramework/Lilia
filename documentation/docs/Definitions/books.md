# Books Item Definition

Literature item system for the Lilia framework.

---

Overview

Books are readable items that display content in a formatted HTML window.
They are categorized as literature and can contain rich text content.

PLACEMENT:
- Place in: ModuleFolder/items/books/ItemHere.lua (for module-specific items)
- Place in: SchemaFolder/items/books/ItemHere.lua (for schema-specific items)

USAGE:
- Books are read by using the item
- They display HTML content in a popup window
- Content can include HTML tags, CSS styling, and images
- Books are not consumed when read
- Can be used multiple times

---

### name

#### 📋 Purpose
Sets the display name shown to players

#### 💡 Example Usage

```lua
    -- Set the book name
    ITEM.name = "The Art of Programming"

```

---

### desc

#### 📋 Purpose
Sets the description text shown to players

#### 💡 Example Usage

```lua
    -- Set the book description
    ITEM.desc = "A comprehensive guide to programming principles"

```

---

### category

#### 📋 Purpose
Sets the category for inventory sorting

#### 💡 Example Usage

```lua
    -- Set inventory category
    ITEM.category = "itemCatLiterature"

```

---

### model

#### 📋 Purpose
Sets the 3D model used for the item

#### 💡 Example Usage

```lua
    -- Set the book model
    ITEM.model = "models/props_lab/bindergraylabel01b.mdl"

```

---

### contents

#### 📋 Purpose
Sets the HTML content displayed when reading the book

#### 💡 Example Usage

```lua
    -- Set book contents with HTML
    ITEM.contents = "<h1>Chapter 1: Introduction</h1><p>Programming is the art of instructing computers to perform specific tasks...</p>"

```

---

