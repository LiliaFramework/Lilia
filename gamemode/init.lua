--------------------------------------------------------------------------------------------------------
DeriveGamemode("sandbox")

--------------------------------------------------------------------------------------------------------
lia = lia or {
    util = {},
    meta = {}
}

--------------------------------------------------------------------------------------------------------
AddCSLuaFile("backend/external/thirdparty/cl_ikon.lua")
AddCSLuaFile("backend/external/thirdparty/cl_markup.lua")
AddCSLuaFile("backend/external/thirdparty/cl_surfaceGetURL.lua")
--------------------------------------------------------------------------------------------------------
include("backend/external/thirdparty/sh_deferred.lua")
include("backend/external/thirdparty/sh_ease.lua")
include("backend/external/thirdparty/sh_netstream2.lua")
include("backend/external/thirdparty/sh_pon.lua")
include("backend/external/thirdparty/sh_utf8.lua")
--------------------------------------------------------------------------------------------------------
AddCSLuaFile("config.lua")
AddCSLuaFile("loader.lua")
--------------------------------------------------------------------------------------------------------
include("config.lua")
include("loader.lua")
include("data.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------
AddCSLuaFile("backend/sh_loader.lua")
AddCSLuaFile("frontend/sh_loader.lua")
--------------------------------------------------------------------------------------------------------
include("backend/sh_loader.lua")
include("frontend/sh_loader.lua")
--------------------------------------------------------------------------------------------------------
resource.AddWorkshop("2959728255")
--------------------------------------------------------------------------------------------------------