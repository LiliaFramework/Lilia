if not pac then return end
ITEM.name = "pacoutfitName"
ITEM.desc = "pacoutfitDesc"
ITEM.category = "outfit"
ITEM.model = "models/Gibs/HGIBS.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
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
                client:notifyLocalized("outfitTypeEquipAlready")
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