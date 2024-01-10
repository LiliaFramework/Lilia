
function LiliaStorage:isSuitableForTrunk(ent)
    if IsValid(ent) and ent:IsVehicle() then return true end
    return false
end


function LiliaStorage:InitializeStorage(ent)
    if LiliaStorage.Vehicles[ent] then return end
    LiliaStorage.Vehicles[ent] = true
    if SERVER then
        ent.receivers = {}
        lia.inventory.instance(LiliaStorage.VehicleTrunk.invType, LiliaStorage.VehicleTrunk.invData):next(
            function(inv)
                inv.isStorage = true
                ent:setNetVar("inv", inv:getID())
                hook.Run("StorageInventorySet", self, inv, true)
            end
        )
    end
end

