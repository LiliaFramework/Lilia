--------------------------------------------------------------------------------------------------------------------------
function GM:CanPlayerInteractItem(client, action, item)
    if not client:Alive() or client:getLocalVar("ragdoll") then return false end
    if client:getNetVar("fallingover") or client:getNetVar("restricted") then return false end
    if action == "drop" and hook.Run("CanPlayerDropItem", client, item) then
        if client.dropDelay == nil then
            client.dropDelay = true
            timer.Create(
                "DropDelay." .. client:SteamID64(),
                lia.config.DropDelay,
                1,
                function()
                    if IsValid(client) then
                        client.dropDelay = nil
                    end
                end
            )

            return true
        else
            client:notify("You need to wait before dropping something again!")

            return false
        end
    end

    if action == "take" and hook.Run("CanPlayerTakeItem", client, item) then
        if client.takeDelay == nil then
            client.takeDelay = true
            timer.Create(
                "TakeDelay." .. client:SteamID64(),
                lia.config.TakeDelay,
                1,
                function()
                    if IsValid(client) then
                        client.takeDelay = nil
                    end
                end
            )

            return true
        else
            client:notify("You need to wait before picking something up again!")

            return false
        end
    end

    if action == "equip" and hook.Run("CanPlayerEquipItem", client, item) then
        if client.equipDelay == nil then
            client.equipDelay = true
            timer.Create(
                "EquipDelay." .. client:SteamID64(),
                lia.config.EquipDelay,
                1,
                function()
                    if IsValid(client) then
                        client.equipDelay = nil
                    end
                end
            )

            return true
        else
            client:notify("You need to wait before equipping something again!")

            return false
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CanPlayerEquipItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.equipDelay ~= nil then
        client:notify("You need to wait before equipping something again!")

        return false
    elseif inventory and (inventory.isBag or inventory.isBank) then
        client:notifyLocalized("forbiddenActionStorage")

        return false
    end

    return true
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CanPlayerTakeItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.takeDelay ~= nil then
        client:notify("You need to wait before picking something up again!")

        return false
    elseif inventory and (inventory.isBag or inventory.isBank) then
        client:notifyLocalized("forbiddenActionStorage")

        return false
    elseif IsValid(item.entity) then
        local char = client:getChar()
        if item.entity.SteamID64 == client:SteamID() and item.entity.liaCharID ~= char:getID() then
            client:notifyLocalized("playerCharBelonging")

            return false
        end
    end

    return true
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CanPlayerDropItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.dropDelay ~= nil then
        client:notify("You need to wait before dropping something again!")

        return false
    elseif item.isBag and item:getInv() then
        local items = item:getInv():getItems()
        for _, otheritem in pairs(items) do
            if not otheritem.ignoreEquipCheck and otheritem:getData("equip") == true then
                client:notifyLocalized("cantDropBagHasEquipped")

                return false
            end
        end
    elseif inventory and (inventory.isBag or inventory.isBank) then
        client:notifyLocalized("forbiddenActionStorage")

        return false
    end

    return true
end
--------------------------------------------------------------------------------------------------------------------------