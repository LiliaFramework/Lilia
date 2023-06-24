GM.Name = "Lilia 1.0"
GM.Author = "Chessnut, Black Tea and Leonheart#7476"
GM.Website = "https://discord.gg/RTcVq92HsH"
lia.version = "1.0"

do
    local playerMeta = FindMetaTable("Player") -- Get the metatable for the Player entity
    playerMeta.liaSteamID64 = playerMeta.liaSteamID64 or playerMeta.SteamID64 -- Add a new field to store the original SteamID64 function

    function playerMeta:SteamID64()
        return self:liaSteamID64() or 0 -- Override the SteamID64 function to return the original SteamID64 or 0 if it doesn't exist
    end

    LiliaTranslateModel = LiliaTranslateModel or player_manager.TranslateToPlayerModelName -- Store the original TranslateToPlayerModelName function

    function player_manager.TranslateToPlayerModelName(model)
        model = model:lower():gsub("\\", "/") -- Convert the model path to lowercase and replace backslashes with forward slashes
        local result = LiliaTranslateModel(model) -- Call the original TranslateToPlayerModelName function

        if result == "kleiner" and not model:find("kleiner") then
            local model2 = model:gsub("models/", "models/player/") -- Modify the model path by replacing "models/" with "models/player/"
            result = LiliaTranslateModel(model2) -- Call the original TranslateToPlayerModelName function with the modified model path
            if result ~= "kleiner" then return result end -- Return the result if it's not "kleiner"
            model2 = model:gsub("models/humans", "models/player") -- Modify the model path by replacing "models/humans" with "models/player"
            result = LiliaTranslateModel(model2) -- Call the original TranslateToPlayerModelName function with the modified model path
            if result ~= "kleiner" then return result end -- Return the result if it's not "kleiner"
            model2 = model:gsub("models/zombie/", "models/player/zombie_") -- Modify the model path by replacing "models/zombie/" with "models/player/zombie_"
            result = LiliaTranslateModel(model2) -- Call the original TranslateToPlayerModelName function with the modified model path
            if result ~= "kleiner" then return result end -- Return the result if it's not "kleiner"
        end
        -- Return the original result

        return result
    end
end

lia.util.include("lilia/gamemode/core/meta/sh_meta.lua") -- Include the shared (client and server) metatable file
lia.util.include("lilia/gamemode/core/meta/sv_meta.lua") -- Include the server-only metatable file
lia.util.includeDir("core/libs/thirdparty") -- Include all files in the "thirdparty" directory of the "libs" folder
lia.util.include("core/sh_config.lua") -- Include the shared (client and server) configuration file
lia.util.includeDir("core/libs") -- Include all files in the "libs" directory of the "core" folder
lia.util.includeDir("core/derma") -- Include all files in the "derma" directory of the "core" folder
lia.util.includeDir("core/hooks") -- Include all files in the "hooks" directory of the "core" folder
lia.lang.loadFromDir("lilia/gamemode/languages") -- Load language files from the "languages" directory of the "lilia/gamemode" folder
lia.item.loadFromDir("lilia/gamemode/items") -- Load item files from the "items" directory of the "lilia/gamemode" folder
lia.util.includeDir("lilia/gamemode/commands") -- Load command files from the "commands" directory of the "lilia/gamemode" folder

function GM:Initialize()
    lia.plugin.initialize() -- Initialize the plugin system
    lia.config.load() -- Load configuration settings
end

LIA_PLUGINS_ALREADY_LOADED = false

function GM:OnReloaded()
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont")) -- Run the "LoadLiliaFonts" hook on the client, passing font parameters from the configuration
    else
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client) -- Run the "CreateSalaryTimer" hook for each player on the server
        end
    end

    if not LIA_PLUGINS_ALREADY_LOADED then
        lia.plugin.initialize() -- Initialize the plugin system if it hasn't been loaded before
        lia.config.load() -- Load configuration settings if they haven't been loaded before
        LIA_PLUGINS_ALREADY_LOADED = true -- Mark the plugins as already loaded
    end

    lia.faction.formatModelData() -- Format model data for factions
end

if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save") -- Remove the "gm_save" console command

    concommand.Add("gm_save", function(client, command, arguments)
        print("COMMAND DISABLED") -- Print a message indicating that the command is disabled
    end)
end