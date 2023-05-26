local PLUGIN = PLUGIN

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PostPlayerLoadout(ply)
    if ply:IsAdmin() or ply:Team() == FACTION_STAFF then
        ply:Give("adminstick")
    end
end

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnedNPC(client, entity)
    entity:SetCreator(client)
    entity:SetNWString("Creator_Nick", client:Nick())
end

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnedEntity(client, entity)
    entity:SetNWString("Creator_Nick", client:Nick())
    entity:SetCreator(client)
end
------------------------------------------------------------------------------------------------------------------------