DeriveGamemode("sandbox")
GM.Name = "Lilia"
GM.Author = "Samael"
GM.Website = "https://discord.gg/esCRH5ckbQ"
local modulesLoaded = false
local function LiliaLog(messageType, message, section, color)
    local colors = {
        bootstrap = {
            prefix = Color(83, 143, 239),
            section = Color(0, 255, 0),
            message = Color(255, 255, 255)
        },
        error = {
            prefix = Color(83, 143, 239),
            message = Color(255, 0, 0)
        },
        deprecated = {
            prefix = Color(83, 143, 239),
            message = Color(255, 255, 0)
        },
        information = {
            prefix = Color(83, 143, 239),
            message = Color(0, 0, 255)
        },
        event = {
            prefix = Color(83, 143, 239),
            message = Color(255, 165, 0)
        },
        print = {
            prefix = Color(83, 143, 239),
            message = Color(255, 255, 255)
        }
    }

    local logType = colors[messageType] or colors.print
    MsgC(logType.prefix, "[Lilia] ")
    if messageType == "bootstrap" and section then MsgC(colors.bootstrap.section, "[" .. section .. "] ") end
    MsgC(color or logType.message, message .. "\n")
end

function LiliaError(message)
    LiliaLog("error", message)
end

function LiliaDeprecated(message)
    LiliaLog("deprecated", message)
end

function LiliaInformation(message)
    LiliaLog("information", message)
end

function LiliaEvent(section, message)
    LiliaLog("event", message, section)
end

function LiliaBootstrap(section, message)
    LiliaLog("bootstrap", message, section)
end

function LiliaPrint(message)
    LiliaLog("print", message)
end

function print(...)
    for _, msg in ipairs({...}) do
        LiliaPrint(tostring(msg))
    end
end

function stripRealmPrefix(name)
    local prefix = name:sub(1, 3)
    return (prefix == "sh_" or prefix == "sv_" or prefix == "cl_") and name:sub(4) or name
end

local function ExecuteServerCommands(commands)
    for _, cmd in ipairs(commands) do
        game.ConsoleCommand(cmd .. "\n")
    end
end

local function RemoveHintTimers()
    for _, timerName in ipairs({"HintSystem_OpeningMenu", "HintSystem_Annoy1", "HintSystem_Annoy2"}) do
        if timer.Exists(timerName) then timer.Remove(timerName) end
    end
end

function GM:Initialize()
    if engine.ActiveGamemode() == "lilia" then LiliaError("No schema loaded. Please place the schema in your gamemodes folder, then set it as your gamemode.") end
    if SERVER then
        LiliaBootstrap("Bootstrapper", "Starting boot sequence...")
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
        LiliaBootstrap("Bootstrapper", "Starting reload sequence...")
    else
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
    end

    RemoveHintTimers()
end

if game.IsDedicated() then concommand.Remove("gm_save") end