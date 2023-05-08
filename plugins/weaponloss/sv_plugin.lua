util.AddNetworkString("death_client")

-------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerDeath(victim, inflictor, attacker)
    if victim == attacker then return end
    if attacker:IsWorld() then return end
    if not attacker:IsPlayer() then return end
    victim.LostItems = {}

    if lia.config.get("DeathPopupEnabled", true) then
        net.Start("death_client")
        net.WriteString(attacker:Nick())
        net.WriteFloat(attacker:getChar():getID())
        net.Send(victim)
    end

    if lia.config.get("WeaponLossOnDeath", false) then
        local items = victim:getChar():getInv():getItems()

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
end
-------------------------------------------------------------------------------------------------------------------------