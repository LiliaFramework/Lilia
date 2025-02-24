util.AddNetworkString("death_client")
util.AddNetworkString("request_respawn")
net.Receive("request_respawn", function(_, client)
    if not IsValid(client) or not client:getChar() then return end
    if not client:Alive() and not client:getNetVar("IsDeadRestricted", false) then client:Spawn() end
end)
