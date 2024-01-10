
--[[ Indicates whether drowning is enabled   ]]
RealisticDamageCore.DrowningEnabled = true

--[[ Indicates whether damage while in cars is enabled   ]]
RealisticDamageCore.DamageInCars = true

--[[ Indicates whether damage scaling is enabled   ]]
RealisticDamageCore.DamageScalerEnabled = true

--[[ Indicates whether hurt sounds are enabled   ]]
RealisticDamageCore.HurtSoundEnabled = true

--[[ Indicates whether death sounds are enabled   ]]
RealisticDamageCore.DeathSoundEnabled = true

--[[ Damage multiplier for limb hits   ]]
RealisticDamageCore.LimbDamage = 0.5

--[[ Global damage scale multiplier   ]]
RealisticDamageCore.DamageScale = 1

--[[ Damage multiplier for headshots   ]]
RealisticDamageCore.HeadShotDamage = 2

--[[ Time (in seconds) it takes for a character to drown   ]]
RealisticDamageCore.DrownTime = 30

--[[ Amount of damage dealt per second while drowning   ]]
RealisticDamageCore.DrownDamage = 10

--[[ Hitgroups considered as limbs ]]
RealisticDamageCore.LimbHitgroups = {HITGROUP_GEAR, HITGROUP_RIGHTARM, HITGROUP_LEFTARM}

--[[ Sounds played when a male character dies   ]]
RealisticDamageCore.MaleDeathSounds = {Sound("vo/npc/male01/pain07.wav"), Sound("vo/npc/male01/pain08.wav"), Sound("vo/npc/male01/pain09.wav")}

--[[ Sounds played when a male character is hurt   ]]
RealisticDamageCore.MaleHurtSounds = {Sound("vo/npc/male01/pain01.wav"), Sound("vo/npc/male01/pain02.wav"), Sound("vo/npc/male01/pain03.wav"), Sound("vo/npc/male01/pain04.wav"), Sound("vo/npc/male01/pain05.wav"), Sound("vo/npc/male01/pain06.wav")}

--[[ Sounds played when a female character dies   ]]
RealisticDamageCore.FemaleDeathSounds = {Sound("vo/npc/female01/pain07.wav"), Sound("vo/npc/female01/pain08.wav"), Sound("vo/npc/female01/pain09.wav")}

--[[ Sounds played when a female character is hurt   ]]
RealisticDamageCore.FemaleHurtSounds = {Sound("vo/npc/female01/pain01.wav"), Sound("vo/npc/female01/pain02.wav"), Sound("vo/npc/female01/pain03.wav"), Sound("vo/npc/female01/pain04.wav"), Sound("vo/npc/female01/pain05.wav"), Sound("vo/npc/female01/pain06.wav")}

--[[ Sounds played when a character is drowning   ]]
RealisticDamageCore.DrownSounds = {Sound("player/pl_drown1.wav"), Sound("player/pl_drown2.wav"), Sound("player/pl_drown3.wav"),}

