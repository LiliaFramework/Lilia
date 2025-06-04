MODULE.name = "Weight Inv UI"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds a simple interface for weight inventories."
if CLIENT then
	function MODULE:CreateInventoryPanel(inventory, parent)
		if inventory.typeID ~= "weight" then return end
		local panel = parent:Add("liaListInventory")
		panel:setInventory(inventory)
		panel:Center()
		return panel
	end

	function MODULE:getItemStackKey(item)
		local elements = {}
		for key, value in SortedPairs(item.data) do
			elements[#elements + 1] = key
			elements[#elements + 1] = value
		end
		return item.uniqueID .. pon.encode(elements)
	end

	function MODULE:getItemStacks(inventory)
		local stacks = {}
		local stack, key
		for _, item in SortedPairs(inventory:getItems()) do
			key = self:getItemStackKey(item)
			stack = stacks[key] or {}
			stack[#stack + 1] = item
			stacks[key] = stack
		end
		return stacks
	end
end