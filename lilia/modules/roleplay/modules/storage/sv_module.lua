--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaStorageOpen")
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaStorageExit")
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaStorageUnlock")
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaStorageTransfer")
--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnedProp(client, model, entity)
	local data = lia.config.StorageDefinitions[model:lower()]
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
				self:saveStorage()
				if isfunction(data.onSpawn) then
					data.onSpawn(storage)
				end
			end
		end,
		function(err)
			ErrorNoHalt("Unable to create storage entity for " .. client:Name() .. "\n" .. err .. "\n")
			if IsValid(storage) then
				storage:Remove()
			end
		end
	)

	entity:Remove()
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerSpawnStorage(client, entity, info)
	if not info.invType or not lia.inventory.types[info.invType] then return false end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanSaveStorage(entity, inventory)
	return lia.config.SaveStorage
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:saveStorage()
	local data = {}
	for _, entity in ipairs(ents.FindByClass("lia_storage")) do
		if hook.Run("CanSaveStorage", entity, entity:getInv()) == false then
			entity.liaForceDelete = true
			continue
		end

		if entity:getInv() then
			data[#data + 1] = {entity:GetPos(), entity:GetAngles(), entity:getNetVar("id"), entity:GetModel():lower(), entity.password}
		end
	end

	self:setData(data)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:StorageItemRemoved(entity, inventory)
	self:saveStorage()
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:LoadData()
	local data = self:getData()
	if not data then return end
	for _, info in ipairs(data) do
		local position, angles, invID, model, password = unpack(info)
		local storage = lia.config.StorageDefinitions[model]
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
					timer.Simple(
						1,
						function()
							if IsValid(storage) then
								storage:Remove()
							end
						end
					)
				end
			end
		)

		local physObject = storage:GetPhysicsObject()
		if physObject then
			physObject:EnableMotion()
		end
	end

	self.loadedData = true
end

--------------------------------------------------------------------------------------------------------------------------
local PROHIBITED_ACTIONS = {
	["Equip"] = true,
	["EquipUn"] = true,
}

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerInteractItem(client, action, itemObject, data)
	local inventory = lia.inventory.instances[itemObject.invID]
	if inventory and inventory.isStorage == true then
		if PROHIBITED_ACTIONS[action] then return false, "forbiddenActionStorage" end
	end
end

--------------------------------------------------------------------------------------------------------------------------
local RULES = {
	AccessIfStorageReceiver = function(inventory, action, context)
		local client = context.client
		if not IsValid(client) then return end
		local storage = context.storage or client.liaStorageEntity
		if not IsValid(storage) then return end
		if storage:getInv() ~= inventory then return end
		local distance = storage:GetPos():Distance(client:GetPos())
		if distance > 128 then return false end
		if storage.receivers[client] then return true end
	end
}

--------------------------------------------------------------------------------------------------------------------------
function MODULE:StorageInventorySet(storage, inventory)
	inventory:addAccessRule(RULES.AccessIfStorageReceiver)
end

return RULES
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------