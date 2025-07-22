local function buildClaimTable(rows)
    local caseclaims = {}
    for _, row in ipairs(rows or {}) do
        local adminID = row._admin
        caseclaims[adminID] = caseclaims[adminID] or {
            name = adminID,
            claims = 0,
            lastclaim = 0,
            claimedFor = {}
        }

        local info = caseclaims[adminID]
        info.claims = info.claims + 1
        if row._timestamp > info.lastclaim then info.lastclaim = row._timestamp end
        local reqPly = player.GetBySteamID64(row._request)
        info.claimedFor[row._request] = IsValid(reqPly) and reqPly:Nick() or row._request
    end

    for adminID, info in pairs(caseclaims) do
        local ply = player.GetBySteamID64(adminID)
        if IsValid(ply) then info.name = ply:Nick() end
    end
    return caseclaims
end

function MODULE:GetAllCaseClaims()
    return lia.db.select({"_request", "_admin", "_timestamp"}, "ticketclaims"):next(function(res) return buildClaimTable(res.results) end)
end

function MODULE:TicketSystemClaim(admin, requester)
    lia.db.insertTable({
        _request = requester:SteamID64(),
        _admin = admin:SteamID64(),
        _timestamp = os.time()
    }, nil, "ticketclaims")
end

function MODULE:PlayerSay(client, text)
    if string.sub(text, 1, 1) == "@" then
        text = string.sub(text, 2)
        ClientAddText(client, Color(70, 0, 130), L("ticketMessageYou"), Color(151, 211, 255), " " .. L("ticketMessageToAdmins") .. " ", Color(0, 255, 0), text)
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
