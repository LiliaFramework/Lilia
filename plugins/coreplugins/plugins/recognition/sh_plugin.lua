PLUGIN.name = "Recognition"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "Adds the ability to recognize people / You can also allow auto faction recognition."
lia.util.include("sv_plugin.lua")
lia.util.include("cl_plugin.lua")
lia.playerInteract.addFunc("recognize", {
    nameLocalized = "recognize",
    callback = function(target)
        netstream.Start("rgnDirect", target)
    end,
    canSee = function(target)
        return true
    end
})
--[[ 
PLUGIN.noRecognise = {
    [FACTION_CITIZEN] = false,
}]]
-- Add interaction function