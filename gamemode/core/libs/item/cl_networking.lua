netstream.Hook("item", function(uniqueID, id, data, invID)
	local item = lia.item.new(uniqueID, id)

	item.data = {}
	if (data) then
		item.data = data
	end

	item.invID = invID or 0
	hook.Run("ItemInitialized", item)
end)

netstream.Hook("invData", function(id, key, value)
	local item = lia.item.instances[id]

	if (item) then
		item.data = item.data or {}
		local oldValue = item.data[key]
		item.data[key] = value
		hook.Run("ItemDataChanged", item, key, oldValue, value)
	end
end)

netstream.Hook("invQuantity", function(id, quantity)
	local item = lia.item.instances[id]

	if (item) then
		local oldValue = item:getQuantity()
		item.quantity = quantity

		hook.Run("ItemQuantityChanged", item, oldValue, quantity)
	end
end)

net.Receive("liaItemInstance", function()
	local itemID = net.ReadUInt(32)
	local itemType = net.ReadString()
	local data = net.ReadTable()
	local item = lia.item.new(itemType, itemID)
	local invID = net.ReadType()
	local quantity = net.ReadUInt(32)

	item.data = table.Merge(item.data or {}, data)
	item.invID = invID
	item.quantity = quantity

	lia.item.instances[itemID] = item
	hook.Run("ItemInitialized", item)
end)

net.Receive("liaCharacterInvList", function()
	local charID = net.ReadUInt(32)
	local length = net.ReadUInt(32)
	local inventories = {}

	for i = 1, length do
		inventories[i] = lia.inventory.instances[net.ReadType()]
	end

	local character = lia.char.loaded[charID]
	if (character) then
		character.vars.inv = inventories
	end
end)

net.Receive("liaItemDelete", function()
	local id = net.ReadUInt(32)
	local instance = lia.item.instances[id]
	if (instance and instance.invID) then
		local inventory = lia.inventory.instances[instance.invID]
		if (not inventory or not inventory.items[id]) then return end

		inventory.items[id] = nil
		instance.invID = 0
		hook.Run("InventoryItemRemoved", inventory, instance)
	end

	lia.item.instances[id] = nil
	hook.Run("ItemDeleted", instance)
end)
