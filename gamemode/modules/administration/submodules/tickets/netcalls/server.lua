local MODULE = MODULE


net.Receive("liaTicketSystemClaim", function(_, client)
    local requester = net.ReadEntity()
    if client == requester then
        client:notifyError(string.format("You cannot perform this action on your own ticket."))
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

        lia.db.insertTable({
            timestamp = os.time(),
            requester = requester:Nick(),
            requesterSteamID = requester:SteamID(),
            admin = client:Nick(),
            adminSteamID = client:SteamID(),
            message = ticketMessage
        }, nil, "ticketclaims")

        hook.Run("TicketSystemClaim", client, requester, ticketMessage)
        hook.Run("OnTicketClaimed", client, requester, ticketMessage)
        requester.CaseClaimed = client
    end
end)

net.Receive("liaTicketSystemClose", function(_, client)
    local requester = net.ReadEntity()
    if client == requester then
        client:notifyError(string.format("You cannot perform this action on your own ticket."))
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


