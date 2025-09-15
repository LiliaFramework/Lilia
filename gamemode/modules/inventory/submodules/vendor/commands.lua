lia.command.add("restockvendor", {
    superAdminOnly = true,
    desc = "restockVendorDesc",
    AdminStick = {
        Name = "restockVendorStickName",
        TargetClass = "lia_vendor",
        Icon = "icon16/box.png"
    },
    onRun = function(client)
        local target = client:getTracedEntity()
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end
        if target:GetClass() == "lia_vendor" then
            for id, itemData in pairs(target.items) do
                if itemData[2] and itemData[4] then target.items[id][2] = itemData[4] end
            end
            client:notifySuccessLocalized("vendorRestocked")
            lia.log.add(client, "restockvendor", target)
        else
            client:notifyErrorLocalized("notLookingAtValidVendor")
        end
    end
})
lia.command.add("restockallvendors", {
    superAdminOnly = true,
    desc = "restockAllVendorsDesc",
    onRun = function(client)
        local count = 0
        for _, vendor in ipairs(ents.FindByClass("lia_vendor")) do
            for id, itemData in pairs(vendor.items) do
                if itemData[2] and itemData[4] then vendor.items[id][2] = itemData[4] end
            end
            count = count + 1
            lia.log.add(client, "restockvendor", vendor)
        end
        client:notifySuccessLocalized("vendorAllVendorsRestocked", count)
        lia.log.add(client, "restockallvendors", count)
    end
})
lia.command.add("createvendorpreset", {
    adminOnly = true,
    desc = "createVendorPresetDesc",
    arguments = {
        {
            name = "presetName",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if not client:hasPrivilege("canCreateVendorPresets") then
            client:notifyErrorLocalized("noPermission")
            return
        end
        local presetName = arguments[1]
        if not presetName or presetName:Trim() == "" then
            client:notifyErrorLocalized("vendorPresetNameRequired")
            return
        end
        local target = client:getTracedEntity()
        if not target or not IsValid(target) or target:GetClass() ~= "lia_vendor" then
            client:notifyErrorLocalized("notLookingAtValidVendor")
            return
        end
        local presetData = {}
        for itemType, itemData in pairs(target.items or {}) do
            if lia.item.list[itemType] then
                presetData[itemType] = {
                    mode = itemData[VENDOR_MODE],
                    price = itemData[VENDOR_PRICE],
                    stock = itemData[VENDOR_STOCK],
                    maxStock = itemData[VENDOR_MAXSTOCK]
                }
            end
        end
        lia.vendor.addPreset(presetName, presetData)
        client:notifySuccessLocalized("vendorPresetSaved", presetName)
        lia.log.add(client, "createvendorpreset", presetName)
    end
})
lia.command.add("deletevendorpreset", {
    adminOnly = true,
    desc = "deleteVendorPresetDesc",
    arguments = {
        {
            name = "presetName",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if not client:hasPrivilege("canCreateVendorPresets") then
            client:notifyErrorLocalized("noPermission")
            return
        end
        local presetName = arguments[1]
        if not presetName or presetName:Trim() == "" then
            client:notifyErrorLocalized("vendorPresetNameRequired")
            return
        end
        presetName = presetName:Trim():lower()
        if not lia.vendor.presets[presetName] then
            client:notifyErrorLocalized("vendorPresetNotFound", presetName)
            return
        end
        lia.vendor.presets[presetName] = nil
        if SERVER then lia.db.delete("vendor_presets", "name = " .. lia.db.convertDataType(presetName)) end
        client:notifySuccessLocalized("vendorPresetDeleted", presetName)
        lia.log.add(client, "deletevendorpreset", presetName)
    end
})
lia.command.add("listvendorpresets", {
    adminOnly = true,
    desc = "listVendorPresetsDesc",
    onRun = function(client)
        if not client:hasPrivilege("canCreateVendorPresets") then
            client:notifyErrorLocalized("noPermission")
            return
        end
        local presets = {}
        for name in pairs(lia.vendor.presets or {}) do
            presets[#presets + 1] = name
        end
        if #presets == 0 then
            client:notifyInfoLocalized("vendorNoPresets")
        else
            table.sort(presets)
            client:notifyInfoLocalized("vendorPresetList", table.concat(presets, ", "))
        end
    end
})
