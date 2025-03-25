MODULE.name = "Logger"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds a Module that implements a action logger"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can See Logs",
        MinAccess = "superadmin",
        Description = "Allows access to Seeing Logs In Console.",
    }
}

MODULE.Dependencies = {
    {
        File = MODULE.path .. "/logs.lua",
        Realm = "server",
    },
}
