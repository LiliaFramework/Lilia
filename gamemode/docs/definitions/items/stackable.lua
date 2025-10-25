﻿--[[
    Stackable Item Definition
    Stackable item system for the Lilia framework.
    Stackable items can be combined together and have quantity limits.
    They display quantity visually and support splitting functionality.
    PLACEMENT:
    - Place in: ModuleFolder/items/stackable/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/stackable/ItemHere.lua (for schema-specific items)
    USAGE:
    - Stackable items can be combined with other stacks
    - They can be split into smaller quantities
    - Visual indicators show quantity in inventory
    - Items are consumed when used
    - Maximum quantity is controlled by ITEM.maxQuantity
]]
--
--[[
    ITEM.name
    Purpose: Sets the display name of the stackable item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.name = "Ammo Box"
    ```
]]
--
ITEM.name = "stackableName"
--[[
    ITEM.model
    Purpose: Sets the 3D model for the stackable item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.model = "models/props_junk/cardboard_box001a.mdl"
    ```
]]
--
ITEM.model = "models/props_junk/cardboard_box001a.mdl"
--[[
    ITEM.width
    Purpose: Sets the inventory width of the stackable item
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
    Purpose: Sets the inventory height of the stackable item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.height = 1  -- Takes 1 slot height
    ```
]]
--
ITEM.height = 1
--[[
    ITEM.isStackable
    Purpose: Marks the item as stackable
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.isStackable = true
    ```
]]
--
ITEM.isStackable = true
--[[
    ITEM.maxQuantity
    Purpose: Sets the maximum quantity for the stackable item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.maxQuantity = 10  -- Maximum 10 items per stack
    ```
]]
--
ITEM.maxQuantity = 10
--[[
    ITEM.canSplit
    Purpose: Sets whether the item can be split
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.canSplit = true  -- Allows splitting the stack
    ```
]]
--
ITEM.canSplit = true
--
--[[
Example Item:

    ```lua
    -- Basic item identification
    ITEM.name = "Ammo Box"                                    -- Display name shown to players
    ITEM.model = "models/props_junk/cardboard_box001a.mdl"   -- 3D model for the item
    ITEM.width = 1                                            -- Inventory width (1 slot)
    ITEM.height = 1                                           -- Inventory height (1 slot)
    ITEM.isStackable = true                                   -- Enables stacking functionality
    ITEM.maxQuantity = 10                                     -- Maximum items per stack
    ```
]]
--