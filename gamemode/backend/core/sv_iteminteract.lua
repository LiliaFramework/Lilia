--------------------------------------------------------------------------------------------------------
lia.config.DisallowedBagForbiddenActions = {
    ["Equip"] = true,
    ["EquipUn"] = true,
}

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerInteractItem(client, action, item)
    local inventory = lia.inventory.instances[item.invID]
    if client:getNetVar("restricted") then return false end
    if not client:Alive() or client:getLocalVar("ragdoll") then return false end
    if action == "equip" and hook.Run("CanPlayerEquipItem", client, item) then return true end
    if action == "drop" and hook.Run("CanPlayerDropItem", client, item) then return true end
    if action == "take" and hook.Run("CanPlayerTakeItem", client, item) then return true end
    if inventory and (inventory.isBag == true or inventory.isBank == true) and lia.config.DisallowedBagForbiddenActions[action] then return false, "forbiddenActionStorage" end
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerEquipItem(client, item)
    if not item.RequiredSkillLevels then return true end

    return client:MeetsRequiredSkills(item.RequiredSkillLevels)
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
end
--------------------------------------------------------------------------------------------------------