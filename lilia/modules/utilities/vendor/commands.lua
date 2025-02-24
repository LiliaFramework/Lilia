local MODULE = MODULE
lia.command.add("restockvendor", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    AdminStick = {
        Name = "Restock Selected Vendor",
        TargetClass = "lia_vendor"
    },
    onRun = function(client)
        local target = client:getTracedEntity()
        if IsValid(target) and target:GetClass() == "lia_vendor" then
            for id, itemData in pairs(target.items) do
                if itemData[2] and itemData[4] then target.items[id][2] = itemData[4] end
            end

            client:notifyLocalized("vendorRestocked")
            lia.log.add(client, "restockvendor", target)
        else
            client:notifyLocalized("vendorNotLookingAtValidVendor")
        end
    end
})

lia.command.add("restockallvendors", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
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
    syntax = "[number amount]",
    AdminStick = {
        Name = "Reset Money for All Vendors",
        TargetClass = "lia_vendor",
        ExtraFields = {
            ["Amount"] = "text",
        }
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
    syntax = "[number amount]",
    AdminStick = {
        Name = "Restock Money for Selected Vendor",
        TargetClass = "lia_vendor",
        ExtraFields = {
            ["Amount"] = "text",
        }
    },
    onRun = function(client, arguments)
        local target = client:getTracedEntity()
        local amount = tonumber(arguments[1])
        if not amount or amount < 0 then return client:notifyLocalized("vendorInvalidAmount") end
        if IsValid(target) and target:GetClass() == "lia_vendor" then
            if target.money ~= nil then
                target.money = amount
                client:notifyLocalized("vendorMoneyRestocked", lia.currency.get(amount))
                lia.log.add(client, "restockvendormoney", target, amount)
            else
                client:notifyLocalized("vendorNoMoneyVariable")
            end
        else
            client:notifyLocalized("vendorNotLookingAtValidVendor")
        end
    end
})

lia.command.add("savevendors", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    onRun = function(client)
        MODULE:SaveData()
        client:notifyLocalized("vendorDataSaved")
        lia.log.add(client, "savevendors")
    end
})
