-- You can change the default language here:
lia.config.language = "english"
lia.config.itemFormat = "<font=liaGenericFont>%s</font>\n<font=liaSmallFont>%s</font>"

--[[
	DO NOT CHANGE ANYTHING BELOW THIS.

	This is the Lilia main configuration file.
	This file DOES NOT set any configurations, instead it just prepares them.
	To set the configuration, there is a "Config" tab in the F1 menu for super admins and above.
	Use the menu to change the variables, not this file.
--]]
lia.config.add("maxChars", 5, "The maximum number of characters a player can have.", nil, {
    data = {
        min = 1,
        max = 50
    },
    category = "characters"
})

lia.config.add("color", Color(75, 119, 190), "The main color theme for the framework.", nil, {
    category = "appearance"
})

lia.config.add("font", "Arial", "The font used to display titles.", function(oldValue, newValue)
    if CLIENT then
        hook.Run("LoadLiliaFonts", newValue, lia.config.get("genericFont"))
    end
end, {
    category = "appearance"
})

lia.config.add("genericFont", "Segoe UI", "The font used to display generic texts.", function(oldValue, newValue)
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.get("font"), newValue)
    end
end, {
    category = "appearance"
})

lia.config.add("fontScale", 1.0, "The scale for the font.", function(oldValue, newValue)
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont"))
    end
end, {
    form = "Float",
    data = {
        min = 0.1,
        max = 2.0
    },
    category = "appearance"
})

lia.config.add("chatRange", 280, "The maximum distance a person's IC chat message goes to.", nil, {
    form = "Float",
    data = {
        min = 10,
        max = 5000
    },
    category = "chat"
})

lia.config.add("chatColor", Color(255, 239, 150), "The default color for IC chat.", nil, {
    category = "chat"
})

lia.config.add("chatListenColor", Color(168, 240, 170), "The color for IC chat if you are looking at the speaker.", nil, {
    category = "chat"
})

lia.config.add("oocDelay", 10, "The delay before a player can use OOC chat again in seconds.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "chat"
})

lia.config.add("oocLimit", 0, "Character limit per OOC message. 0 means no limit", nil, {
    data = {
        min = 0,
        max = 1000
    },
    category = "chat"
})

lia.config.add("oocDelayAdmin", false, "Whether or not OOC chat delay is enabled for admins.", nil, {
    category = "chat"
})

lia.config.add("allowGlobalOOC", true, "Whether or not Global OOC is enabled.", nil, {
    category = "chat"
})

lia.config.add("loocDelay", 0, "The delay before a player can use LOOC chat again in seconds.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "chat"
})

lia.config.add("loocDelayAdmin", false, "Whether or not LOOC chat delay is enabled for admins.", nil, {
    category = "chat"
})

lia.config.add("chatShowTime", false, "Whether or not to show timestamps in front of chat messages.", nil, {
    category = "chat"
})

lia.config.add("spawnTime", 5, "The time it takes to respawn.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "characters"
})

lia.config.add("invW", 6, "How many slots in a row there is in a default inventory.", nil, {
    data = {
        min = 0,
        max = 20
    },
    category = "characters"
})

lia.config.add("invH", 4, "How many slots in a column there is in a default inventory.", nil, {
    data = {
        min = 0,
        max = 20
    },
    category = "characters"
})

lia.config.add("minDescLen", 16, "The minimum number of characters in a description.", nil, {
    data = {
        min = 0,
        max = 300
    },
    category = "characters"
})

lia.config.add("saveInterval", 300, "How often characters save in seconds.", nil, {
    data = {
        min = 60,
        max = 3600
    },
    category = "characters"
})

lia.config.add("walkSpeed", 130, "How fast a player normally walks.", function(oldValue, newValue)
    for k, v in ipairs(player.GetAll()) do
        v:SetWalkSpeed(newValue)
    end
end, {
    data = {
        min = 75,
        max = 500
    },
    category = "characters"
})

lia.config.add("runSpeed", 235, "How fast a player normally runs.", function(oldValue, newValue)
    for k, v in ipairs(player.GetAll()) do
        v:SetRunSpeed(newValue)
    end
end, {
    data = {
        min = 75,
        max = 500
    },
    category = "characters"
})

lia.config.add("walkRatio", 0.5, "How fast one goes when holding ALT.", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 1
    },
    category = "characters"
})

lia.config.add("punchStamina", 10, "How much stamina punches use up.", nil, {
    data = {
        min = 0,
        max = 100
    },
    category = "characters"
})

lia.config.add("defMoney", 0, "The amount of money that players start with.", nil, {
    category = "characters",
    data = {
        min = 0,
        max = 10000
    }
})

lia.config.add("allowExistNames", true, "Whether or not players can use an already existing name upon character creation.", nil, {
    category = "characters"
})

lia.config.add("allowVoice", true, "Whether or not voice chat is allowed.", nil, {
    category = "server"
})

lia.config.add("voiceDistance", 600.0, "How far can the voice be heard.", function(oldValue, newValue)
    lia.config.squaredVoiceDistance = newValue * newValue
end, {
    form = "Float",
    category = "server",
    data = {
        min = 0,
        max = 5000
    }
})

lia.config.add("contentURL", "https://discord.gg/HmfaJ9brfz", "Your server's collection pack.", nil, {
    category = "server"
})

lia.config.add("moneyModel", "models/props_lab/box01a.mdl", "The model for money entities.", nil, {
    category = "server"
})

lia.config.add("salaryInterval", 300, "How often a player gets paid in seconds.", nil, {
    data = {
        min = 1,
        max = 3600
    },
    category = "characters"
})

local dist = lia.config.get("voiceDistance")
lia.config.squaredVoiceDistance = dist * dist
