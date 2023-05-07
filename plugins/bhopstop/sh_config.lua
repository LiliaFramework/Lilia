lia.config.add("bunnyHop", 10, "Number of stamina you need to jump.", nil, {
    data = {
        min = 1,
        max = 30
    },
    category = "characters"
})

lia.config.add("AntiBunnyHopEnabled", true, "Whether or not Anti BunnyHop is enabled.", nil, {
    category = PLUGIN.name
})