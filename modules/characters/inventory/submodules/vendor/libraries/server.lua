function MODULE:SaveData()
    local data = {}
    for _, v in ipairs(ents.FindByClass("lia_vendor")) do
        data[#data + 1] = {
            name = v:getNetVar("name"),
            pos = v:GetPos(),
            angles = v:GetAngles(),
            model = v:GetModel(),
            items = v.items,
            factions = v.factions,
            classes = v.classes,
            money = v.money,
            flag = v:getNetVar("flag"),
            scale = v:getNetVar("scale"),
            welcomeMessage = v:getNetVar("welcomeMessage"),
        }
    end

    self:setData(data)
    lia.information(L("vendorSaved", table.Count(data)))
end

function MODULE:LoadData()
    for _, v in ipairs(self:getData() or {}) do
        local entity = ents.Create("lia_vendor")
        entity:SetPos(v.pos)
        entity:SetAngles(v.angles)
        entity:Spawn()
        entity:SetModel(v.model)
        entity:setNetVar("name", v.name)
        entity:setNetVar("flag", v.flag)
        entity:setNetVar("scale", v.scale or 0.5)
        entity:setNetVar("welcomeMessage", v.welcomeMessage)
        entity.items = v.items or {}
        entity.factions = v.factions or {}
        entity.classes = v.classes or {}
        entity.money = v.money
    end
end

function MODULE:OnCharTradeVendor(client, vendor, item, isSellingToVendor, _, _, isFailed)
    local vendorName = vendor:getNetVar("name") or L("unknown")
    if not isSellingToVendor then
        lia.log.add(client, "vendorBuy", item and (item:getName() or item.name) or "", vendorName, isFailed)
    else
        lia.log.add(client, "vendorSell", item and (item:getName() or item.name) or "", vendorName)
    end
end

function MODULE:CanPlayerAccessVendor(client, vendor)
    local character = client:getChar()
    local flag = vendor:getNetVar("flag")
    if client:CanEditVendor(vendor) then return true end
    if vendor:isClassAllowed(character:getClass()) then return true end
    if vendor:isFactionAllowed(client:Team()) then return true end
    if flag and string.len(flag) == 1 and client:getChar():hasFlags(flag) then return true end
end

function MODULE:CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
    local item = lia.item.list[itemType]
    if not item then return false, L("vendorInvalidItem") end
    local SteamIDWhitelist = item.SteamIDWhitelist
    local FactionWhitelist = item.FactionWhitelist
    local UserGroupWhitelist = item.UsergroupWhitelist
    local VIPOnly = item.VIPWhitelist
    local flag = item.flag
    if not vendor.items[itemType] then return false, L("vendorDoesNotHaveItem") end
    local state = vendor:getTradeMode(itemType)
    if isSellingToVendor and state == VENDOR_SELLONLY then return false, L("sellOnly") end
    if not isSellingToVendor and state == VENDOR_BUYONLY then return false, L("buyOnly") end
    if isSellingToVendor then
        if not client:getChar():getInv():hasItem(itemType) then return false, L("vendorPlayerDoesNotHaveItem") end
    else
        local stock = vendor:getStock(itemType)
        if stock and stock <= 0 then return false, L("vendorNoStock") end
    end

    local price = vendor:getPrice(itemType, isSellingToVendor)
    local money
    if isSellingToVendor then
        money = vendor:getMoney()
    else
        money = client:getChar():getMoney()
    end

    if money and money < price then return false, isSellingToVendor and L("vendorNoMoney") or L("vendorCanNotAfford") end
    if SteamIDWhitelist or FactionWhitelist or UserGroupWhitelist or VIPOnly then
        local hasWhitelist = true
        local isWhitelisted = false
        local errorMessage
        if SteamIDWhitelist and table.HasValue(SteamIDWhitelist, client:SteamID64()) then isWhitelisted = true end
        if FactionWhitelist and table.HasValue(FactionWhitelist, client:Team()) then isWhitelisted = true end
        if UserGroupWhitelist and table.HasValue(UserGroupWhitelist, client:GetUserGroup()) then isWhitelisted = true end
        if VIPOnly and client:isVIP() then isWhitelisted = true end
        if hasWhitelist and not isWhitelisted then
            if SteamIDWhitelist then
                errorMessage = L("vendorSteamIDWhitelist")
            elseif FactionWhitelist then
                errorMessage = L("vendorFactionWhitelist")
            elseif UserGroupWhitelist then
                errorMessage = L("vendorUserGroupWhitelist")
            elseif VIPOnly then
                errorMessage = L("vendorVIPOnly")
            else
                errorMessage = L("vendorNotWhitelisted")
            end
            return false, errorMessage
        end
    end

    if flag and not client:getChar():hasFlags(flag) then return false, L("vendorTradeRestrictedFlag") end
    return true, nil, isWhitelisted
end

function MODULE:VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
    if not VENDOR_INVENTORY_MEASURE and lia.inventory.types["GridInv"] then
        VENDOR_INVENTORY_MEASURE = lia.inventory.types["GridInv"]:new()
        VENDOR_INVENTORY_MEASURE.data = {
            w = 8,
            h = 8
        }

        VENDOR_INVENTORY_MEASURE.virtual = true
        VENDOR_INVENTORY_MEASURE:onInstanced()
    end

    local canAccess, reason = hook.Run("CanPlayerTradeWithVendor", client, vendor, itemType, isSellingToVendor)
    if canAccess == false then
        if isstring(reason) then client:notifyLocalized(reason) end
        return
    end

    if client.vendorTransaction and client.vendorTimeout > RealTime() then return end
    client.vendorTransaction = true
    client.vendorTimeout = RealTime() + 0.1
    local character = client:getChar()
    local price = vendor:getPrice(itemType, isSellingToVendor)
    if isSellingToVendor then
        local inventory = character:getInv()
        local item = inventory:getFirstItemOfType(itemType)
        if item then
            local context = {
                client = client,
                item = item,
                from = inventory,
                to = VENDOR_INVENTORY_MEASURE
            }

            local canTransfer, transferReason = VENDOR_INVENTORY_MEASURE:canAccess("transfer", context)
            if not canTransfer then
                client:notifyLocalized(transferReason or L("vendorError"))
                client.vendorTransaction = nil
                return
            end

            local canTransferItem, itemTransferReason = hook.Run("CanItemBeTransfered", item, inventory, VENDOR_INVENTORY_MEASURE, client)
            if canTransferItem == false then
                client:notifyLocalized(itemTransferReason or "vendorError")
                client.vendorTransaction = nil
                return
            end

            vendor:takeMoney(price)
            character:giveMoney(price)
            item:remove():next(function() client.vendorTransaction = nil end):catch(function() client.vendorTransaction = nil end)
            vendor:addStock(itemType)
            client:notifyLocalized("vendorYouSoldItem", item:getName(), lia.currency.get(price))
            hook.Run("OnCharTradeVendor", client, vendor, item, isSellingToVendor, character)
        end
    else
        if not character:getInv():doesFitInventory(itemType) then
            client:notifyLocalized("vendorNoInventorySpace")
            hook.Run("OnCharTradeVendor", client, vendor, nil, isSellingToVendor, character, itemType, true)
            client.vendorTransaction = nil
            return
        end

        vendor:giveMoney(price)
        character:takeMoney(price)
        vendor:takeStock(itemType)
        character:getInv():add(itemType):next(function(item)
            client:notifyLocalized("vendorYouBoughtItem", item:getName(), lia.currency.get(price))
            hook.Run("OnCharTradeVendor", client, vendor, item, isSellingToVendor, character)
            client.vendorTransaction = nil
        end)
    end
end

function MODULE:PlayerAccessVendor(client, vendor)
    vendor:addReceiver(client)
    net.Start("VendorOpen")
    net.WriteEntity(vendor)
    net.Send(client)
    if client:CanEditVendor(vendor) then
        for factionID in pairs(vendor.factions) do
            net.Start("VendorAllowFaction")
            net.WriteUInt(factionID, 8)
            net.WriteBool(true)
            net.Send(client)
        end

        for classID in pairs(vendor.classes) do
            net.Start("VendorAllowClass")
            net.WriteUInt(classID, 8)
            net.WriteBool(true)
            net.Send(client)
        end
    end
end
