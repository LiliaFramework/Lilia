--[[
    Hooks:
        SuppressHint(string hint)

    Purpose:
        Runs during shared initialization for each default Source hint name so modules can suppress built-in HUD hints.

    Category:
        UI

    Parameters:
        hint (string)
            The engine hint identifier being suppressed, such as `PhysgunFreeze` or `VehicleView`.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("SuppressHint", "liaExampleSuppressHint", function(hint)
            if hint == "PhysgunFreeze" then
                print("Suppressing hint:", hint)
            end
        end)
        ```

    Realm:
        Shared
]]
GM.Name = "Lilia"
GM.version = 7.565
GM.Author = "Samael"
GM.Website = "https://discord.gg/esCRH5ckbQ"
include("core/libraries/loader.lua")
local hints = {"Annoy1", "Annoy2", "OpeningMenu", "OpeningContext", "ContextClick", "PhysgunFreeze", "PhysgunUnfreeze", "PhysgunUse", "VehicleView", "ColorRoom", "EditingSpawnlists", "EditingSpawnlistsSave"}
for _, hint in ipairs(hints) do
    hook.Run("SuppressHint", hint)
end
