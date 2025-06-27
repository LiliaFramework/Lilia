local players_data = {}
local spawn_delay = 8
local update_distance = 5500
local update_rate = 1
local update_amount = 512
local always_send = {
    player = true,
    func_lod = true,
    gmod_hands = true,
    worldspawn = true,
    player_manager = true,
    gmod_gamerules = true,
    bodyque = true,
    network = true,
    soundent = true,
    prop_door_rotating = true,
    phys_slideconstraint = true,
    phys_bone_follower = true,
    ["class C_BaseEntity"] = true,
    func_physbox = true,
    logic_auto = true,
    env_tonemap_controller = true,
    shadow_control = true,
    env_sun = true,
    lua_run = true,
    func_useableladder = true,
    info_ladder_dismount = true,
    func_illusionary = true,
    env_fog_controller = true,
    prop_vehicle_jeep = false,
}

local ToolGunSounds = {
    ["weapons/airboat/airboat_gun_lastshot1.wav"] = true,
    ["weapons/airboat/airboat_gun_lastshot2.wav"] = true
}

local function get_player_data(p)
    return players_data[p:EntIndex()]
end

local function update_transmit_states(pPlayer, range)
    local range_sqr = range and range * range
    for _, ent in ents.Iterator() do
        local cls = ent:GetClass()
        if always_send[cls] or ent.UpdateTransmitState and ent:UpdateTransmitState() == TRANSMIT_ALWAYS then
            ent:SetPreventTransmit(pPlayer, false)
        elseif range_sqr then
            ent:SetPreventTransmit(pPlayer, ent:GetPos():DistToSqr(pPlayer:GetPos()) > range_sqr)
        else
            ent:SetPreventTransmit(pPlayer, true)
        end
    end
end

local function begin_expand(pPlayer)
    local data = get_player_data(pPlayer)
    if not data then return end
    data.expanding = true
    local timer_id = "PVSExpand" .. pPlayer:EntIndex()
    local current_range = 0
    timer.Create(timer_id, update_rate, 0, function()
        if not IsValid(pPlayer) then
            timer.Remove(timer_id)
            return
        end

        current_range = math.min(update_distance, current_range + update_amount)
        update_transmit_states(pPlayer, current_range)
        if current_range == update_distance then
            timer.Remove(timer_id)
            data.expanded = true
            data.expanding = false
        end
    end)
end

local function remove_player(pPlayer)
    players_data[pPlayer:EntIndex()] = nil
end

local function expanded_update()
    for idx, data in pairs(players_data) do
        if data.expanded then
            local ply = data.player
            if IsValid(ply) then
                update_transmit_states(ply, update_distance)
            else
                players_data[idx] = nil
            end
        end
    end
end

timer.Create("PVSExpandedUpdate", 1, 0, expanded_update)
function MODULE:PlayerInitialSpawn(pPlayer)
    players_data[pPlayer:EntIndex()] = {
        player = pPlayer,
        expanded = false,
        expanding = false
    }

    update_transmit_states(pPlayer)
    timer.Simple(spawn_delay, function() if IsValid(pPlayer) then begin_expand(pPlayer) end end)
end

function MODULE:PropBreak(_, entity)
    if IsValid(entity) and IsValid(entity:GetPhysicsObject()) then constraint.RemoveAll(entity) end
end

function MODULE:EntityRemoved(ent)
    if ent:IsPlayer() then remove_player(ent) end
end

function MODULE:EntityEmitSound(tab)
    if IsValid(tab.Entity) and tab.Entity:IsPlayer() then
        local wep = tab.Entity:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "gmod_tool" and ToolGunSounds[tab.SoundName] then return false end
    end
end
