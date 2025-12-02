local MODULE = MODULE
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
    client:setLocalVar("stm", maxStamina)
    client:setNetVar("stamina", maxStamina)
    local uniqueID = "liaStam" .. client:SteamID64()
    timer.Create(uniqueID, 0.25, 0, function()
        if not IsValid(client) then
            timer.Remove(uniqueID)
            return
        end

        self:CalcStaminaChange(client)
    end)
end

function MODULE:PlayerStaminaLost(client)
    if client:getNetVar("brth", false) then return end
    client:setNetVar("brth", true)
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
        local currentStamina = client:getNetVar("stamina", char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100))
        if currentStamina > breathThreshold then
            client:StopSound("player/breathe1.wav")
            client:setNetVar("brth", nil)
            timer.Remove(timerName)
        end
    end)
end

function MODULE:PlayerLoadedChar(client, character)
    timer.Simple(0.25, function()
        if IsValid(client) then
            local maxStamina = hook.Run("GetCharMaxStamina", character) or lia.config.get("DefaultStamina", 100)
            client:setLocalVar("stm", character:getData("stamina", maxStamina))
            client:setNetVar("stamina", client:getLocalVar("stm", maxStamina))
        end
    end)
end

function MODULE:CharacterPreSave(character)
    local client = character:GetPlayer()
    if IsValid(client) then character:SetData("stamina", client:getLocalVar("stm", hook.Run("GetCharMaxStamina", character) or lia.config.get("DefaultStamina", 100))) end
end

function MODULE:PlayerThrowPunch(client)
    local staminaUse = lia.config.get("PunchStamina", 10)
    if staminaUse > 0 then
        local current = client:getLocalVar("stm", 100)
        local max = hook.Run("GetCharMaxStamina", client:getChar()) or lia.config.get("DefaultStamina", 100)
        local value = math.Clamp(current - staminaUse, 0, max)
        client:setLocalVar("stm", value)
        client:setNetVar("stamina", value)
        net.Start("liaStaminaSync")
        net.WriteFloat(value)
        net.Send(client)
    end
end
