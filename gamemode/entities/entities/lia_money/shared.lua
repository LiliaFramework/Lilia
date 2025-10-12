ENT.Type = "anim"
ENT.PrintName = L("money")
ENT.Author = "Samael"
ENT.Contact = "@liliaplayer"
ENT.Category = "Lilia"
ENT.Spawnable = false
ENT.DrawEntityInfo = true
ENT.isMoney = true
ENT.noTarget = true
ENT.Holdable = true
ENT.NoDuplicate = true
function ENT:getAmount()
    return self:getNetVar("amount", 0)
end