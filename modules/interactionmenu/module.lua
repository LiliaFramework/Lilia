MODULE.name = "Interaction Menu"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds an interaction menu featuring quick shortcuts."

function MODULE:ModuleLoaded()
    hook.Run("InteractionMenuModuleLoaded", self)
    hook.Run("InteractionMenuEntriesAdded", self)
    hook.Run("InteractionMenuPanelsCreated", self)
    hook.Run("InteractionMenuKeybindSet", self)
    hook.Run("InteractionMenuReady", self)
end
