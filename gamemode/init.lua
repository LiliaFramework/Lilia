-- Include Lilia content.
resource.AddWorkshop("2959728255")
-- Include features from the Sandbox gamemode.
DeriveGamemode("sandbox")

-- Define a global shared table to store Lilia information.
lia = lia or {
    util = {},
    meta = {}
}

-- Send the following files to players.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("core/sh_util.lua")
AddCSLuaFile("shared.lua")
-- Include utility functions, data storage functions, and then shared.lua
include("core/sh_util.lua")
include("core/sv_data.lua")
include("shared.lua")

-- Connect to the database using SQLite, mysqloo, or tmysql4.
timer.Simple(0, function()
    hook.Run("SetupDatabase")

    lia.db.connect(function()
        -- Create the SQL tables if they do not exist.
        lia.db.loadTables()
        lia.log.loadTables()
        MsgC(Color(0, 255, 0), "Lilia has connected to the database.\n")
        MsgC(Color(0, 255, 0), "Database Type: " .. lia.db.module .. ".\n")
        hook.Run("DatabaseConnected")
    end)
end)

cvars.AddChangeCallback("sbox_persist", function(name, old, new)
    -- A timer in case someone tries to rapily change the convar, such as addons with "live typing" or whatever
    timer.Create("sbox_persist_change_timer", 1, 1, function()
        hook.Run("PersistenceSave", old)
        game.CleanUpMap() -- Maybe this should be moved to PersistenceLoad?
        if new == "" then return end
        hook.Run("PersistenceLoad", new)
    end)
end, "sbox_persist_load")

--[[
    Game runs a lot better on x86 with our Systems. 
]]
hook.Add("HUDPaint", "WARNINGCL", function()
    if BRANCH ~= "x86-64" then
        draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
