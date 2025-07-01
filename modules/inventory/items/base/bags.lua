ITEM.name = "Bag"
ITEM.desc = "A bag to hold more items."
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.category = "Storage"
ITEM.isBag = true
ITEM.invWidth = 2
ITEM.invHeight = 2
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
ITEM.pacData = {}
if CLIENT then
    function ITEM:paintOver(item, w, h)
        if item:getData("equip", false) then
            surface.SetDrawColor(110, 255, 110, 100)
            surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end
end

ITEM.functions.Equip = {
    name = L("equip"),
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        local items = client:getChar():getInv():getItems()
        for _, v in pairs(items) do
            if v.id ~= item.id and v.isBag and v:getData("equip") then
                client:notifyLocalized("bagAlreadyEquipped")
                return false
            end
        end

        if item.pacData and client.addPart then client:addPart(item.uniqueID) end
        item:setData("equip", true)
        return false
    end,
    onCanRun = function(item) if not IsValid(item.entity) then return not item:getData("equip", false) end end
}

ITEM.functions.Unequip = {
    name = L("unequip"),
    icon = "icon16/cross.png",
    onRun = function(item)
        local client = item.player
        if item.pacData and client.removePart then client:removePart(item.uniqueID) end
        item:setData("equip", false)
        return false
    end,
    onCanRun = function(item) if not IsValid(item.entity) then return item:getData("equip", false) end end
}

ITEM.functions.View = {
    name = L("view"),
    icon = "icon16/briefcase.png",
    onClick = function(item)
        local inventory = item:getInv()
        if not inventory then return false end
        local panel = lia.gui["inv" .. inventory:getID()]
        local parent = item.invID and lia.gui["inv" .. item.invID] or nil
        if IsValid(panel) then panel:Remove() end
        if inventory then
            local invPanel = lia.inventory.show(inventory, parent)
            if IsValid(invPanel) then
                invPanel:ShowCloseButton(true)
                invPanel:SetTitle(item:getName())
            end
        end
        return false
    end,
    onCanRun = function(item) if not IsValid(item.entity) and item:getInv() then return item:getData("equip", false) end end
}

function ITEM:onInstanced()
    local data = {
        item = self:getID(),
        w = self.invWidth,
        h = self.invHeight
    }

    lia.inventory.instance("GridInv", data):next(function(inventory)
        self:setData("id", inventory:getID())
        hook.Run("SetupBagInventoryAccessRules", inventory)
        inventory:sync()
        self:resolveInvAwaiters(inventory)
    end)
end

function ITEM:onRestored()
    local invID = self:getData("id")
    if invID then
        lia.inventory.loadByID(invID):next(function(inventory)
            hook.Run("SetupBagInventoryAccessRules", inventory)
            self:resolveInvAwaiters(inventory)
        end)
    end
end

function ITEM:onRemoved()
    local invID = self:getData("id")
    if invID then lia.inventory.deleteByID(invID) end
end

function ITEM:getInv()
    return lia.inventory.instances[self:getData("id")]
end

function ITEM:onSync(recipient)
    local inventory = self:getInv()
    if inventory then inventory:sync(recipient) end
end

function ITEM.postHooks:drop()
    local invID = self:getData("id")
    if invID then
        net.Start("liaInventoryDelete")
        net.WriteType(invID)
        net.Send(self.player)
    end
end

function ITEM:onCombine(other)
    local client = self.player
    local invID = self:getInv() and self:getInv():getID() or nil
    if not invID then return end
    local res = hook.Run("HandleItemTransferRequest", client, other:getID(), nil, nil, invID)
    if not res then return end
    res:next(function(result)
        if not IsValid(client) then return end
        if istable(result) and isstring(result.error) then return client:notifyLocalized(result.error) end
        client:EmitSound(unpack(self.BagSound))
    end)
end

if SERVER then
    function ITEM:onDisposed()
        local inventory = self:getInv()
        if inventory then inventory:destroy() end
    end

    function ITEM:resolveInvAwaiters(inventory)
        if self.awaitingInv then
            for _, d in ipairs(self.awaitingInv) do
                d:resolve(inventory)
            end

            self.awaitingInv = nil
        end
    end

    function ITEM:awaitInv()
        local d = deferred.new()
        local inventory = self:getInv()
        if inventory then
            d:resolve(inventory)
        else
            self.awaitingInv = self.awaitingInv or {}
            self.awaitingInv[#self.awaitingInv + 1] = d
        end
        return d
    end
end
