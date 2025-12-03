lia.chat.register("ic", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "icDesc",
    format = "icFormat",
    onGetColor = function(speaker)
        local client = LocalPlayer()
        if client:getTracedEntity() == speaker then return (lia.color.theme and lia.color.theme.chatListen) or Color(168, 240, 170) end
        return (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
    end,
    onChatAdd = function(speaker, text, anonymous) chat.AddText(lia.chat.timestamp(false), (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), L("icFormat", anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, "ic") or IsValid(speaker) and speaker:Name() or L("console"), text)) end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("TalkRange", 280) then return true end
        return false
    end
})

lia.chat.register("meclose", {
    arguments = {
        {
            name = "action",
            type = "string"
        },
    },
    desc = "mecloseDesc",
    format = "emoteFormat",
    onGetColor = lia.chat.classes.ic.onGetColor,
    onCanHear = lia.config.get("WhisperRange", 70),
    prefix = {"/meclose", "/actionclose"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("actions", {
    arguments = {
        {
            name = "action",
            type = "string"
        },
    },
    desc = "actionsDesc",
    format = "emoteFormat",
    onGetColor = function(speaker)
        local client = LocalPlayer()
        if client:getTracedEntity() == speaker then return (lia.color.theme and lia.color.theme.chatListen) or Color(168, 240, 170) end
        return (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
    end,
    onCanHear = lia.config.get("TalkRange", 280),
    deadCanChat = true
})

lia.chat.register("mefar", {
    arguments = {
        {
            name = "action",
            type = "string"
        },
    },
    desc = "mefarDesc",
    format = "emoteFormat",
    onGetColor = lia.chat.classes.ic.onGetColor,
    onCanHear = lia.config.get("YellRange", 840),
    prefix = {"/mefar", "/actionfar"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("itclose", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "itcloseDesc",
    onChatAdd = function(_, text) chat.AddText((lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), "**" .. text) end,
    onCanHear = lia.config.get("WhisperRange", 70),
    prefix = {"/itclose"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("itfar", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "itfarDesc",
    onChatAdd = function(_, text) chat.AddText((lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), "**" .. text) end,
    onCanHear = lia.config.get("YellRange", 840),
    prefix = {"/itfar"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("coinflip", {
    desc = "coinflipDesc",
    format = "coinflipFormat",
    onCanHear = lia.config.get("TalkRange", 280),
    prefix = {"/coinflip"},
    onGetColor = function(speaker)
        local client = LocalPlayer()
        if client:getTracedEntity() == speaker then return (lia.color.theme and lia.color.theme.chatListen) or Color(168, 240, 170) end
        return (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
    end,
    filter = "actions",
    deadCanChat = false
})

lia.chat.register("me", {
    arguments = {
        {
            name = "action",
            type = "string"
        },
    },
    desc = "meDesc",
    format = "emoteFormat",
    onGetColor = lia.chat.classes.ic.onGetColor,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("TalkRange", 280) then return true end
        return false
    end,
    prefix = {"/me", "/action"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("globalme", {
    arguments = {
        {
            name = "action",
            type = "string"
        },
    },
    desc = "globalMeDesc",
    format = "emoteFormat",
    onGetColor = lia.chat.classes.ic.onGetColor,
    onCanHear = function() return true end,
    prefix = {"/globalme"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("it", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "itDesc",
    onChatAdd = function(_, text) chat.AddText(lia.chat.timestamp(false), (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), "**" .. text) end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("TalkRange", 280) then return true end
        return false
    end,
    prefix = {"/it"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("w", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "wDesc",
    format = "whisperFormat",
    onGetColor = lia.chat.classes.ic.onGetColor,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("WhisperRange", 70) then return true end
        return false
    end,
    prefix = {"/w", "/whisper"}
})

lia.chat.register("y", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "yDesc",
    format = "yellFormat",
    onGetColor = lia.chat.classes.ic.onGetColor,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("YellRange", 840) then return true end
        return false
    end,
    prefix = {"/y", "/yell"}
})

lia.chat.register("looc", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "loocDesc",
    onCanSay = function(speaker)
        local delay = lia.config.get("LOOCDelay", false)
        if speaker:isStaff() and lia.config.get("LOOCDelayAdmin", false) and delay > 0 and speaker.liaLastLOOC then
            local lastLOOC = CurTime() - speaker.liaLastLOOC
            if lastLOOC <= delay then
                speaker:notifyWarningLocalized("loocDelay", delay - math.ceil(lastLOOC))
                return false
            end
        end

        speaker.liaLastLOOC = CurTime()
    end,
    onChatAdd = function(speaker, text) chat.AddText((lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), "[" .. L("looc") .. "] ", (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), speaker:Name(), ": " .. text) end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("TalkRange", 280) then return true end
        return false
    end,
    prefix = {"/looc"},
    noSpaceAfter = true,
    filter = "ooc"
})

lia.chat.register("roll", {
    desc = "rollDesc",
    format = "rollFormat",
    onGetColor = function(speaker)
        local client = LocalPlayer()
        if client:getTracedEntity() == speaker then return (lia.color.theme and lia.color.theme.chatListen) or Color(168, 240, 170) end
        return (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
    end,
    filter = "actions",
    deadCanChat = true,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("TalkRange", 280) then return true end
        return false
    end
})

lia.chat.register("pm", {
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "message",
            type = "string"
        },
    },
    desc = "pmDesc",
    format = "pmFormat",
    onGetColor = function(speaker)
        local client = LocalPlayer()
        if client:getTracedEntity() == speaker then return (lia.color.theme and lia.color.theme.chatListen) or Color(168, 240, 170) end
        return (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
    end,
    onChatAdd = function(speaker, text) chat.AddText((lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), "[" .. L("pm") .. "] ", (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), speaker:Name(), ": " .. text) end,
    filter = "pm",
    deadCanChat = true
})

lia.chat.register("eventlocal", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "eventlocalDesc",
    onCanSay = function(speaker) return speaker:hasPrivilege("localEventChat") end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("YellRange", 840) * 2 then return true end
        return false
    end,
    onChatAdd = function(_, text) chat.AddText((lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), text) end,
    prefix = {"/eventlocal"}
})

lia.chat.register("event", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "eventDesc",
    onCanSay = function(speaker) return speaker:hasPrivilege("eventChat") end,
    onCanHear = function() return true end,
    onChatAdd = function(_, text) chat.AddText((lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), text) end,
    prefix = {"/event"}
})

lia.chat.register("ooc", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "oocDesc",
    onCanSay = function(speaker, text)
        if GetGlobalBool("oocblocked", false) and not speaker:hasPrivilege("bypassOOCBlock") then
            speaker:notifyErrorLocalized("oocBlocked")
            return false
        end

        if speaker:getLiliaData("oocBanned", false) then
            speaker:notifyErrorLocalized("oocBanned")
            return false
        end

        if text and #text > lia.config.get("OOCLimit", 150) then
            speaker:notifyErrorLocalized("textTooBig")
            return false
        end

        local customDelay = hook.Run("GetOOCDelay", speaker)
        local oocDelay = customDelay or lia.config.get("OOCDelay", 10)
        if not speaker:hasPrivilege("noOOCCooldown") and oocDelay > 0 and speaker.liaLastOOC then
            local lastOOC = CurTime() - speaker.liaLastOOC
            if lastOOC <= oocDelay then
                speaker:notifyWarningLocalized("oocDelay", oocDelay - math.ceil(lastOOC))
                return false
            end
        end

        speaker.liaLastOOC = CurTime()
    end,
    onCanHear = function() return true end,
    onChatAdd = function(speaker, text) chat.AddText((lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), " [" .. L("ooc") .. "] ", (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), speaker:Name(), ": " .. text) end,
    prefix = {"//", "/ooc"},
    noSpaceAfter = true,
    filter = "ooc"
})

lia.chat.register("me's", {
    arguments = {
        {
            name = "action",
            type = "string"
        },
    },
    desc = "mesDesc",
    format = "mePossessiveFormat",
    onCanHear = lia.config.get("TalkRange", 280),
    onChatAdd = function(speaker, text, anonymous)
        local texCol = (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
        if LocalPlayer():getTracedEntity() == speaker then texCol = (lia.color.theme and lia.color.theme.chatListen) or Color(168, 240, 170) end
        chat.AddText(texCol, L("mePossessiveFormat", anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, "ic") or IsValid(speaker) and speaker:Name() or language.GetPhrase("#Console"), ""), texCol, text)
    end,
    prefix = {"/me's", "/action's"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("mefarfar", {
    arguments = {
        {
            name = "action",
            type = "string"
        },
    },
    desc = "mefarfarDesc",
    format = "emoteFormat",
    onChatAdd = function(speaker, text, anonymous)
        local texCol = (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
        if LocalPlayer():getTracedEntity() == speaker then texCol = (lia.color.theme and lia.color.theme.chatListen) or Color(168, 240, 170) end
        chat.AddText(texCol, L("emoteFormat", anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, "ic") or IsValid(speaker) and speaker:Name() or language.GetPhrase("#Console"), ""), texCol, text)
    end,
    onCanHear = lia.config.get("YellRange", 840) * 2,
    prefix = {"/mefarfar", "/actionyy", "/meyy"},
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("help", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "helpDesc",
    onCanSay = function() return true end,
    onCanHear = function(speaker, listener)
        if listener:isStaffOnDuty() or listener == speaker or listener:hasPrivilege("accessHelpChat") then return true end
        return false
    end,
    onChatAdd = function(speaker, text) chat.AddText((lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), "[" .. L("help") .. "] ", (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), speaker:GetName(), ": " .. text) end
})
