function MODULE:syncCharList(client)
    if not client.liaCharList then return end
    net.Start("liaCharList")
    net.WriteUInt(#client.liaCharList, 32)
    for i = 1, #client.liaCharList do
        net.WriteUInt(client.liaCharList[i], 32)
    end

    net.Send(client)
end

function MODULE:CanPlayerCreateCharacter(client)
    local count = #client.liaCharList
    local maxChars = hook.Run("GetMaxPlayerCharacter", client) or lia.config.MaxCharacters
    if count >= maxChars then return false end
end