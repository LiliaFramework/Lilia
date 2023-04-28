PLUGIN.name = "List Storage"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "Storage of item lists with weight."

local INV_TYPE_ID = "simple"

STORAGE_DEFINITIONS = STORAGE_DEFINITIONS or {}
STORAGE_DEFINITIONS["models/props_junk/wood_crate001a.mdl"] = {
	name = "Wood Crate",
	desc = "A crate made out of wood.",
	invType = INV_TYPE_ID,
	weight = 15
}

if (CLIENT) then
	function PLUGIN:StorageOpen(storage)
		if (
			IsValid(storage) and
			storage:getStorageInfo().invType == INV_TYPE_ID
		) then
			vgui.Create("liaListStorage"):setStorage(storage)
		end
	end
end
