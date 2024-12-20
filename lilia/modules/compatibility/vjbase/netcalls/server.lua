local function ExploitableNet(client, netName)
    if not IsValid(client) or not client:IsPlayer() then return end
    client:chatNotify("Unauthorized use of net message: " .. netName)
    lia.log.add(client, "unprotectedVJNetCall", {
        netMessage = netName
    })
end

for _, netName in ipairs(exploitableNets) do
    net.Receive(netName, function(_, client) ExploitableNet(client, netName) end)
end