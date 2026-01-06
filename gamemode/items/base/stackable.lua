--[[
    Folder: Items/Base
    File:  stackable.lua
]]
--[[
    Stackable Item Base

    Base stackable item implementation for the Lilia framework.

    Stackable items can be combined together and have quantity limits.
    They display quantity visually and support splitting functionality.
]]
--[[
    Overview:
        Stackable items provide the foundation for all combinable items in Lilia. They enable efficient inventory management through
        quantity stacking, with support for combining stacks, splitting quantities, and visual quantity indicators. The base implementation
        includes automatic quantity management, combination logic, and proper inventory integration.

        The base stackable item supports:
        - Quantity display on item icons
        - Automatic stack combination when items are added
        - Stack splitting functionality
        - Configurable maximum quantities
        - Visual quantity indicators in inventory
        - Integration with Lilia's inventory system
]]

-- Basic item identification
--[[
    Purpose:
        Sets the display name of the stackable item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Ammo Box"
        ```
]]
ITEM.name = "stackableName"
--[[
    Purpose:
        Sets the 3D model for the stackable item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/props_junk/cardboard_box001a.mdl"
        ```
]]
ITEM.model = "models/props_junk/cardboard_box001a.mdl"
--[[
    Purpose:
        Sets the inventory width of the stackable item

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
        Sets the inventory height of the stackable item

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
        Marks the item as stackable

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.isStackable = true
        ```
]]
ITEM.isStackable = true
--[[
    Purpose:
        Sets the maximum quantity for the stackable item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.maxQuantity = 10  -- Maximum 10 items per stack
        ```
]]
ITEM.maxQuantity = 10
--[[
    Purpose:
        Sets whether the item can be split

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.canSplit = true  -- Allows splitting the stack
        ```
]]
ITEM.canSplit = true
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
