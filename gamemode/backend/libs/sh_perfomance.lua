local GM = GM
lia.config.tblPlayers = lia.config.tblPlayers or {}

function GM:GetPlayerData(pPlayer)
    return lia.config.tblPlayers[pPlayer:EntIndex()]
end

function GM:RegisterPlayer(pPlayer)
    lia.config.tblPlayers[pPlayer:EntIndex()] = {
        Player = pPlayer,
        Expanding = false,
        Expanded = false,
        EntBuffer = {},
    }

    self:PlayerUpdateTransmitStates(pPlayer)

    timer.Simple(lia.config.intSpawnDelay, function()
        self:BeginExpand(pPlayer)
    end)
end

function GM:RemovePlayer(pPlayer)
    lia.config.tblPlayers[pPlayer:EntIndex()] = nil
end

function GM:PlayerUpdateTransmitStates(pPlayer, intRange)
    if intRange then
        for _, v in pairs(ents.GetAll()) do
            if lia.config.tblAlwaysSend[v:GetClass()] then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            if v.UpdateTransmitState and v:UpdateTransmitState() == TRANSMIT_ALWAYS then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            if v:GetPos():Distance(pPlayer:GetPos()) > lia.config.intUpdateDistance then
                v:SetPreventTransmit(pPlayer, true)
            else
                v:SetPreventTransmit(pPlayer, false)
            end
        end
    else
        for _, v in pairs(ents.GetAll()) do
            if lia.config.tblAlwaysSend[v:GetClass()] then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            if v.UpdateTransmitState and v:UpdateTransmitState() == TRANSMIT_ALWAYS then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            v:SetPreventTransmit(pPlayer, true)
        end
    end
end

function GM:BeginExpand(pPlayer)
    local data = self:GetPlayerData(pPlayer)
    if not data then return end
    data.Expanding = true
    local timerID = "PVS:" .. pPlayer:EntIndex()
    local currentRange = 0

    timer.Create(timerID, lia.config.intUpdateRate, 0, function()
        if not IsValid(pPlayer) then
            timer.Destroy(timerID)

            return
        end

        currentRange = math.min(lia.config.intUpdateDistance, currentRange + lia.config.intUpdateAmount)
        self:PlayerUpdateTransmitStates(pPlayer, currentRange)

        if currentRange == lia.config.intUpdateDistance then
            timer.Destroy(timerID)
            data.Expanded = true
            data.Expanding = false
        end
    end)
end

function GM:PlayerExpandedUpdate()
    for k, data in pairs(lia.config.tblPlayers) do
        if not data or not data.Expanded then continue end

        if not IsValid(data.Player) then
            lia.config.tblPlayers[k] = nil
            continue
        end

        self:PlayerUpdateTransmitStates(data.Player, lia.config.intUpdateDistance)
    end
end

function GM:EntityRemoved(ent)
    if not ent:IsPlayer() then return end
    self:RemovePlayer(ent)
end

do
    local perfomancekillers = {
        ["class C_PhysPropClientside"] = true,
        ["class C_ClientRagdoll"] = true
    }

    timer.Create("CleanupGarbage", 60, 0, function()
        for _, v in ipairs(ents.GetAll()) do
            if perfomancekillers[v:GetClass()] then
                SafeRemoveEntity(v)
                RunConsoleCommand("r_cleardecals")
            end
        end
    end)

    timer.Create("GM:PlayerExpandedUpdate", 1, 0, function()
        GM:PlayerExpandedUpdate()
    end)
end

function widgets.PlayerTick()
end

hook.Remove("PlayerTick", "TickWidgets")