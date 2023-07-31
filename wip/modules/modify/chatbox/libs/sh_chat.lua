do
    hook.Add(
        "InitializedConfig",
        "liaChatTypes",
        function()
            -- The default in-character chat.
            lia.chat.register(
                "ic",
                {
                    format = "%s says \"%s\"",
                    onGetColor = function(speaker, text)
                        -- If you are looking at the speaker, make it greener to easier identify who is talking.
                        if LocalPlayer():GetEyeTrace().Entity == speaker then return CONFIG.ChatListenColor end

                        return CONFIG.ChatColor
                    end,
                    -- Otherwise, use the normal chat color.
                    radius = function() return CONFIG.ChatRange end
                }
            )

            -- Actions and such.
            lia.chat.register(
                "me",
                {
                    format = "**%s %s",
                    onGetColor = lia.chat.classes.ic.onGetColor,
                    radius = function() return CONFIG.ChatRange end,
                    prefix = {"/me", "/action"},
                    font = "liaChatFontItalics",
                    filter = "actions",
                    deadCanChat = true
                }
            )

            -- Actions and such.
            lia.chat.register(
                "it",
                {
                    onChatAdd = function(speaker, text)
                        chat.AddText(lia.chat.timestamp(false), CONFIG.ChatColor, "**" .. text)
                    end,
                    radius = function() return CONFIG.ChatRange end,
                    prefix = {"/it"},
                    font = "liaChatFontItalics",
                    filter = "actions",
                    deadCanChat = true
                }
            )

            -- Whisper chat.
            lia.chat.register(
                "w",
                {
                    format = "%s whispers \"%s\"",
                    onGetColor = function(speaker, text)
                        local color = lia.chat.classes.ic.onGetColor(speaker, text)

                        return Color(color.r - 35, color.g - 35, color.b - 35)
                    end,
                    -- Make the whisper chat slightly darker than IC chat.
                    radius = function() return CONFIG.ChatRange * 0.25 end,
                    prefix = {"/w", "/whisper"}
                }
            )

            -- Yelling out loud.
            lia.chat.register(
                "y",
                {
                    format = "%s yells \"%s\"",
                    onGetColor = function(speaker, text)
                        local color = lia.chat.classes.ic.onGetColor(speaker, text)

                        return Color(color.r + 35, color.g + 35, color.b + 35)
                    end,
                    -- Make the yell chat slightly brighter than IC chat.
                    radius = function() return CONFIG.ChatRange * 2 end,
                    prefix = {"/y", "/yell"}
                }
            )

            -- Local out of character.
            lia.chat.register(
                "looc",
                {
                    onCanSay = function(speaker, text)
                        local delay = CONFIG.LOOCDelay
                        -- Only need to check the time if they have spoken in LOOC chat before.
                        if speaker:IsAdmin() and CONFIG.LOOCDelayAdmin and delay > 0 and speaker.liaLastLOOC then
                            local lastLOOC = CurTime() - speaker.liaLastLOOC
                            -- Use this method of checking time in case the oocDelay config changes (may not affect admins).
                            if lastLOOC <= delay and (not speaker:IsAdmin() or speaker:IsAdmin() and CONFIG.LOOCDelayAdmin) then
                                speaker:notifyLocalized("loocDelay", delay - math.ceil(lastLOOC))

                                return false
                            end
                        end

                        -- Save the last time they spoke in OOC.
                        speaker.liaLastLOOC = CurTime()
                    end,
                    onChatAdd = function(speaker, text)
                        chat.AddText(lia.chat.timestamp(false), Color(255, 50, 50), "[LOOC] ", CONFIG.ChatColor, speaker:Name() .. ": " .. text)
                    end,
                    radius = function() return CONFIG.ChatRange end,
                    prefix = {".//", "[[", "/looc"},
                    noSpaceAfter = true,
                    filter = "ooc"
                }
            )

            -- Roll information in chat.
            lia.chat.register(
                "roll",
                {
                    format = "%s has rolled %s.",
                    color = Color(155, 111, 176),
                    filter = "actions",
                    font = "liaChatFontItalics",
                    radius = function() return CONFIG.ChatRange end,
                    deadCanChat = true
                }
            )

            lia.chat.register(
                "pm",
                {
                    format = "[PM] %s: %s.",
                    color = Color(249, 211, 89),
                    filter = "pm",
                    deadCanChat = true
                }
            )

            lia.chat.register(
                "event",
                {
                    onCanSay = function(speaker, text) return speaker:IsAdmin() end,
                    onChatAdd = function(speaker, text)
                        chat.AddText(lia.chat.timestamp(false), Color(255, 150, 0), text)
                    end,
                    prefix = {"/event"}
                }
            )
        end
    )
end

hook.Remove("PlayerSay", "ULXMeCheck")
