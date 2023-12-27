--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerLoadout(client)
    local character = client:getChar()
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
    client:SetModel(character:getModel())
    client:SetWalkSpeed(lia.config.WalkSpeed)
    client:SetRunSpeed(lia.config.RunSpeed)
    client:SetJumpPower(160)
    self:ClassOnLoadout(client)
    self:FactionOnLoadout(client)
    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    client:SelectWeapon("lia_hands")
end

--------------------------------------------------------------------------------------------------------------------------
function GM:FactionOnLoadout(client)
    local faction = lia.faction.indices[client:Team()]
    if not faction then return end
    if faction.scale then
        local scaleViewFix = faction.scale
        local scaleViewFixOffset = Vector(0, 0, 64)
        local scaleViewFixOffsetDuck = Vector(0, 0, 28)
        client:SetViewOffset(scaleViewFixOffset * faction.scale)
        client:SetViewOffsetDucked(scaleViewFixOffsetDuck * faction.scale)
        client:SetModelScale(scaleViewFix)
    else
        client:SetViewOffset(Vector(0, 0, 64))
        client:SetViewOffsetDucked(Vector(0, 0, 28))
        client:SetModelScale(1)
    end

    if faction.runSpeed then
        if faction.runSpeedMultiplier then
            client:SetRunSpeed(math.Round(lia.config.RunSpeed * faction.runSpeed))
        else
            client:SetRunSpeed(faction.runSpeed)
        end
    end

    if faction.walkSpeed then
        if faction.walkSpeedMultiplier then
            client:SetWalkSpeed(math.Round(lia.config.WalkSpeed * faction.walkSpeed))
        else
            client:SetWalkSpeed(faction.walkSpeed)
        end
    end

    if faction.jumpPower then
        if faction.jumpPowerMultiplier then
            client:SetJumpPower(math.Round(160 * faction.jumpPower))
        else
            client:SetJumpPower(faction.jumpPower)
        end
    end

    if faction.bloodcolor then
        client:SetBloodColor(faction.bloodcolor)
    else
        client:SetBloodColor(BLOOD_COLOR_RED)
    end

    if faction.health then
        client:SetMaxHealth(faction.health)
        client:SetHealth(faction.health)
    end

    if faction.armor then client:SetArmor(faction.armor) end
    if faction.weapons then
        for _, v in ipairs(faction.weapons) do
            client:Give(v)
        end
    end

    if faction.onSpawn then faction:onSpawn(client) end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:ClassOnLoadout(client)
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    if not class then return end
    if class.None then return end
    if class.scale then
        local scaleViewFix = class.scale
        local scaleViewFixOffset = Vector(0, 0, 64)
        local scaleViewFixOffsetDuck = Vector(0, 0, 28)
        client:SetViewOffset(scaleViewFixOffset * class.scale)
        client:SetViewOffsetDucked(scaleViewFixOffsetDuck * class.scale)
        client:SetModelScale(scaleViewFix)
    else
        client:SetViewOffset(Vector(0, 0, 64))
        client:SetViewOffsetDucked(Vector(0, 0, 28))
        client:SetModelScale(1)
    end

    if class.runSpeed then
        if class.runSpeedMultiplier then
            client:SetRunSpeed(math.Round(lia.config.RunSpeed * class.runSpeed))
        else
            client:SetRunSpeed(class.runSpeed)
        end
    end

    if class.walkSpeed then
        if class.walkSpeedMultiplier then
            client:SetWalkSpeed(math.Round(lia.config.WalkSpeed * class.walkSpeed))
        else
            client:SetWalkSpeed(class.walkSpeed)
        end
    end

    if class.jumpPower then
        if class.jumpPowerMultiplier then
            client:SetJumpPower(math.Round(160 * class.jumpPower))
        else
            client:SetJumpPower(class.jumpPower)
        end
    end

    if class.bloodcolor then
        client:SetBloodColor(class.bloodcolor)
    else
        client:SetBloodColor(BLOOD_COLOR_RED)
    end

    if class.health then
        client:SetMaxHealth(class.health)
        client:SetHealth(class.health)
    end

    if class.armor then client:SetArmor(class.armor) end
    if class.onSpawn then class:onSpawn(client) end
    if class.weapons then
        for _, v in ipairs(class.weapons) do
            client:Give(v)
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnServer(client)
    if pac then client:ConCommand("pac_restart") end
    client:SetNoDraw(false)
    client:UnLock()
    client:SetNotSolid(false)
    client:setAction()
    hook.Run("PlayerLoadout", client)
end

--------------------------------------------------------------------------------------------------------------------------
function GM:OnCharAttribBoosted(client, character, attribID)
    local attribute = lia.attribs.list[attribID]
    if attribute and isfunction(attribute.onSetup) then attribute:onSetup(client, character:getAttrib(attribID, 0)) end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PostPlayerLoadout(client)
    local character = client:getChar()
    client:Give("lia_hands")
    client:SetupHands()
    lia.attribs.setup(client)
    if character:getInv() then
        for _, item in pairs(character:getInv():getItems()) do
            item:call("onLoadout", client)
            if item:getData("equip") and istable(item.attribBoosts) then
                for attribute, boost in pairs(item.attribBoosts) do
                    character:addBoost(item.uniqueID, attribute, boost)
                end
            end
        end
    end

    client:setNetVar("VoiceType", "Talking")
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerDeath(client, inflictor, attacker)
    local char = client:getChar()
    if not char then return end
    netstream.Start(client, "removeF1")
    if IsValid(client.liaRagdoll) then
        client.liaRagdoll.liaIgnoreDelete = true
        client.liaRagdoll:Remove()
        client:setLocalVar("blur", nil)
    end

    char:setData("deathPos", client:GetPos())
    client:setNetVar("deathStartTime", CurTime())
    client:setNetVar("deathTime", CurTime() + 5)
    if lia.config.DeathPopupEnabled then
        net.Start("death_client")
        net.WriteString(attacker:Nick())
        net.WriteFloat(attacker:getChar():getID())
        net.Send(client)
    end

    if (attacker:IsPlayer() and lia.config.LoseWeapononDeathHuman) or (not attacker:IsPlayer() and lia.config.LoseWeapononDeathNPC) or (lia.config.LoseWeapononDeathWorld and attacker:IsWorld()) then self:RemoveAllEquippedWeapons(client) end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:RemoveAllEquippedWeapons(client)
    local char = client:getChar()
    local inventory = char:getInv()
    local items = inventory:getItems()
    client.carryWeapons = {}
    client.LostItems = {}
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

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerDeathThink(client)
    if client:getChar() then
        local deathTime = client:getNetVar("deathTime")
        if deathTime and deathTime <= CurTime() then client:Spawn() end
    end
    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerInitialSpawn(client)
    client.liaJoinTime = RealTime()
    client:loadLiliaData(
        function(data)
            if not IsValid(client) then return end
            local address = client:IPAddress()
            client:setLiliaData("lastIP", address)
            netstream.Start(client, "liaDataSync", data, client.firstJoin, client.lastJoin)
            for _, v in pairs(lia.item.instances) do
                if v.entity and v.invID == 0 then v:sync(client) end
            end

            hook.Run("PlayerLiliaDataLoaded", client)
        end
    )

    if client:IsBot() then return hook.Run("SetupBotCharacter", client) end
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
        local newRank = lia.config.DefaultStaff[client:SteamID()]
        if sam then
            RunConsoleCommand("sam", "setrank", client:SteamID(), newRank)
            client:ChatPrint("You have been set as rank: " .. newRank)
            print(client:Nick() .. " has been set as rank: " .. newRank)
        else
            client:SetUserGroup(newRank)
            client:ChatPrint("You have been set as rank: " .. newRank)
            print(client:Nick() .. " has been set as rank: " .. newRank)
        end
    end

    hook.Run("PostPlayerInitialSpawn", client)
    hook.Run("ReRunNames")
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PostPlayerInitialSpawn(client)
    client:SetNoDraw(true)
    client:SetNotSolid(true)
    client:Lock()
    timer.Simple(
        1,
        function()
            if not IsValid(client) then return end
            client:KillSilent()
            client:StripAmmo()
        end
    )
end
--------------------------------------------------------------------------------------------------------------------------
