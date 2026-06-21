--[[
    Hooks:
        GetInventoryMaxWeight(inventory, maxWeight)

    Purpose:
        Allows code to override the computed maximum carry weight for a weight inventory.

    Parameters:
        inventory (table)
            The inventory whose maximum weight is being calculated.

        maxWeight (number)
            The default maximum weight before overrides are applied.

    Returns:
        number|nil
            Return a replacement max weight to override the default value.

    Realm:
        Shared
]]
MODULE.name = "@weightInv"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@weightInvDescription"
MODULE.Dependencies = {
    {
        File = "weightinv.lua",
        Realm = "shared"
    },
}
