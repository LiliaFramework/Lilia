--------------------------------------------------------------------------------------------------------
CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Management - Can Use PAC3",
        MinAccess = "superadmin",
        Description = "Allows access to Spawning Menu Items.",
    }
)

--------------------------------------------------------------------------------------------------------
function MODULE:isAllowedToUsePAC(client)
    return CAMI.PlayerHasAccess(client, "Lilia - Management - Can Use PAC3", nil)
end

--------------------------------------------------------------------------------------------------------
function MODULE:CanWearParts(client, file)
    return self:isAllowedToUsePAC(client)
end

--------------------------------------------------------------------------------------------------------
function MODULE:PrePACEditorOpen(client)
    return self:isAllowedToUsePAC(client)
end

--------------------------------------------------------------------------------------------------------
function MODULE:PrePACConfigApply(client)
    return self:isAllowedToUsePAC(client)
end
--------------------------------------------------------------------------------------------------------