MODULE.name = "@inventory"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "@inventoryDesc"
MODULE.Privileges = {
    {
        Name = "@noItemCooldown",
        ID = "noItemCooldown",
        MinAccess = "admin",
        Category = "@categoryStaffManagement"
    }
}

MODULE.Dependencies = {
    {
        File = "gridinv.lua",
        Realm = "shared"
    },
}
