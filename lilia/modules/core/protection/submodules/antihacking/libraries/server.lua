local MODULE = MODULE
MODULE.crun = MODULE.crun or concommand.Run
function net.Incoming(length, client)
    local i = net.ReadHeader()
    local strName = util.NetworkIDToString(i)
    if not strName then
        lia.log.add(client, "invalidNet")
        return
    end

    local func = net.Receivers[strName:lower()]
    if not func then
        lia.log.add(client, "invalidNet")
        return
    end

    lia.log.add(client, "net", strName)
    length = length - 16
    func(length, client)
end

function concommand.Run(client, cmd, args, argStr)
    if not IsValid(client) then return MODULE.crun(client, cmd, args, argStr) end
    if not cmd then return MODULE.crun(client, cmd, args, argStr) end
    if cmd == "act" then
        client:SetNW2Bool("IsActing", true)
        timer.Create("ActingExploit_" .. client:SteamID(), ProtectionCore.ActExploitTimer, 1, function() client:SetNW2Bool("IsActing", false) end)
    end

    lia.log.add(client, "concommand", cmd, argStr)
    return MODULE.crun(client, cmd, args, argStr)
end