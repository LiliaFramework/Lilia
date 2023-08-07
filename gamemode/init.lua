DeriveGamemode("sandbox")

--------------------------------------------------------------------------------------------------------
lia = lia or {
    util = {},
    meta = {}
}

--------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("core/sh_config.lua")
AddCSLuaFile("core/sh_include.lua")
AddCSLuaFile("core/sh_loader.lua")
AddCSLuaFile("shared.lua")
include("core/sh_config.lua")
include("core/sh_include.lua")
include("core/sh_loader.lua")
include("core/sv_data.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------
resource.AddWorkshop("2959728255")
--------------------------------------------------------------------------------------------------------