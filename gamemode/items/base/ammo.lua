--[[
    Folder: Definitions
    File:  ammo.md
]]
--[[
    Ammo Item Definition

    Ammunition item system for the Lilia framework.
]]
--[[
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
--[[
    Purpose:
        Sets the display name shown to players

    Example Usage:
        ```lua
        -- Set the ammo name
        ITEM.name = "Pistol Ammo"
        ```
]]
ITEM.name = "ammoName"
--[[
    Purpose:
        Sets the 3D model used for the item

    Example Usage:
        ```lua
        -- Set the ammo model
        ITEM.model = "models/items/boxsrounds.mdl"
        ```
]]
ITEM.model = "models/props_c17/SuitCase001a.mdl"
--[[
    Purpose:
        Sets the inventory width in slots

    Example Usage:
        ```lua
        -- Set inventory width
        ITEM.width = 1
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
        Sets the ammunition type that matches weapon ammo type

    Example Usage:
        ```lua
        -- Set ammo type
        ITEM.ammo = "pistol"
        ```
]]
ITEM.ammo = "pistol"
--[[
    Purpose:
        Sets the category for inventory sorting

    Example Usage:
        ```lua
        -- Set inventory category
        ITEM.category = "itemCatAmmunition"
        ```
]]
ITEM.category = "itemCatAmmunition"
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
