---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:isSuitableForTrunk(entity)
    if IsValid(entity) and entity:IsVehicle() then return true end
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:InitializeStorage(entity)
    if MODULE.Vehicles[entity] then return end
    MODULE.Vehicles[entity] = true
    if SERVER then
        entity.receivers = {}
        lia.inventory.instance(MODULE.VehicleTrunk.invType, MODULE.VehicleTrunk.invData):next(function(inv)
            inv.isStorage = true
            entity:setNetVar("inv", inv:getID())
            hook.Run("StorageInventorySet", self, inv, true)
        end)
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
