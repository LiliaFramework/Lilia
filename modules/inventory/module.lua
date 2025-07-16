MODULE.name = "Grid Inventory"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Introduces Lilia's grid-based inventory system."
MODULE.enabled = function()
    local schemaPath = engine.ActiveGamemode()
    local dir = schemaPath .. "/modules/weightinv"
    local exists, _ = file.Exists(dir, "LUA")
    return not exists
end

MODULE.Dependencies = {
    {
        File = "gridinv.lua",
        Realm = "shared"
    },
}

function MODULE:ModuleLoaded()
    hook.Run("InventoryModuleLoaded", self)
    hook.Run("InventoryRulesAdded", self)
    hook.Run("InventoryPanelsBuilt", self)
    hook.Run("InventoryNetworkingSetUp", self)
    hook.Run("InventoryReady", self)
end
