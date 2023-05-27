util.AddNetworkString("liaTypeStatus")

net.Receive("liaTypeStatus", function(_, client)
    client:setNetVar("typing", net.ReadBool())
end)