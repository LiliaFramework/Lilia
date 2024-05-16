--- Configuration for Chatbox Module.
-- @configurations Chatbox

--- This table defines the default settings for the ChatBox Module.
-- @realm shared
-- @table Configuration
-- @field CustomChatSound Change Chat Sound on Message Send | **bool**
-- @field ChatColor Chat Color | **color**
-- @field ChatRange Range of Chat can be heard | **integer**
-- @field ChatShowTime Should chat show timestamp | **bool**
-- @field OOCLimit Limit of characters on OOC | **integer**
-- @field ChatListenColor Color of chat when directly working at someone | **color**
-- @field OOCDelayAdmin Should Admins to have OOC Delay | **bool**
-- @field LOOCDelayAdmin Should Admins to have LOOC Delay | **bool**
-- @field OOCDelay Set OOC Text Delay | **integer**
-- @field LOOCDelay Set LOOC Text Delay | **integer**
-- @field ChatSizeDiff Enable Different Chat Size Diff | **bool**
MODULE.name = "Framework UI - Chatbox"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds a Chatbox"
MODULE.identifier = "ChatboxCore"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - No OOC Cooldown",
        MinAccess = "admin",
        Description = "Allows access to use the OOC chat command without delay.",
    },
    {
        Name = "Staff Permissions - Admin Chat",
        MinAccess = "admin",
        Description = "Allows access to Admin Chat.",
    },
    {
        Name = "Staff Permissions - Local Event Chat",
        MinAccess = "admin",
        Description = "Allows access to Local Event Chat."
    },
    {
        Name = "Staff Permissions - Event Chat",
        MinAccess = "admin",
        Description = "Allows access to Event Chat."
    },
}
