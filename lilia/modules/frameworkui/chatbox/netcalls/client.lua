
netstream.Hook("adminClearChat", function()
    if ChatboxCore and IsValid(ChatboxCore.panel) then
        ChatboxCore.panel:Remove()
        ChatboxCore:createChat()
    else
        LocalPlayer():ConCommand("fixchatplz")
    end
end)


netstream.Hook("cMsg", function(client, chatType, text, anonymous)
    if IsValid(client) then
        local class = lia.chat.classes[chatType]
        text = hook.Run("OnChatReceived", client, chatType, text, anonymous) or text
        if class then
            CHAT_CLASS = class
            class.onChatAdd(client, text, anonymous)
            if ChatboxCore.CustomChatSound and ChatboxCore.CustomChatSound ~= "" then
                surface.PlaySound(ChatboxCore.CustomChatSound)
            else
                chat.PlaySound()
            end

            CHAT_CLASS = nil
        end
    end
end)

