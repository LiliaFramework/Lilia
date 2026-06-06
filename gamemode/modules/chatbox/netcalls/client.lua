local MODULE = MODULE
net.Receive("liaRegenChat", function()
    for _, panel in ipairs(vgui.GetAll()) do
        if IsValid(panel) and panel:GetName() == "liaChatBox" then panel:Remove() end
    end

    MODULE.panel = nil
    lia.gui.chat = nil
    lia.chat.persistedMessages = {}
    hook.Run("CreateChatboxPanel")
end)
