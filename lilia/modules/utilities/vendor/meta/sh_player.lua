local playerMeta = FindMetaTable("Player")
function playerMeta:CanEditVendor()
  if self:hasPrivilege("Staff Permissions - Can Edit Vendors") then return true end
  return false
end
