local WeightInv = lia.Inventory:extend("WeightInv")
local function getItemWeight(item)
    return item.weight or (item:getWidth() * item:getHeight())
end

local function CanAccessInventoryIfCharacterIsOwner(inventory, action, context)
    local ownerID = inventory:getData("char")
    local client = context.client
    if table.HasValue(client.liaCharList, ownerID) then return true end
end

local function CanAddItemIfNotWeightRestricted(inventory, action, context)
    if action ~= "add" then return end
    if context.forced then return true end
    local weight = inventory:getWeight()
    local maxWeight = inventory:getMaxWeight()
    if weight + getItemWeight(context.item) > maxWeight then return false, "noFit" end
    return true
end

function WeightInv:configure()
    if SERVER then
        self:addAccessRule(CanAddItemIfNotWeightRestricted)
        self:addAccessRule(CanAccessInventoryIfCharacterIsOwner)
    end
end

function WeightInv:canAdd(item)
    if isstring(item) then item = lia.item.list[item] end
    assert(istable(item), L("itemMustBeTable"))
    return self:getWeight() + getItemWeight(item) <= self:getMaxWeight()
end

function WeightInv:doesFitInventory(item)
    if isstring(item) then item = lia.item.list[item] end
    return self:getWeight() + getItemWeight(item) <= self:getMaxWeight()
end

function WeightInv:getItems(noRecurse)
    return self.items
end

if SERVER then
    function WeightInv:wipeItems()
        for _, item in pairs(self:getItems()) do
            item:remove()
        end
    end

    function WeightInv:setOwner(owner, fullUpdate)
        if IsValid(owner) and owner:IsPlayer() and owner:getChar() then
            owner = owner:getChar():getID()
        elseif not isnumber(owner) then
            return
        end

        if fullUpdate then
            for _, client in player.Iterator() do
                if client:getChar():getID() == owner then
                    self:sync(client)
                    break
                end
            end
        end

        self:setData("char", owner)
        self.owner = owner
    end

    function WeightInv:add(itemTypeOrItem, quantity, forced)
        quantity = quantity or 1
        assert(isnumber(quantity), "quantity must be a number")
        local d = deferred.new()
        if quantity <= 0 then return d:reject("quantity must be positive") end
        local item, justAddDirectly
        if lia.item.isItem(itemTypeOrItem) then
            item = itemTypeOrItem
            quantity = 1
            justAddDirectly = true
        else
            item = lia.item.list[itemTypeOrItem]
        end

        if not item then
            return d:resolve({
                error = "invalid item type"
            })
        end

        local context = {
            item = item,
            forced = forced,
            quantity = quantity
        }

        local canAccess, reason = self:canAccess("add", context)
        if not canAccess then return d:reject(reason or "noAccess") end
        if justAddDirectly then
            self:addItem(item)
            return d:resolve(item)
        end

        local items = {}
        local itemType = item.uniqueID
        for i = 1, quantity do
            lia.item.instance(self:getID(), itemType, nil, 0, 0, function(instItem)
                self:addItem(instItem)
                items[#items + 1] = instItem
                if #items == quantity then d:resolve(quantity == 1 and items[1] or items) end
            end)
        end
        return d
    end

    function WeightInv:remove(itemTypeOrID, quantity)
        quantity = quantity or 1
        assert(isnumber(quantity), "quantity must be a number")
        local d = deferred.new()
        if quantity <= 0 then return d:reject("quantity must be positive") end
        if isnumber(itemTypeOrID) then
            self:removeItem(itemTypeOrID)
        else
            local items = self:getItemsOfType(itemTypeOrID)
            for i = 1, math.min(quantity, #items) do
                self:removeItem(items[i]:getID())
            end
        end

        d:resolve()
        return d
    end
end

function WeightInv:getItemsOfType(itemType)
    local items = {}
    for _, item in pairs(self.items) do
        if item.uniqueID == itemType then items[#items + 1] = item end
    end
    return items
end

function WeightInv:getWeight()
    local weight = 0
    for _, item in pairs(self.items) do
        weight = weight + math.max(getItemWeight(item), 0)
    end
    return weight
end

function WeightInv:getMaxWeight()
    local maxWeight = self:getData("maxWeight", lia.config.get("invMaxWeight", 10))
    for _, item in pairs(self.items) do
        if item.weight and item.weight < 0 then maxWeight = maxWeight - item.weight end
    end
    return hook.Run("GetInventoryMaxWeight", self, maxWeight) or maxWeight
end

if CLIENT then
    function WeightInv:requestTransfer(itemID, destinationID)
        net.Start("liaTransferItem")
        net.WriteUInt(itemID, 32)
        net.WriteUInt(0, 32)
        net.WriteUInt(0, 32)
        net.WriteType(destinationID)
        net.SendToServer()
    end
end

WeightInv:register("WeightInv")
