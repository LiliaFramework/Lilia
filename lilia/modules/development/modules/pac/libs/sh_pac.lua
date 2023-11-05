--------------------------------------------------------------------------------------------------------------------------
lia.flag.add("P", "Access to PAC3.")
--------------------------------------------------------------------------------------------------------------------------
function MODULE:setupPACDataFromItems()
    for itemType, item in pairs(lia.item.list) do
        if istable(item.pacData) then self.partData[itemType] = item.pacData end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:InitializedModules()
    timer.Simple(1, function() self:setupPACDataFromItems() end)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:isAllowedToUsePAC(client)
    return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Can Use PAC3", nil) or client:getChar():hasFlags("P")
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanWearParts(client, file)
    return self:isAllowedToUsePAC(client)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PrePACEditorOpen(client)
    return self:isAllowedToUsePAC(client)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PrePACConfigApply(client)
    return self:isAllowedToUsePAC(client)
end

--------------------------------------------------------------------------------------------------------------------------
CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Staff Permissions - Can Use PAC3",
        MinAccess = "superadmin",
        Description = "Allows access to Spawning Menu Items.",
    }
)
--------------------------------------------------------------------------------------------------------------------------