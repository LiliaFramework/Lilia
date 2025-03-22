local GM = GM or GAMEMODE
local MODULE = MODULE
local resetCalled = 0
local DevMode = false
function GM:PlayerSpawnProp(client, model)
    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: Checking model " .. model) end
    PrintTable(MODULE.BlackListedProps, 1)
    if MODULE.BlackListedProps and MODULE.BlackListedProps[model] and not client:hasPrivilege("Spawn Permissions - Can Spawn Blacklisted Props") then
        client:notify("Blacklisted Prop!")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: Blocked blacklisted prop " .. model) end
        return false
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: Model check passed for " .. model) end
    local weapon = client:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "gmod_tool" then
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: gmod_tool active, checking duplicator tool") end
        local toolobj = weapon:GetToolObject()
        if toolobj and (client.AdvDupe2 and client.AdvDupe2.Entities or client.CurrentDupe and client.CurrentDupe.Entities or toolobj.Entities) then
            if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: Allowed via duplicator tool") end
            return true
        end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: Checking general spawn permissions") end
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Props") or client:getChar():hasFlags("e")
    if not canSpawn then
        client:notify("You do not have permission to spawn props.")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnProp: Exiting function") end
    return canSpawn
end

function GM:CanProperty(client, property, entity)
    if DevMode then client:ChatPrint("[DevMode] CanProperty: Checking property '" .. property .. "' on entity " .. tostring(entity)) end
    local restrictedProperties = {
        persist = true,
        drive = true,
        bonemanipulate = true
    }

    if restrictedProperties[property] then
        client:notify("This is disabled to avoid issues with Lilia's Core Features")
        if DevMode then client:ChatPrint("[DevMode] CanProperty: Property '" .. property .. "' is restricted") end
        return false
    end

    if entity:IsWorld() and IsValid(entity) then
        if client:hasPrivilege("Staff Permissions - Can Property World Entities") then
            if DevMode then client:ChatPrint("[DevMode] CanProperty: World entity modification permitted") end
            return true
        end

        client:notify("You do not have permission to modify world entities.")
        if DevMode then client:ChatPrint("[DevMode] CanProperty: Denied world entity modification") end
        return false
    end

    local entityClass = entity:GetClass()
    if (MODULE.RemoverBlockedEntities and MODULE.RemoverBlockedEntities[entityClass]) or (MODULE.RestrictedEnts and MODULE.RestrictedEnts[entityClass]) then
        if client:hasPrivilege("Staff Permissions - Use Entity Properties on Blocked Entities") then
            if DevMode then client:ChatPrint("[DevMode] CanProperty: Allowed modifying blocked entity " .. entityClass) end
            return true
        end

        client:notify("You do not have permission to modify properties on this entity.")
        if DevMode then client:ChatPrint("[DevMode] CanProperty: Denied modifying blocked entity " .. entityClass) end
        return false
    end

    if entity:GetCreator() == client and (property == "remover" or property == "collision") then
        if DevMode then client:ChatPrint("[DevMode] CanProperty: Allowed, client is creator modifying " .. property) end
        return true
    end

    if client:IsSuperAdmin() or (client:hasPrivilege("Staff Permissions - Access Property " .. property:gsub("^%l", string.upper)) and client:isStaffOnDuty()) then
        if DevMode then client:ChatPrint("[DevMode] CanProperty: Permission granted for property " .. property) end
        return true
    end

    client:notify("You do not have permission to modify this property.")
    if DevMode then client:ChatPrint("[DevMode] CanProperty: Permission denied for property " .. property) end
    if DevMode then client:ChatPrint("[DevMode] CanProperty: Exiting function") end
    return false
end

function GM:PhysgunPickup(client, entity)
    local entityClass = entity:GetClass()
    if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Checking entity " .. entityClass) end
    if (client:hasPrivilege("Staff Permissions - Physgun Pickup") or client:isStaffOnDuty()) and MODULE.RestrictedEnts and MODULE.RestrictedEnts[entityClass] then
        if not client:hasPrivilege("Staff Permissions - Physgun Pickup on Restricted Entities") then
            client:notify("You do not have permission to pick up restricted entities with the physgun.")
            if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Denied pickup of restricted entity " .. entityClass) end
            return false
        end

        if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Allowed pickup of restricted entity " .. entityClass) end
        return true
    end

    if client:IsSuperAdmin() then
        if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: SuperAdmin override") end
        return true
    end

    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then
        if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Allowed, client is creator") end
        return true
    end

    if client:hasPrivilege("Staff Permissions - Physgun Pickup") then
        if entity:IsVehicle() then
            if not client:hasPrivilege("Staff Permissions - Physgun Pickup on Vehicles") then
                client:notify("You do not have permission to pick up vehicles with the physgun.")
                if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Denied vehicle pickup") end
                return false
            end

            if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Vehicle pickup allowed") end
            return true
        elseif entity:IsPlayer() then
            if entity:hasPrivilege("Staff Permissions - Can't be Grabbed with PhysGun") or not client:hasPrivilege("Staff Permissions - Can Grab Players") then
                client:notify("You do not have permission to pick up this player with the physgun.")
                if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Denied player pickup") end
                return false
            end

            if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Player pickup allowed") end
            return true
        elseif entity:IsWorld() or entity:CreatedByMap() then
            if not client:hasPrivilege("Staff Permissions - Can Grab World Props") then
                client:notify("You do not have permission to pick up world props with the physgun.")
                if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Denied world prop pickup") end
                return false
            end

            if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: World prop pickup allowed") end
            return true
        end

        if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: General physgun pickup allowed") end
        return true
    end

    client:notify("You do not have permission to pick up this entity with the physgun.")
    if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Permission denied") end
    if DevMode then client:ChatPrint("[DevMode] PhysgunPickup: Exiting function") end
    return false
end

function GM:PlayerSpawnVehicle(client, _, name)
    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnVehicle: Checking vehicle " .. name) end
    if MODULE.RestrictedVehicles and MODULE.RestrictedVehicles[name] and not client:hasPrivilege("Spawn Permissions - Can Spawn Restricted Cars") then
        client:notifyWarning("You can't spawn this vehicle since it's restricted!")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnVehicle: Denied due to restriction (" .. name .. ")") end
        return false
    end

    if not client:hasPrivilege("Spawn Permissions - No Car Spawn Delay") then
        client.NextVehicleSpawn = SysTime() + lia.config.get("PlayerSpawnVehicleDelay", 30)
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnVehicle: Applied spawn delay for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnVehicle: Checking general vehicle spawn permissions") end
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Cars") or client:getChar():hasFlags("C")
    if not canSpawn then
        client:notify("You do not have permission to spawn vehicles.")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnVehicle: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnVehicle: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnVehicle: Exiting function") end
    return canSpawn
end

function GM:PlayerNoClip(client, state)
    if DevMode then client:ChatPrint("[DevMode] PlayerNoClip: Changing state to " .. tostring(state)) end
    if client:isStaffOnDuty() or (client:hasPrivilege("Staff Permissions - No Clip Outside Staff Character") and not client:isStaffOnDuty()) then
        if state then
            client:SetNoDraw(true)
            client:SetNotSolid(true)
            client:DrawWorldModel(false)
            client:DrawShadow(false)
            client:SetNoTarget(true)
            client.liaObsData = {client:GetPos(), client:EyeAngles()}
            hook.Run("OnPlayerObserve", client, state)
            if DevMode then client:ChatPrint("[DevMode] PlayerNoClip: Enabled for " .. client:Name()) end
        else
            if client.liaObsData then
                if client:GetInfoNum("lia_obstpback", 0) > 0 then
                    local position, angles = client.liaObsData[1], client.liaObsData[2]
                    timer.Simple(0, function()
                        client:SetPos(position)
                        client:SetEyeAngles(angles)
                        client:SetVelocity(Vector(0, 0, 0))
                        if DevMode then client:ChatPrint("[DevMode] PlayerNoClip: Reset position and angles for " .. client:Name()) end
                    end)
                end

                client.liaObsData = nil
            end

            client:SetNoDraw(false)
            client:SetNotSolid(false)
            client:DrawWorldModel(true)
            client:DrawShadow(true)
            client:SetNoTarget(false)
            hook.Run("OnPlayerObserve", client, state)
            if DevMode then client:ChatPrint("[DevMode] PlayerNoClip: Disabled for " .. client:Name()) end
        end

        if DevMode then client:ChatPrint("[DevMode] PlayerNoClip: Exiting function") end
        return true
    end

    client:notify("You do not have permission to noclip.")
    if DevMode then client:ChatPrint("[DevMode] PlayerNoClip: Permission denied for " .. client:Name()) end
    if DevMode then client:ChatPrint("[DevMode] PlayerNoClip: Exiting function") end
    return false
end

function GM:PlayerSpawnEffect(client)
    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnEffect: Checking for " .. client:Name()) end
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Effects") or client:getChar():hasFlags("L")
    if not canSpawn then
        client:notify("You do not have permission to spawn effects.")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnEffect: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnEffect: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnEffect: Exiting function") end
    return canSpawn
end

function GM:PlayerSpawnNPC(client)
    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnNPC: Checking for " .. client:Name()) end
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn NPCs") or client:getChar():hasFlags("n")
    if not canSpawn then
        client:notify("You do not have permission to spawn NPCs.")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnNPC: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnNPC: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnNPC: Exiting function") end
    return canSpawn
end

function GM:PlayerSpawnRagdoll(client)
    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnRagdoll: Checking for " .. client:Name()) end
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Ragdolls") or client:getChar():hasFlags("r")
    if not canSpawn then
        client:notify("You do not have permission to spawn ragdolls.")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnRagdoll: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnRagdoll: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnRagdoll: Exiting function") end
    return canSpawn
end

function GM:PlayerSpawnSENT(client)
    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnSENT: Checking for " .. client:Name()) end
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SENTs") or client:getChar():hasFlags("E")
    if not canSpawn then
        client:notify("You do not have permission to spawn SENTs.")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnSENT: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnSENT: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnSENT: Exiting function") end
    return canSpawn
end

function GM:PlayerSpawnSWEP(client)
    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnSWEP: Checking for " .. client:Name()) end
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SWEPs") or client:getChar():hasFlags("z")
    if not canSpawn then
        client:notify("You do not have permission to spawn SWEPs.")
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnSWEP: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] PlayerSpawnSWEP: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerSpawnSWEP: Exiting function") end
    return canSpawn
end

function GM:PlayerGiveSWEP(client)
    if DevMode then client:ChatPrint("[DevMode] PlayerGiveSWEP: Checking for " .. client:Name()) end
    local canGive = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SWEPs") or client:getChar():hasFlags("W")
    if not canGive then
        client:notify("You do not have permission to give SWEPs.")
        if DevMode then client:ChatPrint("[DevMode] PlayerGiveSWEP: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] PlayerGiveSWEP: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] PlayerGiveSWEP: Exiting function") end
    return canGive
end

function GM:OnPhysgunReload(_, client)
    if DevMode then client:ChatPrint("[DevMode] OnPhysgunReload: Checking for " .. client:Name()) end
    local canReload = client:hasPrivilege("Staff Permissions - Can Physgun Reload")
    if not canReload then
        client:notify("You do not have permission to reload the physgun.")
        if DevMode then client:ChatPrint("[DevMode] OnPhysgunReload: Permission denied for " .. client:Name()) end
    else
        if DevMode then client:ChatPrint("[DevMode] OnPhysgunReload: Permission granted for " .. client:Name()) end
    end

    if DevMode then client:ChatPrint("[DevMode] OnPhysgunReload: Exiting function") end
    return canReload
end

function GM:CanTool(client, _, tool)
    if DevMode then client:ChatPrint("[DevMode] CanTool: Checking tool '" .. tool .. "' for " .. client:Name()) end
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
        if DevMode then client:ChatPrint("[DevMode] CheckDuplicationScale: Checking duplication scale, total entities: " .. tostring(#entities)) end
        for _, v in pairs(entities) do
            if v.ModelScale and v.ModelScale > 10 then
                client:notifyWarning("A model within this duplication exceeds the size limit!")
                print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
                if DevMode then client:ChatPrint("[DevMode] CanTool: Duplication scale too high for an entity") end
                return false
            end

            v.ModelScale = 1
            if DevMode then client:ChatPrint("[DevMode] CheckDuplicationScale: Reset model scale for an entity") end
        end

        if DevMode then client:ChatPrint("[DevMode] CheckDuplicationScale: All entity scales checked and reset") end
        return true
    end

    if DisallowedTools[tool] and not client:IsSuperAdmin() then
        client:notify("You are not allowed to use the " .. tool .. " tool.")
        if DevMode then client:ChatPrint("[DevMode] CanTool: Tool '" .. tool .. "' disallowed for non-SuperAdmin") end
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
        if DevMode then client:ChatPrint(string.format("[DevMode] CanTool: Denied tool '%s'. Conditions -> SuperAdmin: %s, Staff/Flag: %s, Privilege: %s", tool, tostring(isSuperAdmin), tostring(isStaffOrFlagged), tostring(hasPriv))) end
        return false
    end

    if DevMode then client:ChatPrint("[DevMode] CanTool: Basic permission check passed for tool " .. tool) end
    local weapon = client:GetActiveWeapon()
    local toolobj = IsValid(weapon) and weapon:GetToolObject() or nil
    local entity = client:getTracedEntity()
    if IsValid(entity) then
        local entClass = entity:GetClass()
        if tool == "remover" then
            if MODULE.RemoverBlockedEntities and MODULE.RemoverBlockedEntities[entClass] then
                if not client:hasPrivilege("Staff Permissions - Can Remove Blocked Entities") then
                    client:notify("You do not have permission to remove blocked entities.")
                    if DevMode then client:ChatPrint("[DevMode] CanTool: Remover denied on blocked entity " .. entClass) end
                    return false
                end

                if DevMode then client:ChatPrint("[DevMode] CanTool: Remover allowed on blocked entity with permission") end
                return true
            elseif entity:IsWorld() then
                if not client:hasPrivilege("Staff Permissions - Can Remove World Entities") then
                    client:notify("You do not have permission to remove world entities.")
                    if DevMode then client:ChatPrint("[DevMode] CanTool: Remover denied on world entity") end
                    return false
                end

                if DevMode then client:ChatPrint("[DevMode] CanTool: Remover allowed on world entity with permission") end
                return true
            end

            if DevMode then client:ChatPrint("[DevMode] CanTool: Remover tool check passed for " .. entClass) end
            return true
        end

        if (tool == "permaall" or tool == "permaprops" or tool == "blacklistandremove") and (string.StartWith(entClass, "lia_") or (MODULE.CanNotPermaProp and MODULE.CanNotPermaProp[entClass]) or entity:isLiliaPersistent() or entity:CreatedByMap()) then
            client:notify("You cannot use " .. tool .. " on this entity.")
            if DevMode then client:ChatPrint("[DevMode] CanTool: " .. tool .. " cannot be used on entity " .. entClass) end
            return false
        end

        if (tool == "adv_duplicator" or tool == "advdupe2" or tool == "duplicator" or tool == "blacklistandremove") and ((MODULE.DuplicatorBlackList and MODULE.DuplicatorBlackList[entClass]) or entity.NoDuplicate) then
            client:notify("This entity cannot be duplicated using " .. tool .. ".")
            if DevMode then client:ChatPrint("[DevMode] CanTool: Entity " .. entClass .. " cannot be duplicated with " .. tool) end
            return false
        end

        if tool == "weld" and entClass == "sent_ball" then
            client:notify("You cannot weld this entity with the weld tool.")
            if DevMode then client:ChatPrint("[DevMode] CanTool: Cannot weld entity of type sent_ball") end
            return false
        end
    end

    if tool == "duplicator" and client.CurrentDupe and not CheckDuplicationScale(client, client.CurrentDupe.Entities) then
        if DevMode then client:ChatPrint("[DevMode] CanTool: Duplicator tool failed duplication scale check") end
        return false
    end

    if tool == "advdupe2" and client.AdvDupe2 and not CheckDuplicationScale(client, client.AdvDupe2.Entities) then
        if DevMode then client:ChatPrint("[DevMode] CanTool: AdvDupe2 tool failed duplication scale check") end
        return false
    end

    if tool == "adv_duplicator" and toolobj and toolobj.Entities and not CheckDuplicationScale(client, toolobj.Entities) then
        if DevMode then client:ChatPrint("[DevMode] CanTool: Adv_duplicator tool failed duplication scale check") end
        return false
    end

    if DevMode then client:ChatPrint("[DevMode] CanTool: Tool '" .. tool .. "' passed all checks for " .. client:Name()) end
    if DevMode then client:ChatPrint("[DevMode] CanTool: Exiting function") end
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
        client:notifyWarning("You must be a Super Admin to forcefully stopsound everyone!")
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