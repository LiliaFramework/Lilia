-- @playermeta Vendor
local playerMeta = FindMetaTable("Player")

--- Determines if the player can edit a vendor.
-- This function checks whether the player has the necessary privilege to edit vendors.
-- @realm shared
-- @treturn boolean true if the player has the privilege to edit vendors, false otherwise.
function playerMeta:CanEditVendor()
    if self:HasPrivilege("Staff Permissions - Can Edit Vendors") then return true end
    return false
end
