lia.config.add("sbWidth", "Scoreboard Width", 0.35, nil, {
    desc = "Scoreboard Width",
    category = "Scoreboard",
    type = "Float",
    min = 0.1,
    max = 1.0
})

lia.config.add("sbHeight", "Scoreboard Height", 0.65, nil, {
    desc = "Scoreboard Height",
    category = "Scoreboard",
    type = "Float",
    min = 0.1,
    max = 1.0
})

lia.config.add("ShowStaff", "Show Staff in Scoreboard", true, nil, {
    desc = "Should Staff Show In Scoreboard",
    category = "Scoreboard",
    type = "Boolean"
})

lia.config.add("DisplayServerName", "Display Server Name in Scoreboard", false, nil, {
    desc = "Should Server Name Show In Scoreboard",
    category = "Scoreboard",
    type = "Boolean"
})

lia.config.add("UseSolidBackground", "Use Solid Background in Scoreboard", false, nil, {
    desc = "Use a solid background for the scoreboard",
    category = "Scoreboard",
    type = "Boolean"
})

lia.config.add("ScoreboardBackgroundColor", "Scoreboard Background Color", {
    r = 255,
    g = 100,
    b = 100,
    a = 255
}, nil, {
    desc = "Sets the background color of the scoreboard. This only applies if 'UseSolidBackground' is enabled.",
    category = "Scoreboard",
    type = "Color"
})