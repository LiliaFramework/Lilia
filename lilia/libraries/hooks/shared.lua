local GM = GM or GAMEMODE
function GM:OnCharVarChanged(char, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(char, oldVar, newVar)
        end
    end
end

function GM:InitializedModules()
    for _, model in pairs(lia.config.PlayerModelTposingFixer) do
        lia.anim.setModelClass(model, "player")
    end

    for tpose, animtype in pairs(lia.anim.DefaultTposingFixer) do
        lia.anim.setModelClass(tpose, animtype)
    end

    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
        RunConsoleCommand("spawnmenu_reload")
    end
end

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

function GM:CanDrive(client)
    if not client:IsSuperAdmin() then return false end
end

function GM:PlayerSpray(_)
    return true
end

function GM:PlayerDeathSound()
    return true
end

function GM:CanPlayerSuicide(_)
    return false
end

function GM:AllowPlayerPickup(_, _)
    return false
end

function GM:PlayerShouldTakeDamage(client, _)
    return client:getChar() ~= nil
end
