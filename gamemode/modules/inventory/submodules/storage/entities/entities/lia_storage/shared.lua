local MODULE = MODULE
ENT.Type = "anim"
ENT.PrintName = L("storage")
ENT.Category = "Lilia"
ENT.Spawnable = false
ENT.isStorageEntity = true
ENT.DrawEntityInfo = true
ENT.IsPersistent = true
function ENT:getInv()
    return lia.inventory.instances[self:getNetVar("id")]
end

function ENT:getStorageInfo()
    self.lowerModel = self.lowerModel or self:GetModel()
    return MODULE.StorageDefinitions[self.lowerModel]
end