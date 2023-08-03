function lia.inventory.show(inventory, parent)
	local globalName = "inv" .. inventory.id

	if IsValid(lia.gui[globalName]) then
		lia.gui[globalName]:Remove()
	end

	local panel = hook.Run("CreateInventoryPanel", inventory, parent)
	lia.gui[globalName] = panel

	return panel
end