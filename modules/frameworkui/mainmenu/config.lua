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

lia.config.add("DiscordURL", "The Discord of the Server", "https://discord.gg/esCRH5ckbQ", nil, {
    desc = "The URL for the Discord server",
    category = "Main Menu",
    type = "Generic"
})

lia.config.add("Workshop", "The Steam Workshop of the Server", "https://steamcommunity.com/sharedfiles/filedetails/?id=2959728255", nil, {
    desc = "The URL for the Steam Workshop page",
    category = "Main Menu",
    type = "Generic"
})

lia.config.add("CharMenuBGInputDisabled", "Character Menu BG Input Disabled", true, nil, {
    desc = "Whether background input is disabled during character menu use",
    category = "Main Menu",
    type = "Boolean"
})
