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

    client:setNetVar("stamina", hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100))
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
    timer.Simple(0.25, function() if IsValid(client) then client:setNetVar("stamina", hook.Run("GetCharMaxStamina", character) or lia.config.get("DefaultStamina", 100)) end end)
end

timer.Remove("liaGlobalStamina")
timer.Create("liaGlobalStamina", 0.25, 0, function()
    for _, client in player.Iterator() do
        if IsValid(client) then MODULE:CalcStaminaChange(client) end
    end
end)

hook.Add("PlayerBindPress", "liaAttributesPlayerBindPress", function(client, bind, pressed) return MODULE:PlayerBindPress(client, bind, pressed) end)
