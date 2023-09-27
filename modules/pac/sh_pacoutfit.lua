
function MODULE:setupPACDataFromItems()
	for itemType, item in pairs(lia.item.list) do
		if istable(item.pacData) then
			self.partData[itemType] = item.pacData
		end
	end
end

function MODULE:InitializedModules()
	timer.Simple(
		1,
		function()
			self:setupPACDataFromItems()
		end
	)
end
