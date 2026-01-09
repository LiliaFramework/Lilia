--[[
    Folder: Definitions
    File:  pacoutfit.md
]]
--[[
    PAC Outfit Item Definition

    PAC outfit item system for the Lilia framework.
]]
--[[
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
if not pac then return end
--[[
    Purpose:
        Sets the display name shown to players

    Example Usage:
        ```lua
        -- Set the outfit name
        ITEM.name = "Cool Sunglasses"
        ```
]]
ITEM.name = "pacoutfitName"
--[[
    Purpose:
        Sets the description text shown to players

    Example Usage:
        ```lua
        -- Set the outfit description
        ITEM.desc = "Stylish sunglasses that look great"
        ```
]]
ITEM.desc = "pacoutfitDesc"
--[[
    Purpose:
        Sets the category for inventory sorting

    Example Usage:
        ```lua
        -- Set inventory category
        ITEM.category = "outfit"
        ```
]]
ITEM.category = "outfit"
--[[
    Purpose:
        Sets the 3D model used for the item

    Example Usage:
        ```lua
        -- Set the item model
        ITEM.model = "models/Gibs/HGIBS.mdl"
        ```
]]
ITEM.model = "models/Gibs/HGIBS.mdl"
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
        Sets the category to prevent conflicting PAC outfits

    Example Usage:
        ```lua
        -- Set outfit category to prevent conflicts
        ITEM.outfitCategory = "hat"
        ```
]]
ITEM.outfitCategory = "hat"
--[[
    Purpose:
        Defines PAC3 outfit data for visual effects

    Example Usage:
        ```lua
        -- Define PAC3 outfit parts
        ITEM.pacData = {
            [1] = {
                ["children"] = {},
                ["self"] = {
                    Skin = 0,
                    UniqueID = "sunglasses_example",
                    Size = 1,
                    Bone = "head",
                    Model = "models/captainbigbutt/skeyler/accessories/glasses01.mdl",
                    ClassName = "model"
                }
            }
        }
        ```
]]
ITEM.pacData = {}
if CLIENT then
    function ITEM:paintOver(item, w, h)
        if item:getData("equip") then
            surface.SetDrawColor(110, 255, 110, 100)
            surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end
end

function ITEM:removePart(client)
    local char = client:getChar()
    self:setData("equip", false)
    if client.removePart then client:removePart(self.uniqueID) end
    if self.attribBoosts then
        for k, _ in pairs(self.attribBoosts) do
            char:removeBoost(self.uniqueID, k)
        end
    end
end

ITEM.functions.Unequip = {
    name = "unequip",
    tip = "equipTip",
    icon = "icon16/cross.png",
    onRun = function(item)
        local client = item.player
        item:removePart(client)
        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) and item:getData("equip", false) end
}

ITEM.functions.Equip = {
    name = "equip",
    tip = "equipTip",
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        local char = client:getChar()
        local items = char:getInv():getItems()
        for _, v in pairs(items) do
            if v.id ~= item.id and v.pacData and v.outfitCategory == item.outfitCategory and v:getData("equip") then
                client:notifyErrorLocalized("outfitTypeEquipAlready")
                return false
            end
        end

        item:setData("equip", true)
        if client.addPart then client:addPart(item.uniqueID) end
        if istable(item.attribBoosts) then
            for attribute, boost in pairs(item.attribBoosts) do
                char:addBoost(item.uniqueID, attribute, boost)
            end
        end
        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) and item:getData("equip") ~= true end
}

function ITEM:onCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
    return true
end

function ITEM:onLoadout()
    if self:getData("equip") and self.player.addPart then self.player:addPart(self.uniqueID) end
end

function ITEM:onRemoved()
    local inv = lia.item.inventories[self.invID]
    local receiver = inv.getReceiver and inv:getReceiver()
    if IsValid(receiver) and receiver:IsPlayer() and self:getData("equip") then self:removePart(receiver) end
end

ITEM:hook("drop", function(item)
    local client = item.player
    if item:getData("equip") then item:removePart(client) end
end)
