ITEM.name = "bagName"
ITEM.desc = "bagDesc"
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.category = "storage"
ITEM.isBag = true
ITEM.invWidth = 2
ITEM.invHeight = 2
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
ITEM.pacData = {}
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
        hook.Run("BagInventoryReady", self, inventory)
    end)
end

function ITEM:onRestored()
    local invID = self:getData("id")
    if invID then
        lia.inventory.loadByID(invID):next(function(inventory)
            hook.Run("SetupBagInventoryAccessRules", inventory)
            self:resolveInvAwaiters(inventory)
            hook.Run("BagInventoryReady", self, inventory)
        end)
    end
end

function ITEM:onRemoved()
    local invID = self:getData("id")
    if invID then
        local inv = lia.inventory.instances[invID]
        if inv then hook.Run("BagInventoryRemoved", self, inv) end
        lia.inventory.deleteByID(invID)
    end
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
        if inventory then
            hook.Run("BagInventoryRemoved", self, inventory)
            inventory:destroy()
        end
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
