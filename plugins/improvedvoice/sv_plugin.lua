local PLUGIN = PLUGIN

hook.Add("PlayerCanHearPlayersVoiceHook3DVoice", "PlayerCanHearPlayersVoiceHook3DVoice", function()
    if not lia.config.get("3DVoiceEnabled") then return false end
    local voicedata = {}
    voicedata.radius = lia.config.get("3DVoiceRadius") * lia.config.get("3DVoiceRadius") -- Number outputted will be obsenely large because im using DistToSqr, which is better optimized than distance.
    voicedata.refreshrate = lia.config.get("3DVoiceRefreshRate")
    voicedata.cache = CurTime() -- internal, dont change this nerd.
    voicedata.CanHearCache = false -- internal, dont change this either, nerd.

    if (CurTime() - voicedata.cache > voicedata.refreshrate) and (listener ~= speaker) then
        voicedata.cache = CurTime()
        voicedata.radius = lia.config.get("3DVoiceRadius") * lia.config.get("3DVoiceRadius")
        voicedata.refreshrate = lia.config.get("3DVoiceRefreshRate")

        if speaker:GetPos():DistToSqr(listener:GetPos()) <= voicedata.radius then
            local tr = util.TraceLine({
                start = speaker:EyePos(),
                endpos = listener:EyePos(),
                filter = player.GetAll()
            })

            if not tr.Hit or table.HasValue(PLUGIN.WhitelistedProps, tr.Entity:GetModel()) then
                voicedata.CanHearCache = true
            else
                voicedata.CanHearCache = false
            end
        else
            voicedata.CanHearCache = false
        end
    end

    if voicedata.CanHearCache then
        return true
    else
        return false
    end
end)