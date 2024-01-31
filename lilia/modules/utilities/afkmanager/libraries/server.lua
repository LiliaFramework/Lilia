---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
util.AddNetworkString("AFKWarning")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
util.AddNetworkString("AFKAnnounce")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:WarnPlayer(client)
    net.Start("AFKWarning")
    net.WriteBool(true)
    net.Send(client)
    client.HasWarning = true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:RemoveWarning(client)
    net.Start("AFKWarning")
    net.WriteBool(false)
    net.Send(client)
    client.HasWarning = false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CharKick(client)
    net.Start("AFKAnnounce")
    net.WriteString(client:Nick())
    net.Broadcast()
    self:ResetAFKTime(client)
    timer.Simple(1 + (client:Ping() / 1000), function() client:getChar():kick() end)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ResetAFKTime(client)
    client.AFKTime = 0
    if client.HasWarning then self:RemoveWarning(client) end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerButtonUp(client)
    self:ResetAFKTime(client)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerButtonDown(client)
    self:ResetAFKTime(client)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
timer.Create("AFKTimer", MODULE.TimerInterval, 0, function()
    local clientCount = player.GetCount()
    local maxPlayers = game.MaxPlayers()
    for _, client in ipairs(player.GetAll()) do
        if not client:getChar() and clientCount < maxPlayers then continue end
        if table.HasValue(MODULE.AFKAllowedPlayers, client:SteamID64()) or client:IsBot() then continue end
        client.AFKTime = (client.AFKTime or 0) + MODULE.TimerInterval
        if client.AFKTime >= MODULE.WarningTime and not client.HasWarning then MODULE:WarnPlayer(client) end
        if client.AFKTime >= MODULE.WarningTime + MODULE.KickTime then
            if clientCount >= maxPlayers then
                client:Kick(MODULE.KickMessage)
            elseif client:getChar() then
                MODULE:CharKick(client)
            end
        end
    end
end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
