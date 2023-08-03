MODULE.name = "Grid Inventory"
MODULE.author = "Leonheart#7476/Cheesenot"
MODULE.desc = "Inventory system where items have a size and fit in a grid."
local INVENTORY_TYPE_ID = "grid"
MODULE.INVENTORY_TYPE_ID = INVENTORY_TYPE_ID
lia.util.include("sh_grid_inv.lua")
lia.util.include("sv_transfer.lua")
lia.util.include("sv_access_rules.lua")

function MODULE:GetDefaultInventoryType(character)
	return INVENTORY_TYPE_ID
end

if SERVER then
	-- Called when item has been dragged on top of target (also an item).
	function MODULE:ItemCombine(client, item, target)
		if target.onCombine then
			if target:call("onCombine", client, nil, item) then return end -- when other items dragged into the item.
		end

		if item.onCombineTo then
			if item and item:call("onCombineTo", client, nil, target) then return end -- when you drag the item on something
		end
	end

	-- Called when an item has been dragged out of its inventory.
	function MODULE:ItemDraggedOutOfInventory(client, item)
		item:interact("drop", client)
	end
end