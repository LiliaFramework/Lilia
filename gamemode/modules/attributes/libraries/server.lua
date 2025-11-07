local MODULE = MODULE
local staminaPlayers = {}
function MODULE:PostPlayerLoadout(client)
    local char = client:getChar()
    if not char then return end
    lia.attribs.setup(client)
    local inv = char:getInv()
    if inv then
        for _, v in pairs(inv:getItems()) do
            v:call("onLoadout", client)
            if v:getData("equip") and istable(v.attribBoosts) then
                for k, b in pairs(v.attribBoosts) do
                    char:addBoost(v.uniqueID, k, b)
                end
            end
        end
    end

    client:setNetVar("stamina", hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100))
    staminaPlayers[client] = true
end

function MODULE:PlayerDisconnected(client)
    staminaPlayers[client] = nil
end

function MODULE:KeyPress(client, key)
    local char = client:getChar()
    if not char then return end
    if key == IN_ATTACK2 then
        local wep = client:GetActiveWeapon()
        if IsValid(wep) and wep.IsHands and wep.ReadyToPickup then
            wep:Pickup()
        elseif IsValid(client.Grabbed) then
            client:DropObject(client.Grabbed)
            client.Grabbed = NULL
        end
    end

    if key == IN_JUMP and not client:InVehicle() and client:Alive() and client:OnGround() and (client.liaNextJump or 0) <= CurTime() then
        client.liaNextJump = CurTime() + 0.1
        if client:GetMoveType() ~= MOVETYPE_NOCLIP then
            local cost = lia.config.get("JumpStaminaCost", 25)
            local maxStamina = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
            client:consumeStamina(cost)
            local newStamina = client:getNetVar("stamina", maxStamina)
            if newStamina <= 0 then
                client:setNetVar("brth", true)
                client:ConCommand("-speed")
            end
        end
    end
end

function MODULE:PlayerLoadedChar(client, character)
    timer.Simple(0.25, function() if IsValid(client) then client:setNetVar("stamina", hook.Run("GetCharMaxStamina", character) or lia.config.get("DefaultStamina", 100)) end end)
end

function MODULE:PlayerStaminaLost(client)
    if client:getNetVar("brth", false) then return end
    client:setNetVar("brth", true)
    client:EmitSound("player/breathe1.wav", 35, 100)
    local character = client:getChar()
    local maxStamina = character and (hook.Run("GetCharMaxStamina", character) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100)
    local breathThreshold = maxStamina * 0.25
    timer.Create("liaStamBreathCheck" .. client:SteamID64(), 1, 0, function()
        if not IsValid(client) then
            timer.Remove("liaStamBreathCheck" .. client:SteamID64())
            return
        end

        local char = client:getChar()
        local currentStamina = client:getNetVar("stamina", char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100))
        if currentStamina <= breathThreshold then
            client:EmitSound("player/breathe1.wav", 35, 100)
            return
        end

        client:StopSound("player/breathe1.wav")
        client:setNetVar("brth", nil)
        timer.Remove("liaStamBreathCheck" .. client:SteamID64())
    end)
end

if SERVER and not timer.Exists("liaGlobalStamina") then
    timer.Create("liaGlobalStamina", 0.25, 0, function()
        for client, _ in pairs(staminaPlayers) do
            if IsValid(client) then
                MODULE:CalcStaminaChange(client)
            else
                staminaPlayers[client] = nil
            end
        end
    end)
end
