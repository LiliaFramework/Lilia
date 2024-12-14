DeriveGamemode("sandbox")
GM.Name = "Lilia"
GM.Author = "Samael"
GM.Website = "https://discord.gg/jjrhyeuzYV"
local modulesLoaded = false
local function ExecuteServerCommands(commands)
    for _, cmd in ipairs(commands) do
        game.ConsoleCommand(cmd .. "\n")
    end
end

local function RemoveHintTimers()
    local hintTimers = {"HintSystem_OpeningMenu", "HintSystem_Annoy1", "HintSystem_Annoy2"}
    for _, timerName in ipairs(hintTimers) do
        if timer.Exists(timerName) then timer.Remove(timerName) end
    end
end

function LogBootstrap(section, message, color)
    color = color or color_white
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. section .. "] ", color, message .. "\n")
end

function GM:Initialize()
    if engine.ActiveGamemode() == "lilia" then LogBootstrap("Error", "No schema loaded. Please place the schema in your gamemodes folder, then set it as your gamemode.", Color(255, 0, 0)) end
    if SERVER then
        LogBootstrap("Bootstrapper", "Starting boot sequence...")
        ExecuteServerCommands({"net_maxfilesize 64", "sv_kickerrornum 0", "sv_allowupload 0", "sv_allowdownload 0", "sv_allowcslua 0", "gmod_physiterations 2", "sbox_noclip 0", "sv_minrate 1048576"})
    else
        hook.Run("LoadLiliaFonts", "Arial", "Segoe UI")
    end

    RemoveHintTimers()
    lia.module.initialize(true)
end

function GM:OnReloaded()
    if not modulesLoaded then
        lia.module.initialize(false)
        modulesLoaded = true
    end

    lia.faction.formatModelData()
    if SERVER then
        LogBootstrap("Bootstrapper", "Starting reload sequence...")
    else
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
    end

    RemoveHintTimers()
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

function stripRealmPrefix(name)
    local prefix = name:sub(1, 3)
    return (prefix == "sh_" or prefix == "sv_" or prefix == "cl_") and name:sub(4) or name
end

if game.IsDedicated() then concommand.Remove("gm_save") end