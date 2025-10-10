ENT.Type = "anim"
ENT.PrintName = L("storage")
ENT.Author = "Samael"
ENT.Contact = "@liliaplayer"
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
    return lia.inventory.getStorage(model:lower())
end