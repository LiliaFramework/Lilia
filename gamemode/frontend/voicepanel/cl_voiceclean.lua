local function VoiceClean()
    for k, v in pairs(nsVoicePanels) do
        if (!IsValid(k)) then
            hook.Run("PlayerEndVoice", k)
        end
    end
end
timer.Create("VoiceClean", 10, 0, VoiceClean)