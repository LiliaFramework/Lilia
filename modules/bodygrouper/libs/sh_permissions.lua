--------------------------------------------------------------------------------------------------------
function MODULE:CanChangeBodygroup(client)
    if CAMI then
        return CAMI.PlayerHasAccess(client, "Characters - Change Bodygroups", nil)
    else
        if lia.config.BodygrouperAdminOnly then return client:IsAdmin() end
    end

    return true
end

--------------------------a------------------------------------------------------------------------------
function MODULE:CanAccessMenu(client)
    for k, v in pairs(ents.FindByClass("bodygrouper_closet")) do
        if v:GetPos():Distance(client:GetPos()) <= 128 then return true end
    end

    return self:CanChangeBodygroup(client)
end

--------------------------------------------------------------------------------------------------------
function MODULE:CanProperty(client, str, ent)
    if str == "persist" and (IsValid(ent) and ent:GetClass() == "bodygrouper_closet") then return false end
end
--------------------------------------------------------------------------------------------------------