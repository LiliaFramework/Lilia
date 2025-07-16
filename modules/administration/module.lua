MODULE.name = "Administration Utilities"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Provides utility commands and tools for server administration."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Remove Warns",
        MinAccess = "superadmin"
    },
    {
        Name = "Staff Permissions - Manage Prop Blacklist",
        MinAccess = "superadmin"
    },
    {
        Name = "Staff Permissions - Access Configuration Menu",
        MinAccess = "superadmin"
    },
    {
        Name = "Staff Permissions - Access Edit Configuration Menu",
        MinAccess = "superadmin"
    },


}function MODULE:ModuleLoaded()
    hook.Run("AdministrationModuleLoaded", self)
    hook.Run("AdministrationDataInitialized", self)
    hook.Run("AdministrationPermissionsLoaded", self)
    hook.Run("AdministrationCommandsReady", self)
    hook.Run("AdministrationFinished", self)
end
