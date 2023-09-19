--------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------
function MODULE:SaveData()
    self:setData(self.oocBans)
end
--------------------------------------------------------------------------------------------------------
function MODULE:LoadData()
    self.oocBans = self:getData()
end
--------------------------------------------------------------------------------------------------------
function MODULE:InitializedModules()
    SetGlobalBool("oocblocked", false)
end
--------------------------------------------------------------------------------------------------------
CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Management - No OOC Cooldown",
        MinAccess = "admin",
        Description = "Allows access to use the OOC chat command without delay.",
    }
)
--------------------------------------------------------------------------------------------------------