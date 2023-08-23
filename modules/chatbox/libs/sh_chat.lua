--------------------------------------------------------------------------------------------------------
function MODULE:InitializedConfig()
    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "ic",
        {
            format = "%s says \"%s\"",
            onGetColor = function(speaker, text)
                if LocalPlayer():GetEyeTrace().Entity == speaker then return lia.config.ChatListenColor end

                return lia.config.ChatColor
            end,
            radius = function(speaker, text) return lia.config.ChatRange end
        }
    )

    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "me",
        {
            format = "**%s %s",
            onGetColor = lia.chat.classes.ic.onGetColor,
            onCanHear = function(speaker, text)
                local trace = util.TraceLine{
                    start = speaker:EyePos(),
                    mask = MASK_SOLID_BRUSHONLY,
                    endpos = listener:EyePos()
                }

                if not trace.Hit then
                    if speaker:EyePos():Distance(listener:EyePos()) <= lia.config.ChatRange then return true end
                end

                return false
            end,
            prefix = {"/me", "/action"},
            font = "liaChatFontItalics",
            filter = "actions",
            deadCanChat = true
        }
    )

    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "it",
        {
            onChatAdd = function(speaker, text)
                chat.AddText(lia.chat.timestamp(false), lia.config.ChatColor, "**" .. text)
            end,
            radius = function(speaker, text) return lia.config.ChatRange end,
            prefix = {"/it"},
            font = "liaChatFontItalics",
            filter = "actions",
            deadCanChat = true
        }
    )

    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "w",
        {
            format = "%s whispers \"%s\"",
            onGetColor = function(speaker, text)
                local color = lia.chat.classes.ic.onGetColor(speaker, text)

                return Color(color.r - 35, color.g - 35, color.b - 35)
            end,
            radius = function(speaker, text) return lia.config.ChatRange * 0.25 end,
            prefix = {"/w", "/whisper"}
        }
    )

    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "y",
        {
            format = "%s yells \"%s\"",
            onGetColor = function(speaker, text)
                local color = lia.chat.classes.ic.onGetColor(speaker, text)

                return Color(color.r + 35, color.g + 35, color.b + 35)
            end,
            radius = function(speaker, text) return lia.config.ChatRange * 2 end,
            prefix = {"/y", "/yell"}
        }
    )

    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "looc",
        {
            onCanSay = function(speaker, text)
                local delay = lia.config.LOOCDelay
                if speaker:IsAdmin() and lia.config.LOOCDelayAdmin and delay > 0 and speaker.liaLastLOOC then
                    local lastLOOC = CurTime() - speaker.liaLastLOOC
                    if lastLOOC <= delay and (not speaker:IsAdmin() or speaker:IsAdmin() and lia.config.LOOCDelayAdmin) then
                        speaker:notifyLocalized("loocDelay", delay - math.ceil(lastLOOC))

                        return false
                    end
                end

                speaker.liaLastLOOC = CurTime()
            end,
            onChatAdd = function(speaker, text)
                chat.AddText(Color(255, 50, 50), "[LOOC] ", lia.config.ChatColor, speaker:Name() .. ": " .. text)
            end,
            radius = function(speaker, text) return lia.config.ChatRange end,
            prefix = {".//", "[[", "/looc"},
            noSpaceAfter = true,
            filter = "ooc"
        }
    )

    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "roll",
        {
            format = "%s has rolled %s.",
            color = Color(155, 111, 176),
            filter = "actions",
            font = "liaChatFontItalics",
            radius = function(speaker, text) return lia.config.ChatRange end,
            deadCanChat = true
        }
    )

    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "pm",
        {
            format = "[PM] %s: %s.",
            color = Color(249, 211, 89),
            filter = "pm",
            deadCanChat = true
        }
    )

    --------------------------------------------------------------------------------------------------------
    lia.chat.register(
        "event",
        {
            onCanSay = function(speaker, text) return speaker:IsAdmin() end,
            onChatAdd = function(speaker, text)
                chat.AddText(lia.chat.timestamp(false), text)
            end,
            prefix = {"/event"}
        }
    )
    --------------------------------------------------------------------------------------------------------
end

hook.Remove("PlayerSay", "ULXMeCheck")