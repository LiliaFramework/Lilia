DeriveGamemode("sandbox")
lia = lia or {
    util = {},
    meta = {}
}

AddCSLuaFile("lilia/gamemode/libraries/config.lua")
include("lilia/gamemode/libraries/config.lua")
include("lilia/gamemode/shared.lua")
include("lilia/gamemode/config/database/database.lua")
include("lilia/gamemode/config/database/tables.lua")
include("lilia/gamemode/libraries/database.lua")
include("lilia/gamemode/hooks/database.lua")
include("lilia/gamemode/libraries/includer.lua")
include("lilia/gamemode/libraries/data.lua")
include("lilia/gamemode/hooks/data.lua")
AddCSLuaFile("lilia/gamemode/hooks/fonts.lua")
AddCSLuaFile("lilia/gamemode/libraries/includer.lua")
AddCSLuaFile("lilia/gamemode/libraries/data.lua")
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
