--------------------------------------------------------------------------------------------------------
DeriveGamemode("sandbox")
--------------------------------------------------------------------------------------------------------
PluginsLoaded = false
--------------------------------------------------------------------------------------------------------
GM.Name = "Lilia 2.0"
GM.Author = "Chessnut, Black Tea and Leonheart#7476"
GM.Website = "https://discord.gg/RTcVq92HsH"
GM.version = "1.0"
--------------------------------------------------------------------------------------------------------
function GM:Initialize()
    lia.module.initialize()
    lia.config.load()
    self:InitializedClientHooks()
end
--------------------------------------------------------------------------------------------------------
function GM:OnReloaded()
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
    else
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client)
        end
    end

    if not PluginsLoaded then
        lia.modules.initialize()
        lia.config.load()
        PluginsLoaded = true
    end

    lia.faction.formatModelData()
end
--------------------------------------------------------------------------------------------------------
if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save"

    concommand.Add("gm_save", function(client, command, arguments)
        print("COMMAND DISABLED")
    end)
end
--------------------------------------------------------------------------------------------------------