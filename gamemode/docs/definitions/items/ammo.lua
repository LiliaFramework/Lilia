--[[
    Ammo Item Definition
    Ammunition item system for the Lilia framework.
    Ammo items are stackable consumables that provide ammunition for weapons.
    They can be loaded in different quantities and have visual quantity indicators.
    PLACEMENT:
    - Place in: ModuleFolder/items/ammo/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/ammo/ItemHere.lua (for schema-specific items)
    USAGE:
    - Ammo items are consumed when used
    - They give ammunition based on the ITEM.ammo type
    - Ammo type must match weapon's ammo type
    - Can be used to reload equipped weapons
    - Items are removed from inventory after use
]]
--
--[[
    ITEM.name
    Purpose: Sets the display name of the ammo item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.name = "Pistol Ammo"
    ```
]]
--
ITEM.name = "ammoName"
--[[
    ITEM.model
    Purpose: Sets the 3D model for the ammo item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.model = "models/props_c17/SuitCase001a.mdl"
    ```
]]
--
ITEM.model = "models/props_c17/SuitCase001a.mdl"
--[[
    ITEM.width
    Purpose: Sets the inventory width of the ammo item
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
    Purpose: Sets the inventory height of the ammo item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.height = 1  -- Takes 1 slot height
    ```
]]
--
ITEM.height = 1
--[[
    ITEM.ammo
    Purpose: Sets the ammo type for the item
    When Called: During item definition (used in use functions)
    Example Usage:
    ```lua
    ITEM.ammo = "pistol"  -- Pistol ammunition type
    ITEM.ammo = "smg1"    -- SMG ammunition type
    ```
]]
--
ITEM.ammo = "pistol"
--[[
    ITEM.category
    Purpose: Sets the category for the ammo item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.category = "itemCatAmmunition"
    ```
]]
--
ITEM.category = "itemCatAmmunition"
--[[
Example Item:
    ```lua
    -- Basic item identification
    ITEM.name = "Pistol Ammo"                    -- Display name shown to players
    ITEM.model = "models/items/boxsrounds.mdl"   -- 3D model for the ammo box
    ITEM.width = 1                               -- Inventory width (1 slot)
    ITEM.height = 1                              -- Inventory height (1 slot)
    ITEM.ammo = "pistol"                         -- Ammo type (matches weapon ammo type)
    ITEM.category = "itemCatAmmunition"          -- Category for inventory sorting
    ```
]]
--
