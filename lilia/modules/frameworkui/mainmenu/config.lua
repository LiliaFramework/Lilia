lia.config.add("MusicVolume", "Music Volume", 0.25, nil, {
    desc = "The volume level for the main menu music",
    category = "Main Menu",
    type = "Float",
    min = 0.0,
    max = 1.0
})

lia.config.add("Music", "Main Menu Music", "", nil, {
    desc = "The file path or URL for the main menu background music",
    category = "Main Menu",
    type = "Generic"
})

lia.config.add("BackgroundURL", "Main Menu Background URL", "", nil, {
    desc = "The URL or file path for the main menu background image",
    category = "Main Menu",
    type = "Generic"
})

lia.config.add("CenterLogo", "Center Logo", "", nil, {
    desc = "The file path or URL for the logo displayed at the center of the screen",
    category = "Main Menu",
    type = "Generic"
})

lia.config.add("ButtonLogo", "Button Logo", "", nil, {
    desc = "The file path or URL for the logo displayed on the button",
    category = "Main Menu",
    type = "Generic"
})

lia.config.add("ButtonURL", "Button URL", "", nil, {
    desc = "The URL opened when the button with ButtonLogo is clicked",
    category = "Main Menu",
    type = "Generic"
})

lia.config.add("CharMenuBGInputDisabled", "Character Menu BG Input Disabled", true, nil, {
    desc = "Whether background input is disabled during character menu use",
    category = "Main Menu",
    type = "Boolean"
})

lia.config.add("KickOnEnteringMainMenu", "Kick on Entering Main Menu", false, nil, {
    desc = "Whether players are kicked upon entering the main menu",
    category = "Main Menu",
    type = "Boolean"
})

lia.config.add("CanSelectBodygroups", "Can Select Bodygroups", true, nil, {
    desc = "Whether players can select bodygroups in the character menu",
    category = "Main Menu",
    type = "Boolean"
})

lia.config.add("CanSelectSkins", "Can Select Skins", true, nil, {
    desc = "Whether players can select skins in the character menu",
    category = "Main Menu",
    type = "Boolean"
})
