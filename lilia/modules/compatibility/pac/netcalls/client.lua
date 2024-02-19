---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
PACCompatibility = PACCompatibility or {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("liaPACSync", function()
    for _, client in ipairs(player.GetAll()) do
        for id in pairs(client:getParts()) do
            PACCompatibility:attachPart(client, id)
        end
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("liaPACPartAdd", function()
    local client = net.ReadEntity()
    local id = net.ReadString()
    if not IsValid(client) then return end
    PACCompatibility:attachPart(client, id)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("liaPACPartRemove", function()
    local client = net.ReadEntity()
    local id = net.ReadString()
    if not IsValid(client) then return end
    PACCompatibility:removePart(client, id)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("liaPACPartReset", function()
    local client = net.ReadEntity()
    if not IsValid(client) or not client.RemovePACPart then return end
    if client.liaPACParts then
        for _, part in pairs(client.liaPACParts) do
            client:RemovePACPart(part)
        end

        client.liaPACParts = nil
    end
end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
