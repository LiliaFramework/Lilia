MODULE.name = "Chatbox"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
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

if CLIENT then
    lia.option.add("ChatShowTime", "Show Chat Timestamp", "Should chat show timestamp", false, nil, {
        category = "Chat",
        type = "Boolean"
    })
end
