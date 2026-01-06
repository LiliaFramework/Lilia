--[[
    Folder: Items/Base
    File:  books.lua
]]
--[[
    Books Item Base

    Base literature item implementation for the Lilia framework.

    Books are readable items that display content in a formatted HTML window.
    They are categorized as literature and can contain rich text content.
]]
--[[
    Overview:
        Books provide a foundation for all readable literature items in Lilia. They enable rich text content display through HTML formatting
        in popup windows, allowing for styled documents, journals, and other written materials. The base implementation includes
        a dedicated reading interface with proper HTML rendering and user-friendly controls.

        The base book item supports:
        - HTML content rendering in a popup window
        - Styled text with custom CSS
        - Non-consumable reading (can be read multiple times)
        - Proper categorization as literature items
        - Integration with Lilia's item system
]]

-- Basic item identification
--[[
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
    Purpose:
        Sets the health value for the item when it's dropped as an entity in the world

    When Called:
        During item definition (used when item is spawned as entity)

    Notes:
        - Defaults to 100 if not specified
        - When the item entity takes damage, its health decreases
        - Item is destroyed when health reaches 0
        - Only applies if ITEM.CanBeDestroyed is true (controlled by config)

    Example Usage:
        ```lua
        ITEM.health = 250  -- Item can take 250 damage before being destroyed
        ```
]]
ITEM.health = 100
ITEM.functions.Read = {
    name = "read",
    onClick = function(item)
        local frame = vgui.Create("liaFrame")
        frame:SetSize(540, 680)
        frame:SetTitle(item.name)
        frame:MakePopup()
        frame:Center()
        frame.html = frame:Add("DHTML")
        frame.html:Dock(FILL)
        frame.html:SetHTML([[<html><body style="background-color: #ECECEC; color: #282B2D; font-family: 'Book Antiqua', Palatino, 'Palatino Linotype', 'Palatino LT STD', Georgia, serif; font-size 16px; text-align: justify;">]] .. item.contents .. [[</body></html>]])
    end,
    onRun = function() return false end,
    icon = "icon16/book_open.png"
}
