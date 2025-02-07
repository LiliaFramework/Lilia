lia.config.add("SalaryInterval", L("SalaryInterval"), 300, nil, {
    desc = L("SalaryIntervalDesc"),
    category = "Money",
    type = "Float",
    min = 60,
    max = 3600
})

lia.config.add("SalaryThreshold", L("SalaryThreshold"), 0, nil, {
    desc = L("SalaryThresholdDesc"),
    category = "Money",
    type = "Int",
    min = 0,
    max = 100000
})