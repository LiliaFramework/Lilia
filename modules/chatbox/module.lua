MODULE.name = "Chatbox"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds an enhanced in-game chat box with staff controls."
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

function MODULE:ModuleLoaded()
    hook.Run("ChatboxModuleLoaded", self)
    hook.Run("ChatboxFontsInitialized", self)
    hook.Run("ChatboxChannelsRegistered", self)
    hook.Run("ChatboxUIBuilt", self)
    hook.Run("ChatboxReady", self)
end
