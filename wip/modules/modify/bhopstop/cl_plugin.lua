function MODULE:PlayerBindPress(client, bind, pressed)
    if lia.config.get("AntiBunnyHopEnabled", true) then
        if client:GetMoveType() == MOVETYPE_NOCLIP or not client:getChar() or client:InVehicle() then return end
        bind = bind:lower()
        if bind:find("jump") and (client:getLocalVar("stm", 0) < lia.config.get("BHOPStamina")) then return true end
    end
end