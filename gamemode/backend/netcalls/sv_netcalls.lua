--------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaCharacterInvList")
util.AddNetworkString("liaItemDelete")
util.AddNetworkString("liaItemInstance")
util.AddNetworkString("liaInventoryInit")
util.AddNetworkString("liaInventoryData")
util.AddNetworkString("liaInventoryDelete")
util.AddNetworkString("liaInventoryAdd")
util.AddNetworkString("liaInventoryRemove")
util.AddNetworkString("liaNotify")
util.AddNetworkString("liaNotifyL")
util.AddNetworkString("liaStringReq")
util.AddNetworkString("liaTypeStatus")
util.AddNetworkString("liaTransferItem")
util.AddNetworkString("cleanup_inbound")
util.AddNetworkString("worlditem_cleanup_inbound")
util.AddNetworkString("worlditem_cleanup_inbound_final")
util.AddNetworkString("map_cleanup_inbound")
util.AddNetworkString("map_cleanup_inbound_final")
util.AddNetworkString("VoiceMenu")
util.AddNetworkString("OpenInvMenu")
util.AddNetworkString("announcement_client")
util.AddNetworkString("advert_client")
--------------------------------------------------------------------------------------------------------
net.Receive("liaStringReq", function(_, client)
    local id = net.ReadUInt(32)
    local value = net.ReadString()

    if client.liaStrReqs and client.liaStrReqs[id] then
        client.liaStrReqs[id](value)
        client.liaStrReqs[id] = nil
    end
end)
--------------------------------------------------------------------------------------------------------
net.Receive("liaTransferItem", function(_, client)
    local itemID = net.ReadUInt(32)
    local x = net.ReadUInt(32)
    local y = net.ReadUInt(32)
    local invID = net.ReadType()
    hook.Run("HandleItemTransferRequest", client, itemID, x, y, invID)
end)
--------------------------------------------------------------------------------------------------------
netstream.Hook("invAct", function(client, action, item, invID, data)
    local character = client:getChar()
    if not character then return end
    local entity

    if isentity(item) then
        if not IsValid(item) then return end
        if item:GetPos():Distance(client:GetPos()) > 96 then return end
        if not item.liaItemID then return end
        entity = item
        item = lia.item.instances[item.liaItemID]
    else
        item = lia.item.instances[item]
    end

    if not item then return end
    local inventory = lia.inventory.instances[item.invID]

    local context = {
        client = client,
        item = item,
        entity = entity,
        action = action
    }

    if inventory and not inventory:canAccess("item", context) then return end
    item:interact(action, client, entity, data)
end)
--------------------------------------------------------------------------------------------------------
netstream.Hook("cmd", function(client, command, arguments)
    if (client.liaNextCmd or 0) < CurTime() then
        local arguments2 = {}

        for _, v in ipairs(arguments) do
            if isstring(v) or isnumber(v) then
                arguments2[#arguments2 + 1] = tostring(v)
            end
        end

        lia.command.parse(client, nil, command, arguments2)
        client.liaNextCmd = CurTime() + 0.2
    end
end)
--------------------------------------------------------------------------------------------------------
netstream.Hook("ChangeMode", function(client, mode)
    client:setNetVar("voiceRange", mode)

    if client:getNetVar("voiceRange") > #lia.config.Ranges then
        client:setNetVar("voiceRange", 2)
    end
end)
--------------------------------------------------------------------------------------------------------
net.Receive("liaTypeStatus", function(_, client)
    client:setNetVar("typing", net.ReadBool())
end)
--------------------------------------------------------------------------------------------------------