local MODULE = MODULE
local function InitializeStaminaTimer()
    local staminaTimer = function()
        for _, client in player.Iterator() do
            if IsValid(client) then
                local char = client:getChar()
                if char and client:GetMoveType() ~= MOVETYPE_NOCLIP then MODULE:CalcStaminaChange(client) end
            end
        end
    end

    if timer.Exists("liaStaminaGlobal") then
        timer.Adjust("liaStaminaGlobal", 0.25, 0, staminaTimer)
    else
        timer.Create("liaStaminaGlobal", 0.25, 0, staminaTimer)
    end
end

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

    local maxStamina = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    client:setLocalVar("stamina", maxStamina)
end

function MODULE:PlayerStaminaLost(client)
    if client:getLocalVar("brth", false) then return end
    client:setLocalVar("brth", true)
    client:StopSound("player/breathe1.wav")
    client:EmitSound("player/breathe1.wav", 35, 100)
    local character = client:getChar()
    local maxStamina = character and (hook.Run("GetCharMaxStamina", character) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100)
    local breathThreshold = maxStamina * 0.25
    local timerName = "liaStamBreathCheck" .. client:SteamID64()
    if timer.Exists(timerName) then timer.Remove(timerName) end
    timer.Create(timerName, 0.5, 0, function()
        if not IsValid(client) then
            timer.Remove(timerName)
            return
        end

        local char = client:getChar()
        local currentMaxStamina = char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100)
        local currentStamina = client:getLocalVar("stamina", currentMaxStamina)
        if currentStamina > breathThreshold then
            client:StopSound("player/breathe1.wav")
            client:setLocalVar("brth", nil)
            timer.Remove(timerName)
        end
    end)
end

function MODULE:PlayerLoadedChar(client, character)
    InitializeStaminaTimer()
    timer.Simple(0.25, function()
        if IsValid(client) then
            local maxStamina = hook.Run("GetCharMaxStamina", character) or lia.config.get("DefaultStamina", 100)
            client:setLocalVar("stamina", character:getData("stamina", maxStamina))
        end
    end)
end

function MODULE:PlayerThrowPunch(client)
    local staminaUse = lia.config.get("PunchStamina", 10)
    if staminaUse > 0 then
        local max = hook.Run("GetCharMaxStamina", client:getChar()) or lia.config.get("DefaultStamina", 100)
        local current = client:getLocalVar("stamina", max)
        local value = math.Clamp(current - staminaUse, 0, max)
        client:setLocalVar("stamina", value)
    end
end

InitializeStaminaTimer()
