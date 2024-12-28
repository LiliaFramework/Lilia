local MODULE = MODULE
local TablePlayers = TablePlayers or {}
local tblAlwaysSend = {"player", "func_lod", "gmod_hands", "worldspawn", "player_manager", "gmod_gamerules", "bodyque", "network", "soundent", "prop_door_rotating", "phys_slideconstraint", "phys_bone_follower", "class C_BaseEntity", "func_physbox", "logic_auto", "env_tonemap_controller", "shadow_control", "env_sun", "lua_run", "func_useableladder", "info_ladder_dismount", "func_illusionary", "env_fog_controller", "prop_vehicle_jeep"}
function MODULE:PlayerInitialSpawn(client)
    self:RegisterPlayer(client)
    if SERVER then self:ServerSidePlayerInitialSpawn(client) end
end

function MODULE:EntityRemoved(entity)
    if entity:IsPlayer() then self:RemovePlayer(entity) end
end

function MODULE:GetPlayerData(client)
    return TablePlayers[client:EntIndex()]
end

function MODULE:RemovePlayer(client)
    TablePlayers[client:EntIndex()] = nil
end

function MODULE:RegisterPlayer(client)
    TablePlayers[client:EntIndex()] = {
        Player = client,
        Expanding = false,
        Expanded = false,
        EntBuffer = {},
    }

    self:PlayerUpdateTransmitStates(client)
    timer.Simple(8, function() self:BeginExpand(client) end)
end

function MODULE:PlayerUpdateTransmitStates(client, intRange)
    local entities = ents.GetAll()
    if intRange then
        for _, v in pairs(entities) do
            if table.HasValue(tblAlwaysSend, v:GetClass()) then
                v:SetPreventTransmit(client, false)
                continue
            end

            if v.UpdateTransmitState and v:UpdateTransmitState() == TRANSMIT_ALWAYS then
                v:SetPreventTransmit(client, false)
                continue
            end

            if v:GetPos():Distance(client:GetPos()) > 5500 then
                v:SetPreventTransmit(client, true)
            else
                v:SetPreventTransmit(client, false)
            end
        end
    else
        for _, v in pairs(entities) do
            if table.HasValue(tblAlwaysSend, v:GetClass()) then
                v:SetPreventTransmit(client, false)
                continue
            end

            if v.UpdateTransmitState and v:UpdateTransmitState() == TRANSMIT_ALWAYS then
                v:SetPreventTransmit(client, false)
                continue
            end

            v:SetPreventTransmit(client, true)
        end
    end
end

function MODULE:BeginExpand(client)
    local data = self:GetPlayerData(client)
    if not data then return end
    data.Expanding = true
    local timerID = "Performanceicks:" .. client:EntIndex()
    local currentRange = 0
    timer.Create(timerID, 1, 0, function()
        if not IsValid(client) then
            timer.Remove(timerID)
            return
        end

        currentRange = math.min(5500, currentRange + 512)
        self:PlayerUpdateTransmitStates(client, currentRange)
        if currentRange == 5500 then
            timer.Remove(timerID)
            data.Expanded = true
            data.Expanding = false
        end
    end)
end

function MODULE:PlayerExpandedUpdate()
    for k, data in pairs(TablePlayers) do
        if not data or not data.Expanded then continue end
        if not IsValid(data.Player) then
            TablePlayers[k] = nil
            continue
        end

        self:PlayerUpdateTransmitStates(data.Player, 5500)
    end
end

timer.Create("PlayerExpandedUpdate", 1, 0, function() MODULE:PlayerExpandedUpdate() end)