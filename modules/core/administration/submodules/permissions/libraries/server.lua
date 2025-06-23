local GM = GM or GAMEMODE
local MODULE = MODULE
local resetCalled = 0
function GM:PlayerSpawnProp(client, model)
    if MODULE.BlackListedProps and MODULE.BlackListedProps[model] and not client:hasPrivilege("Spawn Permissions - Can Spawn Blacklisted Props") then
        client:notify("Blacklisted Prop!")
        return false
    end

    local weapon = client:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "gmod_tool" then
        local toolobj = weapon:GetToolObject()
        if toolobj and (client.AdvDupe2 and client.AdvDupe2.Entities or client.CurrentDupe and client.CurrentDupe.Entities or toolobj.Entities) then return true end
    end

    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Props") or client:getChar():hasFlags("e")
    if not canSpawn then client:notify("You do not have permission to spawn props.") end
    return canSpawn
end

function GM:CanProperty(client, property, entity)
    local restrictedProperties = {
        persist = true,
        drive = true,
        bonemanipulate = true
    }

    if restrictedProperties[property] then
        client:notify("This is disabled to avoid issues with Lilia's Core Features")
        return false
    end

    if entity:IsWorld() and IsValid(entity) then
        if client:hasPrivilege("Staff Permissions - Can Property World Entities") then return true end
        client:notify("You do not have permission to modify world entities.")
        return false
    end

    local entityClass = entity:GetClass()
    if MODULE.RemoverBlockedEntities and MODULE.RemoverBlockedEntities[entityClass] or MODULE.RestrictedEnts and MODULE.RestrictedEnts[entityClass] then
        if client:hasPrivilege("Staff Permissions - Use Entity Properties on Blocked Entities") then return true end
        client:notify("You do not have permission to modify properties on this entity.")
        return false
    end

    if entity:GetCreator() == client and (property == "remover" or property == "collision") then return true end
    if client:IsSuperAdmin() or client:hasPrivilege("Staff Permissions - Access Property " .. property:gsub("^%l", string.upper)) and client:isStaffOnDuty() then return true end
    client:notify("You do not have permission to modify this property.")
    return false
end

function GM:DrawPhysgunBeam(client)
    if client:isNoClipping() then return false end
end

function GM:PhysgunPickup(client, entity)
    local entityClass = entity:GetClass()
    if (client:hasPrivilege("Staff Permissions - Physgun Pickup") or client:isStaffOnDuty()) and MODULE.RestrictedEnts and MODULE.RestrictedEnts[entityClass] then
        if not client:hasPrivilege("Staff Permissions - Physgun Pickup on Restricted Entities") then
            client:notify("You do not have permission to pick up restricted entities with the physgun.")
            return false
        end
        return true
    end

    if client:IsSuperAdmin() then return true end
    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    if client:hasPrivilege("Staff Permissions - Physgun Pickup") then
        if entity:IsVehicle() then
            if not client:hasPrivilege("Staff Permissions - Physgun Pickup on Vehicles") then
                client:notify("You do not have permission to pick up vehicles with the physgun.")
                return false
            end
            return true
        elseif entity:IsPlayer() then
            if entity:hasPrivilege("Staff Permissions - Can't be Grabbed with PhysGun") or not client:hasPrivilege("Staff Permissions - Can Grab Players") then
                client:notify("You do not have permission to pick up this player with the physgun.")
                return false
            end
            return true
        elseif entity:IsWorld() or entity:CreatedByMap() then
            if not client:hasPrivilege("Staff Permissions - Can Grab World Props") then
                client:notify("You do not have permission to pick up world props with the physgun.")
                return false
            end
            return true
        end
        return true
    end

    client:notify("You do not have permission to pick up this entity with the physgun.")
    return false
end

function GM:PlayerSpawnVehicle(client, _, name)
    if MODULE.RestrictedVehicles and MODULE.RestrictedVehicles[name] and not client:hasPrivilege("Spawn Permissions - Can Spawn Restricted Cars") then
        client:notify("You can't spawn this vehicle since it's restricted!")
        return false
    end

    if not client:hasPrivilege("Spawn Permissions - No Car Spawn Delay") then client.NextVehicleSpawn = SysTime() + lia.config.get("PlayerSpawnVehicleDelay", 30) end
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Cars") or client:getChar():hasFlags("C")
    if not canSpawn then client:notify("You do not have permission to spawn vehicles.") end
    return canSpawn
end

function GM:PlayerNoClip(ply, enabled)
    if not (ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")) then
        ply:notify("You do not have permission to noclip.")
        return false
    end

    ply:DrawShadow(not enabled)
    ply:SetNoTarget(enabled)
    ply:AddFlags(FL_NOTARGET)
    hook.Run("OnPlayerObserve", ply, enabled)
    return true
end

function GM:PlayerSpawnEffect(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Effects") or client:getChar():hasFlags("L")
    if not canSpawn then client:notify("You do not have permission to spawn effects.") end
    return canSpawn
end

function GM:PlayerSpawnNPC(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn NPCs") or client:getChar():hasFlags("n")
    if not canSpawn then client:notify("You do not have permission to spawn NPCs.") end
    return canSpawn
end

function GM:PlayerSpawnRagdoll(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Ragdolls") or client:getChar():hasFlags("r")
    if not canSpawn then client:notify("You do not have permission to spawn ragdolls.") end
    return canSpawn
end

function GM:PlayerSpawnSENT(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SENTs") or client:getChar():hasFlags("E")
    if not canSpawn then client:notify("You do not have permission to spawn SENTs.") end
    return canSpawn
end

function GM:PlayerSpawnSWEP(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SWEPs") or client:getChar():hasFlags("z")
    if not canSpawn then client:notify("You do not have permission to spawn SWEPs.") end
    return canSpawn
end

function GM:PlayerGiveSWEP(client)
    local canGive = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SWEPs") or client:getChar():hasFlags("W")
    if not canGive then client:notify("You do not have permission to give SWEPs.") end
    return canGive
end

function GM:OnPhysgunReload(_, client)
    local canReload = client:hasPrivilege("Staff Permissions - Can Physgun Reload")
    if not canReload then client:notify("You do not have permission to reload the physgun.") end
    return canReload
end

function GM:CanTool(client, _, tool)
    local DisallowedTools = {
        rope = true,
        light = true,
        lamp = true,
        dynamite = true,
        physprop = true,
        faceposer = true,
        stacker = true
    }

    local function CheckDuplicationScale(client, entities)
        entities = entities or {}
        for _, v in pairs(entities) do
            if v.ModelScale and v.ModelScale > 10 then
                client:notify("A model within this duplication exceeds the size limit!")
                print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID64() .. ")")
                return false
            end

            v.ModelScale = 1
        end
        return true
    end

    if DisallowedTools[tool] and not client:IsSuperAdmin() then
        client:notify("You are not allowed to use the " .. tool .. " tool.")
        return false
    end

    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local isSuperAdmin = client:IsSuperAdmin()
    local isStaffOrFlagged = client:isStaffOnDuty() or client:getChar():hasFlags("t")
    local hasPriv = client:hasPrivilege(privilege)
    if not isSuperAdmin and not (isStaffOrFlagged and hasPriv) then
        local reasons = {}
        if not isSuperAdmin then table.insert(reasons, "SuperAdmin") end
        if not isStaffOrFlagged then table.insert(reasons, "On‑duty staff or flag 't'") end
        if not hasPriv then table.insert(reasons, "Privilege '" .. privilege .. "'") end
        client:notify("You do not have permission to access tool '" .. tool .. "'. Missing: " .. table.concat(reasons, ", "))
        return false
    end

    local weapon = client:GetActiveWeapon()
    local toolobj = IsValid(weapon) and weapon:GetToolObject() or nil
    local entity = client:getTracedEntity()
    if IsValid(entity) then
        local entClass = entity:GetClass()
        if tool == "remover" then
            if MODULE.RemoverBlockedEntities and MODULE.RemoverBlockedEntities[entClass] then
                if not client:hasPrivilege("Staff Permissions - Can Remove Blocked Entities") then
                    client:notify("You do not have permission to remove blocked entities.")
                    return false
                end
                return true
            elseif entity:IsWorld() then
                if not client:hasPrivilege("Staff Permissions - Can Remove World Entities") then
                    client:notify("You do not have permission to remove world entities.")
                    return false
                end
                return true
            end
            return true
        end

        if (tool == "permaall" or tool == "permaprops" or tool == "blacklistandremove") and (string.StartWith(entClass, "lia_") or MODULE.CanNotPermaProp and MODULE.CanNotPermaProp[entClass] or entity:isLiliaPersistent() or entity:CreatedByMap()) then
            client:notify("You cannot use " .. tool .. " on this entity.")
            return false
        end

        if (tool == "adv_duplicator" or tool == "advdupe2" or tool == "duplicator" or tool == "blacklistandremove") and (MODULE.DuplicatorBlackList and MODULE.DuplicatorBlackList[entClass] or entity.NoDuplicate) then
            client:notify("This entity cannot be duplicated using " .. tool .. ".")
            return false
        end

        if tool == "weld" and entClass == "sent_ball" then
            client:notify("You cannot weld this entity with the weld tool.")
            return false
        end
    end

    if tool == "duplicator" and client.CurrentDupe and not CheckDuplicationScale(client, client.CurrentDupe.Entities) then return false end
    if tool == "advdupe2" and client.AdvDupe2 and not CheckDuplicationScale(client, client.AdvDupe2.Entities) then return false end
    if tool == "adv_duplicator" and toolobj and toolobj.Entities and not CheckDuplicationScale(client, toolobj.Entities) then return false end
    return true
end

function GM:PlayerSpawnedNPC(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedEffect(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedProp(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedRagdoll(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedSENT(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedSWEP(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedVehicle(client, entity)
    entity:SetCreator(client)
end

function GM:CanPlayerUseChar(client)
    if GetGlobalBool("characterSwapLock", false) and not client:hasPrivilege("Staff Permissions - Can Bypass Character Lock") then return false, "Currently the server is in an event and you're unable to change characters." end
end

concommand.Add("kickbots", function()
    for _, bot in player.Iterator() do
        if bot:IsBot() then bot:Kick("All bots kicked") end
    end
end)

concommand.Add("stopsoundall", function(client)
    if client:IsSuperAdmin() then
        for _, v in player.Iterator() do
            v:ConCommand("stopsound")
        end
    else
        client:notify("You must be a Super Admin to forcefully stopsound everyone!")
    end
end)

local function handleDatabaseWipe(commandName)
    concommand.Add(commandName, function(client)
        if IsValid(client) then
            client:notify("This command can only be run from the server console.")
            return
        end

        if resetCalled < RealTime() then
            resetCalled = RealTime() + 3
            MsgC(Color(255, 0, 0), "[Lilia] TO CONFIRM DATABASE RESET, RUN '" .. commandName .. "' AGAIN in 3 SECONDS.\n")
        else
            resetCalled = 0
            MsgC(Color(255, 0, 0), "[Lilia] DATABASE WIPE IN PROGRESS.\n")
            hook.Run("OnWipeTables")
            lia.db.wipeTables(lia.db.loadTables)
            game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
        end
    end)
end

handleDatabaseWipe("lia_recreatedb")
handleDatabaseWipe("lia_wipedb")
