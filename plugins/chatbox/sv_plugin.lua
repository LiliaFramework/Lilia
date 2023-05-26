netstream.Hook("msg", function(client, text)
    local charlimit = 200

    if utf8.len(text) > charlimit then
        text = utf8.sub(text, 1, 200)
        client:notify(string.format("Your message has been shortened due to being longer than %s characters!", charlimit))
    end

    if (client.liaNextChat or 0) < CurTime() and text:find("%S") then
        hook.Run("PlayerSay", client, text)
        client.liaNextChat = CurTime() + math.max(#text / 250, 0.4)
    end
end)