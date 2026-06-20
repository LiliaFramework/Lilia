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

net.Receive("liaChatboxSyncFilteredWords", function()
    local wordCount = net.ReadUInt(16)
    local words = {}
    for index = 1, wordCount do
        words[index] = net.ReadString()
    end

    MODULE.filteredWords = words
    if IsValid(MODULE.filteredWordAdminPanel) and MODULE.filteredWordAdminPanel.populateFilteredWords then MODULE.filteredWordAdminPanel:populateFilteredWords(words) end
end)
