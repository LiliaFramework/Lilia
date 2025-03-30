net.Receive("cMsg", function()
    local client = LocalPlayer()
    local chatType = net.ReadString()
    local text = net.ReadString()
    local anonymous = net.ReadBool()
    print(chatType, text, tostring(anonymous))
    if IsValid(client) then
        local class = lia.chat.classes[chatType]
        text = hook.Run("OnChatReceived", client, chatType, text, anonymous) or text
        if class then
            CHAT_CLASS = class
            class.onChatAdd(client, text, anonymous)
            local customSound = lia.config.get("CustomChatSound", "")
            if customSound and customSound ~= "" then
                surface.PlaySound(customSound)
            else
                chat.PlaySound()
            end

            CHAT_CLASS = nil
        end
    end
end)