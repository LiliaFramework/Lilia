---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("ooc", {
    onCanSay = function(speaker, text)
        if GetGlobalBool("oocblocked", false) then
            speaker:notify("The OOC is Globally Blocked!")
            return false
        end

        if MODULE.OOCBans[speaker:SteamID()] then
            speaker:notify("You have been banned from using OOC!")
            return false
        end

        if string.len(text) > MODULE.OOCLimit then
            speaker:notify("Text too big!")
            return false
        end

        local customDelay = hook.Run("getOOCDelay", speaker)
        local oocDelay = customDelay or MODULE.OOCDelay
        if not CAMI.PlayerHasAccess(speaker, "Staff Permissions - No OOC Cooldown") and oocDelay > 0 and speaker.liaLastOOC then
            local lastOOC = CurTime() - speaker.liaLastOOC
            if lastOOC <= oocDelay then
                speaker:notifyLocalized("oocDelay", oocDelay - math.ceil(lastOOC))
                return false
            end
        end

        speaker.liaLastOOC = CurTime()
    end,
    onCanHear = function() return true end,
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 50, 50), " [OOC] ", speaker, color_white, ": " .. text) end,
    prefix = {"//", "/ooc"},
    noSpaceAfter = true,
    filter = "ooc"
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("meclose", {
    format = "**%s %s",
    onCanHear = MODULE.ChatRange * 0.25,
    prefix = {"/meclose", "/actionclose"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("mefar", {
    format = "**%s %s",
    onCanHear = MODULE.ChatRange * 2,
    prefix = {"/mefar", "/actionfar"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("itclose", {
    onChatAdd = function(_, text) chat.AddText(lia.config.get("chatColor"), "**" .. text) end,
    onCanHear = MODULE.ChatRange * 0.25,
    prefix = {"/itclose"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("itfar", {
    onChatAdd = function(_, text) chat.AddText(MODULE.ChatColor, "**" .. text) end,
    onCanHear = MODULE.ChatRange * 2,
    prefix = {"/itfar"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("coinflip", {
    format = "%s flipped a coin and it landed on %s.",
    onCanHear = MODULE.ChatRange,
    prefix = {"/coinflip"},
    color = Color(236, 100, 9),
    filter = "actions",
    font = "liaChatFontItalics",
    deadCanChat = false
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("announce", {
    format = "%s announces \"%s\"",
    onCanHear = MODULE.ChatRange * 4,
    prefix = {"/announce", "/announcement"},
    color = Color(255, 150, 0),
    font = "liaChatFontBold",
    deadCanChat = false
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("ic", {
    format = "%s says \"%s\"",
    onGetColor = function(speaker, _)
        if LocalPlayer():GetEyeTrace().Entity == speaker then return MODULE.ChatListenColor end
        return MODULE.ChatColor
    end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange then return true end
        return false
    end,
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("me", {
    format = "**%s %s",
    onGetColor = lia.chat.classes.ic.onGetColor,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange then return true end
        return false
    end,
    prefix = {"/me", "/action"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("it", {
    onChatAdd = function(_, text) chat.AddText(lia.chat.timestamp(false), MODULE.ChatColor, "**" .. text) end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange then return true end
        return false
    end,
    prefix = {"/it"},
    font = "liaChatFontItalics",
    filter = "actions",
    deadCanChat = true
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("w", {
    format = "%s whispers \"%s\"",
    onGetColor = function(speaker, text)
        local color = lia.chat.classes.ic.onGetColor(speaker, text)
        return Color(color.r - 35, color.g - 35, color.b - 35)
    end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange * 0.25 then return true end
        return false
    end,
    prefix = {"/w", "/whisper"}
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("notice", {
    onCanSay = function(speaker, _) return not IsValid(speaker) end,
    onCanHear = function(_, _) return true end,
    onChatAdd = function(_, text) chat.AddText("icon16/comment.png", Color(175, 200, 255), text) end,
    prefix = {"/notice"},
    font = "liaMediumFont"
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("y", {
    format = "%s yells \"%s\"",
    onGetColor = function(speaker, text)
        local color = lia.chat.classes.ic.onGetColor(speaker, text)
        return Color(color.r + 35, color.g + 35, color.b + 35)
    end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange * 2 then return true end
        return false
    end,
    prefix = {"/y", "/yell"}
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("looc", {
    onCanSay = function(speaker, _)
        local delay = MODULE.LOOCDelay
        if speaker:IsAdmin() and MODULE.LOOCDelayAdmin and delay > 0 and speaker.liaLastLOOC then
            local lastLOOC = CurTime() - speaker.liaLastLOOC
            if lastLOOC <= delay and (not speaker:IsAdmin() or speaker:IsAdmin() and MODULE.LOOCDelayAdmin) then
                speaker:notifyLocalized("loocDelay", delay - math.ceil(lastLOOC))
                return false
            end
        end

        speaker.liaLastLOOC = CurTime()
    end,
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 50, 50), "[LOOC] ", MODULE.ChatColor, speaker:Name() .. ": " .. text) end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange then return true end
        return false
    end,
    prefix = {".//", "[[", "/looc"},
    noSpaceAfter = true,
    filter = "ooc"
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("adminchat", {
    onGetColor = function(_, _) return Color(0, 196, 255) end,
    onCanHear = function(_, listener)
        if CAMI.PlayerHasAccess(listener, "Staff Permissions - Admin Chat", nil) then return true end
        return false
    end,
    onCanSay = function(speaker, _)
        if CAMI.PlayerHasAccess(speaker, "Staff Permissions - Admin Chat", nil) then
            speaker:notify("You aren't an admin. Use '@messagehere' to create a ticket.")
            return false
        end
        return true
    end,
    onChatAdd = function(speaker, text) chat.AddText(Color(255, 215, 0), "[Аdmin Chat] ", Color(128, 0, 255, 255), speaker:getChar():getName(), ": ", Color(255, 255, 255), text) end,
    prefix = "/adminchat"
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("roll", {
    format = "%s has rolled %s.",
    color = Color(155, 111, 176),
    filter = "actions",
    font = "liaChatFontItalics",
    deadCanChat = true,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange then return true end
        return false
    end,
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("pm", {
    format = "[PM] %s: %s.",
    color = Color(249, 211, 89),
    filter = "pm",
    deadCanChat = true
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("eventlocal", {
    onCanSay = function(speaker, _) return CAMI.PlayerHasAccess(speaker, "Staff Permissions - Local Event Chat", nil) end,
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange * 6 then return true end
        return false
    end,
    onChatAdd = function(_, text) chat.AddText(Color(255, 150, 0), text) end,
    prefix = {"/eventlocal"},
    font = "liaMediumFont"
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("event", {
    onCanSay = function(speaker, _) return CAMI.PlayerHasAccess(speaker, "Staff Permissions - Event Chat", nil) end,
    onCanHear = function(_, _) return true end,
    onChatAdd = function(_, text) chat.AddText(Color(255, 150, 0), text) end,
    prefix = {"/event"},
    font = "liaMediumFont"
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("rolld", {
    format = "%s has %s.",
    color = Color(155, 111, 176),
    filter = "actions",
    font = "liaChatFontItalics",
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange then return true end
        return false
    end,
    deadCanChat = true
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.chat.register("flip", {
    format = "%s flipped a coin and it landed on %s.",
    color = Color(155, 111, 176),
    filter = "actions",
    font = "liaChatFontItalics",
    onCanHear = function(speaker, listener)
        if speaker == listener then return true end
        if speaker:EyePos():Distance(listener:EyePos()) <= MODULE.ChatRange then return true end
        return false
    end,
    deadCanChat = true
})
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
