MODULE.name = "Grid Inventory"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds Lilia's Grid Inventory"
MODULE.enabled = function() return not lia.module.list["weightinv"] end
MODULE.Dependencies = {
    {
        File = "gridinv.lua",
        Realm = "shared"
    },
}