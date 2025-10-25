--[[
    PAC Outfit Item Definition
    PAC outfit item system for the Lilia framework.
    PAC outfit items are wearable items that use PAC (Player Accessory Creator) for visual effects.
    They require the PAC addon and provide visual indicators when equipped.
    PLACEMENT:
    - Place in: ModuleFolder/items/pacoutfit/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/pacoutfit/ItemHere.lua (for schema-specific items)
    USAGE:
    - PAC outfit items are equipped by using them
    - They add PAC3 parts to the player
    - Items remain in inventory when equipped
    - Can be unequipped to remove PAC3 parts
    - Requires PAC3 addon to function properly
]]
--
--[[
    ITEM.name
    Purpose: Sets the display name of the PAC outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.name = "Hat"
    ```
]]
--
ITEM.name = "pacoutfitName"
--[[
    ITEM.desc
    Purpose: Sets the description of the PAC outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.desc = "A stylish hat"
    ```
]]
--
ITEM.desc = "pacoutfitDesc"
--[[
    ITEM.category
    Purpose: Sets the category for the PAC outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.category = "outfit"
    ```
]]
--
ITEM.category = "outfit"
--[[
    ITEM.model
    Purpose: Sets the 3D model for the PAC outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.model = "models/Gibs/HGIBS.mdl"
    ```
]]
--
ITEM.model = "models/Gibs/HGIBS.mdl"
--[[
    ITEM.width
    Purpose: Sets the inventory width of the PAC outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.width = 1  -- Takes 1 slot width
    ```
]]
--
ITEM.width = 1
--[[
    ITEM.height
    Purpose: Sets the inventory height of the PAC outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.height = 1  -- Takes 1 slot height
    ```
]]
--
ITEM.height = 1
--[[
    ITEM.outfitCategory
    Purpose: Sets the outfit category for conflict checking
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.outfitCategory = "hat"  -- Prevents multiple items of same category
    ```
]]
--
ITEM.outfitCategory = "hat"
--[[
    ITEM.pacData
    Purpose: Sets the PAC data for the outfit
    When Called: During item definition
    Example Usage:
    ```lua
        ITEM.pacData = {}  -- PAC attachment data
    ```
]]
--
ITEM.pacData = {}
--[[
Example Item:
    ```lua
    -- Basic item identification
    ITEM.name = "Hat"                               -- Display name shown to players
    ITEM.desc = "A stylish hat"                     -- Description text
    ITEM.category = "outfit"                        -- Category for inventory sorting
    ITEM.model = "models/Gibs/HGIBS.mdl"            -- 3D model for the item
    ITEM.width = 1                                  -- Inventory width (1 slot)
    ITEM.height = 1                                 -- Inventory height (1 slot)
    ITEM.outfitCategory = "hat"                     -- Outfit category for conflict checking
    ```
]]
--
