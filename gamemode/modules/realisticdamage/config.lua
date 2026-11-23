lia.config.add("RealisticDamageHeadMultiplier", "Realistic Damage Head Multiplier", 2, nil, {
    category = "Realistic Damage",
    type = "Number",
    min = 1,
    max = 5,
    desc = "Damage multiplier applied to headshots by the sample realistic damage module."
})

lia.config.add("RealisticDamageLimbMultiplier", "Realistic Damage Limb Multiplier", 0.5, nil, {
    category = "Realistic Damage",
    type = "Number",
    min = 0.1,
    max = 1,
    desc = "Damage multiplier applied to arm and leg hits by the sample realistic damage module."
})

