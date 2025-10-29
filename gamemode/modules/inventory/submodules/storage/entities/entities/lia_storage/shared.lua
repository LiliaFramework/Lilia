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
    if not lia.inventory or not lia.inventory.instances then return end
    return lia.inventory.instances[self:getNetVar("id")]
end

function ENT:getStorageInfo()
    local model = self:GetModel()
    if not model then return end
    if not lia.inventory or not lia.inventory.getStorage then return end
    local storageInfo = lia.inventory.getStorage(model:lower())
    if not storageInfo then
        storageInfo = {
            name = L("storageContainer"),
            desc = "storageContainerDesc",
            invType = "GridInv",
            invData = {
                w = 4,
                h = 4
            }
        }
    end
    return storageInfo
end
