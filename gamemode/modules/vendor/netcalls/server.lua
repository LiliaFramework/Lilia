net.Receive("liaVendorExit", function(_, client)
    local vendor = client.liaVendor
    if IsValid(vendor) then vendor:removeReceiver(client, true) end
end)

net.Receive("liaVendorEdit", function(_, client)
    local key = net.ReadString()
    if not client:canEditVendor() then return end
    local vendor = client.liaVendor
    if not IsValid(vendor) or not lia.vendor.editor[key] then return end
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
    client:notifyInfo(string.format("Vendor preset '%s' has been loaded successfully", presetName))
end)

net.Receive("liaVendorDeletePreset", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaVendorDeletePreset", "hasPrivilege(canCreateVendorPresets)=", tostring(client:hasPrivilege("canCreateVendorPresets")), "finalResult=", tostring(client:hasPrivilege("canCreateVendorPresets")))
    if not client:hasPrivilege("canCreateVendorPresets") then
        client:notifyError(string.format("No Permission"))
        return
    end

    local presetName = net.ReadString()
    if not presetName or presetName:Trim() == "" then
        client:notifyError(string.format("Preset name is required"))
        return
    end

    presetName = presetName:Trim():lower()
    if not lia.vendor.presets[presetName] then
        client:notifyError(string.format("Vendor preset '%s' not found.", presetName))
        return
    end

    lia.vendor.presets[presetName] = nil
    lia.data.set("vendor_presets", lia.vendor.presets)
    client:notifySuccess(string.format("Vendor preset '%s' has been deleted.", presetName))
    net.Start("liaVendorSyncPresets")
    net.WriteTable(lia.vendor.presets)
    net.Broadcast()
end)

net.Receive("liaVendorSavePreset", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaVendorSavePreset", "hasPrivilege(canCreateVendorPresets)=", tostring(client:hasPrivilege("canCreateVendorPresets")), "finalResult=", tostring(client:hasPrivilege("canCreateVendorPresets")))
    if not client:hasPrivilege("canCreateVendorPresets") then
        client:notifyError(string.format("No Permission"))
        return
    end

    local presetName = net.ReadString()
    local itemsData = net.ReadTable()
    if not presetName or presetName:Trim() == "" then
        client:notifyError(string.format("Preset name is required"))
        return
    end

    presetName = presetName:Trim():lower()
    local validItems = {}
    for itemType, itemData in pairs(itemsData) do
        if lia.item.list[itemType] then validItems[itemType] = itemData end
    end

    lia.vendor.presets[presetName] = validItems
    lia.data.set("vendor_presets", lia.vendor.presets)
    client:notifyInfo(string.format("Vendor preset '%s' has been saved successfully", presetName))
    net.Start("liaVendorSyncPresets")
    net.WriteTable(lia.vendor.presets)
    net.Broadcast()
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
