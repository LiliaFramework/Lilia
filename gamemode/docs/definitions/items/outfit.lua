--[[
    Outfit Item Definition
    Outfit item system for the Lilia framework.
    Outfit items are wearable items that can change player appearance, models, skins, bodygroups,
    and provide attribute boosts. They support PAC integration and visual indicators.
    PLACEMENT:
    - Place in: ModuleFolder/items/outfit/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/outfit/ItemHere.lua (for schema-specific items)
    USAGE:
    - Outfit items are equipped by using them
    - They change the player's model and appearance
    - Items remain in inventory when equipped
    - Can be unequipped to restore original appearance
    - Outfit categories prevent conflicts between items
]]
--
--[[
    ITEM.name
    Purpose: Sets the display name of the outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.name = "Police Uniform"
    ```
]]
--
ITEM.name = "outfit"
--[[
    ITEM.desc
    Purpose: Sets the description of the outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.desc = "A standard police uniform"
    ```
]]
--
ITEM.desc = "outfitDesc"
--[[
    ITEM.category
    Purpose: Sets the category for the outfit item
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
    Purpose: Sets the 3D model for the outfit item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.model = "models/props_c17/BriefCase001a.mdl"
    ```
]]
--
ITEM.model = "models/props_c17/BriefCase001a.mdl"
--[[
    ITEM.width
    Purpose: Sets the inventory width of the outfit item
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
    Purpose: Sets the inventory height of the outfit item
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
    ITEM.outfitCategory = "model"  -- Prevents multiple items of same category
    ```
]]
--
ITEM.outfitCategory = "model"
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
    ITEM.isOutfit
    Purpose: Marks the item as an outfit
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.isOutfit = true
    ```
]]
--
ITEM.isOutfit = true
--[[
Example Item:
    ```lua
    -- Basic item identification
    ITEM.name = "Police Uniform"                        -- Display name shown to players
    ITEM.desc = "A standard police uniform"             -- Description text
    ITEM.category = "outfit"                            -- Category for inventory sorting
    ITEM.model = "models/props_c17/BriefCase001a.mdl"   -- 3D model for the item
    ITEM.width = 1                                      -- Inventory width (1 slot)
    ITEM.height = 1                                     -- Inventory height (1 slot)
    ITEM.outfitCategory = "model"                       -- Outfit category for conflict checking
    ```
]]
--
