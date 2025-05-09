lia.config.add("DeathSoundEnabled", "Enable Death Sound", true, nil, {
    desc = "Enable or disable death sounds globally.",
    category = "Audio",
    type = "Boolean"
})

lia.config.add("LimbDamage", "Limb Damage Multiplier", 0.5, nil, {
    desc = "Sets the damage multiplier for limb hits.",
    category = "Combat",
    type = "Float",
    min = 0.1,
    max = 1
})

lia.config.add("DamageScale", "Global Damage Scale", 1, nil, {
    desc = "Scales all damage dealt by this multiplier.",
    category = "Combat",
    type = "Float",
    min = 0.1,
    max = 5
})

lia.config.add("HeadShotDamage", "Headshot Damage Multiplier", 2, nil, {
    desc = "Sets the damage multiplier for headshots.",
    category = "Combat",
    type = "Float",
    min = 1,
    max = 10
})
