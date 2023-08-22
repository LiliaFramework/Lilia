--------------------------------------------------------------------------------------------------------
MODULE.name = "Vendors"
MODULE.author = "STEAM_0:1:176123778/Cheesenut"
MODULE.desc = "Adds NPC vendors that can sell things."
--------------------------------------------------------------------------------------------------------
lia.util.include("cl_editor.lua")
lia.util.include("sh_enums.lua")
lia.util.include("sv_networking.lua")
lia.util.include("cl_networking.lua")
lia.util.include("sv_data.lua")
lia.util.include("sv_hooks.lua")
lia.util.include("cl_hooks.lua")
lia.util.include("sh_meta.lua")

--------------------------------------------------------------------------------------------------------
lia.config.VendorClick = {"buttons/button15.wav", 30, 250}

lia.config.VendorEditorAllowed = {
    ["superadmin"] = true,
    ["admin"] = false,
    ["user"] = true,
}
--------------------------------------------------------------------------------------------------------