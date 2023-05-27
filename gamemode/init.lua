resource.AddWorkshop("2959728255")
DeriveGamemode("sandbox")

lia = lia or {
    util = {},
    meta = {}
}

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("core/sh_util.lua")
AddCSLuaFile("shared.lua")
include("core/sh_util.lua")
include("core/sv_data.lua")
include("shared.lua")

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

cvars.AddChangeCallback("sbox_persist", function(name, old, new)
    timer.Create("sbox_persist_change_timer", 1, 1, function()
        hook.Run("PersistenceSave", old)
        game.CleanUpMap()
        if new == "" then return end
        hook.Run("PersistenceLoad", new)
    end)
end, "sbox_persist_load")

hook.Add("HUDPaint", "WARNINGCL", function()
    if BRANCH ~= "x86-64" then
        draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)