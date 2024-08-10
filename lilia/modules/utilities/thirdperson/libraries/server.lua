function MODULE:PlayerDeath(client)
    if not client:getChar() then return end
    net.Start("Reset3rdPersonStatus")
    net.Send(client)
end

util.AddNetworkString("Reset3rdPersonStatus")