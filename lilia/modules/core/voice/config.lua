MODULE.TalkRanges = {
    ["Whispering"] = 120,
    ["Talking"] = 300,
    ["Yelling"] = 600,
}

lia.config.add("IsVoiceEnabled", "Voice Chat Enabled", true, nil, {
    desc = "Whether or not voice chat is enabled",
    category = "Voice",
    type = "Boolean"
})
