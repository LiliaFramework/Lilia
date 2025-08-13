MODULE.name = "Scoreboard"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Displays an immersive scoreboard showing recognized players, faction information, and built-in admin options for staff."
MODULE.Privileges = {
    {
        Name = "canAccessScoreboardAdminOptions",
        ID = "canAccessScoreboardAdminOptions",
        MinAccess = "admin",
        Category = "scoreboard",
    },
    {
        Name = "canAccessScoreboardInfoOutOfStaff",
        ID = "canAccessScoreboardInfoOutOfStaff",
        MinAccess = "superadmin",
        Category = "scoreboard",
    },
}