--------------------------------------------------------------------------------------------------------
hook.Add("PlayerStartVoice", "liaPlayerStartVoice", function(client)
    if (!IsValid(g_VoicePanelList) or !lia.config.AllowVoice) then return end

    hook.Run("PlayerEndVoice", client)

    if (IsValid(nsVoicePanels[client])) then
        if (nsVoicePanels[client].fadeAnim) then
            nsVoicePanels[client].fadeAnim:Stop()
            nsVoicePanels[client].fadeAnim = nil
        end

        nsVoicePanels[client]:SetAlpha(255)
        return
    end

    if (!IsValid(client)) then return end

    local pnl = g_VoicePanelList:Add("VoicePanel")
    pnl:Setup(client)

    nsVoicePanels[client] = pnl
end)
--------------------------------------------------------------------------------------------------------
hook.Add("PlayerEndVoice", "liaPlayerEndVoice", function(client)
    if (IsValid(nsVoicePanels[client])) then
        if (nsVoicePanels[client].fadeAnim) then return end

        nsVoicePanels[client].fadeAnim = Derma_Anim("FadeOut", nsVoicePanels[client], nsVoicePanels[client].FadeOut)
        nsVoicePanels[client].fadeAnim:Start(2)
    end
end)
--------------------------------------------------------------------------------------------------------
hook.Add("InitPostEntity", "liaCreateVoiceVGUI", function()
	gmod.GetGamemode().PlayerStartVoice = function() end
    gmod.GetGamemode().PlayerEndVoice = function() end

    if (IsValid(g_VoicePanelList)) then
        g_VoicePanelList:Remove()
    end

    g_VoicePanelList = vgui.Create("DPanel")
    g_VoicePanelList:ParentToHUD()
    g_VoicePanelList:SetSize(270, ScrH() - 200)
    g_VoicePanelList:SetPos(ScrW() - 320, 100)
    g_VoicePanelList:SetPaintBackground(false)
end)
--------------------------------------------------------------------------------------------------------