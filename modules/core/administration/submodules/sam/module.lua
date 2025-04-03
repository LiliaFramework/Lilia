MODULE.name = "SAM Compatibility"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds SAM Compatibility"
MODULE.enabled = sam ~= nil
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can See SAM Notifications Outside Staff Character",
        MinAccess = "superadmin",
        Description = "Allows access to Seeing SAM Notifications Outside Staff Character.",
    },
    {
        Name = "Staff Permissions - Can Bypass Staff Faction SAM Command whitelist",
        MinAccess = "superadmin",
        Description = "Allows staff to bypass the SAM command whitelist for the Staff Faction.",
    },
}