lia.config.add("LogRetentionDays", "Log Retention Period", 7, nil, {
    desc = "Determines how many days of logs should be read",
    category = "Logging",
    type = "Int",
    min = 3,
    max = 30,
})

lia.config.add("MaxLogLines", "Maximum Log Lines", 1000, nil, {
    desc = "Determines the maximum number of log lines to retrieve",
    category = "Logging",
    type = "Int",
    min = 500,
    max = 1000000,
})
