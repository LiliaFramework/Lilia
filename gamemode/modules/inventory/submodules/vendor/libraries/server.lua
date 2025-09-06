﻿function MODULE:OnCharTradeVendor(client, vendor, item, isSellingToVendor, _, _, isFailed)
    local vendorName = vendor:getNetVar("name")
    if not isSellingToVendor then
        lia.log.add(client, "vendorBuy", item and (item:getName() or item.name) or "", vendorName or L("unknown"), isFailed)
    else
        lia.log.add(client, "vendorSell", item and (item:getName() or item.name) or "", vendorName or L("unknown"))
    end
end

function MODULE:CanPlayerAccessVendor(client, vendor)
    local character = client:getChar()
    local flag = vendor:getNetVar("flag")
    if client:CanEditVendor(vendor) then return true end
    if vendor:isClassAllowed(character:getClass()) then return true end
    if vendor:isFactionAllowed(client:Team()) then return true end
    if flag and string.len(flag) == 1 and client:hasFlags(flag) then return true end
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

    if money and money < price then return false, isSellingToVendor and L("vendorNoMoney") or L("canNotAfford") end
    if SteamIDWhitelist or FactionWhitelist or UserGroupWhitelist or VIPOnly then
        local hasWhitelist = true
        local isWhitelisted = false
        local errorMessage
        if SteamIDWhitelist and table.HasValue(SteamIDWhitelist, client:SteamID()) then isWhitelisted = true end
        if FactionWhitelist and table.HasValue(FactionWhitelist, client:Team()) then isWhitelisted = true end
        if UserGroupWhitelist and table.HasValue(UserGroupWhitelist, client:GetUserGroup()) then isWhitelisted = true end
        if VIPOnly and client:isVIP() then isWhitelisted = true end
        if hasWhitelist and not isWhitelisted then
            if SteamIDWhitelist then
                errorMessage = L("vendorSteamIDWhitelist")
            elseif FactionWhitelist then
                errorMessage = L("illegalAccess")
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

    if flag and not client:hasFlags(flag) then return false, L("vendorTradeRestrictedFlag") end
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

function MODULE:GetEntitySaveData(ent)
    if ent:GetClass() ~= "lia_vendor" then return end
    return {
        name = ent:getNetVar("name"),
        items = ent.items,
        factions = ent.factions,
        classes = ent.classes,
        money = ent.money,
        model = ent:GetModel(),
        skin = ent:GetSkin(),
        bodygroups = (function()
            local groups = {}
            for i = 0, ent:GetNumBodyGroups() - 1 do
                local val = ent:GetBodygroup(i)
                if val > 0 then groups[i] = val end
            end
            return groups
        end)(),
        flag = ent:getNetVar("flag"),
        scale = ent:getNetVar("scale"),
        welcomeMessage = ent:getNetVar("welcomeMessage"),
        preset = ent:getNetVar("preset"),
    }
end

function MODULE:OnEntityLoaded(ent, data)
    if ent:GetClass() ~= "lia_vendor" or not data then return end
    ent:setNetVar("name", data.name)
    ent:setNetVar("flag", data.flag)
    ent:setNetVar("scale", data.scale or 0.5)
    ent:setNetVar("welcomeMessage", data.welcomeMessage)
    ent:setNetVar("preset", data.preset or "none")
    ent.items = data.items or {}
    ent.factions = data.factions or {}
    ent.classes = data.classes or {}
    ent.money = data.money
    if data.model and data.model ~= "" and data.model ~= ent:GetModel() then
        ent:SetModel(data.model)
        timer.Simple(0.1, function()
            if IsValid(ent) then
                if data.skin then ent:SetSkin(data.skin) end
                if istable(data.bodygroups) then
                    for k, v in pairs(data.bodygroups) do
                        ent:SetBodygroup(tonumber(k), v)
                    end
                end
            end
        end)
    else
        if data.skin then ent:SetSkin(data.skin) end
        if istable(data.bodygroups) then
            for k, v in pairs(data.bodygroups) do
                ent:SetBodygroup(tonumber(k), v)
            end
        end
    end
end

net.Receive("VendorExit", function(_, client)
    local vendor = client.liaVendor
    if IsValid(vendor) then vendor:removeReceiver(client, true) end
end)

net.Receive("VendorEdit", function(_, client)
    local key = net.ReadString()
    if not client:CanEditVendor() then return end
    local vendor = client.liaVendor
    if not IsValid(vendor) or not lia.vendor.editor[key] then return end
    lia.log.add(client, "vendorEdit", vendor, key)
    hook.Run("OnVendorEdited", client, vendor, key)
    lia.vendor.editor[key](vendor, client, key)
    hook.Run("UpdateEntityPersistence", vendor)
end)

net.Receive("VendorTrade", function(_, client)
    local uniqueID = net.ReadString()
    local isSellingToVendor = net.ReadBool()
    if not client:getChar() or not client:getChar():getInv() then return end
    if (client.liaVendorTry or 0) < CurTime() then
        client.liaVendorTry = CurTime() + 0.1
    else
        return
    end

    local entity = client.liaVendor
    if not IsValid(entity) or client:GetPos():Distance(entity:GetPos()) > 192 then return end
    if not hook.Run("CanPlayerAccessVendor", client, entity) then return end
    hook.Run("VendorTradeEvent", client, entity, uniqueID, isSellingToVendor)
end)
