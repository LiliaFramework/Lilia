function MODULE:CanAccessMenu(client)
    for _, v in pairs(ents.FindByClass("lia_bodygrouper")) do
        if v:GetPos():Distance(client:GetPos()) <= 128 then return true end
    end
    return client:hasPrivilege("Commands - Change Bodygroups")
end

function MODULE:CanProperty(_, property, entity)
    if property == "persist" and (IsValid(entity) and entity:GetClass() == "lia_bodygrouper") then return false end
end
