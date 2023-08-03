GM.Name = "Lilia 1.0"
GM.Author = "Chessnut, Black Tea and Leonheart#7476"
GM.Website = "https://discord.gg/RTcVq92HsH"
lia.version = "1.0"
--------------------------------------------------------------------------------------------------------
lia.util.includeDir("core/config")
lia.util.include("core/sh_definitions.lua")
lia.util.includeDir("core/derma")
lia.lang.loadFromDir("lilia/gamemode/languages")
lia.item.loadFromDir("lilia/gamemode/items")

--------------------------------------------------------------------------------------------------------
function GM:Initialize()
    lia.module.initialize()
end

--------------------------------------------------------------------------------------------------------
if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save")

    concommand.Add("gm_save", function(client, command, arguments)
        print("COMMAND DISABLED")
    end)
end