local MODULE = MODULE

netstream.Hook("cMsg", function(client, chatType, text, anonymous)
  if IsValid(client) then
    local class = lia.chat.classes[chatType]
    text = hook.Run("OnChatReceived", client, chatType, text, anonymous) or text
    if class then
      CHAT_CLASS = class
      class.onChatAdd(client, text, anonymous)
      if MODULE.CustomChatSound and MODULE.CustomChatSound ~= "" then
        surface.PlaySound(MODULE.CustomChatSound)
      else
        chat.PlaySound()
      end

      CHAT_CLASS = nil
    end
  end
end)