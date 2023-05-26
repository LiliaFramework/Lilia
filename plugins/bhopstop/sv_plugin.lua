function PLUGIN:KeyPress(client, key)
    if lia.config.get("AntiBunnyHopEnabled", true) then
        if key == IN_JUMP and client:IsOnGround() and not client:InVehicle() then
            local current = client:getLocalVar("stm", 0)
            local value = math.Clamp(current - lia.config.get("BHOPStm"), 0, 100)
            client:setLocalVar("stm", value)
        end
    end
end