---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local GM = GM or GAMEMODE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CanItemBeTransfered(item, curInv, inventory)
    if item.isBag and curInv ~= inventory and item.getInv and item:getInv() and table.Count(item:getInv():getItems()) > 0 then
        local character = lia.char.loaded[curInv.client]
        if SERVER and character and character:getPlayer() then
            char:getPlayer():notify("You can't transfer a backpack that has items inside of it.")
        elseif CLIENT then
            lia.util.notify("You can't transfer a backpack that has items inside of it.")
        end
        return false
    end

    if item.onCanBeTransfered then
        local itemHook = item:onCanBeTransfered(curInv, inventory)
        return itemHook ~= false
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CanPlayerInteractItem(client, action, item)
    if not client:Alive() or client:getLocalVar("ragdoll") then return false end
    if client:getNetVar("fallingover") then return false end
    if item.steamID and not table.HasValue(item.steamID, client:SteamID()) then
        client:notify("This item is whitelisted!")
        return false
    end

    if action == "drop" then
        if hook.Run("CanPlayerDropItem", client, item) ~= false then
            if client.dropDelay == nil then
                client.dropDelay = true
                timer.Create("DropDelay." .. client:SteamID64(), lia.config.DropDelay, 1, function() if IsValid(client) then client.dropDelay = nil end end)
                return true
            else
                client:notify("You need to wait before dropping something again!")
                return false
            end
        else
            return false
        end
    end

    if action == "take" then
        if hook.Run("CanPlayerTakeItem", client, item) ~= false then
            if client.takeDelay == nil then
                client.takeDelay = true
                timer.Create("TakeDelay." .. client:SteamID64(), lia.config.TakeDelay, 1, function() if IsValid(client) then client.takeDelay = nil end end)
                return true
            else
                client:notify("You need to wait before picking something up again!")
                return false
            end
        else
            return false
        end
    end

    if action == "equip" then
        if hook.Run("CanPlayerEquipItem", client, item) ~= false then
            if client.equipDelay == nil then
                client.equipDelay = true
                timer.Create("EquipDelay." .. client:SteamID64(), lia.config.EquipDelay, 1, function() if IsValid(client) then client.equipDelay = nil end end)
                return true
            else
                client:notify("You need to wait before equipping something again!")
                return false
            end
        else
            return false
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CanPlayerEquipItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.equipDelay ~= nil then
        client:notify("You need to wait before equipping something again!")
        return false
    elseif inventory and (inventory.isBag or inventory.isBank) then
        client:notifyLocalized("forbiddenActionStorage")
        return false
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CanPlayerTakeItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.takeDelay ~= nil then
        client:notify("You need to wait before picking something up again!")
        return false
    elseif inventory and (inventory.isBag or inventory.isBank) then
        client:notifyLocalized("forbiddenActionStorage")
        return false
    elseif IsValid(item.entity) then
        local character = client:getChar()
        if item.entity.SteamID64 == client:SteamID() and item.entity.liaCharID ~= char:getID() then
            client:notifyLocalized("playerCharBelonging")
            return false
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
