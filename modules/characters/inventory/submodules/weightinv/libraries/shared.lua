local WeightInv = lia.Inventory:extend("WeightInv")
local function CanAccessInventoryIfCharacterIsOwner(inventory, action, context)
	local ownerID = inventory:getData("char")
	local client = context.client
	if table.HasValue(client.liaCharList, ownerID) then return true end
end

local function CanAddItemIfNotWeightRestricted(inventory, action, context)
	if action ~= "add" then return end
	if context.forced then return true end
	local weight = inventory:getWeight()
	local maxWeight = inventory:getMaxWeight()
	local incomingWeight
	local ratio = lia.config.get("invRatio", 1)
	local item = context.item
	if item.width and item.height then
		local blocks = item.width * item.height
		incomingWeight = math.max(blocks / ratio, 1)
	else
		incomingWeight = item.weight or 1
	end

	if weight + incomingWeight > maxWeight then return false, "noFit" end
	return true
end

function WeightInv:configure()
	if SERVER then
		self:addAccessRule(CanAddItemIfNotWeightRestricted)
		self:addAccessRule(CanAccessInventoryIfCharacterIsOwner)
	end
end

if SERVER then
	function WeightInv:add(itemTypeOrItem, quantity, forced)
		quantity = quantity or 1
		assert(isnumber(quantity), "quantity must be a number")
		local d = deferred.new()
		if quantity <= 0 then return d:reject("quantity must be positive") end
		local item, justAddDirectly
		if lia.item.isItem(itemTypeOrItem) then
			item = itemTypeOrItem
			quantity = 1
			justAddDirectly = true
		else
			item = lia.item.list[itemTypeOrItem]
		end

		if not item then
			return d:resolve({
				error = "invalid item type"
			})
		end

		local context = {
			item = item,
			forced = forced,
			quantity = quantity
		}

		local canAccess, reason = self:canAccess("add", context)
		if not canAccess then return d:reject(reason or "noAccess") end
		if justAddDirectly then
			self:addItem(item)
			return d:resolve(item)
		end

		local items = {}
		local itemType = item.uniqueID
		for i = 1, quantity do
			lia.item.instance(self:getID(), itemType, nil, 0, 0, function(newItem)
				self:addItem(newItem)
				items[#items + 1] = newItem
				if #items == quantity then d:resolve(quantity == 1 and items[1] or items) end
			end)
		end
		return d
	end

	function WeightInv:remove(itemTypeOrID, quantity)
		quantity = quantity or 1
		assert(isnumber(quantity), "quantity must be a number")
		local d = deferred.new()
		if quantity <= 0 then return d:reject("quantity must be positive") end
		if isnumber(itemTypeOrID) then
			self:removeItem(itemTypeOrID)
		else
			local items = self:getItemsOfType(itemTypeOrID)
			for i = 1, math.min(quantity, #items) do
				self:removeItem(items[i]:getID())
			end
		end

		d:resolve()
		return d
	end
end

function WeightInv:getItemsOfType(itemType)
	local items = {}
	for _, item in pairs(self.items) do
		if item.uniqueID == itemType then items[#items + 1] = item end
	end
	return items
end

function WeightInv:getWeight()
	local totalWeight = 0
	local ratio = lia.config.get("invRatio", 1)
	for _, item in pairs(self.items) do
		local itemWeight
		if item.width and item.height then
			local blocks = item.width * item.height
			itemWeight = math.max(blocks / ratio, 1)
		else
			itemWeight = item.weight or 1
		end

		totalWeight = totalWeight + math.max(itemWeight, 0)
	end
	return totalWeight
end

function WeightInv:getMaxWeight()
	local defaultMax = lia.config.get("invMaxWeight", 150)
	local baseMax = tonumber(self:getData("maxWeight", defaultMax))
	for _, item in pairs(self.items) do
		if item.weight and item.weight < 0 then baseMax = baseMax - item.weight end
	end

	local override = hook.Run("WeightInvGetMaxWeight", self, baseMax)
	if isnumber(override) then return override end
	return baseMax
end

function WeightInv:canItemFitInInventory(item, x, y)
	local ratio = lia.config.get("invRatio", 1)
	local incomingWeight
	if item.width and item.height then
		local blocks = item.width * item.height
		incomingWeight = math.max(blocks / ratio, 1)
	else
		incomingWeight = item.weight or 1
	end
	return self:getWeight() + incomingWeight <= self:getMaxWeight()
end

function WeightInv:canAdd(item)
	return self:canItemFitInInventory(item)
end

function WeightInv:doesFitInventory(item)
	return self:canItemFitInInventory(item)
end

function WeightInv:getItems(noRecurse)
	return self.items
end

if SERVER then
	function WeightInv:wipeItems()
		local ids = {}
		for _, item in pairs(self.items) do
			ids[#ids + 1] = item:getID()
		end

		for _, id in pairs(ids) do
			self:removeItem(id)
		end
	end
end

WeightInv:register("weight")