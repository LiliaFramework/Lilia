local MODULE = MODULE
function MODULE:PostPlayerLoadout(client)
    if client:HasPrivilege("Staff Permissions - Use Admin Stick") or client:isStaffOnDuty() then client:Give("adminstick") end
end

function MODULE:InitializedModules()
    if not file.Exists("caseclaims.txt", "DATA") then file.Write("caseclaims.txt", "[]") end
    MsgC(Color(255, 0, 0), "WE DO NOT RECOMMEND THE USE OF ULX AS IT MAY CREATE PERFOMANCE ISSUES!" .. "\n")
end

function MODULE:TicketSystemClaim(admin)
    local caseclaims = util.JSONToTable(file.Read("caseclaims.txt", "DATA"))
    caseclaims[admin:SteamID()] = caseclaims[admin:SteamID()] or {
        name = admin:Nick(),
        claims = 0,
        lastclaim = os.time()
    }

    caseclaims[admin:SteamID()] = {
        name = admin:Nick(),
        claims = caseclaims[admin:SteamID()].claims + 1,
        lastclaim = os.time()
    }

    file.Write("caseclaims.txt", util.TableToJSON(caseclaims))
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
    for _, v in pairs(player.GetAll()) do
        if self:HasAccess(client) then
            net.Start("TicketSystemClose")
            net.WriteEntity(client)
            net.Send(v)
        end
    end
end

function MODULE:SendPopup(noob, message)
    if self.CaseUpdateOnly then
        if noob.CaseClaimed then
            if noob.CaseClaimed:IsValid() and noob.CaseClaimed:IsPlayer() then
                net.Start("TicketSystem")
                net.WriteEntity(noob)
                net.WriteString(message)
                net.WriteEntity(noob.CaseClaimed)
                net.Send(noob.CaseClaimed)
            end
        else
            for _, v in pairs(player.GetAll()) do
                if self:HasAccess(v) then
                    net.Start("TicketSystem")
                    net.WriteEntity(noob)
                    net.WriteString(message)
                    net.WriteEntity(noob.CaseClaimed)
                    net.Send(v)
                end
            end
        end
    else
        for _, v in pairs(player.GetAll()) do
            if self:HasAccess(v) then
                net.Start("TicketSystem")
                net.WriteEntity(noob)
                net.WriteString(message)
                net.WriteEntity(noob.CaseClaimed)
                net.Send(v)
            end
        end
    end

    if noob:IsValid() and noob:IsPlayer() then
        timer.Remove("ticketsystem-" .. noob:SteamID64())
        timer.Create("ticketsystem-" .. noob:SteamID64(), self.Autoclose, 1, function() if noob:IsValid() and noob:IsPlayer() then noob.CaseClaimed = nil end end)
    end
end

lia.log.addType("ticketOpen", function(client) return string.format("%s opened a ticket.", client:Name()) end, "Tickets", Color(255, 0, 0), "Tickets")
lia.log.addType("ticketTook", function(client) return string.format("%s took a ticket.", client:Name()) end, "RT  Tickets", Color(255, 0, 0), "Tickets")
lia.log.addType("ticketClosed", function(client) return string.format("%s closed a ticket.", client:Name()) end, "Tickets", Color(255, 0, 0), "Tickets")
hook.Remove("PlayerSay", "ULXMeCheck")
lia.command.add("viewclaims", {
    description = "View the claims for all admins.",
    adminOnly = true,
    onRun = function(client, arguments)
        if not file.Exists("caseclaims.txt", "DATA") then
            client:ChatPrint("No claims have been recorded yet.")
            return
        end

        local caseclaims = util.JSONToTable(file.Read("caseclaims.txt", "DATA"))
        local claimsData = {}
        for steamID, claim in pairs(caseclaims) do
            table.insert(claimsData, {
                steamID = steamID,
                name = claim.name,
                claims = claim.claims,
                lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim)
            })
        end

        lia.util.CreateTableUI(client, "Admin Claims", {
            {
                name = "SteamID",
                field = "steamID",
                width = 200
            },
            {
                name = "Admin Name",
                field = "name",
                width = 150
            },
            {
                name = "Total Claims",
                field = "claims",
                width = 100
            },
            {
                name = "Last Claim Date",
                field = "lastclaim",
                width = 200
            }
        }, claimsData)
    end
})