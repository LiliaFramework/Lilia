function PLUGIN:PlayerBindPress(client, bind, pressed)
    if lia.config.get("AntiBunnyHopEnabled", true) then
        if client:GetMoveType() == MOVETYPE_NOCLIP or not client:getChar() then return end
        bind = bind:lower()
        if bind:find("jump") and (client:getLocalVar("stm", 0) < nut.config.get("bunnyHop")) then return true end
    end
end