--------------------------------------------------------------------------------------------------------
function MODULE:InitializedConfig()
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

                if speaker == listener then return true end
                if not trace.Hit and speaker:EyePos():Distance(listener:EyePos()) <= lia.config.ChatRange then return true end

                return false
            end,
            prefix = {"/me", "/action"},
            font = "liaChatFontItalics",
            filter = "actions",
            deadCanChat = true
        }
    )

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

    lia.chat.register(
        "adminchat",
        {
            onGetColor = function(self, speaker, text) return Color(0, 196, 255) end,
            onCanHear = function(self, speaker, listener)
                if CAMI.PlayerHasAccess(listener, "Lilia - Management - Admin Chat", nil) then return true end

                return false
            end,
            onCanSay = function(self, speaker, text)
                if CAMI.PlayerHasAccess(speaker, "Lilia - Management - Admin Chat", nil) then
                    speaker:notify("You aren't an admin. Use '@messagehere' to create a ticket.")

                    return false
                end

                return true
            end,
            onChatAdd = function(self, speaker, text)
                if CAMI.PlayerHasAccess(LocalPlayer(), "Lilia - Management - Admin Chat", nil) and CAMI.PlayerHasAccess(speaker, "Lilia - Management - Admin Chat", nil) then
                    chat.AddText(Color(255, 215, 0), "[А] ", Color(128, 0, 255, 255), speaker:getChar():getName(), ": ", Color(255, 255, 255), text)
                end
            end,
            prefix = "/adminchat"
        }
    )

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
                chat.AddText(lia.chat.timestamp(false), text)
            end,
            prefix = {"/event"}
        }
    )

    lia.chat.register(
        "radio",
        {
            format = "%s says in radio: \"%s\"",
            font = "liaRadioFont",
            onGetColor = function(speaker, text) return lia.config.RadioChatColor end,
            onCanHear = function(speaker, listener)
                local dist = speaker:GetPos():Distance(listener:GetPos())
                local speakRange = lia.config.ChatRange
                local listenerEnts = ents.FindInSphere(listener:GetPos(), speakRange)
                local listenerInv = listener:getChar():getInv()
                local freq
                if not CURFREQ or CURFREQ == "" or not CURCHANNEL then return false end
                if dist <= speakRange then return true end
                if listenerInv then
                    for k, v in pairs(listenerInv:getItems()) do
                        if v.uniqueID == "radio" and v:getData("enabled", false) == true then
                            if CURFREQ == v:getData("freq", "000.0") and CURCHANNEL == v:getData("channel", 1) then
                                listener:EndChatter()

                                return true
                            end
                        end
                    end
                end

                if not freq then
                    for k, v in ipairs(listenerEnts) do
                        if v:GetClass() == "lia_item" then
                            local itemTable = v:getItemTable()
                            if itemTable.uniqueID == "radio" and v:getData("enabled", false) == true then
                                if CURFREQ == v:getData("freq", "000.0") and CURCHANNEL == v:getData("channel", 1) then
                                    listener:EndChatter()

                                    return true
                                end
                            end
                        end
                    end
                end

                return false
            end,
            onCanSay = function(speaker, text)
                local schar = speaker:getChar()
                local speakRange = lia.config.ChatRange
                local speakEnts = ents.FindInSphere(speaker:GetPos(), speakRange)
                local speakerInv = schar:getInv()
                local freq
                local channel
                if speakerInv then
                    for k, v in pairs(speakerInv:getItems()) do
                        if v.uniqueID == "radio" and v:getData("enabled", false) == true then
                            freq = v:getData("freq", "000.0")
                            channel = v:getData("channel", 1)
                            break
                        end
                    end
                end

                if not freq then
                    for k, v in ipairs(speakEnts) do
                        if v:GetClass() == "lia_item" then
                            local itemTable = v:getItemTable()
                            if itemTable.uniqueID == "radio" and v:getData("enabled", false) == true then
                                freq = v:getData("freq", "000.0")
                                channel = v:getData("channel", 1)
                                break
                            end
                        end
                    end
                end

                if freq then
                    CURFREQ = freq
                    if channel then
                        CURCHANNEL = channel
                    end

                    speaker:EmitSound("npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav", math.random(50, 60), math.random(80, 120))
                else
                    speaker:notifyLocalized("radioNoRadioComm")

                    return false
                end
            end,
            prefix = {"/r", "/radio"},
        }
    )
end

--------------------------------------------------------------------------------------------------------
hook.Remove("PlayerSay", "ULXMeCheck")
--------------------------------------------------------------------------------------------------------