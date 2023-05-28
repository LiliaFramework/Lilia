lia.config.add("contentURL", "https://discord.gg/HmfaJ9brfz", "Your server's collection pack.", nil, {
    category = "Server Settings"
})

lia.config.add("moneyModel", "models/props_lab/box01a.mdl", "The model for money entities.", nil, {
    category = "Server Settings"
})

lia.config.add("allowVoice", true, "Whether or not voice chat is allowed.", nil, {
    category = "Server Settings"
})

lia.config.add("CarRagdoll", true, "Whether or not Car Ragdoll is Enabled to Avoid VDM.", nil, {
    category = "Server Settings"
})

lia.config.add("CharacterSwitchCooldown", true, "Whether there's cooldown on switching chars.", nil, {
    category = "Server Settings"
})

lia.config.add("PlayerSprayEnabled", false, "Enables Player Spray?", nil, {
    category = "Server Settings"
})

lia.config.add("GlobalFlashlightEnabled", false, "Enables Flashlights for Everyone?", nil, {
    category = "Server Settings"
})

lia.config.add("CentsCompatibility", false, "Enables Cents on Money", nil, {
    category = "Server Settings"
})

lia.config.add("SchemaYear", 2023, "Year That The Gamemode Happens On.", nil, {
    data = {
        min = 1,
        max = 5000
    },
    category = "Server Settings"
})

lia.config.add("StormFox2Compatibility", true, "Whether or not the StormFox2 Time Compatibility is Enabled.", nil, {
    category = "Server Settings"
})

lia.config.add("wepAlwaysRaised", false, "Whether or not weapons are always raised.", nil, {
    category = "Server Settings"
})

lia.config.add("WeaponToggleDelay", 1, "How often you can raise/lower a weapon.", nil, {
    data = {
        min = 50,
        max = 500
    },
    category = "Server Settings"
})

lia.config.add("WeaponRaiseTimer", 1, "How long it takes to raise a weapon.", nil, {
    data = {
        min = 1,
        max = 5
    },
    category = "Server Settings"
})

lia.config.add("introEnabled", false, "Whether or not intro is enabled.", nil, {
    category = "Server Settings"
})

lia.config.add("alwaysPlayIntro", false, "Whether the intro, if enabled, should play every time, or only on first join", nil, {
    category = "Server Settings"
})

lia.config.add("introFont", "Cambria", "Font of the intro screen", nil, {
    category = "Server Settings"
})

lia.config.add("ServerVersionDisplayerEnabled", true, "Whether Version is Displayed.", nil, {
    category = "Server Settings"
})

lia.config.add("voiceDistance", 600.0, "How far can the voice be heard.", function(oldValue, newValue)
    lia.config.squaredVoiceDistance = newValue * newValue
end, {
    form = "Float",
    category = "Server Settings",
    data = {
        min = 0,
        max = 5000
    }
})

lia.config.squaredVoiceDistance = lia.config.get("voiceDistance", 600) * lia.config.get("voiceDistance", 600)