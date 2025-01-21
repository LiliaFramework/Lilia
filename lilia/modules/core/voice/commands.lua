local MODULE = MODULE
lia.command.add("charvoicetoggle", {
  adminOnly = true,
  privilege = "Toggle Voice Ban Character",
  syntax = "[string name]",
  AdminStick = {
    Name = "Toggle Voice",
    Category = "Moderation Tools",
    SubCategory = "Miscellaneous",
    Icon = "icon16/sound_mute.png"
  },
  onRun = function(client, arguments)
    local target = lia.command.findPlayer(client, arguments[1])
    if target == client then
      client:notify("You cannot toggle mute on yourself.")
      return false
    end

    if IsValid(target) then
      local char = target:getChar()
      if char then
        local isBanned = char:getData("VoiceBan", false)
        char:setData("VoiceBan", not isBanned)
        if isBanned then
          client:notify("You have unmuted " .. target:Name() .. ".")
          target:notify("You have been unmuted by an admin.")
        else
          client:notify("You have muted " .. target:Name() .. ".")
          target:notify("You have been muted by an admin.")
        end
      else
        client:notify("The target does not have a valid character.")
      end
    else
      client:notify("Invalid target.")
    end
  end
})

lia.command.add("voicetoggle", {
  superAdminOnly = true,
  privilege = "Voice ban Character",
  syntax = "[string name]",
  onRun = function(client)
    local voiceEnabled = GetGlobalBool("EnabledVoice", true)
    if voiceEnabled then
      client:notify("You have disabled voice!")
    else
      if lia.config.get("IsVoiceEnabled", true) then
        client:notify("You have re-enabled voice!")
      else
        client:notify("Voice isn't activated in config!")
        return
      end
    end

    SetGlobalBool("EnabledVoice", not voiceEnabled)
  end
})