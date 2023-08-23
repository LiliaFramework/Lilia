MODULE.name = "Lilia Character Selection"
MODULE.author = "STEAM_0:1:176123778"
MODULE.desc = "The Lilia character selection screen."
lia.util.include("cl_module.lua")
if lia.config.CustomUIEnabled then
    lia.util.includeDir(MODULE.path .. '/derma/steps', true)
    lia.util.includeDir(MODULE.path .. '/new_ui', true)
else
    lia.util.includeDir(MODULE.path .. "/derma/steps", true)
end