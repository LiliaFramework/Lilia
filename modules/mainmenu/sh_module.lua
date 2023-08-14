MainMenu = MODULE
MODULE.name = "Multiple Characters"
MODULE.author = "Leonheart#7476/Cheesenot"
MODULE.desc = "Allows players to have multiple characters."
lia.util.include("sv_module.lua")
lia.util.include("sh_config.lua")
lia.util.include("cl_module.lua")
lia.util.includeDir(MODULE.path .. "/sections", true)
lia.util.includeDir(MODULE.path .. "/steps", true, true)