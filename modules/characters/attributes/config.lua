lia.config.add("StaminaBlur", "Stamina Blur Enabled", true, nil, {
    desc = "Is Stamina Blur Enabled?",
    category = "Attributes",
    type = "Boolean"
})

lia.config.add("JumpStaminaCost", "Jump Stamina Cost", 20, nil, {
    desc = "Amount of stamina consumed when the player jumps",
    category = "Attributes",
    type = "Int",
    min = 0,
    max = 100
})

lia.config.add("JumpStaminaThreshold", "Jump Stamina Threshold", 25, nil, {
    desc = "Minimum stamina required to perform a jump",
    category = "Attributes",
    type = "Int",
    min = 0,
    max = 100
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

lia.config.add("MaxHoldWeight", "Maximum Hold Weight", 100, nil, {
    desc = "The maximum weight that a player can carry in their hands.",
    category = "General",
    type = "Int",
    min = 1,
    max = 500
})

lia.config.add("ThrowForce", "Throw Force", 100, nil, {
    desc = "How hard a player can throw the item that they're holding.",
    category = "General",
    type = "Int",
    min = 1,
    max = 500
})

lia.config.add("AllowPush", "Allow Push", true, nil, {
    desc = "Whether or not pushing with hands is allowed",
    category = "General",
    type = "Boolean"
})

lia.config.add("StaminaRegenMultiplier", "Stamina Regeneration Multiplier", 1, nil, {
    desc = "Multiplier applied to stamina regeneration rate (higher = faster regeneration)",
    category = "Attributes",
    type = "Int",
    min = 0,
    max = 1000
})
