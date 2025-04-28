DeriveGamemode("sandbox")
GM.Name = "Lilia"
GM.Author = "Samael"
GM.Website = "https://discord.gg/esCRH5ckbQ"
local modulesLoaded = false
local function LiliaLog(messageType, message, section, color)
    local colors = {
        Bootstrap = {
            prefix = Color(83, 143, 239),
            section = Color(0, 255, 0),
            message = Color(255, 255, 255)
        },
        Error = {
            prefix = Color(83, 143, 239),
            message = Color(255, 0, 0)
        },
        Deprecated = {
            prefix = Color(83, 143, 239),
            message = Color(255, 255, 0)
        },
        Information = {
            prefix = Color(83, 143, 239),
            message = Color(83, 143, 239)
        },
        Event = {
            prefix = Color(83, 143, 239),
            message = Color(255, 165, 0)
        },
        Print = {
            prefix = Color(83, 143, 239),
            message = Color(255, 255, 255)
        },
        Updater = {
            prefix = Color(83, 143, 239),
            message = Color(0, 255, 255)
        }
    }

    local logType = colors[messageType] or colors.Print
    MsgC(logType.prefix, "[Lilia] ")
    if messageType then MsgC(logType.prefix, "[" .. messageType .. "] ") end
    if section then MsgC(colors.Bootstrap.section, "[" .. section .. "] ") end
    MsgC(color or logType.message, message .. "\n")
end

function lia.error(message)
    LiliaLog("Error", message)
end

function lia.deprecated(methodName, callback)
    local message = string.format("%s is deprecated. Please use the new methods for optimization purposes.", methodName)
    LiliaLog("Deprecated", message)
    if callback and isfunction(callback) then callback() end
end

function LiliaUpdater(message)
    LiliaLog("Updater", message)
end

function lia.information(message)
    LiliaLog("Information", message)
end

function lia.bootstrap(section, message)
    LiliaLog("Bootstrap", message, section)
end

local function RemoveHintTimers()
    local hintTimers = {"HintSystem_OpeningMenu", "HintSystem_Annoy1", "HintSystem_Annoy2"}
    for _, timerName in ipairs(hintTimers) do
        if timer.Exists(timerName) then timer.Remove(timerName) end
    end
end

function GM:Initialize()
    if engine.ActiveGamemode() == "lilia" then lia.error("No schema loaded. Please place the schema in your gamemodes folder, then set it as your gamemode.") end
    if SERVER then
        lia.bootstrap("Bootstrapper", "Starting boot sequence...")
    else
        hook.Run("l", "Arial", "Segoe UI")
    end

    lia.config.load()
    lia.module.initialize(true)
    if CLIENT then
        lia.option.load()
        lia.keybind.load()
        RemoveHintTimers()
    end
end

function GM:OnReloaded()
    if not modulesLoaded then
        lia.module.initialize(false)
        modulesLoaded = true
    end

    lia.config.load()
    lia.faction.formatModelData()
    if SERVER then lia.bootstrap("Bootstrapper", "Starting reload sequence...") end
    if CLIENT then
        lia.option.load()
        lia.keybind.load()
        RemoveHintTimers()
    end
end

if game.IsDedicated() then concommand.Remove("gm_save") end