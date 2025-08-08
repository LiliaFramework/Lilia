lia.command.add("restockvendor", {
    privilege = "manageVendors",
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
            client:notifyLocalized("notLookingAtValidVendor")
        end
    end
})

lia.command.add("restockallvendors", {
    privilege = "manageVendors",
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

        client:notifyLocalized("vendorAllVendorsRestocked", count)
        lia.log.add(client, "restockallvendors", count)
    end
})

lia.command.add("resetallvendormoney", {
    privilege = "manageVendors",
    superAdminOnly = true,
    desc = "resetAllVendorMoneyDesc",
    arguments = {
        {
            name = "amount",
            type = "string"
        },
    },
    AdminStick = {
        Name = "resetAllVendorMoneyStickName",
        TargetClass = "lia_vendor",
        Icon = "icon16/money_delete.png"
    },
    onRun = function(client, arguments)
        local amount = tonumber(arguments[1])
        if not amount or amount < 0 then return client:notifyLocalized("invalidAmount") end
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
    privilege = "manageVendors",
    superAdminOnly = true,
    desc = "restockVendorMoneyDesc",
    arguments = {
        {
            name = "amount",
            type = "string"
        },
    },
    AdminStick = {
        Name = "restockVendorMoneyStickName",
        TargetClass = "lia_vendor",
        Icon = "icon16/money_add.png"
    },
    onRun = function(client, arguments)
        local target = client:getTracedEntity()
        local amount = tonumber(arguments[1])
        if not amount or amount < 0 then return client:notifyLocalized("invalidAmount") end
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
            client:notifyLocalized("notLookingAtValidVendor")
        end
    end
})