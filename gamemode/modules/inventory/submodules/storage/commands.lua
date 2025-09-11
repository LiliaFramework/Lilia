local MODULE = MODULE
lia.command.add("storagelock", {
    adminOnly = true,
    desc = "storagelockDesc",
    arguments = {
        {
            name = "password",
            type = "string",
            optional = true
        },
    },
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
        else
            client:notifyLocalized("invalidEntity")
        end
    end
})

lia.command.add("trunk", {
    adminOnly = false,
    desc = "trunkOpenDesc",
    onRun = function(client)
        local entity = client:getTracedEntity()
        local maxDistance = 128
        local openTime = 0.7
        if  hook.Run("IsSuitableForTrunk", entity) == false then
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

            entity.receivers = entity.receivers or {}
            entity.receivers[client] = true
            local invID = entity:getNetVar("inv")
            local inv = invID and lia.inventory.instances[invID]
            local function openStorage(storageInv)
                if not storageInv then
                    client:notifyLocalized("noInventory")
                    client.liaStorageEntity = nil
                    return
                end

                storageInv:sync(client)
                net.Start("liaStorageOpen")
                net.WriteBool(true)
                net.WriteEntity(entity)
                net.Send(client)
                entity:EmitSound("items/ammocrate_open.wav")
            end

            if inv then
                openStorage(inv)
            else
                MODULE:InitializeStorage(entity):next(openStorage, function(err)
                    client:notifyLocalized("unableCreateStorageEntity", err)
                    client.liaStorageEntity = nil
                end)
            end
        end)
    end
})
