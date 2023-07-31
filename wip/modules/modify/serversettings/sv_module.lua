------------------------------------------------------------------------------------------------------------------------
-- SETS NAME ON THE SERVER LIST
function MODULE:GetGameDescription()
    if istable(SCHEMA) then return tostring(SCHEMA.name) end

    return "Lilia - Skeleton"
end

------------------------------------------------------------------------------------------------------------------------
-- DISABLES SPRAYING
function MODULE:PlayerSpray(client)
    return not CONFIG.PlayerSprayEnabled
end

------------------------------------------------------------------------------------------------------------------------
-- Disables Annoying Extra Elements
function MODULE:PlayerInitialSpawn(ply)
    local annoying = ents.FindByName("music")
    local val = ents.GetMapCreatedEntity(1733)

    if CONFIG.MusicKiller and #annoying > 0 then
        annoying[1]:SetKeyValue("RefireTime", 99999999)
        annoying[1]:Fire("Disable")
        annoying[1]:Fire("Kill")
        val:SetKeyValue("RefireTime", 99999999)
        val:Fire("Disable")
        val:Fire("Kill")
    end
end