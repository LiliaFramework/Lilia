
local GM = GM or GAMEMODE

function GM:OnCharVarChanged(char, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(char, oldVar, newVar)
        end
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
        self:ServerInitPostEntity()
    else
        self:ClientInitPostEntity()
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

