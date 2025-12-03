function MODULE:OnCharTradeVendor(client, vendor, item, isSellingToVendor, _, _, isFailed)
    local vendorName = lia.vendor.getVendorProperty(vendor, "name")
    if not isSellingToVendor then
        lia.log.add(client, "vendorBuy", item and (item:getName() or item.name) or "", vendorName or L("unknown"), isFailed)
    else
        lia.log.add(client, "vendorSell", item and (item:getName() or item.name) or "", vendorName or L("unknown"))
    end
end

function MODULE:CanPersistEntity(entity)
    if entity:GetClass() == "lia_vendor" then return true end
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

    local price = vendor:getPrice(itemType, isSellingToVendor, client)
    if not isSellingToVendor then
        local money = client:getChar():getMoney()
        if money < price then return false, L("canNotAfford") end
        if item.Cooldown and item.Cooldown > 0 then
            local character = client:getChar()
            local cooldowns = character:getData("vendorCooldowns", {})
            local lastPurchase = cooldowns[itemType] or 0
            if os.time() - lastPurchase < item.Cooldown then
                local remainingTime = math.ceil(item.Cooldown - (os.time() - lastPurchase))
                return false, L("vendorItemOnCooldown", remainingTime)
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
    local price = vendor:getPrice(itemType, isSellingToVendor, client)
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
                client:notifyErrorLocalized(transferReason or L("vendorError"))
                client.vendorTransaction = nil
                return
            end

            local canTransferItem, itemTransferReason = hook.Run("CanItemBeTransfered", item, inventory, VENDOR_INVENTORY_MEASURE, client)
            if canTransferItem == false then
                client:notifyErrorLocalized(itemTransferReason or L("vendorError"))
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
                cooldowns[itemType] = os.time()
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
    net.Start("liaVendorSyncPresets")
    net.WriteTable(lia.vendor.presets)
    net.Send(client)
    local name = lia.vendor.getVendorProperty(vendor, "name")
    local animation = lia.vendor.getVendorProperty(vendor, "animation")
    if name then
        net.Start("liaVendorPropertySync")
        net.WriteEntity(vendor)
        net.WriteString("name")
        net.WriteBool(false)
        net.WriteTable({name})
        net.Send(client)
    end

    if animation then
        net.Start("liaVendorPropertySync")
        net.WriteEntity(vendor)
        net.WriteString("animation")
        net.WriteBool(false)
        net.WriteTable({animation})
        net.Send(client)
    end

    if vendor.factionBuyScales then
        for factionID, scale in pairs(vendor.factionBuyScales) do
            if isnumber(factionID) and isnumber(scale) then
                net.Start("liaVendorFactionBuyScale")
                net.WriteUInt(factionID, 8)
                net.WriteFloat(scale)
                net.Send(client)
            end
        end
    end

    if vendor.factionSellScales then
        for factionID, scale in pairs(vendor.factionSellScales) do
            if isnumber(factionID) and isnumber(scale) then
                net.Start("liaVendorFactionSellScale")
                net.WriteUInt(factionID, 8)
                net.WriteFloat(scale)
                net.Send(client)
            end
        end
    end

    if vendor.messages then
        net.Start("liaVendorSyncMessages")
        net.WriteTable(vendor.messages)
        net.Send(client)
    end

    for factionID in pairs(vendor.factions or {}) do
        if isnumber(factionID) then
            net.Start("liaVendorAllowFaction")
            net.WriteUInt(factionID, 8)
            net.WriteBool(true)
            net.Send(client)
        end
    end

    for classID in pairs(vendor.classes or {}) do
        if isnumber(classID) then
            net.Start("liaVendorAllowClass")
            net.WriteUInt(classID, 8)
            net.WriteBool(true)
            net.Send(client)
        end
    end
end

function MODULE:syncVendorDataToClient(client)
    local vendors = {}
    for _, vendor in pairs(ents.FindByClass("lia_vendor")) do
        if IsValid(vendor) then table.insert(vendors, vendor) end
    end

    if #vendors == 0 then return end
    net.Start("liaVendorInitialSync")
    net.WriteUInt(#vendors, 16)
    for _, vendor in ipairs(vendors) do
        net.WriteEntity(vendor)
        local cached = lia.vendor.stored[vendor] or {}
        local propertyCount = 0
        local propertiesToSync = {}
        local name = lia.vendor.getVendorProperty(vendor, "name")
        local animation = lia.vendor.getVendorProperty(vendor, "animation")
        if name then propertiesToSync["name"] = name end
        if animation then propertiesToSync["animation"] = animation end
        for property, value in pairs(cached) do
            if property ~= "name" and property ~= "animation" then propertiesToSync[property] = value end
        end

        local validProperties = {}
        for property, value in pairs(propertiesToSync) do
            if value ~= nil and (isstring(value) or isnumber(value) or isbool(value) or istable(value)) then validProperties[property] = value end
        end

        for _, _ in pairs(validProperties) do
            propertyCount = propertyCount + 1
        end

        net.WriteUInt(propertyCount, 8)
        for property, value in pairs(validProperties) do
            net.WriteString(property)
            net.WriteTable({value})
        end
    end

    net.Send(client)
end

function MODULE:GetEntitySaveData(ent)
    if ent:GetClass() ~= "lia_vendor" then return end
    local factionBuyScales = ent.factionBuyScales
    local factionSellScales = ent.factionSellScales
    if not istable(factionBuyScales) then
        factionBuyScales = {}
        ent.factionBuyScales = factionBuyScales
    end

    if not istable(factionSellScales) then
        factionSellScales = {}
        ent.factionSellScales = factionSellScales
    end

    local data = {
        name = lia.vendor.getVendorProperty(ent, "name"),
        items = ent.items or {},
        factions = ent.factions or {},
        classes = ent.classes or {},
        messages = ent.messages or {},
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
        animation = lia.vendor.getVendorProperty(ent, "animation"),
        factionBuyScales = factionBuyScales,
        factionSellScales = factionSellScales,
    }
    return data
end

function MODULE:OnEntityLoaded(ent, data)
    if ent:GetClass() ~= "lia_vendor" or not data then return end
    if not istable(data.factionBuyScales) then data.factionBuyScales = {} end
    if not istable(data.factionSellScales) then data.factionSellScales = {} end
    lia.vendor.setVendorProperty(ent, "name", data.name)
    lia.vendor.setVendorProperty(ent, "animation", data.animation or "")
    ent.items = data.items or {}
    ent.factions = data.factions or {}
    ent.classes = data.classes or {}
    ent.messages = data.messages or {}
    ent.factionBuyScales = data.factionBuyScales
    ent.factionSellScales = data.factionSellScales
    timer.Simple(0.1, function()
        if IsValid(ent) then
            for _, client in player.Iterator() do
                if IsValid(client) then self:syncVendorDataToClient(client) end
            end
        end
    end)

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
    lia.vendor.editor[key](vendor, client)
    hook.Run("UpdateEntityPersistence", vendor)
end)

net.Receive("liaVendorTrade", function(_, client)
    local uniqueID = net.ReadString()
    local isSellingToVendor = net.ReadBool()
    if not client:getChar() or not client:getChar():getInv() then return end
    if (client.liaVendorTry or 0) < os.time() then
        client.liaVendorTry = os.time() + 0.1
    else
        return
    end

    local entity = client.liaVendor
    if not IsValid(entity) or client:GetPos():Distance(entity:GetPos()) > 192 then return end
    if not hook.Run("CanPlayerAccessVendor", client, entity) then return end
    hook.Run("VendorTradeEvent", client, entity, uniqueID, isSellingToVendor)
end)

net.Receive("liaVendorLoadPreset", function(_, client)
    local vendor = client.liaVendor
    if not IsValid(vendor) or not client:canEditVendor(vendor) then return end
    local presetName = net.ReadString()
    if not presetName or presetName:Trim() == "" then return end
    presetName = presetName:Trim():lower()
    vendor:loadPreset(presetName)
    client:notifyInfoLocalized("vendorPresetLoaded", presetName)
    lia.log.add(client, "vendorPresetLoad", presetName)
end)

net.Receive("liaVendorDeletePreset", function(_, client)
    if not client:hasPrivilege("canCreateVendorPresets") then
        client:notifyErrorLocalized("noPermission")
        return
    end

    local presetName = net.ReadString()
    if not presetName or presetName:Trim() == "" then
        client:notifyErrorLocalized("vendorPresetNameRequired")
        return
    end

    presetName = presetName:Trim():lower()
    if not lia.vendor.presets[presetName] then
        client:notifyErrorLocalized("vendorPresetNotFound", presetName)
        return
    end

    local presetData = lia.vendor.presets[presetName]
    lia.vendor.presets[presetName] = nil
    lia.db.delete("vendor_presets", "name = " .. lia.db.convertDataType(presetName)):next(function()
        client:notifySuccessLocalized("vendorPresetDeleted", presetName)
        lia.log.add(client, "vendorPresetDelete", presetName)
        net.Start("liaVendorSyncPresets")
        net.WriteTable(lia.vendor.presets)
        net.Broadcast()
    end):catch(function()
        lia.vendor.presets[presetName] = presetData
        client:notifyErrorLocalized("vendorPresetDeleteFailed", presetName)
    end)
end)

net.Receive("liaVendorSavePreset", function(_, client)
    if not client:hasPrivilege("canCreateVendorPresets") then
        client:notifyErrorLocalized("noPermission")
        return
    end

    local presetName = net.ReadString()
    local itemsData = net.ReadTable()
    if not presetName or presetName:Trim() == "" then
        client:notifyErrorLocalized("vendorPresetNameRequired")
        return
    end

    presetName = presetName:Trim():lower()
    local validItems = {}
    for itemType, itemData in pairs(itemsData) do
        if lia.item.list[itemType] then validItems[itemType] = itemData end
    end

    lia.vendor.presets[presetName] = validItems
    local jsonData = util.TableToJSON(validItems)
    lia.db.upsert({
        name = presetName,
        data = jsonData
    }, "vendor_presets"):next(function()
        client:notifyInfoLocalized("vendorPresetSaved", presetName)
        lia.log.add(client, "vendorPresetSave", presetName)
        net.Start("liaVendorSyncPresets")
        net.WriteTable(lia.vendor.presets)
        net.Broadcast()
    end):catch(function() client:notifyErrorLocalized("vendorPresetSaveFailed") end)
end)

net.Receive("liaVendorRequestData", function(_, client)
    local vendor = net.ReadEntity()
    if not IsValid(vendor) or vendor:GetClass() ~= "lia_vendor" then return end
    local name = lia.vendor.getVendorProperty(vendor, "name")
    local animation = lia.vendor.getVendorProperty(vendor, "animation")
    if name then
        net.Start("liaVendorPropertySync")
        net.WriteEntity(vendor)
        net.WriteString("name")
        net.WriteBool(false)
        net.WriteTable({name})
        net.Send(client)
    end

    if animation then
        net.Start("liaVendorPropertySync")
        net.WriteEntity(vendor)
        net.WriteString("animation")
        net.WriteBool(false)
        net.WriteTable({animation})
        net.Send(client)
    end
end)

function MODULE:DatabaseConnected()
    lia.db.query("SELECT name, data FROM lia_vendor_presets"):next(function(result)
        local data = result.results
        if data then
            for _, row in ipairs(data) do
                local presetName = row.name
                local itemsData = util.JSONToTable(row.data)
                if presetName and itemsData then lia.vendor.presets[presetName] = itemsData end
            end
        end
    end):catch(function() end)
end

function MODULE:InitPostEntity()
    timer.Simple(0.1, function()
        for _, client in player.Iterator() do
            if IsValid(client) then self:syncVendorDataToClient(client) end
        end
    end)
end

function MODULE:PostPlayerInitialSpawn(client)
    timer.Simple(0.1, function() if IsValid(client) then self:syncVendorDataToClient(client) end end)
end
