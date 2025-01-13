local MODULE = MODULE
--- The Entity Meta for the Persistence Module.
-- @entitymeta Persistence
local entityMeta = FindMetaTable("Entity")
--- Checks if the entity is persistent.
-- This function checks whether the entity is flagged as persistent.
-- @realm shared
-- @treturn boolean True if the entity is persistent, false otherwise.
function entityMeta:IsLiliaPersistent()
    return self.IsLeonNPC or self.IsPersistent or MODULE.PersistingEntities[self:GetClass()]
end