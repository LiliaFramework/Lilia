GM.Name = "Lilia 1.0"
GM.Author = "Chessnut, Black Tea and Leonheart#7476"
GM.Website = "https://discord.gg/RTcVq92HsH"
lia.version = "1.0"

do
    local playerMeta = FindMetaTable("Player")
    playerMeta.liaSteamID64 = playerMeta.liaSteamID64 or playerMeta.SteamID64

    function playerMeta:SteamID64()
        return self:liaSteamID64() or 0
    end

    LiliaTranslateModel = LiliaTranslateModel or player_manager.TranslateToPlayerModelName

    function player_manager.TranslateToPlayerModelName(model)
        model = model:lower():gsub("\\", "/")
        local result = LiliaTranslateModel(model)

        if result == "kleiner" and not model:find("kleiner") then
            local model2 = model:gsub("models/", "models/player/")
            result = LiliaTranslateModel(model2)
            if result ~= "kleiner" then return result end
            model2 = model:gsub("models/humans", "models/player")
            result = LiliaTranslateModel(model2)
            if result ~= "kleiner" then return result end
            model2 = model:gsub("models/zombie/", "models/player/zombie_")
            result = LiliaTranslateModel(model2)
            if result ~= "kleiner" then return result end
        end

        return result
    end
end

lia.util.includeDir("core/libs/thirdparty")
lia.util.include("core/sh_config.lua")
lia.util.includeDir("core/libs")
lia.util.includeDir("core/derma")
lia.util.includeDir("core/hooks")
lia.lang.loadFromDir("lilia/gamemode/languages")
lia.item.loadFromDir("lilia/gamemode/items")
lia.item.loadFromDir("lilia/gamemode/commands")

function GM:Initialize()
    lia.plugin.initialize()
    lia.config.load()
end

LIA_PLUGINS_ALREADY_LOADED = false

function GM:OnReloaded()
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont"))
    else
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client)
        end
    end

    if not LIA_PLUGINS_ALREADY_LOADED then
        lia.plugin.initialize()
        lia.config.load()
        LIA_PLUGINS_ALREADY_LOADED = true
    end

    lia.faction.formatModelData()
end

if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save")

    concommand.Add("gm_save", function(client, command, arguments)
        print("COMMAND DISABLED")
    end)
end