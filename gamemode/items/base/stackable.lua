--[[
    Folder: Definitions
    File:  stackable.md
]]
--[[
    Stackable Item Definition

    Stackable item system for the Lilia framework.
]]
--[[
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
--[[
    Purpose:
        Sets the display name shown to players

    Example Usage:
        ```lua
        -- Set the item name
        ITEM.name = "Wood Planks"
        ```
]]
ITEM.name = "stackableName"
--[[
    Purpose:
        Sets the 3D model used for the item

    Example Usage:
        ```lua
        -- Set the item model
        ITEM.model = "models/props_debris/wood_board04a.mdl"
        ```
]]
ITEM.model = "models/props_junk/cardboard_box001a.mdl"
--[[
    Purpose:
        Sets the inventory width in slots

    Example Usage:
        ```lua
        -- Set inventory width
        ITEM.width = 2
        ```
]]
ITEM.width = 1
--[[
    Purpose:
        Sets the inventory height in slots

    Example Usage:
        ```lua
        -- Set inventory height
        ITEM.height = 1
        ```
]]
ITEM.height = 1
--[[
    Purpose:
        Enables stacking functionality for this item

    Example Usage:
        ```lua
        -- Enable stacking
        ITEM.isStackable = true
        ```
]]
ITEM.isStackable = true
--[[
    Purpose:
        Sets the maximum quantity that can be stacked together

    Example Usage:
        ```lua
        -- Set maximum stack size
        ITEM.maxQuantity = 20
        ```
]]
ITEM.maxQuantity = 10
--[[
    Purpose:
        Allows players to split stacks into smaller amounts

    Example Usage:
        ```lua
        -- Allow splitting stacks
        ITEM.canSplit = true
        ```
]]
ITEM.canSplit = true
function ITEM:getDesc()
    return L("stackableDesc", self:getQuantity())
end

function ITEM:paintOver(item)
    local quantity = item:getQuantity()
    lia.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "LiliaFont.16")
end

function ITEM:onCombine(other)
    if other.uniqueID ~= self.uniqueID then return end
    local combined = self:getQuantity() + other:getQuantity()
    if combined <= self.maxQuantity then
        self:setQuantity(combined)
        other:remove()
    else
        self:setQuantity(self.maxQuantity)
        other:setQuantity(combined - self.maxQuantity)
    end
    return true
end
--[[
Example Item:

```lua
-- Basic item identification
    ITEM.name = "Wood Planks"                    -- Display name shown to players
    ITEM.desc = "Stackable wooden planks for building"  -- Description text
    ITEM.model = "models/props_debris/wood_board04a.mdl"  -- 3D model for the item
    ITEM.width = 2                               -- Inventory width (2 slots)
    ITEM.height = 1                              -- Inventory height (1 slot)
    ITEM.isStackable = true                      -- Enables stacking functionality
    ITEM.maxQuantity = 20                        -- Maximum quantity that can be stacked
    ITEM.canSplit = true                         -- Allows splitting stacks into smaller amounts
```
]]
