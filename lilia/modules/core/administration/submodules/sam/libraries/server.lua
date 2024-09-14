local MODULE = MODULE

local playerMeta = FindMetaTable("Player")

function MODULE:PlayerInitialSpawn(client)
    local StaffRank = self.DefaultStaff[client:SteamID64()]
    if StaffRank then
        RunConsoleCommand("sam", "setrank", client:SteamID(), StaffRank)
        print(client:Name() .. " has been set as rank: " .. StaffRank)
    end
end

function MODULE:PlayerSpawnProp(client)
    if not playerMeta.GetLimit then return end
    local limit = client:GetLimit("props")
    if limit < 0 then return end
    local props = client:GetCount("props") + 1
    if client:getLiliaData("extraProps") then
        if props > (limit + 50) then
            client:LimitHit("props")
            return false
        end
    else
        if props > limit then
            client:LimitHit("props")
            return false
        end
    end
end

function MODULE:PlayerCheckLimit(client, name)
    if not playerMeta.GetLimit then return end
    if name == "props" then
        if client:isStaffOnDuty() then return true end
        if client:GetLimit("props") < 0 then return end
        if client:getLiliaData("extraProps") then
            local limit = client:GetLimit("props") + 50
            local props = client:GetCount("props")
            if props <= limit + 50 then return true end
        end
    end
end

function MODULE:PlayerSpawnRagdoll(client)
    if not playerMeta.GetLimit then return end
    local limit = client:GetLimit("ragdolls")
    if limit < 0 then return end
    local ragdolls = client:GetCount("ragdolls") + 1
    if ragdolls > limit then
        client:LimitHit("ragdolls")
        return false
    end
end

function MODULE:InitializedModules()
    if not file.Exists("caseclaims.txt", "DATA") then file.Write("caseclaims.txt", "[]") end
end

function MODULE:PostPlayerLoadout(client)
    if client:HasPrivilege("Staff Permissions - Use Admin Stick") or client:isStaffOnDuty() then client:Give("adminstick") end
end

function MODULE:TicketSystemClaim(admin, requester)
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
    for k, v in pairs(player.GetAll()) do
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
        for k, v in pairs(player.GetAll()) do
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