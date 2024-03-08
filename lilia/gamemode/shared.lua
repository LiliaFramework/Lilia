--[[--
Entity menu manipulation.

The Basic Syntax For Lilia Documentation.
Top-level library containing all Lilia libraries. A large majority of the framework is split into respective libraries that
reside within `lia`.
]]
-- @libraries lia
DeriveGamemode("sandbox")
GM.Name = "Lilia"
GM.Author = "Leonheart"
GM.Website = "https://discord.gg/jjrhyeuzYV"
ModulesLoaded = false
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

if game.IsDedicated() then concommand.Remove("gm_save") end
