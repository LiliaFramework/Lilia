MODULE.Name = "@logs"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@categoryLogging"
MODULE.NetworkStrings = {
    "liaSendLogs",
    "liaSendLogsCategories",
    "liaSendLogsCategoriesRequest",
    "liaSendLogsRequest",
}
MODULE.Privileges = {
    ["canSeeLogs"] = {
        Name = "@canSeeLogs",
        MinAccess = "superadmin",
        Category = "@categoryLogging",
    },
}
