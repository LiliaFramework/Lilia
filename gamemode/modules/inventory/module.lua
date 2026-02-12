MODULE.name = "inventoryModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "inventorySystemDescription"
MODULE.Privileges = {
    ["noItemCooldown"] = {
        Name = "noItemCooldown",
        MinAccess = "admin",
        Category = "categoryStaffManagement"
    }
}

MODULE.Dependencies = {
    {
        File = "gridinv.lua",
        Realm = "shared"
    },
}
