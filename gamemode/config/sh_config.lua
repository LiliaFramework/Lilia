lia.config.add("contentURL", "https://discord.gg/HmfaJ9brfz", "Your server's collection pack.", nil, {
    category = "Server Settings"
})

lia.config.add("pkActive", false, "Whether or not permakill is activated on the server.", nil, {
    category = "Permakill"
})

lia.config.add("ShootableDoors", true, "Whether or not doors can be shot to be open.", nil, {
    category = "Server Settings"
})

lia.config.add("pkWorld", false, "Whether or not world and self damage produce permanent death.", nil, {
    category = "Permakill"
})

lia.config.add("moneyModel", "models/props_lab/box01a.mdl", "The model for money entities.", nil, {
    category = "Server Settings"
})

lia.config.add("StaminaSlowdown", true, "Whether or not the Stamina Slowdown is enabled.", nil, {
    category = "Server Settings"
})

lia.config.add("GlobalMaxHealthEnabled", true, "Whether or not the Global Max Health is enabled.", nil, {
    category = "Server Settings"
})

lia.config.add("RespawnButton", true, "Whether or not the respawn button is enabled.", nil, {
    category = "Server Settings"
})

lia.config.add("AFKKickEnabled", false, "Whether or not AFKKick is enabled.", nil, {
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

lia.config.add("GlobalMaxHealth", 100, "The Maximum Health for players", nil, {
    form = "Float",
    data = {
        min = 1,
        max = 5000
    },
    category = "Server Settings"
})

lia.config.add("DefaultHealth", 100, "The Default Health for players", nil, {
    form = "Float",
    data = {
        min = 1,
        max = 5000
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

lia.config.add("defaultStamina", 100, "A higher number means that characters can run longer without tiring.", nil, {
    data = {
        min = 50,
        max = 500
    },
    category = "Player Settings"
})

lia.config.add("staminaRegenMultiplier", 1, "A higher number means that characters can run regenerate stamina faster.", nil, {
    data = {
        min = 0.1,
        max = 20
    },
    category = "Player Settings"
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

lia.config.add("afkTime", 300, "The amount of seconds it takes for someone to be flagged as AFK.", function(oldValue, newValue)
    if SERVER then
        for _, v in ipairs(player.GetAll()) do
            if v:getChar() then
                timer.Adjust("ixAntiAFK" .. v:SteamID64(), newValue)
            end
        end
    end
end, {
    data = {
        min = 60,
        max = 3600
    },
    category = "Server Settings"
})

lia.config.add("serverRestartHour", 6, "At what hours the server should restart, local to timezone.", function()
    if SERVER then
        timer.Simple(0.01, function()
            lia.module.list["restarter"].NextRestart = lia.module.list["restarter"]:GetInitialRestartTime()
            lia.module.list["restarter"].NextNotificationTime = lia.module.list["restarter"]:GetNextNotificationTimeBreakpoint()
        end)
    end
end, {
    data = {
        min = 0,
        max = 23
    },
    category = "Server Settings"
})

lia.config.add("SchemaYear", 2023, "Year That The Gamemode Happens On.", nil, {
    data = {
        min = 1,
        max = 5000
    },
    category = "Server Settings"
})

lia.config.add("year", tonumber(os.date("%Y")), "The current year of the schema.", function()
    if SERVER then
        for k, client in pairs(player.GetHumans()) do
            lia.date.syncClientTime(client)
        end
    end

    category = "Server Settings"
end, {
    data = {
        min = 0,
        max = 4000
    },
})

lia.config.add("month", tonumber(os.date("%m")), "The current month of the schema.", function()
    if SERVER then
        for k, client in pairs(player.GetHumans()) do
            lia.date.syncClientTime(client)
        end
    end

    category = "Server Settings"
end, {
    data = {
        min = 1,
        max = 12
    },
})

lia.config.add("day", tonumber(os.date("%d")), "The current day of the schema.", function()
    if SERVER then
        for k, client in pairs(player.GetHumans()) do
            lia.date.syncClientTime(client)
        end
    end

    category = "Server Settings"
end, {
    data = {
        min = 1,
        max = 31
    },
})

lia.config.squaredVoiceDistance = lia.config.get("voiceDistance", 600) * lia.config.get("voiceDistance", 600)

lia.config.add("StaminaBlur", false, "Whether or not the Stamina Blur shown.", nil, {
    category = "Client Settings"
})

lia.config.add("CrosshairEnabled", false, "Enables Crosshair?", nil, {
    category = "Client Settings"
})

lia.config.add("DrawEntityShadows", true, "Should Entity Shadows Be Drawn?", nil, {
    category = "Client Settings"
})

lia.config.add("vignette", true, "Whether or not the vignette is shown.", nil, {
    category = "Client Settings"
})

lia.config.add("BarsDisabled", false, "Whether or not Bars is Disabled.", nil, {
    category = "Client Settings"
})

lia.config.add("AmmoDrawEnabled", true, "Whether or not Ammo Draw is enabled.", nil, {
    category = "Client Settings"
})

lia.config.add("DarkTheme", false, "Whether or not Dark Theme is enabled.", nil, {
    category = "Client Settings"
})

lia.config.add("chatSizeDiff", false, "Whether or not to use different chat sizes.", nil, {
    category = "Client Settings"
})

lia.config.add("color", Color(75, 119, 190), "The main color theme for the framework.", nil, {
    category = "Client Settings"
})

lia.config.add("font", "Arial", "The font used to display titles.", function(oldValue, newValue)
    if CLIENT then
        hook.Run("LoadLiliaFonts", newValue, lia.config.get("genericFont"))
    end
end, {
    category = "Client Settings"
})

lia.config.add("genericFont", "Segoe UI", "The font used to display generic texts.", function(oldValue, newValue)
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.get("font"), newValue)
    end
end, {
    category = "Client Settings"
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
    category = "Client Settings"
})

lia.config.add("maxChars", 5, "The maximum number of characters a player can have.", nil, {
    data = {
        min = 1,
        max = 50
    },
    category = "Player Settings"
})

lia.config.add("spawnTime", 5, "The time it takes to respawn.", nil, {
    data = {
        min = 0,
        max = 10000
    },
    category = "Player Settings"
})

lia.config.add("invW", 6, "How many slots in a row there is in a default inventory.", nil, {
    data = {
        min = 0,
        max = 20
    },
    category = "Player Settings"
})

lia.config.add("invH", 4, "How many slots in a column there is in a default inventory.", nil, {
    data = {
        min = 0,
        max = 20
    },
    category = "Player Settings"
})

lia.config.add("minDescLen", 16, "The minimum number of characters in a description.", nil, {
    data = {
        min = 0,
        max = 300
    },
    category = "Player Settings"
})

lia.config.add("saveInterval", 300, "How often characters save in seconds.", nil, {
    data = {
        min = 60,
        max = 3600
    },
    category = "Player Settings"
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
    category = "Player Settings"
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
    category = "Player Settings"
})

lia.config.add("walkRatio", 0.5, "How fast one goes when holding ALT.", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 1
    },
    category = "Player Settings"
})

lia.config.add("punchStamina", 10, "How much stamina punches use up.", nil, {
    data = {
        min = 0,
        max = 100
    },
    category = "Player Settings"
})

lia.config.add("defMoney", 0, "The amount of money that players start with.", nil, {
    category = "Player Settings",
    data = {
        min = 0,
        max = 10000
    }
})

lia.config.add("StaffAutoRecognize", true, "Whether or not FACTION_STAFF is globally recognized.", nil, {
    category = "Player Settings"
})

lia.config.add("FactionAutoRecognize", false, "Whether or not players from the same faction recognize themselves (if true, please configure the faction list in the module).", nil, {
    category = "Player Settings"
})

lia.config.add("allowExistNames", true, "Whether or not players can use an already existing name upon character creation.", nil, {
    category = "Player Settings"
})

lia.config.add("strMultiplier", 0.3, "The strength multiplier scale", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 1.0
    },
    category = "Player Settings"
})

lia.config.language = "english"
lia.config.itemFormat = "<font=liaGenericFont>%s</font>\n<font=liaSmallFont>%s</font>"