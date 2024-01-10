local playerMeta = FindMetaTable("Player")
function playerMeta:CanEditVendor()
    if CAMI.PlayerHasAccess(self, "Lilia - Staff Permissions - Can Edit Vendors") then return true end
    return false
end
