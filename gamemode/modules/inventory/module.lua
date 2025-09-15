MODULE.name = "Inventory"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Implements a modular grid-based inventory with item stacking, weight limits, and support for hot-loading additional modules."
MODULE.Privileges = {
    {
        Name = "No item cooldown",
        ID = "noItemCooldown",
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
