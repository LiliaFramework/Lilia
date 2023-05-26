lia.config.add("oocDelay", 10, "The delay before a player can use OOC chat again in seconds.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "chat"
})

lia.config.add("oocLimit", 150, "Character limit per OOC message. 0 means no limit", nil, {
    data = {
        min = 0,
        max = 1000
    },
    category = "chat"
})

lia.config.add("chatColor", Color(255, 239, 150), "The default color for IC chat.", nil, {
    category = "chat"
})

lia.config.add("chatListenColor", Color(168, 240, 170), "The color for IC chat if you are looking at the speaker.", nil, {
    category = "chat"
})

lia.config.add("oocDelayAdmin", false, "Whether or not OOC chat delay is enabled for admins.", nil, {
    category = "chat"
})

lia.config.add("allowGlobalOOC", true, "Whether or not Global OOC is enabled.", nil, {
    category = "chat"
})

lia.config.add("loocDelay", 0, "The delay before a player can use LOOC chat again in seconds.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "chat"
})

lia.config.add("loocDelayAdmin", false, "Whether or not LOOC chat delay is enabled for admins.", nil, {
    category = "chat"
})

lia.config.add("chatShowTime", false, "Whether or not to show timestamps in front of chat messages.", nil, {
    category = "chat"
})

lia.config.add("chatRange", 280, "The maximum distance a person's IC chat message goes to.", nil, {
    form = "Float",
    data = {
        min = 10,
        max = 5000
    },
    category = "chat"
})