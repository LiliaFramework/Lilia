function PLUGIN:KeyPress(client, key)
    if lia.config.get("AntiBunnyHopEnabled", true) then
        local jump_power = client:GetJumpPower()
        local current = client:getLocalVar("stm", 0)
        local value = math.Clamp(current - nut.config.get("bunnyHop"), 0, 100)

        if (key == IN_JUMP) and client:IsOnGround() then
            client:setLocalVar("stm", value)
        end
    end
end