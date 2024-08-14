DeriveGamemode("sandbox")
lia = lia or {
    util = {},
    meta = {}
}

if engine.ActiveGamemode() == "lilia" then MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "No schema loaded. Please place the schema in your gamemodes folder, then set it as your gamemode.\n\n") end
AddCSLuaFile("lilia/gamemode/libraries/config.lua")
include("lilia/gamemode/libraries/config.lua")
include("lilia/gamemode/shared.lua")
include("lilia/gamemode/config/database.lua")
include("lilia/gamemode/libraries/database.lua")
include("lilia/gamemode/hooks/database.lua")
include("lilia/gamemode/libraries/includer.lua")
include("lilia/gamemode/libraries/data.lua")
include("lilia/gamemode/hooks/data.lua")
AddCSLuaFile("lilia/gamemode/hooks/fonts.lua")
AddCSLuaFile("lilia/gamemode/libraries/includer.lua")
AddCSLuaFile("lilia/gamemode/libraries/data.lua")
AddCSLuaFile("lilia/gamemode/shared.lua")
MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Bootstrapper] ", color_white, "Starting boot sequence...\n")
MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Bootstrapper] ", color_white, "Starting server load...\n")
timer.Simple(0, function()
    hook.Run("SetupDatabase")
    lia.db.connect(function()
        lia.db.loadTables()
        lia.log.loadTables()
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " Lilia has connected to the database.\n")
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " Database Type: " .. lia.db.module .. ".\n")
        hook.Run("DatabaseConnected")
    end)
end)

cvars.AddChangeCallback("sbox_persist", function(_, old, new)
    timer.Create("sbox_persist_change_timer", 1, 1, function()
        hook.Run("PersistenceSave", old)
        game.CleanUpMap(false, nil, function() end)
        if new == "" then return end
        hook.Run("PersistenceLoad", new)
    end)
end, "sbox_persist_load")
