--------------------------------------------------------------------------------------------------------------------------
DeriveGamemode("sandbox")
--------------------------------------------------------------------------------------------------------------------------
ModulesLoaded = false
--------------------------------------------------------------------------------------------------------------------------
GM.Name = "Lilia 2.0"
GM.Author = "@liliaplayer"
GM.Website = "https://discord.gg/jWCEUEKQ"
lia.version = "2.0"
--------------------------------------------------------------------------------------------------------------------------
function GM:Initialize()
    lia.module.initialize()
    self:DevelopmentServerLoader()
    self:PSALoader()
end

--------------------------------------------------------------------------------------------------------------------------
function GM:OnReloaded()
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
    else
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client)
        end
    end

    if not ModulesLoaded then
        lia.module.initialize()
        ModulesLoaded = true
    end

    lia.faction.formatModelData()
end

--------------------------------------------------------------------------------------------------------------------------
if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save")
    concommand.Add("gm_save", function(client, command, arguments) end)
end
--------------------------------------------------------------------------------------------------------------------------
