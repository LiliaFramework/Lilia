lia.config.add("ThirdPersonEnabled", L("thirdPersonEnabled"), true, nil, {
    desc = L("thirdPersonEnabledDesc"),
    category = L("thirdPersonCategory"),
    type = "Boolean"
})

lia.config.add("MaxThirdPersonDistance", L("maxThirdPersonDistance"), 100, nil, {
    desc = L("maxThirdPersonDistanceDesc"),
    category = L("thirdPersonCategory"),
    type = "Int"
})

lia.config.add("MaxThirdPersonHorizontal", L("maxThirdPersonHorizontal"), 30, nil, {
    desc = L("maxThirdPersonHorizontalDesc"),
    category = L("thirdPersonCategory"),
    type = "Int"
})

lia.config.add("MaxThirdPersonHeight", L("maxThirdPersonHeight"), 30, nil, {
    desc = L("maxThirdPersonHeightDesc"),
    category = L("thirdPersonCategory"),
    type = "Int"
})

lia.config.add("MaxViewDistance", L("maxViewDistance"), 5000, nil, {
    desc = L("maxViewDistanceDesc"),
    category = L("thirdPersonCategory"),
    type = "Int",
    min = 1000,
    max = 5000,
})

if CLIENT then
    lia.option.add("thirdPersonEnabled", L("thirdPersonEnabledOption"), L("thirdPersonEnabledOptionDesc"), false, function(_, newValue) hook.Run("thirdPersonToggled", newValue) end, {
        category = L("thirdPersonCategory")
    })

    lia.option.add("thirdPersonClassicMode", L("thirdPersonClassicModeOption"), L("thirdPersonClassicModeOptionDesc"), false, nil, {
        category = L("thirdPersonCategory")
    })

    lia.option.add("thirdPersonHeight", L("thirdPersonHeightOption"), L("thirdPersonHeightOptionDesc"), 10, nil, {
        category = L("thirdPersonCategory"),
        min = 0,
        max = lia.config.get("MaxThirdPersonHeight", 30)
    })

    lia.option.add("thirdPersonHorizontal", L("thirdPersonHorizontalOption"), L("thirdPersonHorizontalOptionDesc"), 10, nil, {
        category = L("thirdPersonCategory"),
        min = 0,
        max = lia.config.get("MaxThirdPersonHorizontal", 30)
    })

    lia.option.add("thirdPersonDistance", L("thirdPersonDistanceOption"), L("thirdPersonDistanceOptionDesc"), 50, nil, {
        category = L("thirdPersonCategory"),
        min = 0,
        max = lia.config.get("MaxThirdPersonDistance", 100)
    })
end
