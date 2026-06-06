local MODULE = MODULE

net.Receive("liaTrunkInitStorage", function()
    local entity = net.ReadEntity()
    if IsValid(entity) then hook.Run("InitializeStorage", entity) end
end)
