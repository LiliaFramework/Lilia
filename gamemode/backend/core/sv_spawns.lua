--------------------------------------------------------------------------------------------------------
function GM:PlayerLoadout(client)
    if not client:getChar() then return end

    if client:getChar():hasFlags("P") then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    end

    if client:getChar():hasFlags("t") then
        client:Give("gmod_tool")
        client:SelectWeapon("gmod_tool")
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawn(client)
    local character = client:getChar()

    if lia.config.PKActive and character and character:getData("permakilled") then
        character:ban()
    end

    client:SetNoDraw(false)
    client:UnLock()
    client:SetNotSolid(false)
    client:setAction()
    hook.Run("PlayerLoadout", client)
end

--------------------------------------------------------------------------------------------------------
function GM:OnCharAttribBoosted(client, character, attribID)
    local attribute = lia.attribs.list[attribID]

    if attribute and isfunction(attribute.onSetup) then
        attribute:onSetup(client, character:getAttrib(attribID, 0))
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PostPlayerLoadout(client)
    local char = client:getChar()
    lia.attribs.setup(client)

    if char:getInv() then
        for _, item in pairs(char:getInv():getItems()) do
            item:call("onLoadout", client)

            if item:getData("equip") and istable(item.attribBoosts) then
                for attribute, boost in pairs(item.attribBoosts) do
                    char:addBoost(item.uniqueID, attribute, boost)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerDeath(client, inflictor, attacker)
    local char = client:getChar()
    local inventory = char and char:getInv()
    local items = inventory:getInv():getItems()
    netstream.Start(client, "removeF1")

    if char then
        if IsValid(client.liaRagdoll) then
            client.liaRagdoll.liaIgnoreDelete = true
            client.liaRagdoll:Remove()
            client:setLocalVar("blur", nil)
        end

        if lia.config.PKActive then
            if not (lia.config.PKWorld and (client == attacker or inflictor:IsWorld())) then return end
            character:setData("permakilled", true)
        end

        char:setData("deathPos", client:GetPos())
        client:setNetVar("deathStartTime", CurTime())
        client:setNetVar("deathTime", CurTime() + 5)
        victim.carryWeapons = {}
        victim.LostItems = {}

        if inventory and lia.config.KeepAmmoOnDeath then
            for k, v in pairs(inventory:getItems()) do
                if v.isWeapon and v:getData("equip") then
                    v:setData("ammo", nil)
                end
            end
        end

        if victim ~= attacker and not attacker:IsWorld() then
            if attacker:IsPlayer() then
                if lia.config.DeathPopupEnabled then
                    net.Start("death_client")
                    net.WriteString(attacker:Nick())
                    net.WriteFloat(attacker:getChar():getID())
                    net.Send(victim)
                end

                if lia.config.LoseWeapononDeathHuman then
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
                if lia.config.LoseWeapononDeathNPC then
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
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerDeathThink(client)
    if client:getChar() then
        local deathTime = client:getNetVar("deathTime")

        if deathTime and deathTime <= CurTime() then
            client:Spawn()
        end
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerInitialSpawn(client)
    client.liaJoinTime = RealTime()
    if client:IsBot() then return hook.Run("SetupBotCharacter", client) end

    client:loadLiliaData(function(data)
        if not IsValid(client) then return end
        local address = client:IPAddress()
        client:setLiliaData("lastIP", address)
        netstream.Start(client, "liaDataSync", data, client.firstJoin, client.lastJoin)

        for _, v in pairs(lia.item.instances) do
            if v.entity and v.invID == 0 then
                v:sync(client)
            end
        end

        hook.Run("PlayerLiliaDataLoaded", client)
    end)

    local annoying = ents.FindByName("music")
    local val = ents.GetMapCreatedEntity(1733)

    if lia.config.MusicKiller and #annoying > 0 then
        annoying[1]:SetKeyValue("RefireTime", 99999999)
        annoying[1]:Fire("Disable")
        annoying[1]:Fire("Kill")
        val:SetKeyValue("RefireTime", 99999999)
        val:Fire("Disable")
        val:Fire("Kill")
    end

    self:RegisterPlayer(client)
    hook.Run("PostPlayerInitialSpawn", client)
end
--------------------------------------------------------------------------------------------------------