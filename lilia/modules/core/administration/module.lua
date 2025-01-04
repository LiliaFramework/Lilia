if CLIENT then TicketFrames = {} end
MODULE.name = "SAM"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
MODULE.desc = "Adds SAM Compatibility"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Read Admin Chat",
        MinAccess = "admin",
        Description = "Allows access to Reading the Admin Chat.",
    },
    {
        Name = "Staff Permissions - Can See SAM Notifications Outside Staff Character",
        MinAccess = "superadmin",
        Description = "Allows access to Seeing SAM Notifications Outside Staff Character.",
    }
}

if sam ~= nil then
    MODULE.Dependencies = {
        {
            File = MODULE.path .. "/sam/shared.lua",
        },
        {
            File = MODULE.path .. "/sam/client.lua",
        },
        {
            File = MODULE.path .. "/sam/server.lua",
        },
    }
end

hook.Remove("PlayerSay", "ULXMeCheck")