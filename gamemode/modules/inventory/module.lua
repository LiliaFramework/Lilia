--[[
    Hooks:
        GetDefaultInventorySize(Player client, Character char)

    Purpose:
        Allows modules to override the default dimensions assigned to a character inventory.
        For weight inventories, this changes the inventory panel width and height only.
        Use GetInventoryMaxWeight to override the carry weight limit.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player whose character inventory is being sized.

        char (Character)
            The character whose inventory dimensions are being resolved.

    Returns:
        number|nil, number|nil
            Return width and height values to override the configured defaults.
            In weight inventories, these values affect the UI dimensions rather than max carry weight.
            Returning nil values allows the normal inventory size config to continue.

    Example Usage:
        ```lua
        hook.Add("GetDefaultInventorySize", "liaExampleGetDefaultInventorySize", function(client, char)
            if char and char:getFaction() == FACTION_STAFF then
                return 8, 5
            end
        end)
        ```

    Realm:
        Server
]]
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
