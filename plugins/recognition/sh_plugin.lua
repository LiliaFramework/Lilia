PLUGIN.name = "Recognition"
PLUGIN.author = "Cheesenot/Leonheart#7476"
PLUGIN.desc = "Adds the ability to recognize people // You can also allow auto faction recognition."
lia.util.include("sv_plugin.lua")
lia.util.include("cl_plugin.lua")
--[[
PLUGIN.noRecognise = {
    [FACTION_CITIZEN] = true,
}]]