
DeriveGamemode("sandbox")
lia = lia or {
    util = {},
    meta = {}
}

AddCSLuaFile("lilia/libraries/config.lua")
include("lilia/libraries/config.lua")
include("lilia/gamemode/shared.lua")
include("lilia/libraries/includer.lua")
include("lilia/libraries/data.lua")
include("lilia/hooks/data.lua")
include("lilia/config/database/database.lua")
include("lilia/config/database/tables.lua")
include("lilia/libraries/database.lua")
include("lilia/libraries/loader.lua")
AddCSLuaFile("lilia/libraries/fonts.lua")
AddCSLuaFile("lilia/libraries/includer.lua")
AddCSLuaFile("lilia/libraries/loader.lua")
AddCSLuaFile("lilia/libraries/data.lua")
AddCSLuaFile("lilia/gamemode/shared.lua")
timer.Simple(0, function()
    hook.Run("SetupDatabase")
    lia.db.connect(function()
        lia.db.loadTables()
        lia.log.loadTables()
        MsgC(Color(0, 255, 0), "Lilia has connected to the database.\n")
        MsgC(Color(0, 255, 0), "Database Type: " .. lia.db.module .. ".\n")
        hook.Run("DatabaseConnected")
    end)
end)

cvars.AddChangeCallback("sbox_persist", function(_, old, new)
    timer.Create("sbox_persist_change_timer", 1, 1, function()
        hook.Run("PersistenceSave", old)
        game.CleanUpMap()
        if new == "" then return end
        hook.Run("PersistenceLoad", new)
    end)
end, "sbox_persist_load")
