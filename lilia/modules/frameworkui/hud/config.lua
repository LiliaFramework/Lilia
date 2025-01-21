lia.config.add("Vignette", "Enable Vignette Effect", true, nil, {
    desc = "Enables the vignette effect",
    category = "Visuals",
    type = "Boolean"
})

lia.config.add("CrosshairEnabled", "Enable Crosshair", false, nil, {
    desc = "Enables the crosshair",
    category = "Visuals",
    type = "Boolean"
})

lia.config.add("BarsDisabled", "Disable Bars", false, nil, {
    desc = "Disables bars",
    category = "Visuals",
    type = "Boolean"
})

lia.config.add("AmmoDrawEnabled", "Enable Ammo Display", true, nil, {
    desc = "Enables ammo display",
    category = "Visuals",
    type = "Boolean"
})

lia.config.add("WatermarkEnabled", "Enable Watermark", false, nil, {
    desc = "Enables the watermark display",
    category = "Visuals",
    type = "Boolean"
})

lia.config.add("WatermarkLogo", "Watermark Logo Path", "", nil, {
    desc = "The path to the watermark image (PNG)",
    category = "Visuals",
    type = "Generic"
})

lia.config.add("GamemodeVersion", "Gamemode Version", "", nil, {
    desc = "The version of the gamemode",
    category = "Visuals",
    type = "Generic"
})

MODULE.colors = {}
MODULE.colors.accentColor = Color(225, 75, 75)
MODULE.colors.darkL1 = Color(25, 25, 25)
MODULE.colors.darkL2 = Color(30, 30, 30)
MODULE.colors.darkL3 = Color(35, 35, 35)
BC_WARNING = Color(222, 217, 71)
BC_CRITICAL = Color(225, 75, 75)
BC_AGREE = Color(75, 225, 75)
BC_NEUTRAL = Color(206, 80, 80)
BC_NEUTRAL_HOV = Color(70, 163, 255)
