MODULE.name = "SAM"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
MODULE.desc = "Adds SAM Compatibility"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Remove Warnrs",
        MinAccess = "superadmin",
        Description = "Allows access to Removing Player Warnings.",
    }
}

hook.Remove("PlayerSay", "ULXMeCheck")
