MODULE.name = "Core - Permissions"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Implements CAMI Based Permissions."    
MODULE.identifier = "PermissionCore"
MODULE.CAMIPrivileges = {
    {
        Name = "UserGroups - Staff Group",
        MinAccess = "admin",
        Description = "Defines Player as Staff."
    },
    {
        Name = "UserGroups - VIP Group",
        MinAccess = "superadmin",
        Description = "Defines Player as VIP."
    },
    {
        Name = "Staff Permissions - List Entities",
        MinAccess = "superadmin",
        Description = "Allows a User to List Entities."
    },
}
