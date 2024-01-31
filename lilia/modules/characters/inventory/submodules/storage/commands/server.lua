---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("storagelock", {
    privilege = "Lock Storage",
    adminOnly = true,
    syntax = "[string password]",
    onRun = function(client, arguments)
        local entity = client:GetTracedEntity()
        if entity and entity:IsValid() then
            local password = table.concat(arguments, " ")
            if password ~= "" then
                entity:setNetVar("locked", true)
                entity.password = password
                client:notifyLocalized("storPass", password)
            else
                entity:setNetVar("locked", nil)
                entity.password = nil
                client:notifyLocalized("storPassRmv")
            end

            MODULE:SaveData()
        else
            client:notifyLocalized("invalid", "Entity")
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("trunk", {
    privilege = "Default User Commands",
    adminOnly = false,
    onRun = function(client)
        local entity = client:GetEyeTrace().Entity
        local maxDistance = MODULE.TrunkOpenDistance
        local openTime = MODULE.TrunkOpenTime
        local clientPos = client:GetPos():Distance(entity:GetPos())
        if not hook.Run("isSuitableForTrunk", entity) then
            client:notify("You're not looking at any vehicle!", client)
            return
        end

        if clientPos > maxDistance then
            client:notify("You're too far to open the trunk!", client)
            return
        end

        client.liaStorageEntity = entity
        client:setAction("Opening...", openTime, function()
            if clientPos > maxDistance then
                client.liaStorageEntity = nil
                return
            end

            entity.receivers[client] = true
            lia.inventory.instances[entity:getNetVar("inv")]:sync(client)
            net.Start("liaStorageOpen")
            net.WriteEntity(entity)
            net.Send(client)
            entity:EmitSound("items/ammocrate_open.wav")
        end)
    end
})
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
