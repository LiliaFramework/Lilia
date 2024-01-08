------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "storagelock",
    {
        privilege = "Lock Storage",
        adminOnly = true,
        syntax = "[string password]",
        onRun = function(client, arguments)
            local ent = client:GetTracedEntity()
            if ent and ent:IsValid() then
                local password = table.concat(arguments, " ")
                if password ~= "" then
                    ent:setNetVar("locked", true)
                    ent.password = password
                    client:notifyLocalized("storPass", password)
                else
                    ent:setNetVar("locked", nil)
                    ent.password = nil
                    client:notifyLocalized("storPassRmv")
                end

                LiliaStorage:SaveData()
            else
                client:notifyLocalized("invalid", "Entity")
            end
        end
    }
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "trunk",
    {
        privilege = "Default User Commands",
        adminOnly = false,
        onRun = function(client)
            local ent = client:GetEyeTrace().Entity
            local maxDistance = LiliaStorage.TrunkOpenDistance
            local openTime = LiliaStorage.TrunkOpenTime
            local clientPos = client:GetPos():Distance(ent:GetPos())
            if not hook.Run("isSuitableForTrunk", ent) then
                client:notify("You're not looking at any vehicle!", client)
                return
            end

            if clientPos > maxDistance then
                client:notify("You're too far to open the trunk!", client)
                return
            end

            client.liaStorageEntity = ent
            client:setAction(
                "Opening...",
                openTime,
                function()
                    if clientPos > maxDistance then
                        client.liaStorageEntity = nil
                        return
                    end

                    ent.receivers[client] = true
                    lia.inventory.instances[ent:getNetVar("inv")]:sync(client)
                    net.Start("liaStorageOpen")
                    net.WriteEntity(ent)
                    net.Send(client)
                    ent:EmitSound("items/ammocrate_open.wav")
                end
            )
        end
    }
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
