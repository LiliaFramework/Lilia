local MODULE = MODULE
net.Receive("liaChatboxRequestFilteredWords", function(_, client)
    if not MODULE:CanManageFilteredWords(client) then return end
    MODULE:SyncFilteredWords(client)
end)

net.Receive("liaChatboxAddFilteredWord", function(_, client)
    if not MODULE:CanManageFilteredWords(client) then return end
    local word = net.ReadString()
    local success, result = MODULE:AddFilteredWord(word)
    if not success then
        if result == "exists" then
            client:notifyErrorLocalized("chatFilterWordExists")
        else
            client:notifyErrorLocalized("chatFilterInvalidWord")
        end
        return
    end

    client:notifySuccessLocalized("chatFilterWordAdded", result)
    MODULE:SyncFilteredWords()
end)

net.Receive("liaChatboxRemoveFilteredWord", function(_, client)
    if not MODULE:CanManageFilteredWords(client) then return end
    local word = net.ReadString()
    local success, result = MODULE:RemoveFilteredWord(word)
    if not success then
        if result == "missing" then
            client:notifyErrorLocalized("chatFilterWordMissing")
        else
            client:notifyErrorLocalized("chatFilterInvalidWord")
        end
        return
    end

    client:notifySuccessLocalized("chatFilterWordRemoved", result)
    MODULE:SyncFilteredWords()
end)
