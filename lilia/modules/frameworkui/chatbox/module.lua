--[[--

**Configuration Values:**.

- CustomChatSound: Change Chat Sound on Message Send | bool.

- ChatColor: Chat Color| color.

- ChatRange: Range of Chat can be heard| integer.

- ChatShowTime: Should chat show timestamp | bool.

- OOCLimit: Limit of characters on OOC | integer.

- ChatListenColor: Color of chat when directly working at someone **folor.

- OOCDelayAdmin: Should Admins to have OOC Delay | bool.

- LOOCDelayAdmin: Should Admins to have LOOC Delay | bool.

- OOCDelay: Set OOC Text Delay | integer.

- LOOCDelay: Set LOOC Text Delay | integer.

- ChatSizeDiff: Enable Different Chat Size Diff | bool.

]]
-- @configurations Chatbox
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
