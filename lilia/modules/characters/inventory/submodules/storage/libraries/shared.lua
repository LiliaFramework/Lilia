---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:isSuitableForTrunk(entity)
    if IsValid(entity) and entity:IsVehicle() then return true end
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:InitializeStorage(entity)
    if self.Vehicles[entity] then return end
    self.Vehicles[entity] = true
    if SERVER then
        entity.receivers = {}
        lia.inventory.instance(self.VehicleTrunk.invType, self.VehicleTrunk.invData):next(function(inv)
            inv.isStorage = true
            entity:setNetVar("inv", inv:getID())
            hook.Run("StorageInventorySet", self, inv, true)
        end)
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
