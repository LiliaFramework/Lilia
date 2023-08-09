MODULE.name = "Stamina"
MODULE.author = "Leonheart#7476/Cheesenut"
MODULE.desc = "Adds a stamina system to limit running."
PLUGIN.DevMode = false
lia.util.includeDir(PLUGIN.folder .. "/commands", true, true)

MODULE.RollMultiplier = 1 -- Bonus roll multiplier on the commands
MODULE.StrengthMultiplier = 2.0 -- Percentage bonus damage melee weapons do
MODULE.PunchStrengthMultiplier = 0.7 -- Extra damage multiplier for punches
MODULE.MeleeWeapons = {"weapon_crowbar", "weapon_knife",}
