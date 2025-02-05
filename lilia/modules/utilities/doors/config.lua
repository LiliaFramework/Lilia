lia.config.add("DoorLockTime", L("doorLockTime"), 0.5, nil, {
    desc = L("doorLockTimeDesc"),
    category = L("doorSettings"),
    type = "Float",
    min = 0.1,
    max = 10.0
})

lia.config.add("DoorSellRatio", L("doorSellRatio"), 0.5, nil, {
    desc = L("doorSellRatioDesc"),
    category = L("doorSettings"),
    type = "Float",
    min = 0.0,
    max = 1.0
})
