util.AddNetworkString("AFKWarning")
util.AddNetworkString("AFKAnnounce")
function AFKKicker:WarnPlayer(client)
    net.Start("AFKWarning")
    net.WriteBool(true)
    net.Send(client)
    client.HasWarning = true
end

function AFKKicker:RemoveWarning(client)
    net.Start("AFKWarning")
    net.WriteBool(false)
    net.Send(client)
    client.HasWarning = false
end

function AFKKicker:CharKick(client)
    net.Start("AFKAnnounce")
    net.WriteString(client:Nick())
    net.Broadcast()
    self:ResetAFKTime(client)
    timer.Simple(1 + (client:Ping() / 1000), function() client:getChar():kick() end)
end

function AFKKicker:ResetAFKTime(client)
    client.AFKTime = 0
    if client.HasWarning then self:RemoveWarning(client) end
end

function AFKKicker:PlayerButtonUp(client)
    self:ResetAFKTime(client)
end

function AFKKicker:PlayerButtonDown(client)
    self:ResetAFKTime(client)
end

timer.Create(
    "AFKTimer",
    AFKKicker.TimerInterval,
    0,
    function()
        local clientCount = player.GetCount()
        local maxPlayers = game.MaxPlayers()
        for _, client in ipairs(player.GetAll()) do
            if not client:getChar() and clientCount < maxPlayers then continue end
            if table.HasValue(AFKKicker.AFKAllowedPlayers, client:SteamID64()) or client:IsBot() then continue end
            client.AFKTime = (client.AFKTime or 0) + AFKKicker.TimerInterval
            if client.AFKTime >= AFKKicker.WarningTime and not client.HasWarning then AFKKicker:WarnPlayer(client) end
            if client.AFKTime >= AFKKicker.WarningTime + AFKKicker.KickTime then
                if clientCount >= maxPlayers then
                    client:Kick(AFKKicker.KickMessage)
                elseif client:getChar() then
                    AFKKicker:CharKick(client)
                end
            end
        end
    end
)
