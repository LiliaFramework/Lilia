--------------------------------------------------------------------------------------------------------
lia.config.DisallowedBagForbiddenActions = {
    ["Equip"] = true,
    ["EquipUn"] = true,
}

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerInteractItem(client, action, item)
    local inventory = lia.inventory.instances[item.invID]
    if client:getNetVar("fallingover") then return false end
    if client:getNetVar("restricted") then return false end
    if action == "drop" and hook.Run("CanPlayerDropItem", client, item) == false then
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

        return false
    end

    if action == "take" and hook.Run("CanPlayerTakeItem", client, item) == false then
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

        return false
    end

    if action == "equip" and hook.Run("CanPlayerEquipItem", client, item) == false then
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

        return false
    end

    if not client:Alive() or client:getLocalVar("ragdoll") then return false end
    if inventory and (inventory.isBag == true or inventory.isBank == true) and self.BagForbiddenActions[action] then return false, "forbiddenActionStorage" end
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerEquipItem(client, item)
    if client.equipDelay then
        client:notify("You need to wait before equipping something again!")

        return false
    end

    return true
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerTakeItem(client, item)
    if client.takeDelay then
        client:notify("You need to wait before picking something up again!")

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

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerDropItem(client, item)
    if client.dropDelay then
        client:notify("You need to wait before dropping something again!")

        return false
    elseif item.isBag then
        local inventory = item:getInv()
        if inventory then
            local items = inventory:getItems()
            for _, otheritem in pairs(items) do
                if not otheritem.ignoreEquipCheck and otheritem:getData("equip") == true then
                    client:notifyLocalized("cantDropBagHasEquipped")

                    return false
                end
            end
        end
    end

    return true
end
--------------------------------------------------------------------------------------------------------