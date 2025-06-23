function MODULE:TicketSystemClaim(admin, requester)
    local caseclaims = lia.data.get("caseclaims", {}, true)
    if caseclaims[admin:SteamID()] then
        caseclaims[admin:SteamID64()] = caseclaims[admin:SteamID()]
        caseclaims[admin:SteamID()] = nil
    end

    caseclaims[admin:SteamID64()] = caseclaims[admin:SteamID64()] or {
        name = admin:Nick(),
        claims = 0,
        lastclaim = os.time(),
        claimedFor = {}
    }

    caseclaims[admin:SteamID64()].claims = caseclaims[admin:SteamID64()].claims + 1
    caseclaims[admin:SteamID64()].lastclaim = os.time()
    caseclaims[admin:SteamID64()].claimedFor[requester:SteamID64()] = requester:Nick()
    lia.data.set("caseclaims", caseclaims, true)
end

function MODULE:PlayerSay(client, text)
    if string.sub(text, 1, 1) == "@" then
        text = string.sub(text, 2)
        ClientAddText(client, Color(70, 0, 130), "You", Color(151, 211, 255), " to admins: ", Color(0, 255, 0), text)
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
