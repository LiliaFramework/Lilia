lia.config.language = "english"
lia.config.itemFormat = "<font=liaGenericFont>%s</font>\n<font=liaSmallFont>%s</font>"

lia.config.add("maxChars", 5, "The maximum number of characters a player can have.", nil, {
    data = {
        min = 1,
        max = 50
    },
    category = "Player Settings"
})

lia.config.add("spawnTime", 5, "The time it takes to respawn.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "Player Settings"
})

lia.config.add("invW", 6, "How many slots in a row there is in a default inventory.", nil, {
    data = {
        min = 0,
        max = 20
    },
    category = "Player Settings"
})

lia.config.add("invH", 4, "How many slots in a column there is in a default inventory.", nil, {
    data = {
        min = 0,
        max = 20
    },
    category = "Player Settings"
})

lia.config.add("minDescLen", 16, "The minimum number of characters in a description.", nil, {
    data = {
        min = 0,
        max = 300
    },
    category = "Player Settings"
})

lia.config.add("saveInterval", 300, "How often characters save in seconds.", nil, {
    data = {
        min = 60,
        max = 3600
    },
    category = "Player Settings"
})

lia.config.add("walkSpeed", 130, "How fast a player normally walks.", function(oldValue, newValue)
    for k, v in ipairs(player.GetAll()) do
        v:SetWalkSpeed(newValue)
    end
end, {
    data = {
        min = 75,
        max = 500
    },
    category = "Player Settings"
})

lia.config.add("runSpeed", 235, "How fast a player normally runs.", function(oldValue, newValue)
    for k, v in ipairs(player.GetAll()) do
        v:SetRunSpeed(newValue)
    end
end, {
    data = {
        min = 75,
        max = 500
    },
    category = "Player Settings"
})

lia.config.add("walkRatio", 0.5, "How fast one goes when holding ALT.", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 1
    },
    category = "Player Settings"
})

lia.config.add("punchStamina", 10, "How much stamina punches use up.", nil, {
    data = {
        min = 0,
        max = 100
    },
    category = "Player Settings"
})

lia.config.add("defMoney", 0, "The amount of money that players start with.", nil, {
    category = "Player Settings",
    data = {
        min = 0,
        max = 10000
    }
})

lia.config.add("allowExistNames", true, "Whether or not players can use an already existing name upon character creation.", nil, {
    category = "Player Settings"
})

local dist = lia.config.get("voiceDistance")
lia.config.squaredVoiceDistance = dist * dist