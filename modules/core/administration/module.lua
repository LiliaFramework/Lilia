MODULE.name = "Administration Utilities"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds some Administration Utilities"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Remove Warnrs",
        MinAccess = "superadmin",
        Description = "Allows access to Removing Player Warnings.",
    },
    {
        Name = "Staff Permissions - Access Configuration Menu",
        MinAccess = "superadmin",
        Description = "Allows access to Access Configuration Menu.",
    },
    {
        Name = "Staff Permissions - Access Edit Configuration Menu",
        MinAccess = "superadmin",
        Description = "Allows access to Access Configuration Menu.",
    },
}

hook.Remove("PlayerSay", "ULXMeCheck")
