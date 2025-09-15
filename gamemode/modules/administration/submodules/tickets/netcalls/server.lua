local MODULE = MODULE
net.Receive("ViewClaims", function(_, client)
    local sid = net.ReadString()
    MODULE:GetAllCaseClaims():next(function(caseclaims)
        net.Start("ViewClaims")
        net.WriteTable(caseclaims)
        net.WriteString(sid)
        net.Send(client)
    end)
end)

net.Receive("TicketSystemClaim", function(_, client)
    local requester = net.ReadEntity()
    if client == requester then
        client:notifyErrorLocalized("ticketActionSelf")
        return
    end

    if (client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty()) and not requester.CaseClaimed then
        for _, v in player.Iterator() do
            if v:hasPrivilege("alwaysSeeTickets") or v:isStaffOnDuty() then
                net.Start("TicketSystemClaim")
                net.WriteEntity(client)
                net.WriteEntity(requester)
                net.Send(v)
            end
        end

        local ticketMessage = ""
        local t = MODULE.ActiveTickets[requester:SteamID()]
        if t then
            ticketMessage = t.message or ""
            t.admin = client:SteamID()
        end

        hook.Run("TicketSystemClaim", client, requester, ticketMessage)
        hook.Run("OnTicketClaimed", client, requester, ticketMessage)
        requester.CaseClaimed = client
    end
end)

net.Receive("TicketSystemClose", function(_, client)
    local requester = net.ReadEntity()
    if client == requester then
        client:notifyErrorLocalized("ticketActionSelf")
        return
    end

    if not requester or not IsValid(requester) or requester.CaseClaimed ~= client then return end
    if timer.Exists("ticketsystem-" .. requester:SteamID()) then timer.Remove("ticketsystem-" .. requester:SteamID()) end
    for _, v in player.Iterator() do
        if v:hasPrivilege("alwaysSeeTickets") or v:isStaffOnDuty() then
            net.Start("TicketSystemClose")
            net.WriteEntity(requester)
            net.Send(v)
        end
    end

    local ticketMessage = ""
    local t = MODULE.ActiveTickets[requester:SteamID()]
    if t then ticketMessage = t.message or "" end
    hook.Run("TicketSystemClose", client, requester, ticketMessage)
    hook.Run("OnTicketClosed", client, requester, ticketMessage)
    requester.CaseClaimed = nil
    MODULE.ActiveTickets[requester:SteamID()] = nil
end)

net.Receive("liaRequestActiveTickets", function(_, client)
    if not (client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty()) then return end
    lia.db.select({"timestamp", "requesterSteamID", "adminSteamID", "message"}, "ticketclaims"):next(function(res)
        local tickets = {}
        for _, row in ipairs(res.results or {}) do
            tickets[#tickets + 1] = {
                requester = row.requesterSteamID,
                timestamp = isnumber(row.timestamp) and row.timestamp or os.time(lia.time.toNumber(row.timestamp)),
                admin = row.adminSteamID,
                message = row.message,
            }
        end

        net.Start("liaActiveTickets")
        net.WriteTable(tickets)
        net.Send(client)
    end)
end)

net.Receive("liaRequestTicketsCount", function(_, client)
    if not (client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty()) then return end
    lia.db.count("ticketclaims"):next(function(count)
        net.Start("liaTicketsCount")
        net.WriteInt(count or 0, 32)
        net.Send(client)
    end)
end)
