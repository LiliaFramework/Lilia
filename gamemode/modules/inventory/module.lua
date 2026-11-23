MODULE.name = "Inventory"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "Implements a modular grid-based inventory with item stacking, weight limits, and support for hot-loading additional modules."
MODULE.Privileges = {
    ["noItemCooldown"] = {
        Name = "No item cooldown",
        MinAccess = "admin",
        Category = "Staff: Management"
    }
}

local invType = string.lower(hook.Run("GetDefaultInventoryType") or "gridinv")
lia.module.load(invType, MODULE.folder .. "/types/" .. invType)
