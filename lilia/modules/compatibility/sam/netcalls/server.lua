local MODULE = MODULE
util.AddNetworkString("sam_blind")
util.AddNetworkString("ViewClaims")
util.AddNetworkString("TicketSystem")
util.AddNetworkString("TicketSystemClaim")
util.AddNetworkString("TicketSystemClose")
util.AddNetworkString("TicketClientNotify")
net.Receive("ViewClaims", function(_, client)
    local sid = net.ReadString()
    net.Start("ViewClaims")
    net.WriteTable(util.JSONToTable(file.Read("caseclaims.txt", "DATA")))
    net.WriteString(sid)
    net.Send(client)
end)

net.Receive("TicketSystemClaim", function(_, client)
    local requester = net.ReadEntity()
    if MODULE:HasAccess(client) and not requester.CaseClaimed then
        for _, v in pairs(player.GetAll()) do
            if MODULE:HasAccess(v) then
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
        if MODULE:HasAccess(v) then
            net.Start("TicketSystemClose")
            net.WriteEntity(requester)
            net.Send(v)
        end
    end

    requester.CaseClaimed = nil
end)