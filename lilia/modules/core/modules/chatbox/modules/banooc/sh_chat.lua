--------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------------------------
function MODULE:InitializedConfig()
    lia.chat.register(
        "ooc",
        {
            onCanSay = function(speaker, text)
                if GetGlobalBool("oocblocked", false) then
                    speaker:notify("The OOC is Globally Blocked!")
                    return false
                end

                if self.oocBans[speaker:SteamID()] then
                    speaker:notify("You have been banned from using OOC!")
                    return false
                end

                if string.len(text) > lia.config.OOCLimit then
                    speaker:notify("Text too big!")
                    return false
                end

                if not CAMI.PlayerHasAccess(speaker, "Lilia - Staff Permissions - No OOC Cooldown") and lia.config.OOCDelay > 0 and speaker.liaLastOOC then
                    local lastOOC = CurTime() - speaker.liaLastOOC
                    if lastOOC <= lia.config.OOCDelay then
                        speaker:notifyLocalized("oocDelay", lia.config.OOCDelay - math.ceil(lastOOC))
                        return false
                    end
                end

                speaker.liaLastOOC = CurTime()
            end,
            onChatAdd = function(speaker, text) chat.AddText(Color(255, 50, 50), " [OOC] ", speaker, color_white, ": " .. text) end,
            prefix = {"//", "/ooc"},
            noSpaceAfter = true,
            filter = "ooc"
        }
    )
end
--------------------------------------------------------------------------------------------------------------------------
