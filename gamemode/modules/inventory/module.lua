MODULE.name = "@inv"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@inventorySystemDescription"
MODULE.Privileges = {
    ["noItemCooldown"] = {
        Name = "@noItemCooldown",
        MinAccess = "admin",
        Category = "@categoryStaffManagement"
    }
}

local invType = string.lower(hook.Run("GetDefaultInventoryType") or "gridinv")
lia.module.load(invType, MODULE.folder .. "/types/" .. invType)
