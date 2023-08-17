lia.config.TakeDelay = 1
lia.config.EquipDelay = 1
lia.config.DropDelay = 1

lia.config.DisallowedBagForbiddenActions = {
    ["Equip"] = true,
    ["EquipUn"] = true,
}

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerInteractItem(client, action, item)
    local inventory = lia.inventory.instances[itemObject.invID]
    if client:getNetVar("restricted") then return false end
    if not client:Alive() or client:getLocalVar("ragdoll") then return false end

    if action == "equip" and hook.Run("CanPlayerEquipItem", client, item) then
        if lia.config.EquipDelay > 0 then
            client.EquipDelay = true

            timer.Create("EquipDelay." .. ply:SteamID64(), lia.config.EquipDelay, 1, function()
                if IsValid(client) then
                    ply.EquipDelay = nil
                end
            end)
        else
            return true
        end
    end

    if action == "drop" and hook.Run("CanPlayerDropItem", client, item) then
        if lia.config.DropDelay > 0 then
            client.DropDelay = true

            timer.Create("DropDelay." .. ply:SteamID64(), lia.config.DropDelay, 1, function()
                if IsValid(client) then
                    ply.DropDelay = nil
                end
            end)
        else
            return true
        end
    end

    if action == "take" and not hook.Run("CanPlayerTakeItem", client, item) then
        if lia.config.TakeDelay > 0 then
            client.TakeDelay = true

            timer.Create("TakeDelay." .. ply:SteamID64(), lia.config.TakeDelay, 1, function()
                if IsValid(client) then
                    ply.TakeDelay = nil
                end
            end)
        else
            return true
        end
    end

    if inventory and (inventory.isBag == true or inventory.isBank == true) and lia.config.DisallowedBagForbiddenActions[action] then return false, "forbiddenActionStorage" end
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerEquipItem(client, item)
    if client.EquipDelay then
        client:notify("You need to wait before equipping something again!")

        return false
    end

    if not item.RequiredSkillLevels then return true end

    return client:MeetsRequiredSkills(item.RequiredSkillLevels)
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerTakeItem(client, item)
    if client.TakeDelay then
        client:notify("You need to wait before picking something up again!")

        return false
    end

    if IsValid(item.entity) then
        local char = client:getChar()

        if item.entity.SteamID64 == client:SteamID() and item.entity.liaCharID ~= char:getID() then
            client:notifyLocalized("playerCharBelonging")

            return false
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerDropItem(client, item)
    if client.DropDelay then
        client:notify("You need to wait before dropping something again!")

        return false
    end

    if item.isBag then
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
end
--------------------------------------------------------------------------------------------------------