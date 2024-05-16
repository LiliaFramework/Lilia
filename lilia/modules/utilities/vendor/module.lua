--- Configuration for Vendors Module.
-- @configurations Vendors

--- This table defines the default settings for the Vendors Module.
-- @realm shared
-- @table Configuration
-- @field DefaultVendorMoney The Default Vendor Money | **number**
-- @field VendorClick The sound that plays when using a vendor | **table**
MODULE.name = "Utilities - Vendors"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds NPC vendors that can sell things."
MODULE.CAMIPrivileges = {
    {
        Name = "Lilia - Staff Permissions - Can Edit Vendors",
        MinAccess = "admin",
        Description = "Allows access to edit vendors.",
    },
}
