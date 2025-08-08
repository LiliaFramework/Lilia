MODULE.name = "moduleAdministrationName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "moduleAdministrationDesc"
MODULE.Privileges = {
    {
        Name = L("managePropBlacklist"),
        ID = "managePropBlacklist",
        MinAccess = "superadmin",
        Category = "categoryBlacklisting",
    },
    {
        Name = L("manageVehicleBlacklist"),
        ID = "manageVehicleBlacklist",
        MinAccess = "superadmin",
        Category = "categoryBlacklisting",
    },
    {
        Name = L("manageEntityBlacklist"),
        ID = "manageEntityBlacklist",
        MinAccess = "superadmin",
        Category = "categoryBlacklisting",
    },
    {
        Name = L("accessConfigurationMenu"),
        ID = "accessConfigurationMenu",
        MinAccess = "superadmin",
        Category = "categoryConfiguration",
    },
    {
        Name = L("accessEditConfigurationMenu"),
        ID = "accessEditConfigurationMenu",
        MinAccess = "superadmin",
        Category = "categoryConfiguration",
    },
    {
        Name = L("manageUsergroups"),
        ID = "manageUsergroups",
        MinAccess = "superadmin",
        Category = "categoryUsergroups",
    },
    {
        Name = L("viewStaffManagement"),
        ID = "viewStaffManagement",
        MinAccess = "superadmin",
        Category = "categoryStaffManagement",
    },
    {
        Name = L("canAccessPlayerList"),
        ID = "canAccessPlayerList",
        MinAccess = "admin",
        Category = "players"
    },
    {
        Name = L("listCharacters"),
        ID = "listCharacters",
        MinAccess = "admin",
        Category = "character"
    },
    {
        Name = L("viewDBTables"),
        ID = "viewDBTables",
        MinAccess = "superadmin",
        Category = "database"
    },
    {
        Name = L("canAccessFlagManagement"),
        ID = "canAccessFlagManagement",
        MinAccess = "superadmin",
        Category = "flags",
    },
}
