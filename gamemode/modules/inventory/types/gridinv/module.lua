MODULE.name = "@inv"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@inventorySystemDescription"
print("Loading inventory type: " .. MODULE.name)
MODULE.Dependencies = {
    {
        File = "gridinv.lua",
        Realm = "shared"
    },
}
