MODULE.TalkRanges = {
    ["Whispering"] = 120,
    ["Talking"] = 300,
    ["Yelling"] = 600,
}

lia.config.add("IsVoiceEnabled", L("voiceChatEnabled"), true, nil, {
    desc = L("voiceChatEnabledDesc"),
    category = L("voice"),
    type = "Boolean"
})