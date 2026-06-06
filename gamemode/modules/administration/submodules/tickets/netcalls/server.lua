local MODULE = MODULE

net.Receive("liaViewClaims", function(_, client)
    local sid = net.ReadString()
    MODULE:GetAllCaseClaims():next(function(caseclaims)
        net.Start("liaViewClaims")
        net.WriteTable(caseclaims)
        net.WriteString(sid)
        net.Send(client)
    end)
end)

net.Receive("liaTicketSystemClaim", function(_, client)
    local requester = net.ReadEntity()
    if client == requester then
        client:notifyErrorLocalized("ticketActionSelf")
        return
    end

    local hasAlwaysSeeTickets = client:hasPrivilege("alwaysSeeTickets")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = (hasAlwaysSeeTickets or isStaffOnDuty) and not requester.CaseClaimed
    lia.debug("[Permissions]", "Permission Check for net.Receive liaTicketSystemClaim", "hasPrivilege(alwaysSeeTickets)=", tostring(hasAlwaysSeeTickets), "isStaffOnDuty=", tostring(isStaffOnDuty), "requesterAlreadyClaimed=", tostring(requester.CaseClaimed ~= nil), "finalResult=", tostring(permission))
    if permission then
        for _, v in player.Iterator() do
            local targetHasAlwaysSeeTickets = v:hasPrivilege("alwaysSeeTickets")
            local targetIsStaffOnDuty = v:isStaffOnDuty()
            local targetPermission = targetHasAlwaysSeeTickets or targetIsStaffOnDuty
            lia.debug("[Permissions]", "Permission Check for net.Receive liaTicketSystemClaim broadcast recipient", "targetPlayer=", tostring(v:Name()), "hasPrivilege(alwaysSeeTickets)=", tostring(targetHasAlwaysSeeTickets), "isStaffOnDuty=", tostring(targetIsStaffOnDuty), "finalResult=", tostring(targetPermission))
            if targetPermission then
                net.Start("liaTicketSystemClaim")
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

net.Receive("liaTicketSystemClose", function(_, client)
    local requester = net.ReadEntity()
    if client == requester then
        client:notifyErrorLocalized("ticketActionSelf")
        return
    end

    if not requester or not IsValid(requester) or requester.CaseClaimed ~= client then return end
    if timer.Exists("ticketsystem-" .. requester:SteamID()) then timer.Remove("ticketsystem-" .. requester:SteamID()) end
    for _, v in player.Iterator() do
        local hasAlwaysSeeTickets = v:hasPrivilege("alwaysSeeTickets")
        local isStaffOnDuty = v:isStaffOnDuty()
        local permission = hasAlwaysSeeTickets or isStaffOnDuty
        lia.debug("[Permissions]", "Permission Check for net.Receive liaTicketSystemClose broadcast recipient", "targetPlayer=", tostring(v:Name()), "hasPrivilege(alwaysSeeTickets)=", tostring(hasAlwaysSeeTickets), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
        if permission then
            net.Start("liaTicketSystemClose")
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
    local hasAlwaysSeeTickets = client:hasPrivilege("alwaysSeeTickets")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasAlwaysSeeTickets or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestActiveTickets", "hasPrivilege(alwaysSeeTickets)=", tostring(hasAlwaysSeeTickets), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
    if not permission then return end
    local tickets = {}
    for steamID, ticket in pairs(MODULE.ActiveTickets) do
        tickets[#tickets + 1] = {
            requester = steamID,
            timestamp = ticket.timestamp or os.time(),
            admin = ticket.admin,
            message = ticket.message,
        }
    end

    table.sort(tickets, function(a, b) return (a.timestamp or 0) > (b.timestamp or 0) end)
    net.Start("liaActiveTickets")
    net.WriteTable(tickets)
    net.Send(client)
end)

net.Receive("liaRequestTicketsCount", function(_, client)
    local hasAlwaysSeeTickets = client:hasPrivilege("alwaysSeeTickets")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasAlwaysSeeTickets or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestTicketsCount", "hasPrivilege(alwaysSeeTickets)=", tostring(hasAlwaysSeeTickets), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
    if not permission then return end
    lia.db.count("ticketclaims"):next(function(count)
        net.Start("liaTicketsCount")
        net.WriteInt(count or 0, 32)
        net.Send(client)
    end)
end)
