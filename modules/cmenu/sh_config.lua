----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lia.config.InteractionDistance = 100
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lia.config.ZipTieItems = {"tie", "zipties"}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lia.config.VisualizeOptions = {
    ["Tie Player"] = {
        OptionType = "command",
        CommandString = "tieplayer",
        CanTargetOthers = true,
        CanTargetRestricted = false,
    },
    ["Open Detailed Description"] = {
        OptionType = "function",
        CanTargetOthers = true,
        CanTargetRestricted = true,
    },
    ["Set Detailed Description"] = {
        OptionType = "function",
        CanTargetOthers = true,
        CanTargetRestricted = true,
    },
}
----------------------------------------------------------------------------------------------