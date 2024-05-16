--- Configuration for Scoreboard Module.
-- @configurations Scoreboard

--- This table defines the default settings for the Scoreboard Module.
-- @realm shared
-- @table Configuration
-- @field HiddenFactions Scoreboard Table of Factions that are hidden | **table**
-- @field sbHeight Scoreboard Height | **number**
-- @field sbWidth Scoreboard Width | **number**
-- @field ShowStaff Should Staff Show In Scoreboard | **bool**
MODULE.name = "Framework UI - Scoreboard"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds a RPish Scoreboard with Recognition"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Access Scoreboard Admin Options",
        MinAccess = "admin",
        Description = "Allows access to Scoreboard Admin Options.",
    },
    {
        Name = "Staff Permissions - Can Access Scoreboard Info Out Of Staff",
        MinAccess = "admin",
        Description = "Allows access to Scoreboard Info Out Of Staff.",
    },
}
