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
            message = Color(83, 143, 239)
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

function LiliaDeprecated(methodName, callback)
    local message = string.format("%s is deprecated. Please use the new methods for optimization purposes.", methodName)
    LiliaLog("deprecated", message)
    if callback and isfunction(callback) then callback() end
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

function GM:Initialize()
    if engine.ActiveGamemode() == "lilia" then LiliaError("No schema loaded. Please place the schema in your gamemodes folder, then set it as your gamemode.") end
    if SERVER then
        LiliaBootstrap("Bootstrapper", "Starting boot sequence...")
    else
        hook.Run("LoadLiliaFonts", "Arial", "Segoe UI")
        lia.option.load()
        lia.keybind.load()
    end

    lia.config.load()
    lia.module.initialize(true)
end

function GM:OnReloaded()
    if not modulesLoaded then
        lia.module.initialize(false)
        modulesLoaded = true
    end

    lia.config.load()
    lia.faction.formatModelData()
    if SERVER then
        LiliaBootstrap("Bootstrapper", "Starting reload sequence...")
    else
        hook.Run("LoadLiliaFonts", lia.config.get("Font"), lia.config.get("GenericFont"))
        lia.option.load()
        lia.keybind.load()
    end
end

if game.IsDedicated() then concommand.Remove("gm_save") end
