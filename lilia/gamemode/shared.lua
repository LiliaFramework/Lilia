DeriveGamemode("sandbox")
GM.Name = "Lilia"
GM.Author = "Samael"
GM.Website = "https://discord.gg/jjrhyeuzYV"
ModulesLoaded = false
MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Bootstrapper] ", color_white, "Starting shared load...\n")

function GM:Initialize()
    hook.Run("LoadLiliaFonts", "Arial", "Segoe UI")
    lia.module.initialize()
end

function GM:OnReloaded()
    if not ModulesLoaded then
        lia.module.initialize()
        ModulesLoaded = true
    end

    lia.faction.formatModelData()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
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