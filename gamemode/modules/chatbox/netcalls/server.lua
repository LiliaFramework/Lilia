local MODULE = MODULE
net.Receive("liaChatboxRequestFilteredWords", function(_, client)
    if not hook.Run("CanManageFilteredWords", client) then return end
    MODULE:SyncFilteredWords(client)
end)

net.Receive("liaChatboxAddFilteredWord", function(_, client)
    if not hook.Run("CanManageFilteredWords", client) then return end
    local word = net.ReadString()
    local success, result = MODULE:AddFilteredWord(word)
    if not success then
        if result == "exists" then
            client:notifyError(string.format("That word is already filtered."))
        else
            client:notifyError(string.format("Enter a valid word first."))
        end
        return
    end

    client:notifySuccess(string.format("Added filtered word: %s", result))
    MODULE:SyncFilteredWords()
end)

net.Receive("liaChatboxRemoveFilteredWord", function(_, client)
    if not hook.Run("CanManageFilteredWords", client) then return end
    local word = net.ReadString()
    local success, result = MODULE:RemoveFilteredWord(word)
    if not success then
        if result == "missing" then
            client:notifyError(string.format("That word is not in the filter list."))
        else
            client:notifyError(string.format("Enter a valid word first."))
        end
        return
    end

    client:notifySuccess(string.format("Removed filtered word: %s", result))
    MODULE:SyncFilteredWords()
end)
