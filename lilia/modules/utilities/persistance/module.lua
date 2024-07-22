﻿local MODULE = MODULE
local entityMeta = FindMetaTable("Entity")
MODULE.name = "Persistance"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds a Module that implements persistance"
MODULE.PersistingEntities = {}
function entityMeta:IsLiliaPersistent()
    return self.IsLeonNPC or self.IsPersistent or table.HasValue(MODULE.PersistingEntities, self:GetClass())
end