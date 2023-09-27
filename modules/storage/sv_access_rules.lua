--------------------------------------------------------------------------------------------------------
local PROHIBITED_ACTIONS = {
	["Equip"] = true,
	["EquipUn"] = true,
}

--------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerInteractItem(client, action, itemObject, data)
	local inventory = lia.inventory.instances[itemObject.invID]
	if inventory and inventory.isStorage == true and PROHIBITED_ACTIONS[action] then return false, "forbiddenActionStorage" end
end

--------------------------------------------------------------------------------------------------------
local RULES = {
	AccessIfStorageReceiver = function(inventory, action, context)
		-- Ensure correct storage entity and player.
		local client = context.client
		if not IsValid(client) then return end
		local storage = context.storage or client.liaStorageEntity
		if not IsValid(storage) then return end
		if storage:getInv() ~= inventory then return end
		-- If the player is too far away from storage, then ignore.
		local distance = storage:GetPos():Distance(client:GetPos())
		if distance > 128 then return false end
		-- Allow if the player is a receiver of the storage.
		if storage.receivers[client] then return true end
	end
}

--------------------------------------------------------------------------------------------------------
function MODULE:StorageInventorySet(storage, inventory)
	inventory:addAccessRule(RULES.AccessIfStorageReceiver)
end

return RULES
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------