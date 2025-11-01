--[[
    Aid Item Definition

    Medical aid item system for the Lilia framework.

    Aid items are consumable medical items that can restore health to players.
    They can be used on the player themselves or on other players through targeting.

    PLACEMENT:
    - Place in: ModuleFolder/items/aid/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/aid/ItemHere.lua (for schema-specific items)

    USAGE:
    - Aid items are automatically consumed when used
    - They restore health based on the ITEM.health value
    - Can be used on self or other players
    - Health restoration is instant and cannot be interrupted
    - Items are removed from inventory after use
]]
--[[
    Purpose:
        Sets the display name of the aid item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Medical Kit"
        ```
]]
ITEM.name = "aidName"
--[[
    Purpose:
        Sets the description of the aid item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.desc = "A medical kit that restores health"
        ```
]]
ITEM.desc = "aidDesc"
--[[
    Purpose:
        Sets the 3D model for the aid item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/weapons/w_package.mdl"
        ```
]]
ITEM.model = "models/weapons/w_package.mdl"
--[[
    Purpose:
        Sets the inventory width of the aid item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.width = 1  -- Takes 1 slot width
        ```
]]
ITEM.width = 1
--[[
    Purpose:
        Sets the inventory height of the aid item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.height = 1  -- Takes 1 slot height
        ```
]]
ITEM.height = 1
--[[
    Purpose:
        Sets the amount of health restored by the aid item

    When Called:
        During item definition (used in use functions)

    Example Usage:
        ```lua
        ITEM.health = 25  -- Restores 25 health points
        ```
]]
ITEM.health = 0
--[[
Example Item:

```lua
-- Basic item identification
    ITEM.name = "Medical Kit"                    -- Display name shown to players
    ITEM.desc = "A medical kit that restores 25 health points"  -- Description text
    ITEM.model = "models/items/medkit.mdl"       -- 3D model for the item
    ITEM.width = 1                               -- Inventory width (1 slot)
    ITEM.height = 1                              -- Inventory height (1 slot)
    ITEM.health = 25                             -- Health amount restored when used
```
]]
