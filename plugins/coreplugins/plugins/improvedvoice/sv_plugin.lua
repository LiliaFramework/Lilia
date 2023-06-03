util.AddNetworkString("VoiceMenu")

hook.Add("PlayerCanHearPlayersVoiceTalker", "PlayerCanHearPlayersVoiceTalker", function()
    if not speaker:getNetVar("voiceRange") then return false end
    local oldrange = Voice.Ranges[speaker:getNetVar("voiceRange", 2)].range
    oldrange = oldrange * oldrange
    if listener:GetPos():DistToSqr(speaker:GetPos()) < oldrange then return true, true end

    return false, false
end)

netstream.Hook("ChangeMode", function(client, mode)
    client:setNetVar("voiceRange", mode)

    if client:getNetVar("voiceRange") > #Voice.Ranges then
        client:setNetVar("voiceRange", 2)
    end
end)

function PLUGIN:PlayerSpawn(client)
    client:setNetVar("voiceRange", 2)
end