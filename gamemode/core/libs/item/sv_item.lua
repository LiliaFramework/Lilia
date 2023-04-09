function lia.item.instance(index, uniqueID, itemData, x, y, callback)
	-- New overload: lia.item.instance(itemType, itemData = {})
	-- which returns a promise that resolves to the item instance
	if (
		isstring(index) and
		(istable(uniqueID) or (itemData == nil and x == nil))
	) then
		itemData = uniqueID
		uniqueID = index
	end

	local d = deferred.new()
	local itemTable = lia.item.list[uniqueID]
	if (not itemTable) then
		d:reject("Attempt to instantiate invalid item "..tostring(uniqueID))
		return d
	end

	if (not istable(itemData)) then
		itemData = {}
	end

	-- Legacy support for x, y data: have the x, y data save to the correct
	-- x, y column instead of the data column
	if (isnumber(itemData.x)) then
		x = itemData.x
		itemData.x = nil
	end
	if (isnumber(itemData.y)) then
		y = itemData.y
		itemData.y = nil
	end

	local function onItemCreated(data, itemID)
		local item = lia.item.new(uniqueID, itemID)

		if (item) then
			item.data = itemData
			item.invID = index

			-- Legacy support for x, y data: add it back to the data for use
			item.data.x = x
			item.data.y = y
			item.quantity = itemTable.maxQuantity

			if (callback) then
				callback(item)
			end

			d:resolve(item)
			item:onInstanced(index, x, y, item)
		end
	end

	if (not isnumber(index)) then
		index = NULL
	end

	if (MYSQLOO_PREPARED and isnumber(index)) then
		lia.db.preparedCall(
			"itemInstance", onItemCreated, index, uniqueID, itemData, x, y, itemTable.maxQuantity or 1
		)
	else
		lia.db.insertTable({
			_invID = index,
			_uniqueID = uniqueID,
			_data = itemData,
			_x = x,
			_y = y,
			_quantity = itemTable.maxQuantity or 1
		}, onItemCreated, "items")
	end

	return d
end

function lia.item.deleteByID(id)
	if (lia.item.instances[id]) then
		lia.item.instances[id]:delete()
	else
		lia.db.delete("items", "_itemID = "..id)
	end
end

function lia.item.loadItemByID(itemIndex, recipientFilter)
	local range
	if (istable(itemIndex)) then
		range = "("..table.concat(itemIndex, ", ")..")"
	elseif (isnumber(itemIndex)) then
		range = "(".. itemIndex ..")"
	else
		return
	end

	lia.db.query("SELECT _itemID, _uniqueID, _data, _x, _y, _quantity FROM lia_items WHERE _itemID IN "..range, function(data)
		if (data) then
			for k, v in ipairs(data) do
				local itemID = tonumber(v._itemID)
				local data = util.JSONToTable(v._data or "[]")
				local uniqueID = v._uniqueID
				local itemTable = lia.item.list[uniqueID]

				if (itemTable and itemID) then
					local item = lia.item.new(uniqueID, itemID)

					item.invID = 0
					item.data = data or {}

					-- Legacy support for x, y data
					item.data.x = tonumber(v._x)
					item.data.y = tonumber(v._y)

					item.quantity = tonumber(v._quantity)

					item:onRestored()
				end
			end
		end
	end)
end

-- Instances and spawns a given item type.
function lia.item.spawn(uniqueID, position, callback, angles, data)
	local d
	if (not isfunction(callback)) then
		-- Promise returning overload (uniqueID, position[, angles, data])
		if (type(callback) == "Angle" or istable(angles)) then
			angles = callback
			data = angles
		end

		d = deferred.new()
		callback = function(item)
			d:resolve(item)
		end
	end

	lia.item.instance(0, uniqueID, data or {}, 1, 1, function(item)
		local entity = item:spawn(position, angles)
		if (callback) then
			callback(item, entity)
		end
	end)

	return d
end
