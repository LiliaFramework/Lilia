lia.config.add("AutoRegen", true, "Whether HP Regen is enabled.", nil, {
    category = "Player Settings"
})

lia.config.add("HealingTimer", 60, "How Long it Takes to Heal.", nil, {
    data = {
        min = 1,
        max = 500
    },
    category = "Player Settings"
})

lia.config.add("HealingAmount", 1, "How much AutoRegen heals per HealingTimer.", nil, {
    data = {
        min = 1,
        max = 100
    },
    category = "Player Settings"
})