net.Receive("liaStorageUnlock", function()
    local entity = net.ReadEntity()
    hook.Run("StorageUnlockPrompt", entity)
end)

net.Receive("liaStorageOpen", function()
    local isCar = net.ReadBool() or false
    local entity = net.ReadEntity()
    local carInv = lia.inventory.instances[entity:getNetVar("inv")]
    hook.Run("StorageOpen", isCar and carInv or entity, isCar)
end)