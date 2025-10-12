net.Receive("liaMessageData", function(_, client)
    local text = net.ReadString()
    local charlimit = lia.config.get("MaxChatLength")
    if charlimit > 0 then
        if (client.liaNextChat or 0) < CurTime() and text:find("%S") then
            hook.Run("PlayerSay", client, text)
            client.liaNextChat = CurTime() + math.max(#text / 250, 0.4)
        end
    else
        if utf8.len(text) > charlimit then
            client:notifyErrorLocalized("messageTooLong", charlimit)
        else
            if (client.liaNextChat or 0) < CurTime() and text:find("%S") then
                hook.Run("PlayerSay", client, text)
                client.liaNextChat = CurTime() + math.max(#text / 250, 0.4)
            end
        end
    end
end)