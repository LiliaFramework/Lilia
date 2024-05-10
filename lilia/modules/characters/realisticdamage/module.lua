--- Configuration for RealisticDamage Module.
-- @configurations RealisticDamage


--- This table defines the default settings for the RealisticDamage Module.
-- @realm shared
-- @table Configuration
-- @field DrowningEnabled Indicates whether drowning is enabled | bool
-- @field DamageScalerEnabled Indicates whether damage scaling is enabled | bool
-- @field HurtSoundEnabled Indicates whether hurt sounds are enabled | bool
-- @field DeathSoundEnabled Indicates whether death sounds are enabled | bool
-- @field LimbDamage Damage multiplier for limb hits | **float**
-- @field DamageScale Global damage scale multiplier | **float**
-- @field HeadShotDamage Damage multiplier for headshots | **float**
-- @field DrownTime Time (in seconds) it takes for a character to drown | integer
-- @field DrownDamage Amount of damage dealt per second while drowning | integer
-- @field LimbHitgroups Hitgroups considered as limbs | table
-- @field MaleDeathSounds Sounds played when a male character dies | table
-- @field MaleHurtSounds Sounds played when a male character is hurt | table
-- @field FemaleDeathSounds Sounds played when a female character dies | table
-- @field FemaleHurtSounds Sounds played when a female character is hurt | table
-- @field DrownSounds Sounds played when a character is drowning | table
-- @field InjuriesTable Defines the text referring to condition that appears when looking at someone | table
MODULE.name = "Characters - Realistic Damage"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds Damage Scalers for Realism"
