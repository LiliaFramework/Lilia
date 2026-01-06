--[[
    Folder: Items/Base
    File:  ammo.lua
]]
--[[
    Ammo Item Base

    Base ammunition item implementation for the Lilia framework.

    Ammo items are stackable consumables that provide ammunition for weapons.
    They can be loaded in different quantities and have visual quantity indicators.
]]
--[[
    Overview:
        Ammo items serve as the foundation for all ammunition types in Lilia. They provide a standardized way to handle weapon ammunition
        with support for different loading amounts, quantity tracking, and visual feedback. The base implementation includes
        multiple loading options and proper inventory integration.

        The base ammo item supports:
        - Multiple loading amounts (load all, load 5, load 10, load 30)
        - Quantity display on the item icon
        - Sound effects when loading ammunition
        - Integration with Lilia's stackable item system
]]

-- Basic item identification
--[[
    Purpose:
        Sets the display name of the ammo item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Pistol Ammo"
        ```
]]
ITEM.name = "ammoName"
--[[
    Purpose:
        Sets the 3D model for the ammo item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/props_c17/SuitCase001a.mdl"
        ```
]]
ITEM.model = "models/props_c17/SuitCase001a.mdl"
--[[
    Purpose:
        Sets the inventory width of the ammo item

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
        Sets the inventory height of the ammo item

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
        Sets the ammo type for the item

    When Called:
        During item definition (used in use functions)

    Example Usage:
        ```lua
        ITEM.ammo = "pistol"  -- Pistol ammunition type
        ITEM.ammo = "smg1"    -- SMG ammunition type
        ```
]]
ITEM.ammo = "pistol"
--[[
    Purpose:
        Sets the category for the ammo item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.category = "itemCatAmmunition"
        ```
]]
ITEM.category = "itemCatAmmunition"
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
ITEM.functions.use = {
    name = "load",
    tip = "useTip",
    icon = "icon16/add.png",
    multiOptions = {
        [L("ammoLoadAll")] = {
            function(item)
                item.player:GiveAmmo(item:getQuantity(), item.ammo)
                item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
                return true
            end,
            function() return true end
        },
        [L("ammoLoadAmount", 5)] = {
            function(item)
                item:addQuantity(-5)
                item.player:GiveAmmo(5, item.ammo)
                item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
                return item:getQuantity() <= 0
            end,
            function(item) return item:getQuantity() >= 5 end
        },
        [L("ammoLoadAmount", 10)] = {
            function(item)
                item:addQuantity(-10)
                item.player:GiveAmmo(10, item.ammo)
                item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
                return item:getQuantity() <= 0
            end,
            function(item) return item:getQuantity() >= 10 end
        },
        [L("ammoLoadAmount", 30)] = {
            function(item)
                item:addQuantity(-30)
                item.player:GiveAmmo(30, item.ammo)
                item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
                return item:getQuantity() <= 0
            end,
            function(item) return item:getQuantity() >= 30 end
        }
    }
}

function ITEM:getDesc()
    return L("ammoDesc", self:getQuantity())
end

function ITEM:paintOver(item)
    local quantity = item:getQuantity()
    lia.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "LiliaFont.16")
end
