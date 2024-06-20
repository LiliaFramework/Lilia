function GM:PostPlayerLoadout(client)
    local character = client:getChar()
    if not (IsValid(client) or character) then return end
    client:Give("lia_hands")
    client:SetupHands()
end

function GM:PlayerDeath(client)
    local character = client:getChar()
    if not character then return end
    if client:hasRagdoll() then
        local ragdoll = client:getRagdoll()
        ragdoll.liaIgnoreDelete = true
        ragdoll:Remove()
        client:setLocalVar("blur", nil)
    end
end

function GM:PlayerSpawn(client)
    client:SetNoDraw(false)
    client:UnLock()
    client:SetNotSolid(false)
    client:stopAction()
    hook.Run("PlayerLoadout", client)
end

function GM:PlayerDisconnected(client)
    client:saveLiliaData()
    local character = client:getChar()
    if character then
        local charEnts = character:getVar("charEnts") or {}
        for _, v in ipairs(charEnts) do
            if v and IsValid(v) then v:Remove() end
        end

        hook.Run("OnCharDisconnect", client, character)
        character:save()
        lia.log.add(client, "playerDisconnected")
    end

    if client:hasRagdoll() then
        local ragdoll = client:getRagdoll()
        ragdoll.liaNoReset = true
        ragdoll.liaIgnoreDelete = true
        ragdoll:Remove()
    end

    lia.char.cleanUpForPlayer(client)
    for _, entity in pairs(ents.GetAll()) do
        if entity:GetCreator() == client and not string.StartsWith(entity:GetClass(), "lia_") then entity:Remove() end
    end
end

function GM:PlayerInitialSpawn(client)
    if client:IsBot() then
        self:SetupBotPlayer(client)
        return
    end

    client.liaJoinTime = RealTime()
    client:loadLiliaData(function(data)
        if not IsValid(client) then return end
        local address = client:IPAddress()
        client:setLiliaData("lastIP", address)
        netstream.Start(client, "liaDataSync", data, client.firstJoin, client.lastJoin)
        for _, v in pairs(lia.item.instances) do
            if v.entity and v.invID == 0 then v:sync(client) end
        end

        hook.Run("PlayerLiliaDataLoaded", client)
    end)

    hook.Run("PostPlayerInitialSpawn", client)
end

function GM:PlayerLoadout(client)
    local character = client:getChar()
    if client.liaSkipLoadout then
        client.liaSkipLoadout = nil
        return
    end

    if not character then
        client:SetNoDraw(true)
        client:Lock()
        client:SetNotSolid(true)
        return
    end

    client:SetWeaponColor(Vector(0.30, 0.80, 0.10))
    client:StripWeapons()
    client:setLocalVar("blur", nil)
    client:SetModel(character:getModel())
    client:SetWalkSpeed(lia.config.WalkSpeed)
    client:SetRunSpeed(lia.config.RunSpeed)
    client:SetJumpPower(160)
    hook.Run("FactionOnLoadout", client)
    hook.Run("ClassOnLoadout", client)
    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    hook.Run("FactionPostLoadout", client)
    hook.Run("ClassPostLoadout", client)
    client:SelectWeapon("lia_hands")
end

function GM:SetupBotPlayer(client)
    local botID = os.time()
    local index = math.random(1, table.Count(lia.faction.indices))
    local faction = lia.faction.indices[index]
    local inventory = lia.inventory.new("grid")
    local character = lia.char.new({
        name = client:Name(),
        faction = faction and faction.uniqueID or "unknown",
        desc = "This is a bot. BotID is " .. botID .. ".",
        model = "models/gman.mdl",
    }, botID, client, client:SteamID64())

    character.isBot = true
    character.vars.inv = {}
    inventory.id = "bot" .. character:getID()
    character.vars.inv[1] = inventory
    lia.inventory.instances[inventory.id] = inventory
    lia.char.loaded[botID] = character
    character:setup()
    client:Spawn()
end

function GM:PlayerAuthed(client)
    lia.log.add(client, "playerConnected", client)
end

function GM:PlayerHurt(client, attacker, health, damage)
    lia.log.add(client, "playerHurt", attacker:IsPlayer() and attacker:Name() or attacker:GetClass(), damage, health)
end
