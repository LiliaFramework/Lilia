lia.chat.register("meclose", {
    arguments = {
        {
            name = "action",
            type = "string"
        },
    },
    desc = "mecloseDesc",
    format = "emoteFormat",
    onCanHear = lia.config.get("ChatRange", 280) * 0.25,
    prefix = {"/meclose", "/actionclose"},
    font = "liaChatFontItalics",
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
    color = Color(255, 150, 0),
    onCanHear = lia.config.get("ChatRange", 280),
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
    onCanHear = lia.config.get("ChatRange", 280) * 2,
    prefix = {"/mefar", "/actionfar"},
    font = "liaChatFontItalics",
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
    onChatAdd = function(_, text) chat.AddText(lia.config.get("ChatColor"), "**" .. text) end,
    onCanHear = lia.config.get("ChatRange", 280) * 0.25,
    prefix = {"/itclose"},
    font = "liaChatFontItalics",
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
    onChatAdd = function(_, text) chat.AddText(lia.config.get("ChatColor"), "**" .. text) end,
    onCanHear = lia.config.get("ChatRange", 280) * 2,
    prefix = {"/itfar"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})
lia.chat.register("coinflip", {
    desc = "coinflipDesc",
    format = "coinflipFormat",
    onCanHear = lia.config.get("ChatRange", 280),
    prefix = {"/coinflip"},
    color = Color(236, 100, 9),
    filter = "actions",
    font = "liaChatFontItalics",
    deadCanChat = false
})
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
        if client:getTracedEntity() == speaker then return lia.config.get("ChatListenColor") end
        return lia.config.get("ChatColor")
    end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("ChatRange", 280) then return true end
        return false
    end
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
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("ChatRange", 280) then return true end
        return false
    end,
    prefix = {"/me", "/action"},
    font = "liaChatFontItalics",
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
    font = "liaChatFontItalics",
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
    onChatAdd = function(_, text) chat.AddText(lia.chat.timestamp(false), lia.config.get("ChatColor"), "**" .. text) end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("ChatRange", 280) then return true end
        return false
    end,
    prefix = {"/it"},
    font = "liaChatFontItalics",
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
    onGetColor = function(speaker)
        local color = lia.chat.classes.ic.onGetColor(speaker)
        return Color(color.r - 35, color.g - 35, color.b - 35)
    end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("ChatRange", 280) * 0.25 then return true end
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
    onGetColor = function(speaker)
        local color = lia.chat.classes.ic.onGetColor(speaker)
        return Color(color.r + 35, color.g + 35, color.b + 35)
    end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("ChatRange", 280) * 2 then return true end
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
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 50, 50), "[" .. L("looc") .. "] ", lia.config.get("ChatColor"), speaker:Name() .. ": " .. text) end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("ChatRange", 280) then return true end
        return false
    end,
    prefix = {"looc"},
    noSpaceAfter = true,
    filter = "ooc"
})
lia.chat.register("adminchat", {
    arguments = {
        {
            name = "text",
            type = "string"
        },
    },
    desc = "adminchatDesc",
    onGetColor = function() return Color(0, 196, 255) end,
    onCanHear = function(_, listener) return listener:hasPrivilege("adminChat") end,
    onCanSay = function(speaker)
        if not speaker:hasPrivilege("adminChat") then
            speaker:notifyErrorLocalized("notAdminForTicket")
            return false
        end
        return true
    end,
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 215, 0), "[" .. L("adminChat") .. "] ", Color(128, 0, 255, 255), speaker:getChar():getName(), ": ", Color(255, 255, 255), text) end,
    prefix = {"/adminchat", "/asay", "/admin", "/a"}
})
lia.chat.register("roll", {
    desc = "rollDesc",
    format = "rollFormat",
    color = Color(155, 111, 176),
    filter = "actions",
    font = "liaChatFontItalics",
    deadCanChat = true,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("ChatRange", 280) then return true end
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
    color = Color(249, 211, 89),
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
        if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.get("ChatRange", 280) * 6 then return true end
        return false
    end,
    onChatAdd = function(_, text) chat.AddText(Color(255, 150, 0), text) end,
    prefix = {"/eventlocal"},
    font = "liaMediumFont"
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
    onChatAdd = function(_, text) chat.AddText(Color(255, 150, 0), text) end,
    prefix = {"/event"},
    font = "liaMediumFont"
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
        if GetGlobalBool("oocblocked", false) then
            speaker:notifyErrorLocalized("oocBlocked")
            return false
        end
        if speaker:getLiliaData("oocBanned", false) then
            speaker:notifyErrorLocalized("oocBanned")
            return false
        end
        if #text > lia.config.get("OOCLimit", 150) then
            speaker:notifyErrorLocalized("textTooBig")
            return false
        end
        local customDelay = hook.Run("getOOCDelay", speaker)
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
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 50, 50), " [" .. L("ooc") .. "] ", speaker, color_white, ": " .. text) end,
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
    onCanHear = lia.config.get("ChatRange", 280),
    onChatAdd = function(speaker, text, anonymous)
        local texCol = lia.config.get("ChatColor")
        if LocalPlayer():getTracedEntity() == speaker then texCol = lia.config.get("ChatListenColor") end
        texCol = Color(texCol.r, texCol.g, texCol.b)
        local nameCol = Color(texCol.r + 30, texCol.g + 30, texCol.b + 30)
        if LocalPlayer() == speaker then
            local tempCol = lia.config.get("ChatListenColor")
            texCol = Color(tempCol.r + 20, tempCol.b + 20, tempCol.g + 20)
            nameCol = Color(tempCol.r + 40, tempCol.b + 60, tempCol.g + 40)
        end
        chat.AddText(nameCol, L("mePossessiveFormat", anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, "ic") or IsValid(speaker) and speaker:Name() or language.GetPhrase("#Console"), ""), texCol, text)
    end,
    prefix = {"/me's", "/action's"},
    font = "liaChatFontItalics",
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
        local texCol = lia.config.get("ChatColor")
        if LocalPlayer():getTracedEntity() == speaker then texCol = lia.config.get("ChatListenColor") end
        texCol = Color(texCol.r + 45, texCol.g + 45, texCol.b + 45)
        local nameCol = Color(texCol.r + 30, texCol.g + 30, texCol.b + 30)
        if LocalPlayer() == speaker then
            local tempCol = lia.config.get("ChatListenColor")
            texCol = Color(tempCol.r + 65, tempCol.b + 65, tempCol.g + 65)
            nameCol = Color(tempCol.r + 40, tempCol.b + 60, tempCol.g + 40)
        end
        chat.AddText(nameCol, L("emoteFormat", anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, "ic") or IsValid(speaker) and speaker:Name() or language.GetPhrase("#Console"), ""), texCol, text)
    end,
    onCanHear = lia.config.get("ChatRange", 280) * 4,
    prefix = {"/mefarfar", "/actionyy", "/meyy"},
    font = "liaChatFontItalics",
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
    onChatAdd = function(speaker, text) chat.AddText(Color(200, 50, 50), "[" .. L("help") .. "] " .. speaker:GetName(), color_white, ": " .. text) end
})
