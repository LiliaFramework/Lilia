lia.command.add("charvoicetoggle", {
    adminOnly = true,
    privilege = "Toggle Voice Ban Character",
    desc = L("charVoiceToggleDesc"),
    syntax = "[string name]",
    AdminStick = {
        Name = L("toggleVoice"),
        Category = L("moderationTools"),
        SubCategory = L("miscellaneous"),
        Icon = "icon16/sound_mute.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if target == client then
            client:notifyLocalized("cannotMuteSelf")
            return false
        end

        local char = target:getChar()
        if char then
            local isBanned = char:getData("VoiceBan", false)
            char:setData("VoiceBan", not isBanned)
            if isBanned then
                client:notifyLocalized("voiceUnmuted", target:Name())
                target:notifyLocalized("voiceUnmutedByAdmin")
            else
                client:notifyLocalized("voiceMuted", target:Name())
                target:notifyLocalized("voiceMutedByAdmin")
            end
        else
            client:notifyLocalized("noValidCharacter")
        end
    end
})
