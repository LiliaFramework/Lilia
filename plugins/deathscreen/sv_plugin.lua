util.AddNetworkString("death_client")

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerDeath(victim, inflictor, attacker)
    netstream.Start(ply, "removeF1")
    if victim == attacker then return end

    if attacker:IsPlayer() then
        if lia.config.get("DeathInformation", true) then
            net.Start("death_client")
            net.WriteString(attacker:Nick())
            net.WriteFloat(attacker:getChar():getID())
            net.Send(victim)
        end

        if lia.config.get("LoseWeapononDeath", true) then
            victim.LostItems = {}
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
end

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("returnitems", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        local target = lia.command.findPlayer(client, arguments[1])

        if lia.config.get("LoseWeapononDeath", true) then
            if not UserGroups.modRanks[uniqueID] then
                client:notify("Your rank is not high enough to use this command.")

                return false
            end

            if IsValid(target) then
                if not target.LostItems then
                    client:notify("The target hasn't died recently or they had their items returned already!")

                    return
                end

                if table.IsEmpty(target.LostItems) then
                    client:notify("Cannot return any items; the player hasn't lost any!")

                    return
                end

                local char = target:getChar()
                if not char then return end
                local inv = char:getInv()
                if not inv then return end

                for k, v in pairs(target.LostItems) do
                    inv:add(v)
                end

                target.LostItems = nil
                target:notify("Your items have been returned.")
                client:notify("Returned the items.")
            end
        else
            client:notify("Weapon on Death not Enabled!")
        end
    end
})