---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
util.AddNetworkString("AFKWarning")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
util.AddNetworkString("AFKAnnounce")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function AFKKickerCore:WarnPlayer(client)
    net.Start("AFKWarning")
    net.WriteBool(true)
    net.Send(client)
    client.HasWarning = true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function AFKKickerCore:RemoveWarning(client)
    net.Start("AFKWarning")
    net.WriteBool(false)
    net.Send(client)
    client.HasWarning = false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function AFKKickerCore:CharKick(client)
    net.Start("AFKAnnounce")
    net.WriteString(client:Nick())
    net.Broadcast()
    self:ResetAFKTime(client)
    timer.Simple(1 + (client:Ping() / 1000), function() client:getChar():kick() end)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function AFKKickerCore:ResetAFKTime(client)
    client.AFKTime = 0
    if client.HasWarning then self:RemoveWarning(client) end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function AFKKickerCore:PlayerButtonUp(client)
    self:ResetAFKTime(client)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function AFKKickerCore:PlayerButtonDown(client)
    self:ResetAFKTime(client)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
timer.Create("AFKTimer", AFKKickerCore.TimerInterval, 0, function()
    local clientCount = player.GetCount()
    local maxPlayers = game.MaxPlayers()
    for _, client in ipairs(player.GetAll()) do
        if not client:getChar() and clientCount < maxPlayers then continue end
        if table.HasValue(AFKKickerCore.AFKAllowedPlayers, client:SteamID64()) or client:IsBot() then continue end
        client.AFKTime = (client.AFKTime or 0) + AFKKickerCore.TimerInterval
        if client.AFKTime >= AFKKickerCore.WarningTime and not client.HasWarning then AFKKickerCore:WarnPlayer(client) end
        if client.AFKTime >= AFKKickerCore.WarningTime + AFKKickerCore.KickTime then
            if clientCount >= maxPlayers then
                client:Kick(AFKKickerCore.KickMessage)
            elseif client:getChar() then
                AFKKickerCore:CharKick(client)
            end
        end
    end
end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
