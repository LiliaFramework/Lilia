lia.config.add("SalaryInterval", "Salary Interval", 300, function()
    for _, client in player.Iterator() do
        hook.Run("CreateSalaryTimer", client)
    end
end, {
    desc = "Interval in seconds between salary payouts.",
    category = "Salary",
    type = "Float",
    min = 60,
    max = 3600
})

lia.config.add("SalaryThreshold", "Salary Threshold", 0, nil, {
    desc = "Money threshold above which salaries will not be given.",
    category = "Salary",
    type = "Int",
    min = 0,
    max = 100000
})