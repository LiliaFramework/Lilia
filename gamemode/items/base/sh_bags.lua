local INVENTORY_TYPE_ID = "grid" -- The ID of the inventory type used for the bag
ITEM.name = "Bag" -- The name of the item
ITEM.desc = "A bag to hold more items." -- The description of the item
ITEM.model = "models/props_c17/suitcase001a.mdl" -- The model of the item
ITEM.category = "Storage" -- The category of the item
ITEM.isBag = true -- Indicates that the item is a bag

-- Sound played when interacting with the bag
local SOUND_BAG_RESPONSE = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}

ITEM.invWidth = 2 -- The width of the bag's inventory grid
ITEM.invHeight = 2 -- The height of the bag's inventory grid

-- The "View" function of the item
ITEM.functions.View = {
    icon = "icon16/briefcase.png", -- The icon used for the function
    onClick = function(item)
        local inventory = item:getInv()
        if not inventory then return false end
        local panel = lia.gui["inv" .. inventory:getID()]
        local parent = item.invID and lia.gui["inv" .. item.invID] or nil

        if IsValid(panel) then
            panel:Remove()
        end

        if inventory then
            local panel = lia.inventory.show(inventory, parent)

            if IsValid(panel) then
                panel:ShowCloseButton(true)
                panel:SetTitle(item:getName())
            end
        else
            local itemID = item:getID()
            local index = item:getData("id", "nil")
            ErrorNoHalt("Invalid inventory " .. index .. " for bag item " .. itemID .. "\n")
        end

        return false
    end, -- The function to execute when the function is clicked
    onCanRun = function(item) return not IsValid(item.entity) and item:getInv() end -- The function to determine if the function can be run
    
}

function ITEM:onInstanced()
    local data = {
        item = self:getID(),
        w = self.invWidth,
        h = self.invHeight
    }

    lia.inventory.instance(INVENTORY_TYPE_ID, data):next(function(inventory)
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

    if invID then
        lia.inventory.deleteByID(invID)
    end
end

function ITEM:getInv()
    return lia.inventory.instances[self:getData("id")]
end

function ITEM:onSync(recipient)
    local inventory = self:getInv()

    if inventory then
        inventory:sync(recipient)
    end
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
    -- If other item was combined onto this item, put it in the bag.
    local res = hook.Run("HandleItemTransferRequest", client, other:getID(), nil, nil, invID)
    if not res then return end

    -- If an attempt was made, either report the error or make a
    -- "success" sound.
    res:next(function(res)
        if not IsValid(client) then return end
        if istable(res) and isstring(res.error) then return client:notifyLocalized(res.error) end
        client:EmitSound(unpack(SOUND_BAG_RESPONSE))
    end)
end

if SERVER then
    function ITEM:onDisposed()
        local inventory = self:getInv()

        if inventory then
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