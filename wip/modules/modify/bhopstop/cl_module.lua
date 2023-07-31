function MODULE:PlayerBindPress(client, bind, pressed)
    if CONFIG.AntiBunnyHopEnabledthen
        if client:GetMoveType() == MOVETYPE_NOCLIP or not client:getChar() or client:InVehicle() then return end
        bind = bind:lower()
        if bind:find("jump") and (client:getLocalVar("stm", 0) =< CONFIG.BHOPStamina) then return true end
    end
end

