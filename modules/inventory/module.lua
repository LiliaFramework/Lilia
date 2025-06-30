MODULE.name = "Grid Inventory"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds Lilia's Grid Inventory"
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
