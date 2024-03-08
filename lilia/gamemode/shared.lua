--- Top-level library containing all Lilia libraries. A large majority of the framework is split into respective libraries that
-- reside within `lia`.
-- @module lia
--- A table of variable types that are used throughout the framework. It represents types as a table with the keys being the
-- name of the type, and the values being some number value. **You should never directly use these number values!** Using the
-- values from this table will ensure backwards compatibility if the values in this table change.
-- This table also contains the numerical values of the types as keys. This means that if you need to check if a type exists, or
-- if you need to get the name of a type, you can do a table lookup with a numerical value. Note that special types are not
-- included since they are not real types that can be compared with.
-- @realm shared
-- @field string A regular string. In the case of `lia.command.add`, this represents one word.
-- @field text A regular string. In the case of `lia.command.add`, this represents all words concatenated into a string.
-- @field number Any number.
-- @field player Any player that matches the given query string in `lia.util.FindPlayer`.
-- @field character Any player's character that matches the given query string in `lia.util.findPlayer`.
-- @field bool A string representation of a bool - `false` and `0` will return `false`, anything else will return `true`.
-- @field color A color represented by its red/green/blue/alpha values.
-- @field vector A 3D vector represented by its x/y/z values.
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