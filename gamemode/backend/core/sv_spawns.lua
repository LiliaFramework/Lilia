--------------------------------------------------------------------------------------------------------
function GM:PlayerLoadout(client)
    if client.liaSkipLoadout then
        client.liaSkipLoadout = nil

        return
    end

    if not client:getChar() then
        client:SetNoDraw(true)
        client:Lock()
        client:SetNotSolid(true)

        return
    end

    client:SetWeaponColor(Vector(client:GetInfo("cl_weaponcolor")))
    client:StripWeapons()
    client:setLocalVar("blur", nil)
    local character = client:getChar()
    client:SetupHands()
    client:SetModel(character:getModel())
    if client:getChar():hasFlags("p") then
        client:Give("weapon_physgun")
    end

    if client:getChar():hasFlags("t") then
        client:Give("gmod_tool")
    end

    client:Give("lia_hands")
    client:SetWalkSpeed(lia.config.WalkSpeed)
    client:SetRunSpeed(lia.config.RunSpeed)
    local faction = lia.faction.indices[client:Team()]
    if faction then
        if faction.onSpawn then
            faction:onSpawn(client)
        end

        if faction.weapons then
            for _, v in ipairs(faction.weapons) do
                client:Give(v)
            end
        end
    end

    local class = lia.class.list[client:getChar():getClass()]
    if class then
        if class.onSpawn then
            class:onSpawn(client)
        end

        if class.weapons then
            for _, v in ipairs(class.weapons) do
                client:Give(v)
            end
        end
    end

    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    client:SelectWeapon("lia_hands")
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawn(client)
    if pac then
        client:ConCommand("pac_restart")
    end

    client:setNetVar("VoiceType", "Talking")
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
    if char then
        netstream.Start(client, "removeF1")
        if IsValid(client.liaRagdoll) then
            client.liaRagdoll.liaIgnoreDelete = true
            client.liaRagdoll:Remove()
            client:setLocalVar("blur", nil)
        end

        char:setData("deathPos", client:GetPos())
        client:setNetVar("deathStartTime", CurTime())
        client:setNetVar("deathTime", CurTime() + 5)
        local inventory = char:getInv()
        local items = inventory:getItems()
        client.carryWeapons = {}
        client.LostItems = {}
        if inventory and lia.config.KeepAmmoOnDeath then
            for _, v in pairs(items) do
                if (v.isWeapon or v.isCW) and v:getData("equip") then
                    v:setData("ammo", nil)
                end
            end
        end

        if client ~= attacker and not attacker:IsWorld() then
            if attacker:IsPlayer() then
                if lia.config.DeathPopupEnabled then
                    net.Start("death_client")
                    net.WriteString(attacker:Nick())
                    net.WriteFloat(attacker:getChar():getID())
                    net.Send(client)
                end

                if lia.config.LoseWeapononDeathHuman then
                    for _, v in pairs(items) do
                        if (v.isWeapon or v.isCW) and v:getData("equip") then
                            table.insert(client.LostItems, v.uniqueID)
                            v:remove()
                        end
                    end

                    if #client.LostItems > 0 then
                        local amount = #client.LostItems > 1 and #client.LostItems .. " items" or "an item"
                        client:notify("Because you died, you have lost " .. amount .. ".")
                    end
                end
            elseif not attacker:IsPlayer() and lia.config.LoseWeapononDeathNPC then
                for _, v in pairs(items) do
                    if (v.isWeapon or v.isCW) and v:getData("equip") then
                        table.insert(client.LostItems, v.uniqueID)
                        v:remove()
                    end
                end

                if #client.LostItems > 0 then
                    local amount = #client.LostItems > 1 and #client.LostItems .. " items" or "an item"
                    client:notify("Because you died, you have lost " .. amount .. ".")
                end
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
    if client:IsBot() then return hook.Run("SetupBotCharacter", client) end
    client.liaJoinTime = RealTime()
    client:loadLiliaData(
        function(data)
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
        end
    )

    client:SetCanZoom(false)
    local annoying = ents.FindByName("music")
    local val = ents.GetMapCreatedEntity(1733)
    if #annoying > 0 then
        annoying[1]:SetKeyValue("RefireTime", 99999999)
        annoying[1]:Fire("Disable")
        annoying[1]:Fire("Kill")
        val:SetKeyValue("RefireTime", 99999999)
        val:Fire("Disable")
        val:Fire("Kill")
    end

    self:RegisterPlayer(client)
    if lia.config.DefaultStaff[client:SteamID()] then
        if sam then
            RunConsoleCommand("sam", "setrank", target:SteamID(), lia.config.DefaultStaff[client:SteamID()])
        else
            client:SetUserGroup(lia.config.DefaultStaff[client:SteamID()])
        end
    end

    hook.Run("PostPlayerInitialSpawn", client)
    hook.Run("ReRunNames")
end
--------------------------------------------------------------------------------------------------------