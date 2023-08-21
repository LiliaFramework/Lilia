--------------------------------------------------------------------------------------------------------
DeriveGamemode("sandbox")

--------------------------------------------------------------------------------------------------------
lia = lia or {
    util = {},
    meta = {}
}

--------------------------------------------------------------------------------------------------------
AddCSLuaFile("config.lua")
AddCSLuaFile("includer.lua")
AddCSLuaFile("loader.lua")
AddCSLuaFile("shared.lua")
--------------------------------------------------------------------------------------------------------
include("shared.lua")
include("config.lua")
include("includer.lua")
include("data.lua")
include("database.lua")

--------------------------------------------------------------------------------------------------------
timer.Simple(0, function()
    hook.Run("SetupDatabase")

    lia.db.connect(function()
        lia.db.loadTables()
        MsgC(Color(0, 255, 0), "Lilia has connected to the database.\n")
        MsgC(Color(0, 255, 0), "Database Type: " .. lia.db.module .. ".\n")
        hook.Run("DatabaseConnected")
    end)
end)

--------------------------------------------------------------------------------------------------------
include("loader.lua")
--------------------------------------------------------------------------------------------------------
resource.AddWorkshop("2959728255")

--------------------------------------------------------------------------------------------------------
cvars.AddChangeCallback("sbox_persist", function(name, old, new)
    timer.Create("sbox_persist_change_timer", 1, 1, function()
        hook.Run("PersistenceSave", old)
        game.CleanUpMap()
        if new == "" then return end
        hook.Run("PersistenceLoad", new)
    end)
end, "sbox_persist_load")
--------------------------------------------------------------------------------------------------------