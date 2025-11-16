function MODULE:OnCharTradeVendor(client, vendor, item, isSellingToVendor, _, _, isFailed)
    local vendorName = vendor:getNetVar("name")
    if not isSellingToVendor then
        lia.log.add(client, "vendorBuy", item and (item:getName() or item.name) or "", vendorName or L("unknown"), isFailed)
    else
        lia.log.add(client, "vendorSell", item and (item:getName() or item.name) or "", vendorName or L("unknown"))
    end
end

function MODULE:CanPlayerAccessVendor(client, vendor)
    local character = client:getChar()
    if client:canEditVendor(vendor) then return true end
    if vendor:isClassAllowed(character:getClass()) then return true end
    if vendor:isFactionAllowed(client:Team()) then return true end
end

function MODULE:CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
    local item = lia.item.list[itemType]
    if not item then return false, L("vendorInvalidItem") end
    local SteamIDWhitelist = item.SteamIDWhitelist
    local FactionWhitelist = item.FactionWhitelist
    local UserGroupWhitelist = item.UsergroupWhitelist
    local VIPOnly = item.VIPWhitelist
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
    if not isSellingToVendor then
        local money = client:getChar():getMoney()
        if money < price then return false, L("canNotAfford") end
        -- Check cooldown for buying items
        if item.Cooldown and item.Cooldown > 0 then
            local character = client:getChar()
            local cooldowns = character:getData("vendorCooldowns", {})
            local lastPurchase = cooldowns[itemType] or 0
            if CurTime() - lastPurchase < item.Cooldown then
                local remainingTime = math.ceil(item.Cooldown - (CurTime() - lastPurchase))
                return false, "vendorItemOnCooldown", remainingTime
            end
        end
    end

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

    local canAccess, reason, param1 = hook.Run("CanPlayerTradeWithVendor", client, vendor, itemType, isSellingToVendor)
    if canAccess == false then
        if isstring(reason) then
            if param1 then
                client:notifyErrorLocalized(reason, param1)
            else
                client:notifyErrorLocalized(reason)
            end
        end
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
                client:notifyErrorLocalized(transferReason or "vendorError")
                client.vendorTransaction = nil
                return
            end

            local canTransferItem, itemTransferReason = hook.Run("CanItemBeTransfered", item, inventory, VENDOR_INVENTORY_MEASURE, client)
            if canTransferItem == false then
                client:notifyErrorLocalized(itemTransferReason or "vendorError")
                client.vendorTransaction = nil
                return
            end

            character:giveMoney(price)
            item:remove():next(function() client.vendorTransaction = nil end):catch(function() client.vendorTransaction = nil end)
            vendor:addStock(itemType)
            client:notifyMoneyLocalized("vendorYouSoldItem", item:getName(), lia.currency.get(price))
            hook.Run("OnCharTradeVendor", client, vendor, item, isSellingToVendor, character)
        end
    else
        if not character:getInv():doesFitInventory(itemType) then
            client:notifyErrorLocalized("vendorNoInventorySpace")
            hook.Run("OnCharTradeVendor", client, vendor, nil, isSellingToVendor, character, itemType, true)
            client.vendorTransaction = nil
            return
        end

        character:takeMoney(price)
        vendor:takeStock(itemType)
        character:getInv():add(itemType):next(function(item)
            client:notifyMoneyLocalized("vendorYouBoughtItem", item:getName(), lia.currency.get(price))
            local itemData = lia.item.list[itemType]
            if itemData and itemData.Cooldown and itemData.Cooldown > 0 then
                local cooldowns = character:getData("vendorCooldowns", {})
                cooldowns[itemType] = CurTime()
                character:setData("vendorCooldowns", cooldowns)
            end

            hook.Run("OnCharTradeVendor", client, vendor, item, isSellingToVendor, character)
            client.vendorTransaction = nil
        end)
    end
end

function MODULE:PlayerAccessVendor(client, vendor)
    vendor:addReceiver(client)
    net.Start("liaVendorOpen")
    net.WriteEntity(vendor)
    net.Send(client)
    if client:canEditVendor(vendor) then
        for factionID in pairs(vendor.factions) do
            net.Start("liaVendorAllowFaction")
            net.WriteUInt(factionID, 8)
            net.WriteBool(true)
            net.Send(client)
        end

        for classID in pairs(vendor.classes) do
            net.Start("liaVendorAllowClass")
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
        welcomeMessage = ent:getNetVar("welcomeMessage"),
        preset = ent:getNetVar("preset"),
        animation = ent:getNetVar("animation"),
    }
end

function MODULE:OnEntityLoaded(ent, data)
    if ent:GetClass() ~= "lia_vendor" or not data then return end
    ent:setNetVar("name", data.name)
    ent:setNetVar("welcomeMessage", data.welcomeMessage)
    ent:setNetVar("preset", data.preset or "none")
    ent:setNetVar("animation", data.animation or "")
    if data.preset and data.preset ~= "none" then
        ent:applyPreset(data.preset)
    else
        ent.items = data.items or {}
    end

    ent.factions = data.factions or {}
    ent.classes = data.classes or {}
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

                if ent.isReadyForAnim and ent:isReadyForAnim() then
                    ent:setAnim()
                else
                    timer.Simple(0.2, function() if IsValid(ent) and ent.isReadyForAnim and ent:isReadyForAnim() then ent:setAnim() end end)
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

        if ent.isReadyForAnim and ent:isReadyForAnim() then
            ent:setAnim()
        else
            timer.Simple(0.2, function() if IsValid(ent) and ent.isReadyForAnim and ent:isReadyForAnim() then ent:setAnim() end end)
        end
    end
end

net.Receive("liaVendorExit", function(_, client)
    local vendor = client.liaVendor
    if IsValid(vendor) then vendor:removeReceiver(client, true) end
end)

net.Receive("liaVendorEdit", function(_, client)
    local key = net.ReadString()
    if not client:canEditVendor() then return end
    local vendor = client.liaVendor
    if not IsValid(vendor) or not lia.vendor.editor[key] then return end
    lia.log.add(client, "vendorEdit", vendor, key)
    hook.Run("OnVendorEdited", client, vendor, key)
    lia.vendor.editor[key](vendor, client, key)
    hook.Run("UpdateEntityPersistence", vendor)
end)

net.Receive("liaVendorTrade", function(_, client)
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
