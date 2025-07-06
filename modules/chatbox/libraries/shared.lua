local MODULE = MODULE
lia.chat.register("meclose", {
    syntax = "[string Action]",
    desc = "mecloseDesc",
    format = "emoteFormat",
    onCanHear = lia.config.get("ChatRange", 280) * 0.25,
    prefix = {"/meclose", "/actionclose"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("actions", {
    syntax = "[string Action]",
    desc = "actionsDesc",
    format = "emoteFormat",
    color = Color(255, 150, 0),
    onCanHear = lia.config.get("ChatRange", 280),
    deadCanChat = true
})

lia.chat.register("mefar", {
    syntax = "[string Action]",
    desc = "mefarDesc",
    format = "emoteFormat",
    onCanHear = lia.config.get("ChatRange", 280) * 2,
    prefix = {"/mefar", "/actionfar"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("itclose", {
    syntax = "[string Text]",
    desc = "itcloseDesc",
    onChatAdd = function(_, text) chat.AddText(lia.config.get("ChatColor"), "**" .. text) end,
    onCanHear = lia.config.get("ChatRange", 280) * 0.25,
    prefix = {"/itclose"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("itfar", {
    syntax = "[string Text]",
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
    syntax = "[string Text]",
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
    syntax = "[string Action]",
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
    syntax = "[string Action]",
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
    syntax = "[string Text]",
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
    syntax = "[string Text]",
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
    syntax = "[string Text]",
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
    syntax = "[string Text]",
    desc = "loocDesc",
    onCanSay = function(speaker)
        local delay = lia.config.get("LOOCDelay", false)
        if speaker:isStaff() and lia.config.get("LOOCDelayAdmin", false) and delay > 0 and speaker.liaLastLOOC then
            local lastLOOC = CurTime() - speaker.liaLastLOOC
            if lastLOOC <= delay then
                speaker:notifyLocalized("loocDelay", delay - math.ceil(lastLOOC))
                return false
            end
        end

        speaker.liaLastLOOC = CurTime()
    end,
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 50, 50), L("loocPrefix") .. " ", lia.config.get("ChatColor"), speaker:Name() .. ": " .. text) end,
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
    syntax = "[string Text]",
    desc = "adminchatDesc",
    onGetColor = function() return Color(0, 196, 255) end,
    onCanHear = function(_, listener) return listener:hasPrivilege("Staff Permissions - Admin Chat") end,
    onCanSay = function(speaker)
        if not speaker:hasPrivilege("Staff Permissions - Admin Chat") then
            speaker:notifyLocalized("notAdminForTicket")
            return false
        end
        return true
    end,
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 215, 0), L("adminChatPrefix") .. " ", Color(128, 0, 255, 255), speaker:getChar():getName(), ": ", Color(255, 255, 255), text) end,
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
    syntax = "[string Player Name] [string Message]",
    desc = "pmDesc",
    format = "pmFormat",
    color = Color(249, 211, 89),
    filter = "pm",
    deadCanChat = true
})

lia.chat.register("eventlocal", {
    syntax = "[string Text]",
    desc = "eventlocalDesc",
    onCanSay = function(speaker) return speaker:hasPrivilege("Staff Permissions - Local Event Chat") end,
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
    syntax = "[string Text]",
    desc = "eventDesc",
    onCanSay = function(speaker) return speaker:hasPrivilege("Staff Permissions - Event Chat") end,
    onCanHear = function() return true end,
    onChatAdd = function(_, text) chat.AddText(Color(255, 150, 0), text) end,
    prefix = {"/event"},
    font = "liaMediumFont"
})

lia.chat.register("ooc", {
    syntax = "[string Text]",
    desc = "oocDesc",
    onCanSay = function(speaker, text)
        if GetGlobalBool("oocblocked", false) then
            speaker:notifyLocalized("oocBlocked")
            return false
        end

        if MODULE.OOCBans[speaker:SteamID64()] then
            speaker:notifyLocalized("oocBanned")
            return false
        end

        if #text > lia.config.get("OOCLimit", 150) then
            speaker:notifyLocalized("textTooBig")
            return false
        end

        local customDelay = hook.Run("getOOCDelay", speaker)
        local oocDelay = customDelay or lia.config.get("OOCDelay", 10)
        if not speaker:hasPrivilege("Staff Permissions - No OOC Cooldown") and oocDelay > 0 and speaker.liaLastOOC then
            local lastOOC = CurTime() - speaker.liaLastOOC
            if lastOOC <= oocDelay then
                speaker:notifyLocalized("oocDelay", oocDelay - math.ceil(lastOOC))
                return false
            end
        end

        speaker.liaLastOOC = CurTime()
    end,
    onCanHear = function() return true end,
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 50, 50), " " .. L("oocPrefix") .. " ", speaker, color_white, ": " .. text) end,
    prefix = {"//", "/ooc"},
    noSpaceAfter = true,
    filter = "ooc"
})

lia.chat.register("me's", {
    syntax = "[string Action]",
    desc = "mesDesc",
    format = "mePossessiveFormat",
    onCanHear = lia.config.get("ChatRange", 280),
    onChatAdd = function(speaker, text, anonymous)
        local speako = anonymous and "Someone" or hook.Run("GetDisplayedName", speaker, "ic") or IsValid(speaker) and speaker:Name() or "Console"
        local texCol = lia.config.get("ChatColor")
        if LocalPlayer():getTracedEntity() == speaker then texCol = lia.config.get("ChatListenColor") end
        texCol = Color(texCol.r, texCol.g, texCol.b)
        local nameCol = Color(texCol.r + 30, texCol.g + 30, texCol.b + 30)
        if LocalPlayer() == speaker then
            local tempCol = lia.config.get("ChatListenColor")
            texCol = Color(tempCol.r + 20, tempCol.b + 20, tempCol.g + 20)
            nameCol = Color(tempCol.r + 40, tempCol.b + 60, tempCol.g + 40)
        end

        chat.AddText(nameCol, "**" .. speako .. "'s", texCol, " " .. text)
    end,
    prefix = {"/me's", "/action's"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("mefarfar", {
    syntax = "[string Action]",
    desc = "mefarfarDesc",
    format = "emoteFormat",
    onChatAdd = function(speaker, text, anonymous)
        local speako = anonymous and "Someone" or hook.Run("GetDisplayedName", speaker, "ic") or IsValid(speaker) and speaker:Name() or "Console"
        local texCol = lia.config.get("ChatColor")
        if LocalPlayer():getTracedEntity() == speaker then texCol = lia.config.get("ChatListenColor") end
        texCol = Color(texCol.r + 45, texCol.g + 45, texCol.b + 45)
        local nameCol = Color(texCol.r + 30, texCol.g + 30, texCol.b + 30)
        if LocalPlayer() == speaker then
            local tempCol = lia.config.get("ChatListenColor")
            texCol = Color(tempCol.r + 65, tempCol.b + 65, tempCol.g + 65)
            nameCol = Color(tempCol.r + 40, tempCol.b + 60, tempCol.g + 40)
        end

        chat.AddText(nameCol, "**" .. speako, texCol, " " .. text)
    end,
    onCanHear = lia.config.get("ChatRange", 280) * 4,
    prefix = {"/mefarfar", "/actionyy", "/meyy"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

lia.chat.register("help", {
    syntax = "[string Text]",
    desc = "helpDesc",
    onCanSay = function() return true end,
    onCanHear = function(speaker, listener)
        if listener:isStaffOnDuty() or listener == speaker or listener:hasPrivilege("Staff Permissions - Always Have Access to Help Chat") then return true end
        return false
    end,
    onChatAdd = function(speaker, text) chat.AddText(Color(200, 50, 50), L("helpPrefix") .. " " .. speaker:GetName(), color_white, ": " .. text) end
})
