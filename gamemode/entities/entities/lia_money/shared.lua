ENT.Type = "anim"
ENT.PrintName = "Money"
ENT.Category = "Lilia"
ENT.Spawnable = false
ENT.DrawEntityInfo = true
ENT.isMoney = true
ENT.noTarget = true
function ENT:getAmount()
    return self:getNetVar("amount", 0)
end