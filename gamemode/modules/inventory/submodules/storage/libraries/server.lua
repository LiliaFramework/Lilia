﻿local RULES = {
    AccessIfStorageReceiver = function(inventory, _, context)
        local client = context.client
        if not IsValid(client) then return end
        local storage = context.storage or client.liaStorageEntity
        if not IsValid(storage) then return end
        if storage:getInv() ~= inventory then return end
        local distance = storage:GetPos():Distance(client:GetPos())
        if distance > 128 then return false end
        if storage.receivers[client] then return true end
    end,
    AccessIfCarStorageReceiver = function(_, _, context)
        local client = context.client
        if not IsValid(client) then return end
        local storage = context.storage or client.liaStorageEntity
        if not IsValid(storage) then return end
        local distance = storage:GetPos():Distance(client:GetPos())
        if distance > 128 then return false end
        if storage.receivers[client] then return true end
    end
}

function MODULE:PlayerSpawnedProp(client, model, entity)
    local data = self.StorageDefinitions[model:lower()]
    if not data then return end
    if hook.Run("CanPlayerSpawnStorage", client, entity, data) == false then return end
    local storage = ents.Create("lia_storage")
    storage:SetPos(entity:GetPos())
    storage:SetAngles(entity:GetAngles())
    storage:Spawn()
    storage:SetModel(model)
    storage:SetSolid(SOLID_VPHYSICS)
    storage:PhysicsInit(SOLID_VPHYSICS)
    lia.inventory.instance(data.invType, data.invData):next(function(inventory)
        if IsValid(storage) then
            inventory.isStorage = true
            storage:setInventory(inventory)
            self:SaveData()
            if isfunction(data.OnSpawn) then data.OnSpawn(storage) end
        end
    end, function(err)
        lia.error("Unable to create storage entity for " .. client:Name() .. "\n" .. err .. "\n")
        if IsValid(storage) then SafeRemoveEntity(storage) end
    end)

    SafeRemoveEntity(entity)
end

function MODULE:CanPlayerSpawnStorage(client, _, info)
    if not client then return true end
    if not client:hasPrivilege("Staff Permissions - Can Spawn Storage") then return false end
    if not info.invType or not lia.inventory.types[info.invType] then return false end
end

function MODULE:CanSaveData()
    return self.SaveData
end

function MODULE:StorageItemRemoved()
    self:SaveData()
end

local PROHIBITED_ACTIONS = {
    ["Equip"] = true,
    ["EquipUn"] = true,
}

function MODULE:CanPlayerInteractItem(_, action, itemObject)
    local inventory = lia.inventory.instances[itemObject.invID]
    if inventory and inventory.isStorage and PROHIBITED_ACTIONS[action] then return false, "forbiddenActionStorage" end
end

function MODULE:EntityRemoved(entity)
    self.Vehicles[entity] = nil
    if not self:isSuitableForTrunk(entity) then return end
    local storageInv = lia.inventory.instances[entity:getNetVar("inv")]
    if storageInv then storageInv:delete() end
end

function MODULE:OnEntityCreated(entity)
    if not self:isSuitableForTrunk(entity) then return end
    if entity:isSimfphysCar() then
        net.Start("trunkInitStorage")
        net.WriteBool(false)
        net.WriteEntity(entity)
        net.Broadcast()
    end

    self:InitializeStorage(entity)
end

function MODULE:PlayerInitialSpawn(client)
    net.Start("trunkInitStorage")
    net.WriteBool(true)
    net.WriteTable(self.Vehicles)
    net.Send(client)
end

function MODULE:StorageInventorySet(_, inventory, isCar)
    inventory:addAccessRule(isCar and RULES.AccessIfCarStorageReceiver or RULES.AccessIfStorageReceiver)
end

function MODULE:GetEntitySaveData(ent)
    if ent:GetClass() ~= "lia_storage" then return end
    return {
        id = ent:getNetVar("id"),
        password = ent.password
    }
end

function MODULE:OnEntityLoaded(ent, data)
    if ent:GetClass() ~= "lia_storage" or not data then return end
    if data.password then
        ent.password = data.password
        ent:setNetVar("locked", true)
    end

    local invID = data.id
    if invID then
        lia.inventory.loadByID(invID):next(function(inventory)
            if inventory and IsValid(ent) then
                inventory.isStorage = true
                ent:setInventory(inventory)
                hook.Run("StorageRestored", ent, inventory)
            elseif IsValid(ent) then
                SafeRemoveEntityDelayed(ent, 1)
            end
        end)
    end
end
return RULES
