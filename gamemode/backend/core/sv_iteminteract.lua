--------------------------------------------------------------------------------------------------------
function GM:CanPlayerInteractItem(client, action, item)
    local inventory = lia.inventory.instances[itemObject.invID]
    if client:getNetVar("restricted") then return false end
    if action == "equip" and hook.Run("CanPlayerEquipItem", client, item) == false then return false end
    if action == "drop" and hook.Run("CanPlayerDropItem", client, item) == false then return false end
    if action == "take" and hook.Run("CanPlayerTakeItem", client, item) == false then return false end
    if not client:Alive() or client:getLocalVar("ragdoll") then return false end
    if inventory and (inventory.isBag == true or inventory.isBank == true) then
        if lia.config.DisallowedBagForbiddenActions[action] then return false, "forbiddenActionStorage" end
    end
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

        if item.entity.liaSteamID == client:SteamID() and item.entity.liaCharID ~= char:getID() then
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

            for _, item in pairs(items) do
                if not item.ignoreEquipCheck and item:getData("equip") == true then
                    client:notifyLocalized("cantDropBagHasEquipped")

                    return false
                end
            end
        end
    end
end
--------------------------------------------------------------------------------------------------------