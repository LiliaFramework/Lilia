lia.config.add("CustomChatSound", "Custom Chat Sound", "", nil, {
    desc = "Change Chat Sound on Message Send",
    category = "Chat",
    type = "Generic"
})

lia.config.add("ChatColor", "Chat Color", {
    r = 255,
    g = 239,
    b = 150,
    a = 255
}, nil, {
    desc = "Chat Color",
    category = "Chat",
    type = "Color"
})

lia.config.add("ChatRange", "Chat Range", 280, nil, {
    desc = "Range of Chat can be heard",
    category = "Chat",
    type = "Int",
    min = 0,
    max = 10000
})

lia.config.add("OOCLimit", "OOC Character Limit", 150, nil, {
    desc = "Limit of characters on OOC",
    category = "Chat",
    type = "Int",
    min = 10,
    max = 1000
})

lia.config.add("ChatListenColor", "Chat Listen Color", {
    r = 168,
    g = 240,
    b = 170,
    a = 255
}, nil, {
    desc = "Color of chat when directly working at someone",
    category = "Chat",
    type = "Color"
})

lia.config.add("OOCDelay", "OOC Delay", 10, nil, {
    desc = "Set OOC Text Delay",
    category = "Chat",
    type = "Float",
    min = 0,
    max = 60
})

lia.config.add("LOOCDelay", "LOOC Delay", 6, nil, {
    desc = "Set LOOC Text Delay",
    category = "Chat",
    type = "Float",
    min = 0,
    max = 60
})

lia.config.add("LOOCDelayAdmin", "LOOC Delay for Admins", false, nil, {
    desc = "Should Admins have LOOC Delay",
    category = "Chat",
    type = "Boolean"
})

lia.config.add("ChatSizeDiff", "Enable Different Chat Size", false, nil, {
    desc = "Enable Different Chat Size Diff",
    category = "Chat",
    type = "Boolean"
})
