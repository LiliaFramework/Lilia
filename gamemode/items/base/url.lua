--[[
    Folder: Items/Base
    File:  url.lua
]]
--[[
    URL Item Base

    Base URL item implementation for the Lilia framework.

    URL items open web URLs when used by players.
    They are simple items with a single use function.
]]
--[[
    Overview:
        URL items provide a simple way to create clickable links that open web pages for players. They enable integration with external
        websites, documentation, or web-based content within the game's inventory system. The base implementation includes URL validation,
        browser opening functionality, and proper client-server communication.

        The base URL item supports:
        - Opening URLs in the player's default web browser
        - Non-consumable usage (can be used multiple times)
        - Client-side URL opening for security
        - Integration with Lilia's item function system
]]
-- Basic item identification
--[[
    Purpose:
        Sets the display name of the URL item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Website Link"
        ```
]]
ITEM.name = "urlName"
--[[
    Purpose:
        Sets the description of the URL item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.desc = "A link to an external website"
        ```
]]
ITEM.desc = "urlDesc"
--[[
    Purpose:
        Sets the 3D model for the URL item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/props_interiors/pot01a.mdl"
        ```
]]
ITEM.model = "models/props_interiors/pot01a.mdl"
--[[
    Purpose:
        Sets the URL to open when the item is used

    When Called:
        During item definition (used in use function)

    Example Usage:
        ```lua
        ITEM.url = "https://example.com"
        ```
]]
ITEM.url = ""
ITEM.functions.use = {
    name = "open",
    icon = "icon16/book_link.png",
    onRun = function(item)
        if CLIENT then gui.OpenURL(item.url) end
        return false
    end,
}