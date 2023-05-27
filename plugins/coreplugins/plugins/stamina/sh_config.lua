lia.config.add("defaultStamina", 100, "A higher number means that characters can run longer without tiring.", nil, {
    data = {
        min = 50,
        max = 500
    },
    category = "stamina"
})

lia.config.add("staminaRegenMultiplier", 1, "A higher number means that characters can run regenerate stamina faster.", nil, {
    data = {
        min = 0.1,
        max = 20
    },
    category = "stamina"
})