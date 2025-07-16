MODULE.name = "Recognition"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds player recognition and optional automatic faction recognition."

function MODULE:ModuleLoaded()
    hook.Run("RecognitionModuleLoaded", self)
    hook.Run("RecognitionDataLoaded", self)
    hook.Run("RecognitionHooksAdded", self)
    hook.Run("RecognitionRulesSetup", self)
    hook.Run("RecognitionReady", self)
end
