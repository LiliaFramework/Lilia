lia.config.add("wepAlwaysRaised", false, "Whether or not weapons are always raised.", nil, {
    category = "server"
})

lia.config.add("WeaponToggleDelay", 1, "How often you can raise/lower a weapon.", nil, {
    data = {
        min = 50,
        max = 500
    },
    category = "server"
})

lia.config.add("WeaponRaiseTimer", 1, "How long it takes to raise a weapon.", nil, {
    data = {
        min = 1,
        max = 5
    },
    category = "server"
})