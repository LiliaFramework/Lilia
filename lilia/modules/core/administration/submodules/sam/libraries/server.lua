local MODULE = MODULE
util.AddNetworkString("NetTicket")
util.AddNetworkString("TicketSync")
util.AddNetworkString("UpdateTicketStatus")
local playerMeta = FindMetaTable("Player")
MODULE.Active = {}
function MODULE:InitializedModules()
    sam.config.set("Restrictions.Tool", false)
    sam.config.set("Restrictions.Spawning", false)
end

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

net.Receive("TicketSync", function()
    MODULE.Active = net.ReadTable()
    net.Start("TicketSync")
    net.WriteTable(MODULE.Active)
    net.Broadcast()
end)

function MODULE:NewTicket(ply, msg)
    net.Start("NetTicket")
    net.WriteEntity(ply)
    net.WriteString(msg)
    net.WriteInt(#MODULE.Active + 1, 8)
    net.Broadcast()
    MODULE.Active[ply] = {
        active = true,
        claimer = nil
    }

    net.Start("TicketSync")
    net.WriteTable(MODULE.Active)
    net.Broadcast()
end

lia.command.add("ticket", {
    adminOnly = false,
    onRun = function(client)
        client:requestString("Enter Ticket Details", "Please provide a brief description for your ticket.", function(text)
            MODULE:NewTicket(client, text)
            lia.log.add(client, "ticketOpen")
        end)
    end
})

net.Receive("UpdateTicketStatus", function(_, client)
    local ticketState = net.ReadBool()
    if ticketState then
        hook.Run("OnTicketTaken", client)
        lia.log.add(client, "ticketTook")
    else
        hook.Run("OnTicketClosed", client)
        lia.log.add(client, "ticketClosed")
    end
end)

lia.log.addType("ticketOpen", function(client) return string.format("%s opened a ticket.", client:Name()) end, "Tickets", Color(255, 0, 0), "Tickets")
lia.log.addType("ticketTook", function(client) return string.format("%s took a ticket.", client:Name()) end, "RT  Tickets", Color(255, 0, 0), "Tickets")
lia.log.addType("ticketClosed", function(client) return string.format("%s closed a ticket.", client:Name()) end, "Tickets", Color(255, 0, 0), "Tickets")