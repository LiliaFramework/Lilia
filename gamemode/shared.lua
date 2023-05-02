-- Define gamemode information.
GM.Name = "Lilia 1.0"
GM.Author = "Cheesenot, Black Tea and Leonheart#7476"
GM.Website = "https://discord.gg/RTcVq92HsH"
lia.version = "1.0"

-- Fix for client:SteamID64() returning nil when in single-player.
do
    local playerMeta = FindMetaTable("Player")
    playerMeta.liaSteamID64 = playerMeta.liaSteamID64 or playerMeta.SteamID64

    -- Overwrite the normal SteamID64 method.
    function playerMeta:SteamID64()
        return self:liaSteamID64() or 0
    end

    -- Return 0 if the SteamID64 could not be found.
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

-- Include core framework files.
lia.util.includeDir("core/libs/thirdparty")
lia.util.include("core/sh_config.lua")
lia.util.includeDir("core/libs")
lia.util.includeDir("core/derma")
lia.util.includeDir("core/hooks")
-- Include language and default base items.
lia.lang.loadFromDir("lilia/gamemode/languages")
lia.item.loadFromDir("lilia/gamemode/items")
lia.item.loadFromDir("lilia/gamemode/commands")

-- Called after the gamemode has loaded.
function GM:Initialize()
    -- Load all of the Lilia plugins.
    lia.plugin.initialize()
    -- Restore the configurations from earlier if applicable.
    lia.config.load()
end

LIA_PLUGINS_ALREADY_LOADED = false

-- Called when a file has been modified.
function GM:OnReloaded()
    -- Reload the default fonts.
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont"))
    else
        -- Auto-reload support for faction pay timers.
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client)
        end
    end

    if not LIA_PLUGINS_ALREADY_LOADED then
        -- Load all of the Lilia plugins.
        lia.plugin.initialize()
        -- Restore the configurations from earlier if applicable.
        lia.config.load()
        LIA_PLUGINS_ALREADY_LOADED = true
    end

    lia.faction.formatModelData()
end

-- Include default Lilia chat commands.
if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save")
    concommand.Add("gm_save", function(client, command, arguments) end)
end