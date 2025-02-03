lia.config.add("sbWidth", L("sbWidth"), 0.35, nil, {
    desc = L("sbWidthDesc"),
    category = L("scoreboard"),
    type = "Float",
    min = 0.1,
    max = 1.0
})

lia.config.add("sbHeight", L("sbHeight"), 0.65, nil, {
    desc = L("sbHeightDesc"),
    category = L("scoreboard"),
    type = "Float",
    min = 0.1,
    max = 1.0
})

lia.config.add("ShowStaff", L("showStaff"), true, nil, {
    desc = L("showStaffDesc"),
    category = L("scoreboard"),
    type = "Boolean"
})

lia.config.add("DisplayServerName", L("displayServerName"), false, nil, {
    desc = L("displayServerNameDesc"),
    category = L("scoreboard"),
    type = "Boolean"
})

lia.config.add("UseSolidBackground", L("useSolidBackground"), false, nil, {
    desc = L("useSolidBackgroundDesc"),
    category = L("scoreboard"),
    type = "Boolean"
})

lia.config.add("ScoreboardBackgroundColor", L("scoreboardBackgroundColor"), {
    r = 255,
    g = 100,
    b = 100,
    a = 255
}, nil, {
    desc = L("scoreboardBackgroundColorDesc"),
    category = L("scoreboard"),
    type = "Color"
})