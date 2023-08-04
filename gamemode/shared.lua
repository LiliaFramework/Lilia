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
lia.module.loaded = false

function GM:OnReloaded()
    if SERVER then
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client)
        end

        if not lia.module.loaded then
            lia.module.initialize()
            lia.module.loaded = true
        end

        lia.faction.formatModelData()
    else
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)

        if not lia.module.loaded then
            lia.module.initialize()
            lia.module.loaded = true
        end

        lia.faction.formatModelData()
    end
end

--------------------------------------------------------------------------------------------------------
function GM:Initialize()
    lia.module.initialize()
    lia.module.load()
end

--------------------------------------------------------------------------------------------------------
if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save")

    concommand.Add("gm_save", function(client, command, arguments)
        print("COMMAND DISABLED")
    end)
end