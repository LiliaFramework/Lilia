local MODULE = MODULE

net.Receive("liaTicketSystem", function()
    local pl = net.ReadEntity()
    local msg = net.ReadString()
    local claimed = net.ReadEntity()
    local client = LocalPlayer()
    local permission = IsValid(client) and (client:isStaffOnDuty() or client:hasPrivilege("alwaysSeeTickets")) or false
    if permission then MODULE:CreateTicketFrame(pl, msg, claimed) end
end)

net.Receive("liaTicketSystemClaim", function()
    local pl = net.ReadEntity()
    local requester = net.ReadEntity()
    MODULE.TicketFrames = MODULE.TicketFrames or {}
    local requesterSteamID = IsValid(requester) and requester:SteamID() or nil
    for _, v in pairs(MODULE.TicketFrames) do
        if v.requesterSteamID == requesterSteamID then
            v:SetTitle(requester:Nick() .. " - " .. "Claimed by" .. " " .. pl:Nick())
            local bu = v:GetChildren()[11]
            if not bu or not IsValid(bu) then return end
            bu.DoClick = function()
                if LocalPlayer() == pl then
                    net.Start("liaTicketSystemClose")
                    net.WriteEntity(requester)
                    net.SendToServer()
                else
                    v:Close()
                end
            end
        end
    end
end)

net.Receive("liaTicketSystemClose", function()
    local requester = net.ReadEntity()
    if not IsValid(requester) or not requester:IsPlayer() then return end
    MODULE.TicketFrames = MODULE.TicketFrames or {}
    local requesterSteamID = requester:SteamID()
    for _, v in pairs(MODULE.TicketFrames) do
        if v.requesterSteamID == requesterSteamID then v:Remove() end
    end
end)

net.Receive("liaClearAllTicketFrames", function()
    MODULE.TicketFrames = MODULE.TicketFrames or {}
    for _, v in pairs(MODULE.TicketFrames) do
        if IsValid(v) then v:Remove() end
    end

    table.Empty(MODULE.TicketFrames)
end)
