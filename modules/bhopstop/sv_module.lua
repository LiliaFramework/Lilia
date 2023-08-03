function MODULE:KeyPress(client, key)
    if lia.config.AntiBunnyHopEnabled then
        if key == IN_JUMP and client:IsOnGround() and not client:InVehicle() then
            local current = client:getLocalVar("stm", 0)
            local value = math.Clamp(current - lia.config.BHOPStamina, 0, 100)
            client:setLocalVar("stm", value)
        end
    end
end