MODULE.name = "Logger"
MODULE.author = "Samael"
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
        File = "logs.lua",
        Realm = "server",
    },
}
