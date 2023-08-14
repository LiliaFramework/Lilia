--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")

--------------------------------------------------------------------------------------------------------
function playerMeta:CanEditVendor()
    if not lia.config.VendorEditorAllowed then return self:IsSuperAdmin() end
    local userGroup = self:GetUserGroup()

    return lia.config.VendorEditorAllowed[userGroup] or false
end
--------------------------------------------------------------------------------------------------------