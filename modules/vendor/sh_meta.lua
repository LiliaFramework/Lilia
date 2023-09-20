--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
function playerMeta:CanEditVendor()
    if CAMI.PlayerHasAccess(self, "Lilia - Management - Can Edit Vendors") then
        return true
    else
        return self:IsSuperAdmin()
    end
end
--------------------------------------------------------------------------------------------------------
CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Management - Can Edit Vendors",
        MinAccess = "admin",
        Description = "Allows access to edit vendors.",
    }
)
--------------------------------------------------------------------------------------------------------