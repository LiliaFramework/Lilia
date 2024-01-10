---
function BodygrouperCore:CanAccessMenu(client)
    for _, v in pairs(ents.FindByClass("lia_bodygrouper")) do
        if v:GetPos():Distance(client:GetPos()) <= 128 then return true end
    end
    return CAMI.PlayerHasAccess(client, "Commands - Change Bodygroups", nil)
end

---
function BodygrouperCore:CanProperty(_, str, ent)
    if str == "persist" and (IsValid(ent) and ent:GetClass() == "lia_bodygrouper") then return false end
end
---
