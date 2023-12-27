--------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PostPlayerLoadout(client)
    local uniqueID = "StamCheck" .. client:SteamID()
    timer.Create(
        uniqueID,
        0.25,
        0,
        function()
            if not IsValid(client) then
                timer.Remove(uniqueID)
                return
            end

            self:CalcStaminaChange(client)
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerLoadedChar(client, character)
    local maxstm = character:GetMaxStamina()
    timer.Simple(0.25, function() client:setLocalVar("stamina", maxstm) end)
end

--------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerStaminaLost(client)
    if client.isBreathing then return end
    client:EmitSound("player/breathe1.wav", 35, 100)
    client.isBreathing = true
    timer.Create(
        "liaStamBreathCheck" .. client:SteamID(),
        1,
        0,
        function()
            if client:getLocalVar("stamina", 0) < 50 then return end
            client:StopSound("player/breathe1.wav")
            client.isBreathing = nil
            timer.Remove("liaStamBreathCheck" .. client:SteamID())
        end
    )
end
--------------------------------------------------------------------------------------------------------------------------------------------
