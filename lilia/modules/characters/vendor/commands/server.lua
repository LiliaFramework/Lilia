---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("restockallvendors", {
    privilege = "Restock Vendors",
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("resetallvendormoney", {
    privilege = "Reset Vendor Money",
    superAdminOnly = true,
    syntax = "<int amount>",
    onRun = function(_, arguments)
        for _, v in ipairs(ents.FindByClass("lia_vendor")) do
            if v.money then v.money = tonumber(arguments[1]) or 0 end
        end
        return "Reset the money of all vendors to " .. (arguments[1] or 0)
    end
})
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
