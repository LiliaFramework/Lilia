util.AddNetworkString("liaTypeStatus")
net.Receive("liaTypeStatus", function(_, client) client:setNetVar("typing", net.ReadBool()) end)
function MODULE:PlayerSpawn(client)
    client:setNetVar("typing", false)
end
