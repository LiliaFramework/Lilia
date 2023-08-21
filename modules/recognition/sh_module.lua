--------------------------------------------------------------------------------------------------------
MODULE.name = "Recognition"
MODULE.author = "Leonheart#7476/Cheesenot"
MODULE.desc = "Adds the ability to recognize people / You can also allow auto faction recognition."
--------------------------------------------------------------------------------------------------------
lia.util.include("sv_module.lua")
lia.util.include("cl_module.lua")
lia.config.RecognitionEnabled = true
lia.config.StaffAutoRecognize = false
lia.config.FactionAutoRecognize = false

--------------------------------------------------------------------------------------------------------
lia.config.noRecognise = {
    [FACTION_STAFF] = false,
}
--------------------------------------------------------------------------------------------------------