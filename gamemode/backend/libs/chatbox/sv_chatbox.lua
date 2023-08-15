--------------------------------------------------------------------------------------------------------
function lia.chat.send(speaker, chatType, text, anonymous, receivers)
    local class = lia.chat.classes[chatType]
    if class and class.onCanSay(speaker, text) ~= false then
        if class.onCanHear and not receivers then
            receivers = {}
            for _, v in ipairs(player.GetAll()) do
                if v:getChar() and class.onCanHear(speaker, v) ~= false then receivers[#receivers + 1] = v end
            end

            if #receivers == 0 then return end
        end

        netstream.Start(receivers, "cMsg", speaker, chatType, hook.Run("PlayerMessageSend", speaker, chatType, text, anonymous, receivers) or text, anonymous)
    end
end
--------------------------------------------------------------------------------------------------------