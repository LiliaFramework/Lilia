---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function LiliaStorage:isSuitableForTrunk(entity)
    if IsValid(entity) and entity:IsVehicle() then return true end
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function LiliaStorage:InitializeStorage(entity)
    if LiliaStorage.Vehicles[entity] then return end
    LiliaStorage.Vehicles[entity] = true
    if SERVER then
        entity.receivers = {}
        lia.inventory.instance(LiliaStorage.VehicleTrunk.invType, LiliaStorage.VehicleTrunk.invData):next(function(inv)
            inv.isStorage = true
            entity:setNetVar("inv", inv:getID())
            hook.Run("StorageInventorySet", self, inv, true)
        end)
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------