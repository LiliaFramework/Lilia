---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:SaveData()
    local data = {}
    for _, v in ipairs(ents.FindByClass("lia_vendor")) do
        data[#data + 1] = {
            name = v:getNetVar("name"),
            desc = v:getNetVar("desc"),
            pos = v:GetPos(),
            angles = v:GetAngles(),
            model = v:GetModel(),
            bubble = v:getNetVar("noBubble"),
            items = v.items,
            factions = v.factions,
            classes = v.classes,
            money = v.money,
            scale = v:getNetVar("scale")
        }
    end

    self:setData(data)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:LoadData()
    for _, v in ipairs(self:getData() or {}) do
        local entity = ents.Create("lia_vendor")
        entity:SetPos(v.pos)
        entity:SetAngles(v.angles)
        entity:Spawn()
        entity:SetModel(v.model)
        entity:setNetVar("noBubble", v.bubble)
        entity:setNetVar("name", v.name)
        entity:setNetVar("desc", v.desc)
        entity:setNetVar("scale", v.scale or 0.5)
        entity.items = v.items or {}
        entity.factions = v.factions or {}
        entity.classes = v.classes or {}
        entity.money = v.money
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CanPlayerAccessVendor(client, vendor)
    if client:CanEditVendor() then return true end
    local character = client:getChar()
    if vendor:isClassAllowed(character:getClass()) then return true end
    if vendor:isFactionAllowed(client:Team()) then return true end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
    local item = lia.item.list[itemType]
    local SteamIDWhitelist = item.SteamIDWhitelist
    local FactionWhitelist = item.FactionWhitelist
    local UserGroupWhitelist = item.UsergroupWhitelist
    local VIPOnly = item.VIP
    if not vendor.items[itemType] then return false end
    local state = vendor:getTradeMode(itemType)
    if isSellingToVendor and state == VENDOR_SELLONLY then return false end
    if not isSellingToVendor and state == VENDOR_BUYONLY then return false end
    if isSellingToVendor and not client:getChar():getInv():hasItem(itemType) then
        return false
    elseif not isSellingToVendor then
        local stock = vendor:getStock(itemType)
        if stock and stock <= 0 then return false, "vendorNoStock" end
    end

    local price = vendor:getPrice(itemType, isSellingToVendor)
    local money
    if isSellingToVendor then
        money = vendor:getMoney()
    else
        money = client:getChar():getMoney()
    end

    if money and money < price then return false, isSellingToVendor and "vendorNoMoney" or "canNotAfford" end
    if SteamIDWhitelist and ((istable(SteamIDWhitelist) and not table.HasValue(SteamIDWhitelist, client:SteamID())) or (isstring(SteamIDWhitelist) and client:SteamID() ~= SteamIDWhitelist)) then
        return false, "You are not whitelisted to buy this item!"
    elseif FactionWhitelist and ((istable(FactionWhitelist) and not table.HasValue(FactionWhitelist, client:Team())) or (isstring(FactionWhitelist) and client:Team() ~= FactionWhitelist)) then
        return false, "Your faction is not whitelisted to buy this item!"
    elseif UserGroupWhitelist and ((istable(UserGroupWhitelist) and not table.HasValue(UserGroupWhitelist, client:GetUserGroup())) or (isstring(UserGroupWhitelist) and client:GetUserGroup() ~= UserGroupWhitelist)) then
        return false, "Your usergroup is not whitelisted to buy this item!"
    elseif VIPOnly and not client:isVIP() then
        return false, "This item is meant for VIPs!"
    end
end

if not VENDOR_INVENTORY_MEASURE then
    VENDOR_INVENTORY_MEASURE = lia.inventory.types["grid"]:new()
    VENDOR_INVENTORY_MEASURE.data = {
        w = 8,
        h = 8
    }

    VENDOR_INVENTORY_MEASURE.virtual = true
    VENDOR_INVENTORY_MEASURE:onInstanced()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:VendorTradeAttempt(client, vendor, itemType, isSellingToVendor)
    local canAccess, reason = hook.Run("CanPlayerTradeWithVendor", client, vendor, itemType, isSellingToVendor)
    if canAccess == false then
        if isstring(reason) then client:notifyLocalized(reason) end
        return
    end

    local character = client:getChar()
    local price = vendor:getPrice(itemType, isSellingToVendor)
    if client.vendorTransaction and client.vendorTimeout > RealTime() then return end
    client.vendorTransaction = true
    client.vendorTimeout = RealTime() + .1
    if isSellingToVendor then
        self:VendorSellEvent(client, vendor, itemType, isSellingToVendor, character, price)
    else
        self:VendorBuyEvent(client, vendor, itemType, isSellingToVendor, character, price)
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerAccessVendor(client, vendor)
    vendor:addReceiver(client)
    net.Start("liaVendorOpen")
    net.WriteEntity(vendor)
    net.Send(client)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:VendorSellEvent(client, vendor, itemType, _, character, price)
    local inventory = character:getInv()
    local item = inventory:getFirstItemOfType(itemType)
    if item then
        local context = {
            client = client,
            item = item,
            from = inventory,
            to = VENDOR_INVENTORY_MEASURE
        }

        local canTransfer, reason = VENDOR_INVENTORY_MEASURE:canAccess("transfer", context)
        if not canTransfer then
            client:notifyLocalized(reason or "vendorError")
            return
        end

        local canTransferItem, reason = hook.Run("CanItemBeTransfered", item, inventory, VENDOR_INVENTORY_MEASURE, client)
        if canTransferItem == false then
            client:notifyLocalized(reason or "vendorError")
            return
        end

        vendor:takeMoney(price)
        character:giveMoney(price)
        item:remove():next(function() client.vendorTransaction = nil end):catch(function() client.vendorTransaction = nil end)
        vendor:addStock(itemType)
        lia.log.add(client, "vendorSell", itemType, vendor:getNetVar("name"))
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:VendorBuyEvent(client, vendor, itemType, isSellingToVendor, character, price)
    if not character:getInv():doesFitInventory(itemType) then
        client:ChatPrint("You don't have space for this item!")
        lia.log.add(client, "vendorBuyFail", itemType, vendor:getNetVar("name"))
        client.vendorTransaction = nil
        return
    end

    vendor:giveMoney(price)
    character:takeMoney(price)
    vendor:takeStock(itemType)
    character:getInv():add(itemType):next(function(item)
        lia.log.add(client, "vendorBuy", itemType, vendor:getNetVar("name"))
        hook.Run("OnCharTradeVendor", client, vendor, item, isSellingToVendor, character)
        client.vendorTransaction = nil
    end)
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------