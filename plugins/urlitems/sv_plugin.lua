util.AddNetworkString("SpecialDocumentsExchange")
util.AddNetworkString("SpecialDocumentsSendURL")
util.AddNetworkString("SpecialDocumentsSetItemName")

net.Receive("SpecialDocumentsExchange", function(len, ply)
    local itemID = net.ReadDouble()
    local str = net.ReadString()
    local overrideName = net.ReadString()
    local findString = "https://docs.google.com/"
    if not ply:getChar() then return end
    if not lia.item.instances[itemID] then return end
    if str:sub(1, #findString) ~= findString then return end
    local invID = lia.item.instances[itemID].invID
    if not invID then return end
    local charID = lia.item.inventories[invID].owner
    if not charID then return end
    local char = lia.char.loaded[charID]
    if not char or char.id ~= ply:getChar().id then return end -- down the rabbit hole, neo
    lia.item.instances[itemID].docLink = str
    lia.item.instances[itemID].overrideName = overrideName
    lia.item.instances[itemID].overrideDesc = str
    net.Start("SpecialDocumentsSetItemName")
    net.WriteDouble(itemID)
    net.WriteString(overrideName or "")
    net.WriteString(str)
    net.Broadcast()
end)