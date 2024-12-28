local MODULE = MODULE
util.AddNetworkString(MODULE.AltCheckSeed)
util.AddNetworkString(MODULE.HackingCheckSeed)
util.AddNetworkString("VerifyCheats")
for _, v in pairs(KnownExploits) do
    net.Receive(v, function(_, client)
        client.nextExploitNotify = client.nextExploitNotify or 0
        if client.nextExploitNotify > CurTime() then return end
        client.nextExploitNotify = CurTime() + 2
        for _, p in pairs(player.GetAll()) do
            if p:isStaffOnDuty() then p:notify(client:Name() .. " (" .. client:SteamID() .. ") may be attempting to run exploits!") end
        end
    end)
end

net.Receive(MODULE.AltCheckSeed, function(_, client)
    local sentSteamID = net.ReadString()
    if not sentSteamID or sentSteamID == "" then
        MODULE:NotifyAdmin("The SteamID of player " .. client:Name() .. " (" .. client:SteamID() .. ") wasn't received properly. This can signify tampering with net messages.")
        return
    end

    if client:SteamID() ~= sentSteamID then MODULE:NotifyAdmin("The SteamID of player " .. client:Name() .. " (" .. client:SteamID() .. ") is different than the saved one (" .. sentSteamID .. ")") end
end)

net.Receive(MODULE.HackingCheckSeed, function(_, client) MODULE:ApplyPunishment(client, "Hacking", true, true, 0) end)
