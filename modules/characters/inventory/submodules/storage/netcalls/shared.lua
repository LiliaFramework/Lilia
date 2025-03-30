local MODULE = MODULE
net.Receive("trunkInitStorage", function()
    local isTable = net.ReadBool()
    if isTable then
        local vehicles = net.ReadTable()
        for _, vehicle in pairs(vehicles) do
            MODULE:InitializeStorage(vehicle)
        end
    else
        local entity = net.ReadEntity()
        MODULE:InitializeStorage(entity)
    end
end)