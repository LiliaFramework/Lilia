function GM:PlayerButtonDown(client, button)
    if button == KEY_F2 and IsFirstTimePredicted() then netstream.Start("VoiceMenu", client) end
end