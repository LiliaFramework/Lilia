function MODULE:TicketSystemClaim(admin, requester)
    local caseclaims = lia.data.get("caseclaims", {}, true)
    caseclaims[admin:SteamID()] = caseclaims[admin:SteamID()] or {
        name = admin:Nick(),
        claims = 0,
        lastclaim = os.time(),
        claimedFor = {}
    }

    caseclaims[admin:SteamID()].claims = caseclaims[admin:SteamID()].claims + 1
    caseclaims[admin:SteamID()].lastclaim = os.time()
    caseclaims[admin:SteamID()].claimedFor[requester:SteamID()] = requester:Nick()
    lia.data.set("caseclaims", caseclaims, true)
end

function MODULE:PlayerSay(client, text)
    if string.sub(text, 1, 2) == "@ " then
        text = string.sub(text, 2)
        net.Start("TicketClientNotify")
        net.WriteString(text)
        net.Send(client)
        self:SendPopup(client, text)
        return ""
    end
end

function MODULE:PlayerDisconnected(client)
    for _, v in player.Iterator() do
        if v:hasPrivilege("Staff Permissions - Always See Tickets") or v:isStaffOnDuty() then
            net.Start("TicketSystemClose")
            net.WriteEntity(client)
            net.Send(v)
        end
    end
end

function MODULE:SendPopup(noob, message)
    for _, v in player.Iterator() do
        if v:hasPrivilege("Staff Permissions - Always See Tickets") or v:isStaffOnDuty() then
            net.Start("TicketSystem")
            net.WriteEntity(noob)
            net.WriteString(message)
            net.WriteEntity(noob.CaseClaimed)
            net.Send(v)
        end
    end

    if IsValid(noob) and noob:IsPlayer() then
        timer.Remove("ticketsystem-" .. noob:SteamID64())
        timer.Create("ticketsystem-" .. noob:SteamID64(), 60, 1, function() if IsValid(noob) and noob:IsPlayer() then noob.CaseClaimed = nil end end)
    end
end
