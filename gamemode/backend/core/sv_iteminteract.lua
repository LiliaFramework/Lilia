--------------------------------------------------------------------------------------------------------
lia.config.DisallowedBagForbiddenActions = {
    ["Equip"] = true,
    ["EquipUn"] = true,
}

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerInteractItem(client, action, item)
    client:ChatPrint(action)
    client:ChatPrint(tostring(item))
    return true
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerEquipItem(client, item)
    return true
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerTakeItem(client, item)
    if IsValid(item.entity) then
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

    return true
end
--------------------------------------------------------------------------------------------------------