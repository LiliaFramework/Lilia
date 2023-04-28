nut.log.addType("itemSpawned", function(client, itemID)
    return string.format("%s (%s) has spawned '%s'", client:SteamName(), client:SteamID(), nut.item.list[itemID].name)
end)

netstream.Hook("nutItemSpawn", function(client, itemID)
    local uniqueID = client:GetUserGroup()

    if not client.itemSpawnCooldown then
        client.itemSpawnCooldown = 0
    end

    if CurTime() > client.itemSpawnCooldown and UserGroups.uaRanks[uniqueID] then
        client.itemSpawnCooldown = CurTime() + PLUGIN.cooldown
        nut.log.add(client, "itemSpawned", itemID)
        nut.item.spawn(itemID, client:GetShootPos())
    end
end)