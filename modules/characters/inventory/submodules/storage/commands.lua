lia.command.add("storagelock", {
    privilege = "Lock Storage",
    adminOnly = true,
    desc = L("storagelockDesc"),
    syntax = "[string password]",
    onRun = function(client, arguments)
        local entity = client:getTracedEntity()
        if entity and IsValid(entity) then
            local password = table.concat(arguments, " ")
            if password ~= "" then
                entity:setNetVar("locked", true)
                entity.password = password
                client:notifyLocalized("storPass", password)
                lia.log.add(client, "storageLock", entity:GetClass(), true)
            else
                entity:setNetVar("locked", nil)
                entity.password = nil
                client:notifyLocalized("storPassRmv")
                lia.log.add(client, "storageLock", entity:GetClass(), false)
            end

            MODULE:SaveData()
        else
            client:notifyLocalized("invalidEntity")
        end
    end
})

lia.command.add("trunk", {
    adminOnly = false,
    desc = L("trunkOpenDesc"),
    syntax = nil,
    onRun = function(client)
        local entity = client:getTracedEntity()
        local maxDistance = 110
        local openTime = 0.7
        if not hook.Run("isSuitableForTrunk", entity) then
            client:notifyLocalized("notLookingAtVehicle")
            return
        end

        if client:GetPos():Distance(entity:GetPos()) > maxDistance then
            client:notifyLocalized("tooFarToOpenTrunk")
            return
        end

        client.liaStorageEntity = entity
        client:setAction(L("openingTrunk"), openTime, function()
            if client:GetPos():Distance(entity:GetPos()) > maxDistance then
                client.liaStorageEntity = nil
                return
            end

            entity.receivers[client] = true
            lia.inventory.instances[entity:getNetVar("inv")]:sync(client)
            net.Start("liaStorageOpen")
            net.WriteBool(true)
            net.WriteEntity(entity)
            net.Send(client)
            entity:EmitSound("items/ammocrate_open.wav")
        end)
    end
})
