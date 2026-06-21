local MODULE = MODULE
net.Receive("liaSendLogsRequest", function(_, client)
    if not hook.Run("CanPlayerSeeLogs", client) then return end
    local category = net.ReadString()
    local page = net.ReadUInt(16)
    if hook.Run("CanPlayerSeeLogCategory", client, category) == false then return end
    MODULE:ReadLogEntries(category, page):next(function(result) lia.net.writeBigTable(client, "liaSendLogs", result) end)
end)

net.Receive("liaSendLogsCategoriesRequest", function(_, client)
    if not hook.Run("CanPlayerSeeLogs", client) then return end
    local categories = {}
    for _, v in pairs(lia.log.types) do
        categories[v.category or L("uncategorized")] = true
    end

    local catList = {}
    for k in pairs(categories) do
        if hook.Run("CanPlayerSeeLogCategory", client, k) ~= false then catList[#catList + 1] = k end
    end

    net.Start("liaSendLogsCategories")
    net.WriteTable(catList)
    net.Send(client)
end)
