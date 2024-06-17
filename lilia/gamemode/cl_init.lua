DeriveGamemode("sandbox")
lia = lia or {
    util = {},
    gui = {},
    meta = {}
}

MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Bootstrapper] ", color_white, "Starting client load...\n")
include("lilia/gamemode/libraries/config.lua")
include("lilia/gamemode/shared.lua")
include("lilia/gamemode/hooks/fonts.lua")
include("lilia/gamemode/libraries/includer.lua")
include("lilia/gamemode/libraries/data.lua")
