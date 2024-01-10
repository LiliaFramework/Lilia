
local GM = GM or GAMEMODE

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


function GM:LiliaLoaded()
    local namecache = {}
    for _, MODULE in pairs(lia.module.list) do
        local authorID = (tonumber(MODULE.author) and tostring(MODULE.author)) or (string.match(MODULE.author, "STEAM_") and util.SteamIDTo64(MODULE.author)) or nil
        if authorID then
            if namecache[authorID] ~= nil then
                MODULE.author = namecache[authorID]
            else
                steamworks.RequestPlayerInfo(
                    authorID,
                    function(newName)
                        namecache[authorID] = newName
                        MODULE.author = newName or MODULE.author
                    end
                )
            end
        end
    end

    lia.module.namecache = namecache
end


function GM:ModuleLoaded(uniqueID, ModuleGlobal, MODULE)
    local ModuleWorkshopContent = MODULE.WorkshopContent
    local ModuleCAMIPermissions = MODULE.CAMIPrivileges
    local IsValidForGlobal = ModuleGlobal ~= "" and ModuleGlobal ~= nil
    if ModuleCAMIPermissions then
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


function GM:ModuleDependenciesPreLoad(uniqueID, ModuleGlobal, MODULE)
    local IsValidForGlobal = ModuleGlobal ~= "" and ModuleGlobal ~= nil
    if IsValidForGlobal and uniqueID ~= "schema" then _G[ModuleGlobal] = MODULE end
end

