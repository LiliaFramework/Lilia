--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
function playerMeta:CanUseVendor()
    if not lia.config.VendorEditorAllowed then return self:IsSuperAdmin() end
    local userGroup = self:GetUserGroup()
    return lia.config.VendorEditorAllowed[userGroup] or false
end
--------------------------------------------------------------------------------------------------------