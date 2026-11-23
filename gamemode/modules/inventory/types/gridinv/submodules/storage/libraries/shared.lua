function MODULE:IsSuitableForTrunk(ent)
    if not IsValid(ent) then return false end
    if ent.isSimfphysCar and ent:isSimfphysCar() then return true end
    if ent:IsVehicle() and ent:getNetVar("hasStorage", false) then return true end
    return false
end

function MODULE:InitializeStorage(entity)
    if not IsValid(entity) then
        local d = deferred.new()
        d:reject("Invalid entity selected.")
        return d
    end

    if not self:IsSuitableForTrunk(entity) then
        local d = deferred.new()
        d:reject("Entity is not suitable for trunk storage.")
        return d
    end

    local existingID = entity:getNetVar("inv")
    if existingID then
        local d = deferred.new()
        d:resolve(lia.inventory.instances[existingID])
        return d
    end

    if entity.liaStorageInitPromise then return entity.liaStorageInitPromise end
    local function tryInitialize()
        local key
        local model = entity:GetModel()
        if entity:IsVehicle() then
            key = entity:GetClass():lower()
        else
            if not model or model == "" then
                key = "models/props_junk/wood_crate001a.mdl"
            else
                key = model:lower()
            end
        end

        local def = lia.inventory.storage and lia.inventory.storage[key]
        if not def and entity:IsVehicle() and lia.inventory.storage then def = lia.inventory.storage["vehicle"] end
        if not def then
            def = {
                name = "Storage Container",
                invType = "GridInv",
                invData = {
                    w = 4,
                    h = 4
                }
            }
        end

        if SERVER then
            entity.receivers = {}
            local d = lia.inventory.instance(def.invType, def.invData):next(function(inv)
                inv.isStorage = true
                entity:setNetVar("inv", inv:getID())
                entity:setNetVar("hasStorage", true)
                hook.Run("StorageInventorySet", self, inv, entity:IsVehicle())
                return inv
            end)
            return d
        end

        local d = deferred.new()
        d:reject("Storage Init Server Only")
        return d
    end

    entity.liaStorageInitPromise = tryInitialize()
    return entity.liaStorageInitPromise
end