---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:InitializedModules()
    sam.config.set("Restrictions.Tool", false)
    sam.config.set("Restrictions.Limits", false)
    sam.config.set("Restrictions.Spawning", false)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerInitialSpawn(client)
    local StaffRank = self.DefaultStaff[client:SteamID()]
    if StaffRank then
        RunConsoleCommand("sam", "setrank", client:SteamID(), StaffRank)
        client:ChatPrint("You have been set as rank: " .. StaffRank)
        print(client:Nick() .. " has been set as rank: " .. StaffRank)
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerSpawnProp(client)
    if not FindMetaTable("Player").GetLimit then return end
    local limit = client:GetLimit("props")
    if limit < 0 then return end
    local props = client:GetCount("props") + 1
    if client:getLiliaData("extraProps") then
        if props > (limit + 50) then
            client:LimitHit("props")
            return false
        end
    else
        if props > limit then
            client:LimitHit("props")
            return false
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerCheckLimit(client, name)
    if not FindMetaTable("Player").GetLimit then return end
    if name == "props" then
        if client:isStaffOnDuty() then return true end
        if client:GetLimit("props") < 0 then return end
        if client:getLiliaData("extraProps") then
            local limit = client:GetLimit("props") + 50
            local props = client:GetCount("props")
            if props <= limit + 50 then return true end
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerSpawnRagdoll(client)
    if not FindMetaTable("Player").GetLimit then return end
    local limit = client:GetLimit("ragdolls")
    if limit < 0 then return end
    local ragdolls = client:GetCount("ragdolls") + 1
    if ragdolls > limit then
        client:LimitHit("ragdolls")
        return false
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
