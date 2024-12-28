local MODULE = MODULE
function MODULE:InitializedModules()
    if not file.Exists("caseclaims.txt", "DATA") then file.Write("caseclaims.txt", "[]") end
end

function MODULE:PostPlayerLoadout(client)
    if client:hasPrivilege("Staff Permissions - Use Admin Stick") or client:isStaffOnDuty() then client:Give("adminstick") end
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

function MODULE:HasAccess(client)
    return client:hasPrivilege("Staff Permissions - Always See Tickets") or client:isStaffOnDuty()
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
    for _, v in pairs(player.GetAll()) do
        if self:HasAccess(v) then
            net.Start("TicketSystem")
            net.WriteEntity(noob)
            net.WriteString(message)
            net.WriteEntity(noob.CaseClaimed)
            net.Send(v)
        end
    end

    if IsValid(noob) and noob:IsPlayer() then
        timer.Remove("ticketsystem-" .. noob:SteamID64())
        timer.Create("ticketsystem-" .. noob:SteamID64(), self.Autoclose, 1, function() if IsValid(noob) and noob:IsPlayer() then noob.CaseClaimed = nil end end)
    end
end