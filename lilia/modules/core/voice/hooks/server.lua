local GM = GM or GAMEMODE
local MODULE = MODULE
function GM:PlayerCanHearPlayersVoice(listener, speaker)
    local char = speaker:getChar()
    local canHear = char and not char:getData("VoiceBan", false) and MODULE.IsVoiceEnabled and GetGlobalBool("EnabledVoice", true) and listener ~= speaker
    return canHear and true or false, canHear and true or false
end