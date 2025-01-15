local NetworkStrings = {"ViewClaims", "TicketSystem", "TicketSystemClaim", "TicketSystemClose", "TicketClientNotify"}

net.Receive("ViewClaims", function(_, client)
    local sid = net.ReadString()
    net.Start("ViewClaims")
    net.WriteTable(util.JSONToTable(file.Read("caseclaims.txt", "DATA")))
    net.WriteString(sid)
    net.Send(client)
end)

net.Receive("TicketSystemClaim", function(_, client)
    local requester = net.ReadEntity()
    if client:hasPrivilege("Staff Permissions - Always See Tickets") or client:isStaffOnDuty() and not requester.CaseClaimed then
        for _, v in pairs(player.GetAll()) do
            if v:hasPrivilege("Staff Permissions - Always See Tickets") or v:isStaffOnDuty() then
                net.Start("TicketSystemClaim")
                net.WriteEntity(client)
                net.WriteEntity(requester)
                net.Send(v)
            end
        end

        hook.Call("TicketSystemClaim", GAMEMODE, client, requester)
        requester.CaseClaimed = client
    end
end)

net.Receive("TicketSystemClose", function(_, client)
    local requester = net.ReadEntity()
    if not requester or not IsValid(requester) or requester.CaseClaimed ~= client then return end
    if timer.Exists("ticketsystem-" .. requester:SteamID64()) then timer.Remove("ticketsystem-" .. requester:SteamID64()) end
    for _, v in pairs(player.GetAll()) do
        if v:hasPrivilege("Staff Permissions - Always See Tickets") or v:isStaffOnDuty() then
            net.Start("TicketSystemClose")
            net.WriteEntity(requester)
            net.Send(v)
        end
    end

    requester.CaseClaimed = nil
end)

for _, netString in ipairs(NetworkStrings) do
    util.AddNetworkString(netString)
end