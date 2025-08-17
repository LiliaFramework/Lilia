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
    local model = self:GetModel()
    if not model then return end
    return MODULE.StorageDefinitions[model:lower()]
end
