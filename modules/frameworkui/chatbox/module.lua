MODULE.name = "Chatbox"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds a Chatbox"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - No OOC Cooldown",
        MinAccess = "admin"
    },
    {
        Name = "Staff Permissions - Admin Chat",
        MinAccess = "admin"
    },
    {
        Name = "Staff Permissions - Local Event Chat",
        MinAccess = "admin"
    },
    {
        Name = "Staff Permissions - Event Chat",
        MinAccess = "admin"
    },
    {
        Name = "Staff Permissions - Always Have Access to Help Chat",
        MinAccess = "superadmin"
    },
}

lia.option.add("ChatShowTime", "Show Chat Timestamp", "Should chat show timestamp", false, nil, {
    category = "Chat",
    type = "Boolean"
})
