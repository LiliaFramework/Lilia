function MODULE:InitializedModules()
end
net.Receive("liaCheckSeed", function(_, client)
    local sentSteamID = net.ReadString()
    if not sentSteamID or sentSteamID == "" then
        lia.adminstrator.notifyAdmin(L("steamIDMissing", client:Name(), client:SteamID()))
        lia.log.add(client, "steamIDMissing", client:Name(), client:SteamID())
        return
    end
    if client:SteamID() ~= sentSteamID then
        lia.adminstrator.notifyAdmin(L("steamIDMismatch", client:Name(), client:SteamID(), sentSteamID))
        lia.log.add(client, "steamIDMismatch", client:Name(), client:SteamID(), sentSteamID)
    end
end)
net.Receive("liaCheckHack", function(_, client)
    lia.log.add(client, "hackAttempt", "CheckHack")
    local override = hook.Run("PlayerCheatDetected", client)
    client:setNetVar("cheater", true)
    client:setLiliaData("cheater", true)
    hook.Run("OnCheaterCaught", client)
    if override ~= true then lia.adminstrator.applyPunishment(client, L("hackingInfraction"), true, true, 0, "kickedForInfractionPeriod", "bannedForInfractionPeriod") end
end)
net.Receive("liaVerifyCheatsResponse", function(_, client)
    lia.log.add(client, "verifyCheatsOK")
    client.VerifyCheatsPending = nil
    if client.VerifyCheatsTimer then
        timer.Remove(client.VerifyCheatsTimer)
        client.VerifyCheatsTimer = nil
    end
end)
local function getEntityDisplayName(ent)
    if not IsValid(ent) then return L("unknownEntity") end
    if ent:GetClass() == "lia_item" and ent.getItemTable then
        local item = ent:getItemTable()
        if item and item.getName then
            return item:getName()
        elseif item and item.name then
            return item.name
        end
    end
    if ent:GetClass() == "lia_vendor" then
        local vendorName = ent:getNetVar("name")
        if vendorName and vendorName ~= "" then return vendorName end
    end
    if ent:GetClass() == "lia_storage" then
        local storageInfo = ent:getStorageInfo()
        if storageInfo and storageInfo.name then return storageInfo.name end
    end
    if ent:IsPlayer() and ent:getChar() then return ent:getChar():getName() end
    if ent:IsVehicle() then
        local vehicleName = ent:GetVehicleClass()
        if vehicleName and vehicleName ~= "" then return vehicleName end
    end
    if ent.PrintName and ent.PrintName ~= "" then return ent.PrintName end
    local className = ent:GetClass()
    if className:StartWith("lia_") then return className:sub(5):gsub("_", " "):gsub("^%l", string.upper) end
    return className
end
net.Receive("liaTeleportToEntity", function(_, client)
    if not client:hasPrivilege("teleportToEntity") then
        client:notifyErrorLocalized("noPrivilege")
        return
    end
    local entity = net.ReadEntity()
    if not IsValid(entity) then
        client:notifyErrorLocalized("invalidEntity")
        return
    end
    client.previousPosition = client:GetPos()
    local entityPos = entity:GetPos()
    local trace = util.TraceLine({
        start = entityPos,
        endpos = entityPos + Vector(0, 0, 100),
        mask = MASK_SOLID
    })
    if trace.Hit then
        client:SetPos(trace.HitPos + Vector(0, 0, 10))
    else
        client:SetPos(entityPos + Vector(0, 0, 50))
    end
    client:notifySuccessLocalized("teleportedToEntity")
    lia.log.add(client, "entityTeleport", client:Name(), getEntityDisplayName(entity), tostring(entity:GetPos()))
end)
net.Receive("liaReturnFromEntity", function(_, client)
    if not client.previousPosition then
        client:notifyErrorLocalized("noPreviousPosition")
        return
    end
    local returnPos = client.previousPosition
    client:SetPos(returnPos)
    client.previousPosition = nil
    client:notifySuccessLocalized("returnedFromEntity")
    lia.log.add(client, "entityReturn", client:Name(), tostring(returnPos))
end)