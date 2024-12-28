local MODULE = MODULE
lia.command.add("storagelock", {
    privilege = "Lock Storage",
    adminOnly = true,
    syntax = "[string password]",
    onRun = function(client, arguments)
        local entity = client:GetTracedEntity()
        if entity and IsValid(entity) then
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
            client:notifyLocalized("invalidEntity")
        end
    end
})

lia.command.add("trunk", {
    adminOnly = false,
    onRun = function(client)
        local entity = client:GetTracedEntity()
        local maxDistance = 110
        local openTime = 0.7
        local clientPos = client:GetPos():Distance(entity:GetPos())
        if not hook.Run("isSuitableForTrunk", entity) then
            client:notifyLocalized("notLookingAtVehicle")
            return
        end

        if clientPos > maxDistance then
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
    end,
})