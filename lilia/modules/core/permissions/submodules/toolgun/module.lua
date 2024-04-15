--[[--
Permissions - Tool Gun.

This module manages toolgun permissions and also patches some exploits.
]]
-- @moduleinfo toolgun
MODULE.name = "Permissions - Tool Gun"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "A Module that Manages Tool Gun."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Remove Blocked Entities",
        MinAccess = "admin",
        Description = "Allows access to removing blocked entities."
    },
    {
        Name = "Staff Permissions - Can Remove World Entities",
        MinAccess = "superadmin",
        Description = "Allows access to removing world props."
    },
}