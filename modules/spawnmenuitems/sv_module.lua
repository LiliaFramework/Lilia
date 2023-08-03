netstream.Hook("liaItemSpawn", function(client, itemID)
    local uniqueID = client:GetUserGroup()

    if not client.itemSpawnCooldown then
        client.itemSpawnCooldown = 0
    end

    if CurTime() > client.itemSpawnCooldown and lia.config.CanSpawnMenuItems[uniqueID] then
        client.itemSpawnCooldown = CurTime() + lia.config.cooldown
        lia.item.spawn(itemID, client:GetShootPos())
    end
end)