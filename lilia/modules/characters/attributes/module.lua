--- Configuration for Attributes Module.
-- @realm shared
-- @configurations Attributes
-- @table Configuration
-- @field StaminaBlur Is Stamina Blur Enabled? | **bool**
-- @field StaminaSlowdown Is Stamina Slowdown Enabled? | **bool**
-- @field DefaultStamina Sets Default Stamina Value | **integer**
-- @field StaminaBlurThreshold Sets Stamina Threshold for Blur to Show | **integer**
-- @field StaminaBreathingThreshold Sets Stamina Threshold for Breathing to Happen | **integer**
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
