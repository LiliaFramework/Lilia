local MODULE = MODULE
MODULE.ActiveTickets = MODULE.ActiveTickets or {}
local function buildClaimTable(rows)
    local caseclaims = {}
    for _, row in ipairs(rows or {}) do
        local adminID = row.adminSteamID
        caseclaims[adminID] = caseclaims[adminID] or {
            name = row.admin,
            claims = 0,
            lastclaim = 0,
            claimedFor = {}
        }

        local info = caseclaims[adminID]
        info.claims = info.claims + 1
        local rowTime = isnumber(row.timestamp) and row.timestamp or os.time(lia.time.toNumber(row.timestamp))
        if rowTime > info.lastclaim then info.lastclaim = rowTime end
        local reqPly = lia.util.getBySteamID(row.requesterSteamID)
        info.claimedFor[row.requesterSteamID] = IsValid(reqPly) and reqPly:Nick() or row.requester
    end

    for adminID, info in pairs(caseclaims) do
        local ply = lia.util.getBySteamID(adminID)
        if IsValid(ply) then info.name = ply:Nick() end
    end
    return caseclaims
end

function MODULE:GetAllCaseClaims()
    return lia.db.select({"timestamp", "requester", "requesterSteamID", "admin", "adminSteamID", "message"}, "ticketclaims"):next(function(res) return buildClaimTable(res.results) end)
end

function MODULE:GetTicketsByRequester(steamID)
    local condition = "requesterSteamID = " .. lia.db.convertDataType(steamID)
    return lia.db.select({"timestamp", "requester", "requesterSteamID", "admin", "adminSteamID", "message"}, "ticketclaims", condition):next(function(res)
        local tickets = {}
        for _, row in ipairs(res.results or {}) do
            tickets[#tickets + 1] = {
                timestamp = isnumber(row.timestamp) and row.timestamp or os.time(lia.time.toNumber(row.timestamp)),
                requester = row.requester,
                requesterSteamID = row.requesterSteamID,
                admin = row.admin,
                adminSteamID = row.adminSteamID,
                message = row.message
            }
        end
        return tickets
    end)
end

function MODULE:TicketSystemClaim(admin, requester)
    local ticket = MODULE.ActiveTickets[requester:SteamID()]
    lia.db.insertTable({
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        requester = requester:Nick(),
        requesterSteamID = requester:SteamID(),
        admin = admin:Nick(),
        adminSteamID = admin:SteamID(),
        message = ticket and ticket.message or ""
    }, nil, "ticketclaims")
end

function MODULE:PlayerSay(client, text)
    if string.sub(text, 1, 1) == "@" then
        text = string.sub(text, 2)
        ClientAddText(client, Color(70, 0, 130), L("you"), Color(151, 211, 255), " " .. L("ticketMessageToAdmins") .. ": ", Color(0, 255, 0), text)
        self:SendPopup(client, text)
        return ""
    end
end

function MODULE:PlayerDisconnected(client)
    for _, v in player.Iterator() do
        if v:hasPrivilege("alwaysSeeTickets") or v:isStaffOnDuty() then
            net.Start("TicketSystemClose")
            net.WriteEntity(client)
            net.Send(v)
        end
    end

    MODULE.ActiveTickets[client:SteamID()] = nil
end

function MODULE:SendPopup(noob, message)
    for _, v in player.Iterator() do
        if v:hasPrivilege("alwaysSeeTickets") or v:isStaffOnDuty() then
            net.Start("TicketSystem")
            net.WriteEntity(noob)
            net.WriteString(message)
            net.WriteEntity(noob.CaseClaimed)
            net.Send(v)
        end
    end

    if IsValid(noob) and noob:IsPlayer() then
        MODULE.ActiveTickets[noob:SteamID()] = {
            timestamp = os.time(),
            requester = noob:SteamID(),
            admin = noob.CaseClaimed and IsValid(noob.CaseClaimed) and noob.CaseClaimed:SteamID() or nil,
            message = message
        }

        timer.Remove("ticketsystem-" .. noob:SteamID())
        timer.Create("ticketsystem-" .. noob:SteamID(), 60, 1, function()
            if IsValid(noob) and noob:IsPlayer() then noob.CaseClaimed = nil end
            MODULE.ActiveTickets[noob:SteamID()] = nil
        end)
    end
end