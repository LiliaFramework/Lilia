DeriveGamemode("sandbox")
lia = lia or {
    util = {},
    gui = {},
    meta = {},
    notices = {},
}

MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Bootstrapper] ", color_white, "Starting client load...\n")
include("lilia/gamemode/core/libraries/config.lua")
include("lilia/gamemode/shared.lua")
include("lilia/gamemode/core/libraries/includer.lua")
include("lilia/gamemode/core/libraries/data.lua")