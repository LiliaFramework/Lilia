lia.config.add("AutoRegen", true, "Whether HP Regen is enabled.", nil, {
    category = "Regen"
})

lia.config.add("HealingTimer", 60, "How Long it Takes to Heal.", nil, {
    data = {
        min = 1,
        max = 500
    },
    category = "server"
})

lia.config.add("HealingAmount", 1, "How much AutoRegen heals per HealingTimer.", nil, {
    data = {
        min = 1,
        max = 100
    },
    category = "server"
})