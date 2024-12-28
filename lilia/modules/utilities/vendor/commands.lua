local MODULE = MODULE
lia.command.add("restockvendor", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    onRun = function(client)
        local target = client:GetEyeTrace().Entity
        if IsValid(target) and target:GetClass() == "lia_vendor" then
            for id, itemData in pairs(target.items) do
                if itemData[2] and itemData[4] then target.items[id][2] = itemData[4] end
            end
            return "The vendor has been restocked."
        else
            return "You are not looking at a valid vendor."
        end
    end
})

lia.command.add("restockallvendors", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    onRun = function()
        for _, v in ipairs(ents.FindByClass("lia_vendor")) do
            for id, _ in pairs(v.items) do
                if v.items[id][2] and v.items[id][4] then v.items[id][2] = v.items[id][4] end
            end
        end
        return "Restocked all vendors."
    end
})

lia.command.add("resetallvendormoney", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    syntax = "<int amount>",
    onRun = function(_, arguments)
        for _, v in ipairs(ents.FindByClass("lia_vendor")) do
            if v.money then v.money = tonumber(arguments[1]) or 0 end
        end
        return "Reset the money of all vendors to " .. (arguments[1] or 0)
    end
})

lia.command.add("restockvendormoney", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    syntax = "<int amount>",
    onRun = function(client, arguments)
        local target = client:GetEyeTrace().Entity
        local amount = tonumber(arguments[1])
        if not amount or amount < 0 then return "Invalid amount. Please provide a non-negative number." end
        if IsValid(target) and target:GetClass() == "lia_vendor" then
            if target.money then
                target.money = amount
                return "The vendor's money has been restocked to " .. amount .. "."
            else
                return "This vendor does not have a money variable."
            end
        else
            return "You are not looking at a valid vendor."
        end
    end
})

lia.command.add("savevendors", {
    superAdminOnly = true,
    privilege = "Manage Vendors",
    onRun = function() MODULE:SaveData() end
})