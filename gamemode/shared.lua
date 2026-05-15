GM.Name = "Lilia"
GM.version = 7.430
GM.Author = "Samael"
GM.Website = "https://discord.gg/esCRH5ckbQ"
include("core/libraries/loader.lua")
local hints = {"Annoy1", "Annoy2", "OpeningMenu", "OpeningContext", "ContextClick", "PhysgunFreeze", "PhysgunUnfreeze", "PhysgunUse", "VehicleView", "ColorRoom", "EditingSpawnlists", "EditingSpawnlistsSave"}
for _, hint in ipairs(hints) do
    hook.Run("SuppressHint", hint)
end