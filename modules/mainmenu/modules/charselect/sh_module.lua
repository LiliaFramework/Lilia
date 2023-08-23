PLUGIN.name = "Lilia Character Selection"
PLUGIN.author = "STEAM_0:1:176123778"
PLUGIN.desc = "The Lilia character selection screen."
lia.util.include("sh_config.lua")
lia.util.include("cl_plugin.lua")

if lia.config.CustomUIEnabled then 
    lia.util.includeDir(PLUGIN.path .. '/derma', true)
    lia.util.includeDir(PLUGIN.path .. '/derma/steps', true)
    lia.util.includeDir(PLUGIN.path .. '/new_derma', true)
else
    lia.util.includeDir(PLUGIN.path .. "/derma", true)
    lia.util.includeDir(PLUGIN.path .. "/derma/steps", true)
end