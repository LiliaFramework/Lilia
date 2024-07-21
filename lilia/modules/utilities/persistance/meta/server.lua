local MODULE = MODULE
local entityMeta = FindMetaTable("Entity")
function entityMeta:IsPersistent()
    return self.IsLeonNPC or self.IsPersistent or table.HasValue(MODULE.PersistingEntities, self:GetClass())
end