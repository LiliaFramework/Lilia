MODULE.name = "Warns"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds a warning system complete with logs and a management menu so staff can issue, track, and remove player warnings."
MODULE.Privileges = {
    {
        Name = "canRemoveWarns",
        ID = "canRemoveWarns",
        MinAccess = "superadmin",
        Category = "warning",
    },
    {
        Name = "viewPlayerWarnings",
        ID = "viewPlayerWarnings",
        MinAccess = "admin",
        Category = "warning",
    },
}