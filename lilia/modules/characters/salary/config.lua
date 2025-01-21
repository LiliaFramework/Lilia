lia.config.add("SalaryInterval", "Salary Interval", 300, nil, {
    desc = "Interval in seconds between salary payouts.",
    category = "Money",
    type = "Int",
    min = 60,
    max = 3600
})

lia.config.add("SalaryThreshold", "Salary Threshold", 0, nil, {
    desc = "Money threshold above which salaries will not be given.",
    category = "Money",
    type = "Int",
    min = 0,
    max = 100000
})
