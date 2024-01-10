
lia.command.add(
    "charvoiceunban",
    {
        adminOnly = true,
        privilege = "Voice Unban Character",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if target == client then
                client:notify("You cannot run mute commands on yourself.")
                return false
            end

            if IsValid(target) and target:getChar():getData("VoiceBan", false) then target:getChar():SetData("VoiceBan", false) end
            client:notify("You have unmuted a player.")
            target:notify("You've been unmuted by the admin.")
        end
    }
)


lia.command.add(
    "charvoiceban",
    {
        adminOnly = true,
        privilege = "Voice ban Character",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if target == client then
                client:notify("You cannot run mute commands on yourself.")
                return false
            end

            if IsValid(target) and not target:getData("VoiceBan", false) then target:SetData("VoiceBan", true) end
            client:notify("You have muted a player.")
            target:notify("You've been muted by the admin.")
        end
    }
)


lia.command.add(
    "voicetoggle",
    {
        superAdminOnly = true,
        privilege = "Voice ban Character",
        syntax = "<string name>",
        onRun = function(client)
            local voiceEnabled = GetGlobalBool("EnabledVoice", true)
            if voiceEnabled then
                client:notify("You have disabled voice!")
            else
                if VoiceCore.IsVoiceEnabled then
                    client:notify("You have re-enabled voice!")
                else
                    client:notify("Voice isn't activated in config!!")
                    return
                end
            end

            SetGlobalBool("EnabledVoice", not voiceEnabled)
        end
    }
)

