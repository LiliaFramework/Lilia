--[[--
Permissions - Physgun.

This module manages physgun permissions and also patches some exploits.
]]
-- @moduleinfo physgun
MODULE.name = "Permissions - Physgun"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "A Module that Manages Physgun."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Grab World Props",
        MinAccess = "superadmin",
        Description = "Allows access to grabbing world props."
    },
    {
        Name = "Staff Permissions - Can Grab Players",
        MinAccess = "superadmin",
        Description = "Allows access to grabbing players props."
    },
    {
        Name = "Staff Permissions - Physgun Pickup",
        MinAccess = "admin",
        Description = "Allows access to picking up entities with Physgun."
    },
    {
        Name = "Staff Permissions - Physgun Pickup on Restricted Entities",
        MinAccess = "superadmin",
        Description = "Allows access to picking up restricted entities with Physgun."
    },
    {
        Name = "Staff Permissions - Physgun Pickup on Vehicles",
        MinAccess = "admin",
        Description = "Allows access to picking up Vehicles with Physgun."
    },
    {
        Name = "Staff Permissions - Can't be Grabbed with PhysGun",
        MinAccess = "superadmin",
        Description = "Allows access to not being Grabbed with PhysGun."
    },
    {
        Name = "Staff Permissions - Can Physgun Reload",
        MinAccess = "superadmin",
        Description = "Allows access to Reloading Physgun.",
    },
}