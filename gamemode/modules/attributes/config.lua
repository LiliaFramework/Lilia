lia.config.add("MaxStartingAttributes", "Max Starting Attributes", 30, nil, {
    desc = "Maximum value of each attribute at character creation.",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("StartingAttributePoints", "Starting Attribute Points", 30, nil, {
    desc = "Total number of points available for starting attribute allocation.",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})

lia.config.add("maxAttributes", "Max Attributes", 100, nil, {
    desc = "The maximum total number of attribute points a character can have.",
    category = "Core",
    type = "Int",
    min = 1,
    max = 1000
})

lia.config.add("MaxAttributePoints", "Max Attribute Points", 30, nil, {
    desc = "Maximum number of points that can be allocated across an attribute.",
    category = "Core",
    isGlobal = true,
    type = "Number",
    min = 1,
    max = 100
})