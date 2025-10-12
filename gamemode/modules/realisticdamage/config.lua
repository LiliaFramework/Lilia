lia.config.add("DeathSoundEnabled", "enableDeathSound", true, nil, {
    desc = "enableDeathSoundDesc",
    category = "audio",
    type = "Boolean"
})

lia.config.add("LimbDamage", "limbDamageMultiplier", 0.5, nil, {
    desc = "limbDamageMultiplierDesc",
    category = "combat",
    type = "Float",
    min = 0.1,
    max = 1
})

lia.config.add("DamageScale", "globalDamageScale", 1, nil, {
    desc = "globalDamageScaleDesc",
    category = "combat",
    type = "Float",
    min = 0.1,
    max = 5
})

lia.config.add("HeadShotDamage", "headshotDamageMultiplier", 2, nil, {
    desc = "headshotDamageMultiplierDesc",
    category = "combat",
    type = "Float",
    min = 1,
    max = 10
})
