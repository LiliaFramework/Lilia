local GM = GM or GAMEMODE

function GM:PlayerCanHearPlayersVoice(listener, speaker)
    local HasCharacter = speaker:getChar()
    if not HasCharacter then return false end
    local IsVoiceEnabled = VoiceCore.IsVoiceEnabled and GetGlobalBool("EnabledVoice", true)
    local IsVoiceBanned = speaker:getChar():getData("VoiceBan", false)
    local VoiceType = speaker:getNetVar("VoiceType", "Talking")
    local VoiceRadius = VoiceCore.TalkRanges[VoiceType]
    local VoiceRadiusSquared = VoiceRadius * VoiceRadius
    if IsVoiceBanned then return false end
    if IsVoiceEnabled and (listener ~= speaker) and speaker:GetPos():DistToSqr(listener:GetPos()) <= VoiceRadiusSquared then return true, true end
    return false, false
end

function MODULE:PostPlayerLoadout(client)
    client:setNetVar("VoiceType", "Talking")
end
