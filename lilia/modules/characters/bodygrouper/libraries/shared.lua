
function MODULE:CanAccessMenu(client)
    for _, v in pairs(ents.FindByClass("lia_bodygrouper")) do
        if v:GetPos():Distance(client:GetPos()) <= 128 then return true end
    end
    return CAMI.PlayerHasAccess(client, "Commands - Change Bodygroups", nil)
end


function MODULE:CanProperty(_, property, entity)
    if property == "persist" and (IsValid(entity) and entity:GetClass() == "lia_bodygrouper") then return false end
end

