local MODULE = MODULE

do
    hook.Add("InitializedConfig", "liaChatOOC", function()
        lia.chat.register("ooc", {
            onCanSay = function(speaker, text)
                local delay = lia.config.OOCDelay
                local oocmaxsize = lia.config.OOCLimit

                if GetGlobalBool("oocblocked", false) then
                    speaker:notify("The OOC is Globally Blocked!")

                    return false
                end

                if MODULE.oocBans[speaker:SteamID()] then
                    speaker:notify("You have been banned from using OOC!")

                    return false
                end

                if string.len(text) > oocmaxsize then
                    speaker:notify("Text too big!")

                    return false
                end

                if not speaker:IsAdmin() then
                    if delay > 0 and speaker.liaLastOOC then
                        local lastOOC = CurTime() - speaker.liaLastOOC

                        if lastOOC <= delay then
                            speaker:notifyLocalized("oocDelay", delay - math.ceil(lastOOC))

                            return false
                        end
                    end
                end

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
    end)
end