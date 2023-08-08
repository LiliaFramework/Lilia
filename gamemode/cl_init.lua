--------------------------------------------------------------------------------------------------------
DeriveGamemode("sandbox")

--------------------------------------------------------------------------------------------------------
lia = lia or {
    util = {},
    gui = {},
    meta = {}
}
--------------------------------------------------------------------------------------------------------
include("backend/external/thirdparty/cl_ikon.lua")
include("backend/external/thirdparty/cl_markup.lua")
include("backend/external/thirdparty/cl_surfaceGetURL.lua")
include("backend/external/thirdparty/sh_deferred.lua")
include("backend/external/thirdparty/sh_ease.lua")
include("backend/external/thirdparty/sh_netstream2.lua")
include("backend/external/thirdparty/sh_pon.lua")
include("backend/external/thirdparty/sh_utf8.lua")
--------------------------------------------------------------------------------------------------------
include("sh_config.lua")
include("sh_loader.lua")
include("backend/sh_loader.lua")
include("frontend/sh_loader.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------
timer.Remove("HintSystem_OpeningMenu")
timer.Remove("HintSystem_Annoy1")
timer.Remove("HintSystem_Annoy2")
--------------------------------------------------------------------------------------------------------