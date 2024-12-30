local GM = GM or GAMEMODE
local MODULE = MODULE
function GM:PlayerCanHearPlayersVoice(listener, speaker)
    if not IsValid(listener) or not IsValid(speaker) then return false, false end
    if listener == speaker then return false, false end
    local char = speaker:getChar()
    if not (char and not char:getData("VoiceBan", false)) then return false, false end
    if not (MODULE.IsVoiceEnabled and GetGlobalBool("EnabledVoice", true)) then return false, false end
    local voiceType = speaker:getNetVar("VoiceType", "Talking")
    local range = MODULE.TalkRanges[voiceType]
    local distance = listener:GetPos():Distance(speaker:GetPos())
    local canHear = distance <= range
    return canHear, canHear
end

function MODULE:PostPlayerLoadout(client)
    client:setNetVar("VoiceType", "Talking")
end

util.AddNetworkString("ChangeSpeakMode")
net.Receive("ChangeSpeakMode", function(_, client)
    local mode = net.ReadString()
    if MODULE.TalkRanges[mode] then
        client:setNetVar("VoiceType", mode)
    else
        client:chatNotify("Invalid voice mode selected.")
    end
end)