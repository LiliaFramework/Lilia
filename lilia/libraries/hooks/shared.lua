---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local GM = GM or GAMEMODE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:OnCharVarChanged(char, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(char, oldVar, newVar)
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:InitializedModules()
    for model, animtype in pairs(lia.anim.DefaultTposingFixer) do
        lia.anim.setModelClass(model, animtype)
    end

    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
        RunConsoleCommand("spawnmenu_reload")
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:Move(client, moveData)
    local char = client:getChar()
    if not char then return end
    if client:GetMoveType() == MOVETYPE_WALK and moveData:KeyDown(IN_WALK) then
        local mf, ms = 0, 0
        local speed = client:GetWalkSpeed()
        local ratio = lia.config.WalkRatio
        if moveData:KeyDown(IN_FORWARD) then
            mf = ratio
        elseif moveData:KeyDown(IN_BACK) then
            mf = -ratio
        end

        if moveData:KeyDown(IN_MOVELEFT) then
            ms = -ratio
        elseif moveData:KeyDown(IN_MOVERIGHT) then
            ms = ratio
        end

        moveData:SetForwardSpeed(mf * speed)
        moveData:SetSideSpeed(ms * speed)
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:VerifyModuleValidity(uniqueID, MODULE)
    local isEnabled = MODULE.enabled
    if uniqueID == "schema" then return true end
    for ModuleName, conditions in pairs(lia.module.ModuleConditions) do
        if uniqueID ~= ModuleName then continue end
        if _G[conditions.global] ~= nil then
            print(conditions.name .. " found. Activating Compatibility!")
            return true
        else
            return false
        end
    end
    return isEnabled
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:LiliaLoaded()
    local namecache = {}
    for _, MODULE in pairs(lia.module.list) do
        local authorID = (tonumber(MODULE.author) and tostring(MODULE.author)) or (string.match(MODULE.author, "STEAM_") and util.SteamIDTo64(MODULE.author)) or "Unknown"
        if authorID then
            if namecache[authorID] ~= nil then
                MODULE.author = namecache[authorID]
            else
                steamworks.RequestPlayerInfo(authorID, function(newName)
                    namecache[authorID] = newName
                    MODULE.author = newName or MODULE.author
                end)
            end
        end
    end

    lia.module.namecache = namecache
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:ModuleLoaded(uniqueID, ModuleGlobal, MODULE)
    local ModuleWorkshopContent = MODULE.WorkshopContent
    local ModuleCAMIPermissions = MODULE.CAMIPrivileges
    local IsValidForGlobal = ModuleGlobal ~= "" and ModuleGlobal ~= nil
    if ModuleCAMIPermissions and istable(ModuleCAMIPermissions) then
        for _, privilegeData in ipairs(ModuleCAMIPermissions) do
            local privilegeInfo = {
                Name = privilegeData.Name,
                MinAccess = privilegeData.MinAccess or "admin",
                Description = privilegeData.Description or ("Allows access to " .. privilegeData.Name:gsub("^%l", string.upper))
            }

            if not CAMI.GetPrivilege(privilegeData.Name) then CAMI.RegisterPrivilege(privilegeInfo) end
        end
    end

    if IsValidForGlobal and uniqueID ~= "schema" then _G[ModuleGlobal] = MODULE end
    if ModuleWorkshopContent then
        if istable(ModuleWorkshopContent) then
            for i = 1, #ModuleWorkshopContent do
                local workshopID = ModuleWorkshopContent[i]
                if isstring(workshopID) and workshopID:match("^%d+$") then
                    resource.AddWorkshop(workshopID)
                else
                    print("Invalid Workshop ID:", workshopID)
                end
            end
        else
            resource.AddWorkshop(ModuleWorkshopContent)
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:ModuleDependenciesPreLoad(uniqueID, ModuleGlobal, MODULE)
    local IsValidForGlobal = ModuleGlobal ~= "" and ModuleGlobal ~= nil
    if IsValidForGlobal and uniqueID ~= "schema" then _G[ModuleGlobal] = MODULE end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:InitPostEntity()
    if SERVER then
        lia.faction.formatModelData()
        timer.Simple(2, function() lia.entityDataLoaded = true end)
        lia.db.waitForTablesToLoad():next(function()
            hook.Run("LoadData")
            hook.Run("PostLoadData")
        end)
    else
        lia.joinTime = RealTime() - 0.9716
        if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
        for command, value in pairs(lia.config.StartupConsoleCommands) do
            local client_command = command .. " " .. value
            if concommand.GetTable()[command] ~= nil then
                LocalPlayer():ConCommand(client_command)
                print(string.format("Executed console command on client: %s", client_command))
            end
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CanDrive(client)
    if not client:IsSuperAdmin() then return false end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerSpray(_)
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerDeathSound()
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CanPlayerSuicide(_)
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:AllowPlayerPickup(_, _)
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerShouldTakeDamage(client, _)
    return client:getChar() ~= nil
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
