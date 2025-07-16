lia.config.add("DoorLockTime", "Door Lock Time", 0.5, nil, {
    desc = "Time it takes to lock a door",
    category = "Doors",
    type = "Float",
    min = 0.1,
    max = 10.0
})

lia.config.add("DoorSellRatio", "Door Sell Ratio", 0.5, nil, {
    desc = "Percentage you can sell a door for",
    category = "Doors",
    type = "Float",
    min = 0.0,
    max = 1.0
})
