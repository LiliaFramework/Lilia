DeriveGamemode("sandbox")
--------------------------------------------------------------------------------------------------------
lia = lia or {
    util = {},
    meta = {}
}
--------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("core/sh_include.lua")
AddCSLuaFile("shared.lua")
include("core/sh_include.lua")
include("core/sv_data.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------