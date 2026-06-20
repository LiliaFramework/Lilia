MODULE.name = "@chatboxModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@chatSystemDescription"
MODULE.NetworkStrings = {"liaChatboxAddFilteredWord", "liaChatboxRemoveFilteredWord", "liaChatboxRequestFilteredWords", "liaChatboxSyncFilteredWords"}
MODULE.Privileges = {
    ["noOOCCooldown"] = {
        Name = "@noOOCCooldown",
        MinAccess = "admin",
        Category = "@categoryChat",
    },
    ["adminChat"] = {
        Name = "@adminChat",
        MinAccess = "superadmin",
        Category = "@categoryChat",
    },
    ["localEventChat"] = {
        Name = "@localEventChat",
        MinAccess = "admin",
        Category = "@categoryChat",
    },
    ["eventChat"] = {
        Name = "@eventChat",
        MinAccess = "admin",
        Category = "@categoryChat",
    },
    ["accessHelpChat"] = {
        Name = "@accessHelpChat",
        MinAccess = "superadmin",
        Category = "@categoryChat",
    },
    ["bypassOOCBlock"] = {
        Name = "@bypassOOCBlockPrivilege",
        MinAccess = "superadmin",
        Category = "@categoryChat",
    },
    ["manageChatFilter"] = {
        Name = "@manageChatFilter",
        MinAccess = "superadmin",
        Category = "@categoryChat",
    },
}
