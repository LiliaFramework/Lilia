local playerMeta = FindMetaTable("Player")
function playerMeta:CanEditVendor()
    if self:HasPrivilege("Staff Permissions - Can Edit Vendors") then return true end
    return false
end
