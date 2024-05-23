--- Configuration for SAM Compatibility Module.
-- @configurations SAM

--- This table defines the default settings for the SAM Module.
-- @realm shared
-- @table Configuration
-- @field DefaultStaff List of Default Staff and corresponding usergroups | **table**
-- @field DisplayStaffCommands Should staff commands appear in chat? | **bool**
MODULE.name = "Compatibility - SAM"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds SAM Compatibility"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Speak in Admin Chat",
        MinAccess = "admin",
        Description = "Allows access to Speaking in Admin Chat.",
    },
    {
        Name = "Staff Permissions - Read Admin Chat",
        MinAccess = "admin",
        Description = "Allows access to Reading the Admin Chat.",
    }
}