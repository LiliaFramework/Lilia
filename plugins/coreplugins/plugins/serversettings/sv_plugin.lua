------------------------------------------------------------------------------------------------------------------------
-- SETS NAME ON THE SERVER LIST
function PLUGIN:GetGameDescription()
    if istable(SCHEMA) then return tostring(SCHEMA.name) end

    return "Lilia - Skeleton"
end

------------------------------------------------------------------------------------------------------------------------
-- DISABLES SPRAYING
function PLUGIN:PlayerSpray(client)
    return not lia.config.get("PlayerSprayEnabled", false)
end

-------------------------------------------------------------------------------------------------------------------------
-- EVERYONE CAN USE FLASHLIGHT
function PLUGIN:PlayerSwitchFlashlight(ply, on)
    return lia.config.get("GlobalFlashlightEnabled", false)
end

------------------------------------------------------------------------------------------------------------------------
-- Disables Annoying Extra Elements
function PLUGIN:PlayerInitialSpawn(ply)
    local annoying = ents.FindByName("music")
    local val = ents.GetMapCreatedEntity(1733)

    if lia.config.get("MusicKiller", true) and #annoying > 0 then
        annoying[1]:SetKeyValue("RefireTime", 99999999)
        annoying[1]:Fire("Disable")
        annoying[1]:Fire("Kill")
        val:SetKeyValue("RefireTime", 99999999)
        val:Fire("Disable") --i dont know if killing it stops the timer so here
        val:Fire("Kill")
    end
end