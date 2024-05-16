--- Configuration for Attributes Module.
-- @configurations Attributes


--- This table defines the default settings for the Attributes Module.
-- @realm shared
-- @table Configuration
-- @field StaminaBlur Is Stamina Blur Enabled? | **bool**
-- @field StaminaSlowdown Is Stamina Slowdown Enabled? | **bool**
-- @field DefaultStamina Sets Default Stamina Value | **number**
-- @field StaminaBlurThreshold Sets Stamina Threshold for Blur to Show | **number**
-- @field StaminaBreathingThreshold Sets Stamina Threshold for Breathing to Happen | **number**
-- @field CharAttrib Sets Sounds Made when hitting the attribute button | **table**
MODULE.name = "Characters - Attributes"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds Several Character Tied Attributes That Influence Gameplay"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - One Punch Man",
        MinAccess = "superadmin",
        Description = "Allows access to OPM to Ragdoll Minges.",
    },
}