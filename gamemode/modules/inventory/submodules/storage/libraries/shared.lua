﻿function MODULE:IsSuitableForTrunk(entity)
    if IsValid(entity) and entity:IsVehicle() and entity:getNetVar("hasStorage", false) then return true end
end

function MODULE:InitializeStorage(entity)
    if not IsValid(entity) then
        local d = deferred.new()
        d:reject("Invalid entity")
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

        local def = lia.inventory.storage[key]
        if not def and entity:IsVehicle() then def = lia.inventory.storage["vehicle"] end
        if not def then
            local d = deferred.new()
            d:reject("No storage definition found for " .. key .. (entity:IsVehicle() and " or vehicle" or ""))
            return d
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
        else
            local d = deferred.new()
            d:reject("Storage initialization only available on server")
            return d
        end
    end

    entity.liaStorageInitPromise = tryInitialize()
    return entity.liaStorageInitPromise
end

net.Receive("trunkInitStorage", function()
    local entity = net.ReadEntity()
    if IsValid(entity) then MODULE:InitializeStorage(entity) end
end)
