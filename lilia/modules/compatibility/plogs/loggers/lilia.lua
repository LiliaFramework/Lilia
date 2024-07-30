plogs.Register("Connections", true, Color(52, 152, 219))
plogs.Register("Spawn", true, Color(52, 152, 219))
plogs.Register("Chat", true, Color(52, 152, 219))
plogs.Register("Character", true, Color(52, 152, 219))
plogs.Register("Doors", true, Color(52, 152, 219))
plogs.Register("Vendor", true, Color(52, 152, 219))
plogs.Register("Inventory", true, Color(52, 152, 219))
plogs.Register("Money", true, Color(52, 152, 219))
plogs.Register("Damage", true, Color(52, 152, 219))
plogs.Register("Kills/Deaths", true, Color(52, 152, 219))
plogs.Register("Toolgun", true, Color(52, 152, 219))
plogs.Register("Staff", true, Color(52, 152, 219))
plogs.Register("Network", true, Color(52, 152, 219))
plogs.AddHook("OnServerLog", function(client, logType, logString)
    if not plogs.data[logType] then plogs.data[logType] = {} end
    if not IsValid(client) then
        print("Invalid client entity")
        return
    end

    local logData = lia.log.types[logType]
    if not logData then
        print("Log data not found for log type:", logType)
        return
    end

    if not logData.PLogs then
        print("PLogs not enabled for log type:", logType)
        return
    end

    plogs.PlayerLog(client, logData.PLogs, logString, {
        ["Name"] = client:Name(),
        ["SteamID"] = client:SteamID()
    })
end)