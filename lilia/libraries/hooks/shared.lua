---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local GM = GM or GAMEMODE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
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
    local character = client:getChar()
    if not character then return end
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
