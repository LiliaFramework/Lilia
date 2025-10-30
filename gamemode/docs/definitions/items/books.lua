--[[
    Books Item Definition

    Literature item system for the Lilia framework.

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
]]
--[[
    ITEM.name
    Purpose:
        Sets the display name of the book item
    When Called:
        During item definition
    Example Usage:
        ```lua
        ITEM.name = "Medical Journal"
        ```
]]
ITEM.name = "booksName"
--[[
    ITEM.desc
    Purpose:
        Sets the description of the book item
    When Called:
        During item definition
    Example Usage:
        ```lua
        ITEM.desc = "A medical journal containing important information"
        ```
]]
ITEM.desc = "booksDesc"
--[[
    ITEM.category
    Purpose:
        Sets the category for the book item
    When Called:
        During item definition
    Example Usage:
        ```lua
        ITEM.category = "itemCatLiterature"
        ```
]]
ITEM.category = "itemCatLiterature"
--[[
    ITEM.model
    Purpose:
        Sets the 3D model for the book item
    When Called:
        During item definition
    Example Usage:
        ```lua
        ITEM.model = "models/props_lab/bindergraylabel01b.mdl"
        ```
]]
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"
--[[
    ITEM.contents
    Purpose:
        Sets the HTML content to display when reading the book
    When Called:
        During item definition (used in Read function)
    Example Usage:
        ```lua
        ITEM.contents = "<h1>Chapter 1</h1><p>This is the content...</p>"
        ```
]]
ITEM.contents = ""
--[[
Example Item:

```lua
-- Basic item identification
ITEM.name = "Medical Journal"                                    -- Display name shown to players
ITEM.desc = "A medical journal containing important information" -- Description text
ITEM.category = "itemCatLiterature"                              -- Category for inventory sorting
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"           -- 3D model for the book
ITEM.contents = "<h1>Chapter 1: Basic Medicine</h1><p>This journal contains essential medical knowledge...</p>"  -- HTML content displayed when reading
```
]]
