lia.config.add("StaminaBlur", L("staminaBlur"), false, nil, {
    desc = L("staminaBlurDesc"),
    category = L("attributes"),
    type = "Boolean"
})

lia.config.add("StaminaSlowdown", L("staminaSlowdown"), true, nil, {
    desc = L("staminaSlowdownDesc"),
    category = L("attributes"),
    type = "Boolean"
})

lia.config.add("DefaultStamina", L("defaultStamina"), 100, nil, {
    desc = L("defaultStaminaDesc"),
    category = L("attributes"),
    type = "Int",
    min = 0,
    max = 1000
})

lia.config.add("StaminaBlurThreshold", L("staminaBlurThreshold"), 25, nil, {
    desc = L("staminaBlurThresholdDesc"),
    category = L("attributes"),
    type = "Int",
    min = 0,
    max = 100
})

lia.config.add("StaminaBreathingThreshold", L("staminaBreathingThreshold"), 50, nil, {
    desc = L("staminaBreathingThresholdDesc"),
    category = L("attributes"),
    type = "Int",
    min = 0,
    max = 100
})

lia.config.add("MaxAttributePoints", L("maxAttributePoints"), 30, nil, {
    desc = L("maxAttributePointsDesc"),
    category = L("attributes"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("MaxStartingAttributes", L("maxStartingAttributes"), 30, nil, {
    desc = L("maxStartingAttributesDesc"),
    category = L("attributes"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("StartingAttributePoints", L("startingAttributePoints"), 30, nil, {
    desc = L("startingAttributePointsDesc"),
    category = L("attributes"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("PunchStamina", L("punchStamina"), 10, nil, {
    desc = L("punchStaminaDesc"),
    category = L("attributes"),
    noNetworking = false,
    schemaOnly = false,
    type = "Int",
    min = 0,
    max = 100
})