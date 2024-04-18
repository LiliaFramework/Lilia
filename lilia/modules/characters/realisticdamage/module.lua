--[[--
Characters - Realistic Damage

**Configuration Values:**.

- **DrowningEnabled**: Indicates whether drowning is enabled | **bool**.

- **DamageScalerEnabled**: Indicates whether damage scaling is enabled | **bool**.

- **HurtSoundEnabled**: Indicates whether hurt sounds are enabled | **bool**.

- **DeathSoundEnabled**: Indicates whether death sounds are enabled | **bool**.

- **LimbDamage**: Damage multiplier for limb hits | **float**.

- **DamageScale**: Global damage scale multiplier | **float**.

- **HeadShotDamage**: Damage multiplier for headshots | **float**.

- **DrownTime**: Time (in seconds) it takes for a character to drown | **integer**.

- **DrownDamage**: Amount of damage dealt per second while drowning | **integer**.

- **LimbHitgroups**: Hitgroups considered as limbs | **table**.

- **MaleDeathSounds**: Sounds played when a male character dies | **table**.

- **MaleHurtSounds**: Sounds played when a male character is hurt | **table**.

- **FemaleDeathSounds**: Sounds played when a female character dies | **table**.

- **FemaleHurtSounds**: Sounds played when a female character is hurt | **table**.

- **DrownSounds**: Sounds played when a character is drowning | **table**.

- **InjuriesTable**: Defines the text referring to condition that appears when looking at someone | **table**.
]]
-- @configurations RealisticDamage
MODULE.name = "Characters - Realistic Damage"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds Damage Scalers for Realism"