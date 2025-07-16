MODULE.name = "Attributes"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Introduces character-bound attributes that affect gameplay."

function MODULE:ModuleLoaded()
    hook.Run("AttributesModuleLoaded", self)
    hook.Run("AttributesDataInitialized", self)
    hook.Run("AttributesBoostsReady", self)
    hook.Run("AttributesEventsBound", self)
    hook.Run("AttributesFinished", self)
end
