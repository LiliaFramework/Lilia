DeriveGamemode("sandbox")
GM.Name = "Lilia"
GM.Author = "Samael"
GM.Website = "https://discord.gg/jjrhyeuzYV"
ModulesLoaded = false
MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Bootstrapper] ", color_white, "Starting shared load...\n")
function GM:Initialize()
    if SERVER then
        game.ConsoleCommand("net_maxfilesize 64\n")
        game.ConsoleCommand("sv_kickerrornum 0\n")
        game.ConsoleCommand("sv_allowupload 0\n")
        game.ConsoleCommand("sv_allowdownload 0\n")
        game.ConsoleCommand("sv_allowcslua 0\n")
        game.ConsoleCommand("gmod_physiterations 2\n")
        game.ConsoleCommand("sv_minrate 1048576\n")
    else
        timer.Remove("HintSystem_OpeningMenu")
        timer.Remove("HintSystem_Annoy1")
        timer.Remove("HintSystem_Annoy2")
        hook.Run("LoadLiliaFonts", "Arial", "Segoe UI")
    end

    lia.module.initialize(true)
end

function GM:OnReloaded()
    if not ModulesLoaded then
        lia.module.initialize(false)
        ModulesLoaded = true
    end

    lia.faction.formatModelData()
    if CLIENT then
        timer.Remove("HintSystem_OpeningMenu")
        timer.Remove("HintSystem_Annoy1")
        timer.Remove("HintSystem_Annoy2")
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
    end
end

function LiliaPrint(message, color)
    color = color or Color(255, 255, 255)
    MsgC(Color(83, 143, 239), "[Lilia] ", color, message .. "\n")
end

function LiliaError(message)
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 0, 0), message .. "\n")
end

function LiliaDeprecated(message)
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 0), message .. "\n")
end

function LiliaInformation(message)
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 0, 255), message .. "\n")
end

if game.IsDedicated() then concommand.Remove("gm_save") end