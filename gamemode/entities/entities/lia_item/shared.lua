ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = L("item")
ENT.Author = "Samael"
ENT.Contact = "@liliaplayer"
ENT.Category = "Lilia"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.DrawEntityInfo = true
ENT.isItem = true
ENT.hasMenu = true
ENT.noTarget = true
ENT.Holdable = true
ENT.NoDuplicate = true
function ENT:getItemID()
    return self:getNetVar("instanceID")
end

function ENT:getItemTable()
    local itemID = self:getItemID()
    if not itemID then
        self.cachedItemID = nil
        self.cachedItemTable = nil
        return nil
    end

    if self.cachedItemID ~= itemID then
        self.cachedItemID = itemID
        self.cachedItemTable = lia.item.instances[itemID]
    end

    if self.cachedItemTable and not lia.item.instances[itemID] then
        self.cachedItemTable = nil
        return nil
    end
    return self.cachedItemTable
end

function ENT:getData(key, default)
    local data = self:getNetVar("data", {})
    if data[key] == nil then return default end
    return data[key]
end
