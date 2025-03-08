lia.config.add("StaminaBlur", "Stamina Blur Enabled", false, nil, {
    desc = "Is Stamina Blur Enabled?",
    category = "Attributes",
    type = "Boolean"
})

lia.config.add("StaminaSlowdown", "Stamina Slowdown Enabled", true, nil, {
    desc = "Is Stamina Slowdown Enabled?",
    category = "Attributes",
    type = "Boolean"
})

lia.config.add("DefaultStamina", "Default Stamina Value", 100, nil, {
    desc = "Sets Default Stamina Value",
    category = "Attributes",
    type = "Int",
    min = 0,
    max = 1000
})

lia.config.add("StaminaBlurThreshold", "Stamina Blur Threshold", 25, nil, {
    desc = "Sets Stamina Threshold for Blur to Show",
    category = "Attributes",
    type = "Int",
    min = 0,
    max = 100
})

lia.config.add("StaminaBreathingThreshold", "Stamina Breathing Threshold", 50, nil, {
    desc = "Sets Stamina Threshold for Breathing to Happen",
    category = "Attributes",
    type = "Int",
    min = 0,
    max = 100
})

lia.config.add("MaxAttributePoints", "Max Attribute Points", 30, nil, {
    desc = "Maximum number of points that can be allocated across an attribute.",
    category = "Attributes",
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("MaxStartingAttributes", "Max Starting Attributes", 30, nil, {
    desc = "Maximum value of each attribute at character creation.",
    category = "Attributes",
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("StartingAttributePoints", "Starting Attribute Points", 30, nil, {
    desc = "Total number of points available for starting attribute allocation.",
    category = "Attributes",
    isGlobal = true,
    type = "Int",
    min = 1,
    max = 100
})

lia.config.add("PunchStamina", "Punch Stamina", 10, nil, {
    desc = "Stamina usage for punches.",
    category = "Attributes",
    isGlobal = true,
    type = "Int",
    min = 0,
    max = 100
})
