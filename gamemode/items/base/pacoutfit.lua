--[[
    Folder: Items/Base
    File:  pacoutfit.lua
]]
--[[
    PAC Outfit Item Base

    Base PAC outfit item implementation for the Lilia framework.

    PAC outfit items are wearable items that use PAC (Player Accessory Creator) for visual effects.
    They require the PAC addon and provide visual indicators when equipped.
]]
--[[
    Overview:
        PAC outfit items provide advanced character customization through PAC3 integration. They enable complex visual modifications
        that persist across sessions and work seamlessly with Lilia's outfit system. The base implementation includes equip/unequip
        mechanics, conflict prevention, and proper integration with PAC3's part management system.

        The base PAC outfit item supports:
        - PAC3 part attachment and removal
        - Visual equip indicators in inventory
        - Outfit category conflict prevention
        - Attribute bonuses through PAC data
        - Automatic unequipping on item removal/drop
        - Persistence across player sessions
]]

if not pac then return end
-- Basic item identification
--[[
    Purpose:
        Sets the display name of the PAC outfit item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Hat"
        ```
]]
ITEM.name = "pacoutfitName"
--[[
    Purpose:
        Sets the description of the PAC outfit item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.desc = "A stylish hat"
        ```
]]
ITEM.desc = "pacoutfitDesc"
--[[
    Purpose:
        Sets the category for the PAC outfit item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.category = "outfit"
        ```
]]
ITEM.category = "outfit"
--[[
    Purpose:
        Sets the 3D model for the PAC outfit item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/Gibs/HGIBS.mdl"
        ```
]]
ITEM.model = "models/Gibs/HGIBS.mdl"
--[[
    Purpose:
        Sets the inventory width of the PAC outfit item

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
        Sets the inventory height of the PAC outfit item

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
        Sets the outfit category for conflict checking

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.outfitCategory = "hat"  -- Prevents multiple items of same category
        ```
]]
ITEM.outfitCategory = "hat"
--[[
    Purpose:
        Sets the PAC data for the outfit

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.pacData = {}  -- PAC attachment data
        ```
]]
ITEM.pacData = {}
if CLIENT then
    --[[
        Purpose:
            Custom paint function to show equipped status

        When Called:
            When rendering the item in inventory (CLIENT only)

        Example Usage:
            ```lua
            function ITEM:paintOver(item, w, h)
                if item:getData("equip") then
                    surface.SetDrawColor(110, 255, 110, 100)
                    surface.DrawRect(w - 14, h - 14, 8, 8)
                end
            end
            ```
    ]]
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
