--[[
    URL Item Definition

    URL item system for the Lilia framework.

    URL items open web URLs when used by players.
    They are simple items with a single use function.

    PLACEMENT:
    - Place in: ModuleFolder/items/url/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/url/ItemHere.lua (for schema-specific items)

    USAGE:
    - URL items are used by clicking them
    - They open the URL specified in ITEM.url
    - URLs open in the player's default browser
    - Items are not consumed when used
    - Can be used multiple times
]]
--
--[[
    ITEM.name
    Purpose: Sets the display name of the URL item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.name = "Website Link"
        ```
]]
--
ITEM.name = "urlName"
--[[
    ITEM.desc
    Purpose: Sets the description of the URL item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.desc = "A link to an external website"
        ```
]]
--
ITEM.desc = "urlDesc"
--[[
    ITEM.model
    Purpose: Sets the 3D model for the URL item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.model = "models/props_interiors/pot01a.mdl"
        ```
]]
--
ITEM.model = "models/props_interiors/pot01a.mdl"
--[[
    ITEM.url
    Purpose: Sets the URL to open when the item is used
    When Called: During item definition (used in use function)
    Example Usage:
        ```lua
        ITEM.url = "https://example.com"
        ```
]]
--
ITEM.url = ""
--[[
Example Item:

```lua
-- Basic item identification
ITEM.name = "Website Link"                        -- Display name shown to players
ITEM.desc = "A link to an external website"       -- Description text
ITEM.model = "models/props_interiors/pot01a.mdl"  -- 3D model for the item
ITEM.url = "https://example.com"                  -- URL to open when used
```
]]
--
