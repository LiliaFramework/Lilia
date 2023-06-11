resource.AddWorkshop("2959728255") -- Adds the gamemode content
DeriveGamemode("sandbox") -- Derive the current gamemode from the "sandbox" gamemode

lia = lia or {
    util = {},
    meta = {}
}

AddCSLuaFile("cl_init.lua") -- Add the specified file to be sent to clients when needed
AddCSLuaFile("core/sh_util.lua")
AddCSLuaFile("shared.lua")
include("core/sh_util.lua") -- Include the specified Lua file on the server
include("core/sv_data.lua")
include("shared.lua") -- Include the specified Lua file on the server

timer.Simple(0, function()
    hook.Run("SetupDatabase") -- Call the "SetupDatabase" hook

    -- Connect to the database using a callback function
    lia.db.connect(function()
        lia.db.loadTables() -- Load database tables
        lia.log.loadTables() -- Load log tables
        MsgC(Color(0, 255, 0), "Lilia has connected to the database.\n") -- Print a message to the console
        MsgC(Color(0, 255, 0), "Database Type: " .. lia.db.module .. ".\n") -- Print a message to the console with the database type
        hook.Run("DatabaseConnected") -- Call the "DatabaseConnected" hook
    end)
end)

cvars.AddChangeCallback("sbox_persist", function(name, old, new)
    timer.Create("sbox_persist_change_timer", 1, 1, function()
        hook.Run("PersistenceSave", old) -- Call the "PersistenceSave" hook with the old value
        game.CleanUpMap() -- Clean up the map
        if new == "" then return end
        hook.Run("PersistenceLoad", new) -- Call the "PersistenceLoad" hook with the new value
    end)
end, "sbox_persist_load")

-- Add a change callback for the "sbox_persist" convar
hook.Add("HUDPaint", "WARNINGCL", function()
    -- Check if the server is running on the x86-64 branch
    if BRANCH ~= "x86-64" then
        draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)