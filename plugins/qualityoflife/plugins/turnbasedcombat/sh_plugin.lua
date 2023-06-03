PLUGIN.TotalCombats = PLUGIN.TotalCombats or {}
PLUGIN.Data = {}
PLUGIN.name = "Turn Based Combat System"
PLUGIN.author = "SHOOTER#5269/Leonheart#7476"
PLUGIN.desc = "Implements a turn based combat system, that works for PvE, PvP, PvPvE"
lia.util.include("sv_plugin.lua")
lia.util.include("sh_config.lua")
lia.util.include("cl_plugin.lua")
--[[
Known Bugs:
- NPCs that you don't enter turn based conbat with, most flying NPCs should be added due to them not liking to freeze when not there turn is active
- The plugin will not work on singleplayer. I have no clue why It just don't.
- The server may spit out nul values when players are flip flopping between turns. The combat works normally but it's still going to spit it out.
- Some NPC won't freeze properly and will continue to attack even when frozen 
- Projectile based weapons can not initiate ranged combat
- Granades will still explode. (I'd love to have them join the turn order but for some reason they aren't counted as true NPCs)
--]]