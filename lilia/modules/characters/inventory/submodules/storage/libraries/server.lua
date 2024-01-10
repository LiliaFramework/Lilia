local RULES = {
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

function LiliaStorage:PlayerSpawnedProp(client, model, entity)
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
    lia.inventory.instance(data.invType, data.invData):next(
        function(inventory)
            if IsValid(storage) then
                inventory.isStorage = true
                storage:setInventory(inventory)
                self:SaveData()
                if isfunction(data.onSpawn) then data.onSpawn(storage) end
            end
        end,
        function(err)
            ErrorNoHalt("Unable to create storage entity for " .. client:Name() .. "\n" .. err .. "\n")
            if IsValid(storage) then storage:Remove() end
        end
    )

    entity:Remove()
end

function LiliaStorage:CanPlayerSpawnStorage(client, _, info)
    if not CAMI.PlayerHasAccess(client, "Staff Permissions - Can Spawn Storage", nil) then return false end
    if not info.invType or not lia.inventory.types[info.invType] then return false end
end

function LiliaStorage:CanSaveData(_, _)
    return self.SaveData
end

function LiliaStorage:SaveData()
    local data = {}
    for _, entity in ipairs(ents.FindByClass("lia_storage")) do
        if hook.Run("CanSaveData", entity, entity:getInv()) == false then
            entity.liaForceDelete = true
            continue
        end

        if entity:getInv() then data[#data + 1] = {entity:GetPos(), entity:GetAngles(), entity:getNetVar("id"), entity:GetModel():lower(), entity.password} end
    end

    self:setData(data)
end

function LiliaStorage:StorageItemRemoved(_, _)
    self:SaveData()
end

function LiliaStorage:LoadData()
    local data = self:getData()
    if not data then return end
    for _, info in ipairs(data) do
        local position, angles, invID, model, password = unpack(info)
        local storage = self.StorageDefinitions[model]
        if not storage then continue end
        local storage = ents.Create("lia_storage")
        storage:SetPos(position)
        storage:SetAngles(angles)
        storage:Spawn()
        storage:SetModel(model)
        storage:SetSolid(SOLID_VPHYSICS)
        storage:PhysicsInit(SOLID_VPHYSICS)
        if password then
            storage.password = password
            storage:setNetVar("locked", true)
        end

        lia.inventory.loadByID(invID):next(
            function(inventory)
                if inventory and IsValid(storage) then
                    inventory.isStorage = true
                    storage:setInventory(inventory)
                    hook.Run("StorageRestored", storage, inventory)
                elseif IsValid(storage) then
                    timer.Simple(1, function() if IsValid(storage) then storage:Remove() end end)
                end
            end
        )

        local physObject = storage:GetPhysicsObject()
        if physObject then physObject:EnableMotion() end
    end

    self.loadedData = true
end

local PROHIBITED_ACTIONS = {
    ["Equip"] = true,
    ["EquipUn"] = true,
}

function LiliaStorage:CanPlayerInteractItem(_, action, itemObject, _)
    local inventory = lia.inventory.instances[itemObject.invID]
    if inventory and inventory.isStorage == true and PROHIBITED_ACTIONS[action] then return false, "forbiddenActionStorage" end
end

function LiliaStorage:EntityRemoved(ent)
    LiliaStorage.Vehicles[ent] = nil
    if not LiliaStorage:isSuitableForTrunk(ent) then return end
    local storageInv = lia.inventory.instances[ent:getNetVar("inv")]
    if storageInv then storageInv:delete() end
end

function LiliaStorage:OnEntityCreated(ent)
    if not LiliaStorage:isSuitableForTrunk(ent) then return end
    if ent.IsSimfphyscar then netstream.Start(nil, "trunkInitStorage", ent) end
    self:InitializeStorage(ent)
end

function LiliaStorage:PlayerInitialSpawn(client)
    netstream.Start(client, "trunkInitStorage", LiliaStorage.Vehicles)
end

function LiliaStorage:StorageInventorySet(_, inventory, isCar)
    if isCar then
        inventory:addAccessRule(RULES.AccessIfCarStorageReceiver)
    else
        inventory:addAccessRule(RULES.AccessIfStorageReceiver)
    end
end
return RULES
