local GM = GM or GAMEMODE
if SERVER then
    function GM:CanItemBeTransfered(item, curInv, inventory)
        if item.isBag and curInv ~= inventory and item.getInv and item:getInv() and table.Count(item:getInv():getItems()) > 0 then
            local character = lia.char.loaded[curInv.client]
            if SERVER and character and character:getPlayer() then
                character:getPlayer():notify("You can't transfer a backpack that has items inside of it.")
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

    function GM:CanPlayerInteractItem(client, action, item)
        local SteamIDWhitelist = item.ItemInteractSteamIDWhitelist
        local FactionWhitelist = item.ItemInteractFactionWhitelist
        local UserGroupWhitelist = item.ItemInteractUsergroupWhitelist
        local VIPOnly = item.ItemInteractVIP
        if not client:Alive() then return false, "You can't use items while dead" end
        if client:getLocalVar("ragdoll", false) then return false, "You can't use items while ragdolled." end
        if SteamIDWhitelist then
            local isWhitelisted = istable(SteamIDWhitelist) and table.HasValue(SteamIDWhitelist, client:SteamID()) or isstring(SteamIDWhitelist) and client:SteamID() == SteamIDWhitelist
            if not isWhitelisted then return false, "You are not whitelisted to use this item!" end
        elseif FactionWhitelist then
            local isWhitelisted = istable(FactionWhitelist) and table.HasValue(FactionWhitelist, client:Team()) or isstring(FactionWhitelist) and client:Team() == FactionWhitelist
            if not isWhitelisted then return false, "Your faction is not whitelisted to use this item!" end
        elseif UserGroupWhitelist then
            local isWhitelisted = istable(UserGroupWhitelist) and table.HasValue(UserGroupWhitelist, client:GetUserGroup()) or isstring(UserGroupWhitelist) and client:GetUserGroup() == UserGroupWhitelist
            if not isWhitelisted then return false, "Your usergroup is not whitelisted to use this item!" end
        elseif VIPOnly and not client:isVIP() then
            return false, "This item is meant for VIPs!"
        end

        if action == "drop" then
            if hook.Run("CanPlayerDropItem", client, item) ~= false then
                if not client.dropDelay then
                    client.dropDelay = true
                    timer.Create("DropDelay." .. client:SteamID64(), lia.config.DropDelay, 1, function() if IsValid(client) then client.dropDelay = nil end end)
                    lia.chat.send(client, "iteminternal", Format("drops their %s.", item.name), false)
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
                if not client.takeDelay then
                    client.takeDelay = true
                    timer.Create("TakeDelay." .. client:SteamID64(), lia.config.TakeDelay, 1, function() if IsValid(client) then client.takeDelay = nil end end)
                    lia.chat.send(client, "iteminternal", Format("picks up the %s.", item.name), false)
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
                if not client.equipDelay then
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

        if action == "unequip" then
            if hook.Run("CanPlayerUnequipItem", client, item) ~= false then
                if not client.unequipDelay then
                    client.unequipDelay = true
                    timer.Create("UnequipDelay." .. client:SteamID64(), lia.config.UnequipDelay, 1, function() if IsValid(client) then client.unequipDelay = nil end end)
                    return true
                else
                    client:notify("You need to wait before unequipping something again!")
                    return false
                end
            else
                return false
            end
        end
    end

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
            if item.entity.SteamID64 == client:SteamID() and item.entity.liaCharID ~= character:getID() then
                client:notifyLocalized("playerCharBelonging")
                return false
            end
        end
    end

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
else
    function GM:ItemShowEntityMenu(entity)
        for k, v in ipairs(lia.menu.list) do
            if v.entity == entity then table.remove(lia.menu.list, k) end
        end

        local options = {}
        local itemTable = entity:getItemTable()
        if not itemTable then return end
        local function callback(index)
            if IsValid(entity) then netstream.Start("invAct", index, entity) end
        end

        itemTable.player = LocalPlayer()
        itemTable.entity = entity
        if input.IsShiftDown() then callback("take") end
        for k, v in SortedPairs(itemTable.functions) do
            if k == "combine" then continue end
            if (hook.Run("onCanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun)) and (not v.onCanRun(itemTable)) then continue end
            options[L(v.name or k)] = function()
                local send = true
                if v.onClick then send = v.onClick(itemTable) end
                if v.sound then surface.PlaySound(v.sound) end
                if send ~= false then callback(k) end
            end
        end

        if table.Count(options) > 0 then entity.liaMenuIndex = lia.menu.add(options, entity) end
        itemTable.player = nil
        itemTable.entity = nil
    end
end