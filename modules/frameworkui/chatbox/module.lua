MODULE.name = "Chatbox"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds a Chatbox"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - No OOC Cooldown",
        MinAccess = "admin",
        Description = "Allows access to use the OOC chat command without delay.",
    },
    {
        Name = "Staff Permissions - Admin Chat",
        MinAccess = "admin",
        Description = "Allows access to Admin Chat.",
    },
    {
        Name = "Staff Permissions - Local Event Chat",
        MinAccess = "admin",
        Description = "Allows access to Local Event Chat."
    },
    {
        Name = "Staff Permissions - Event Chat",
        MinAccess = "admin",
        Description = "Allows access to Event Chat."
    },
    {
        Name = "Staff Permissions - Always Have Access to Help Chat",
        MinAccess = "superadmin",
        Description = "Allows access to Help Chat."
    },
}

lia.option.add("ChatShowTime", "Show Chat Timestamp", "Should chat show timestamp", false, nil, {
    category = "Chat",
    type = "Boolean"
})
