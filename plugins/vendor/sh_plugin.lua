PLUGIN.name = "Vendors"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "Adds NPC vendors that can sell things."

if SERVER then
    AddCSLuaFile("cl_editor.lua")
end

lia.util.include("sv_logging.lua")
lia.util.include("sh_enums.lua")
lia.util.include("sv_networking.lua")
lia.util.include("cl_networking.lua")
lia.util.include("sv_data.lua")
lia.util.include("sv_hooks.lua")
lia.util.include("cl_hooks.lua")