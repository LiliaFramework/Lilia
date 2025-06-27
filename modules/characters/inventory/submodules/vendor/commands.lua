lia.command.add("restockvendor", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    desc = L("restockVendorDesc"),
    AdminStick = {
        Name = L("restockVendorStickName"),
        TargetClass = "lia_vendor"
    },
    onRun = function(client)
        local target = client:getTracedEntity()
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if target:GetClass() == "lia_vendor" then
            for id, itemData in pairs(target.items) do
                if itemData[2] and itemData[4] then target.items[id][2] = itemData[4] end
            end

            client:notifyLocalized("vendorRestocked")
            lia.log.add(client, "restockvendor", target)
        else
            client:notifyLocalized("NotLookingAtValidVendor")
        end
    end
})

lia.command.add("restockallvendors", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    desc = L("restockAllVendorsDesc"),
    onRun = function(client)
        local count = 0
        for _, vendor in ipairs(ents.FindByClass("lia_vendor")) do
            for id, itemData in pairs(vendor.items) do
                if itemData[2] and itemData[4] then vendor.items[id][2] = itemData[4] end
            end

            count = count + 1
            lia.log.add(client, "restockvendor", vendor)
        end

        client:notifyLocalized("vendorAllVendorsRestocked", count)
        lia.log.add(client, "restockallvendors", count)
    end
})

lia.command.add("resetallvendormoney", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    desc = L("resetAllVendorMoneyDesc"),
    syntax = "[number Amount]",
    AdminStick = {
        Name = L("resetAllVendorMoneyStickName"),
        TargetClass = "lia_vendor"
    },
    onRun = function(client, arguments)
        local amount = tonumber(arguments[1])
        if not amount or amount < 0 then return client:notifyLocalized("vendorInvalidAmount") end
        local count = 0
        for _, vendor in ipairs(ents.FindByClass("lia_vendor")) do
            if vendor.money ~= nil then
                vendor.money = amount
                count = count + 1
                lia.log.add(client, "resetvendormoney", vendor, amount)
            end
        end

        client:notifyLocalized("vendorAllMoneyReset", lia.currency.get(amount), count)
        lia.log.add(client, "resetallvendormoney", amount, count)
    end
})

lia.command.add("restockvendormoney", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    desc = L("restockVendorMoneyDesc"),
    syntax = "[number Amount]",
    AdminStick = {
        Name = L("restockVendorMoneyStickName"),
        TargetClass = "lia_vendor"
    },
    onRun = function(client, arguments)
        local target = client:getTracedEntity()
        local amount = tonumber(arguments[1])
        if not amount or amount < 0 then return client:notifyLocalized("vendorInvalidAmount") end
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if target:GetClass() == "lia_vendor" then
            if target.money ~= nil then
                target.money = amount
                client:notifyLocalized("vendorMoneyRestocked", lia.currency.get(amount))
                lia.log.add(client, "restockvendormoney", target, amount)
            else
                client:notifyLocalized("vendorNoMoneyVariable")
            end
        else
            client:notifyLocalized("NotLookingAtValidVendor")
        end
    end
})

lia.command.add("savevendors", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    desc = L("saveVendorsDesc"),
    onRun = function(client)
        MODULE:SaveData()
        client:notifyLocalized("vendorDataSaved")
        lia.log.add(client, "savevendors")
    end
})
