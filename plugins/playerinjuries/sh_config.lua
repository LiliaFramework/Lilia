lia.config.add("dmgScale", 1, "How much damage is scaled for players", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 10.0
    },
    category = PLUGIN.name
})

lia.config.add("dmgScaleHead", 2, "How much headshot damage is scaled for players", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 10.0
    },
    category = PLUGIN.name
})

lia.config.add("dmgScaleLimb", 0.5, "How much limb (legs or arms) damage is scaled for players", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 10.0
    },
    category = PLUGIN.name
})

lia.config.add("drownEnabled", true, "Whether or not players can drown from being under water too long.", nil, {
    category = PLUGIN.name
})

lia.config.add("drownDamage", 10, "How much damage players take from drowning.", nil, {
    form = "Int",
    data = {
        min = 0,
        max = 100
    },
    category = PLUGIN.name
})

lia.config.add("drownTime", 30, "Number of seconds a player has to be under water before drowning.", nil, {
    form = "Int",
    data = {
        min = 0,
        max = 300
    },
    category = PLUGIN.name
})