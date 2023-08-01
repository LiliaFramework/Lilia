util.AddNetworkString("death_client")

------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerDeath(victim, inflictor, attacker)
    local char = victim:getChar()
    local inventory = char and victim:getChar():getInv()
    local items = inventory:getInv():getItems()
    victim.carryWeapons = {}
    victim.LostItems = {}
    netstream.Start(victim, "removeF1")

    if inventory and CONFIG.KeepAmmoOnDeath then
        for k, v in pairs(inventory:getItems()) do
            if v.isWeapon and v:getData("equip") then
                v:setData("ammo", nil)
            end
        end
    end

    if victim == attacker then return end

    if attacker:IsPlayer() then
        if CONFIG.DeathPopupEnabled then
            net.Start("death_client")
            net.WriteString(attacker:Nick())
            net.WriteFloat(attacker:getChar():getID())
            net.Send(victim)
        end

        if CONFIG.LoseWeapononDeathHuman then
            for k, v in pairs(items) do
                if (v.isWeapon or v.isCW) and v:getData("equip") then
                    table.insert(victim.LostItems, v.uniqueID)
                    v:remove()
                end
            end

            if #victim.LostItems > 0 then
                local amount = #victim.LostItems > 1 and #victim.LostItems .. " items" or "an item"
                victim:notify("Because you died, you have lost " .. amount .. ".")
            end
        end

        return
    elseif not attacker:IsPlayer() then
        if CONFIG.LoseWeapononDeathNPC then
            for k, v in pairs(items) do
                if (v.isWeapon or v.isCW) and v:getData("equip") then
                    table.insert(victim.LostItems, v.uniqueID)
                    v:remove()
                end
            end

            if #victim.LostItems > 0 then
                local amount = #victim.LostItems > 1 and #victim.LostItems .. " items" or "an item"
                victim:notify("Because you died, you have lost " .. amount .. ".")
            end
        end

        return
    end
end