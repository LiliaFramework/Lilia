--------------------------------------------------------------------------------------------------------
function MODULE:CanChangeBodygroup(client)
    if lia.config.BodygrouperAdminOnly then
        if CAMI then
            return CAMI.PlayerHasAccess(client, "Change Bodygroups", nil)
        else
            return client:IsAdmin()
        end
    end
end

--------------------------a------------------------------------------------------------------------------
function MODULE:CanAccessMenu(client)
    for k, v in pairs(ents.FindByClass("lia_bodygrouper")) do
        if v:GetPos():Distance(client:GetPos()) <= 128 then return true end
    end
    return self:CanChangeBodygroup(client)
end

--------------------------------------------------------------------------------------------------------
function MODULE:CanProperty(client, str, ent)
    if str == "persist" and (IsValid(ent) and ent:GetClass() == "lia_bodygrouper") then return false end
end
--------------------------------------------------------------------------------------------------------