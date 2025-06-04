MODULE.name = "List Storage"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Storage of item lists with weight."
STORAGE_DEFINITIONS = STORAGE_DEFINITIONS or {}
STORAGE_DEFINITIONS["models/props_junk/wood_crate001a.mdl"] = {
	name = "Wood Crate",
	desc = "A crate made out of wood.",
	invType = "weight",
	weight = 15
}

if CLIENT then
	function MODULE:StorageOpen(storage)
		if IsValid(storage) and storage:getStorageInfo().invType == "weight" then vgui.Create("liaListStorage"):setStorage(storage) end
	end
end