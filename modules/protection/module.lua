MODULE.name = "Protection"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Implements protection features to safeguard gameplay."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can See Alting Notifications",
        MinAccess = "admin"
    },
}

function MODULE:ModuleLoaded()
    hook.Run("ProtectionModuleLoaded", self)
    hook.Run("ProtectionConfigLoaded", self)
    hook.Run("ProtectionHooksAdded", self)
    hook.Run("ProtectionChecksInitialized", self)
    hook.Run("ProtectionReady", self)
end
