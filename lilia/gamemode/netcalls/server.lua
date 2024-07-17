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
util.AddNetworkString("liaTransferItem")
util.AddNetworkString("announcement_client")
util.AddNetworkString("SendMessage")
util.AddNetworkString("SendPrintTable")
util.AddNetworkString("SendPrint")
util.AddNetworkString("StringRequest")
util.AddNetworkString("ReloadLightMaps")
util.AddNetworkString("OpenInformationMenu")
util.AddNetworkString("chatNotifyNet")
util.AddNetworkString("OpenVGUI")
util.AddNetworkString("OpenPage")
net.Receive("StringRequest", function(_, client)
    local time = net.ReadUInt(32)
    local text = net.ReadString()
    if client.StrReqs and client.StrReqs[time] then
        client.StrReqs[time](text)
        client.StrReqs[time] = nil
    end
end)

netstream.Hook("lia_eventLogSave", function(_, eventLog)
    local path = "lilia/" .. SCHEMA.folder .. "/eventlog.txt"
    file.Write(path, eventLog)
end)

netstream.Hook("liaCharKickSelf", function(client)
    local character = client:getChar()
    if character then
        if not client:Alive() then character:setData("pos", nil) end
        character:kick()
    end
end)

net.Receive("liaStringReq", function(_, client)
    local id = net.ReadUInt(32)
    local value = net.ReadString()
    if client.liaStrReqs and client.liaStrReqs[id] then
        client.liaStrReqs[id](value)
        client.liaStrReqs[id] = nil
    end
end)

net.Receive("liaTransferItem", function(_, client)
    local itemID = net.ReadUInt(32)
    local x = net.ReadUInt(32)
    local y = net.ReadUInt(32)
    local invID = net.ReadType()
    hook.Run("HandleItemTransferRequest", client, itemID, x, y, invID)
end)

netstream.Hook("unflagblacklistRequest", function(client, target, bid)
    if not (client:HasPrivilege("Commands - Manage Permanent Flags") or client:IsSuperAdmin()) then return end
    if not IsValid(target) then
        client:notify("That target is no longer online")
        return
    end

    local bData = target:getLiliaData("flagblacklistlog", {})[bid]
    if not bData then
        client:notify("Blacklist ID invalid")
        return
    end

    bData = target:getLiliaData("flagblacklistlog")
    bData[bid].remove = true
    target:setLiliaData("flagblacklistlog", bData)
    target:saveLiliaData()
    client:notify("Target blacklist has been flagged for deactivation. It may take up to 10 seconds.")
end)

netstream.Hook("invAct", function(client, action, item, _, data)
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

netstream.Hook("cmd", function(client, command, arguments)
    if (client.liaNextCmd or 0) < CurTime() then
        local arguments2 = {}
        for _, v in ipairs(arguments) do
            if isstring(v) or isnumber(v) then arguments2[#arguments2 + 1] = tostring(v) end
        end

        lia.command.parse(client, nil, command, arguments2)
        client.liaNextCmd = CurTime() + 0.2
    end
end)

netstream.Hook("liaCharFetchNames", function(client) netstream.Start(client, "liaCharFetchNames", lia.char.names) end)
