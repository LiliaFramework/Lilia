local PLUGIN = PLUGIN

do
    hook.Add("InitializedConfig", "liaChatTypes", function()
        -- The default in-character chat.
        lia.chat.register("ic", {
            format = "%s says \"%s\"",
            onGetColor = function(speaker, text)
                -- If you are looking at the speaker, make it greener to easier identify who is talking.
                if LocalPlayer():GetEyeTrace().Entity == speaker then return lia.config.get("chatListenColor") end

                -- Otherwise, use the normal chat color.
                return lia.config.get("chatColor")
            end,
            radius = function()
                return lia.config.get("chatRange", 280)
            end
        })

        -- Actions and such.
        lia.chat.register("me", {
            format = "**%s %s",
            onGetColor = lia.chat.classes.ic.onGetColor,
            radius = function()
                return lia.config.get("chatRange", 280)
            end,
            prefix = {"/me", "/action"},
            font = "liaChatFontItalics",
            filter = "actions",
            deadCanChat = true
        })

        -- Actions and such.
        lia.chat.register("it", {
            onChatAdd = function(speaker, text)
                chat.AddText(lia.chat.timestamp(false), lia.config.get("chatColor"), "**" .. text)
            end,
            radius = function()
                return lia.config.get("chatRange", 280)
            end,
            prefix = {"/it"},
            font = "liaChatFontItalics",
            filter = "actions",
            deadCanChat = true
        })

        -- Whisper chat.
        lia.chat.register("w", {
            format = "%s whispers \"%s\"",
            onGetColor = function(speaker, text)
                local color = lia.chat.classes.ic.onGetColor(speaker, text)

                -- Make the whisper chat slightly darker than IC chat.
                return Color(color.r - 35, color.g - 35, color.b - 35)
            end,
            radius = function()
                return lia.config.get("chatRange", 280) * 0.25
            end,
            prefix = {"/w", "/whisper"}
        })

        -- Yelling out loud.
        lia.chat.register("y", {
            format = "%s yells \"%s\"",
            onGetColor = function(speaker, text)
                local color = lia.chat.classes.ic.onGetColor(speaker, text)

                -- Make the yell chat slightly brighter than IC chat.
                return Color(color.r + 35, color.g + 35, color.b + 35)
            end,
            radius = function()
                return lia.config.get("chatRange", 280) * 2
            end,
            prefix = {"/y", "/yell"}
        })

        -- Local out of character.
        lia.chat.register("looc", {
            onCanSay = function(speaker, text)
                local delay = lia.config.get("loocDelay", 0)

                -- Only need to check the time if they have spoken in LOOC chat before.
                if speaker:IsAdmin() and lia.config.get("loocDelayAdmin", false) and delay > 0 and speaker.liaLastLOOC then
                    local lastLOOC = CurTime() - speaker.liaLastLOOC

                    -- Use this method of checking time in case the oocDelay config changes (may not affect admins).
                    if lastLOOC <= delay and (not speaker:IsAdmin() or speaker:IsAdmin() and lia.config.get("loocDelayAdmin", false)) then
                        speaker:notifyLocalized("loocDelay", delay - math.ceil(lastLOOC))

                        return false
                    end
                end

                -- Save the last time they spoke in OOC.
                speaker.liaLastLOOC = CurTime()
            end,
            onChatAdd = function(speaker, text)
                chat.AddText(lia.chat.timestamp(false), Color(255, 50, 50), "[LOOC] ", lia.config.get("chatColor"), speaker:Name() .. ": " .. text)
            end,
            radius = function()
                return lia.config.get("chatRange", 280)
            end,
            prefix = {".//", "[[", "/looc"},
            noSpaceAfter = true,
            filter = "ooc"
        })

        -- Roll information in chat.
        lia.chat.register("roll", {
            format = "%s has rolled %s.",
            color = Color(155, 111, 176),
            filter = "actions",
            font = "liaChatFontItalics",
            radius = function()
                return lia.config.get("chatRange", 280)
            end,
            deadCanChat = true
        })

        lia.chat.register("ooc", {
            onCanSay = function(speaker, text)
                local delay = lia.config.get("oocDelay", 10)
                local oocmaxsize = lia.config.get("oocLimit", 10)

                if GetGlobalBool("oocblocked", false) then
                    speaker:notify("The OOC is Globally Blocked!")

                    return false
                end

                if PLUGIN.oocBans[speaker:SteamID()] then
                    speaker:notify("You have been banned from using OOC!")

                    return false
                end

                if string.len(text) > oocmaxsize then
                    speaker:notify("Text too big!")

                    return false
                end

                if not speaker:IsAdmin() then
                    -- Only need to check the time if they have spoken in OOC chat before.
                    if delay > 0 and speaker.liaLastOOC then
                        local lastOOC = CurTime() - speaker.liaLastOOC

                        -- Use this method of checking time in case the oocDelay config changes.
                        if lastOOC <= delay then
                            speaker:notifyLocalized("oocDelay", delay - math.ceil(lastOOC))

                            return false
                        end
                    end
                end

                -- Save the last time they spoke in OOC.
                speaker.liaLastOOC = CurTime()
            end,
            onChatAdd = function(speaker, text)
                local icon = "icon16/user.png"
                icon = Material(hook.Run("GetPlayerIcon", speaker) or icon)
                chat.AddText(icon, Color(255, 50, 50), " [OOC] ", speaker, color_white, ": " .. text)
            end,
            prefix = {"//", "/ooc"},
            noSpaceAfter = true,
            filter = "ooc"
        })

        lia.chat.register("pm", {
            format = "[PM] %s: %s.",
            color = Color(249, 211, 89),
            filter = "pm",
            deadCanChat = true
        })

        lia.chat.register("event", {
            onCanSay = function(speaker, text)
                return speaker:IsAdmin()
            end,
            onChatAdd = function(speaker, text)
                chat.AddText(lia.chat.timestamp(false), Color(255, 150, 0), text)
            end,
            prefix = {"/event"}
        })
    end)
end

hook.Remove("PlayerSay", "ULXMeCheck")