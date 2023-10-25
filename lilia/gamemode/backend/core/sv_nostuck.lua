--------------------------------------------------------------------------------------------------------------------------
local GM = GM
--------------------------------------------------------------------------------------------------------------------------
function GM:CanCollide(ent1, ent2)
    local ShouldCollide = hook.Run("ShouldCollide", ent1, ent2)
    if ShouldCollide == nil then
        ShouldCollide = true
    end

    return ShouldCollide
end

--------------------------------------------------------------------------------------------------------------------------
function GM:ShouldCheck(ply)
    return IsValid(ply) and ply:IsPlayer() and ply:Alive() and not ply:InVehicle() and not ply:IsNoClipping() and ply:IsSolid()
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CheckIfPlayerStuck()
    for _, ply in ipairs(player.GetAll()) do
        if self:ShouldCheck(ply) then
            local Offset = Vector(5, 5, 5)
            local Stuck = false
            if ply.Stuck then
                Offset = Vector(2, 2, 2)
            end

            for _, ent in pairs(ents.FindInBox(ply:GetPos() + ply:OBBMins() + Offset, ply:GetPos() + ply:OBBMaxs() - Offset)) do
                if self:ShouldCheck(ent) and ent ~= ply and self:CanCollide(ply, ent) then
                    ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                    local velocity = ent:GetForward() * 200
                    ply:SetVelocity(velocity)
                    ent:SetVelocity(-velocity)
                    Stuck = true
                end
            end

            if not Stuck then
                ply.Stuck = false
                if ply:GetCollisionGroup() ~= COLLISION_GROUP_PLAYER then
                    ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
                    MsgC(Color(255, 155, 0), "[ANTI-STUCK] ", Color(255, 255, 255), "Changing collision group back to player for: " .. ply:Nick())
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:ShouldCollide(ent1, ent2)
    if table.HasValue(lia.config.BlockedCollideEntities, ent1:GetClass()) and table.HasValue(lia.config.BlockedCollideEntities, ent2:GetClass()) then return false end
end

--------------------------------------------------------------------------------------------------------------------------
timer.Create(
    "CheckIfPlayerStuck",
    4,
    0,
    function()
        GM:CheckIfPlayerStuck()
    end
)
--------------------------------------------------------------------------------------------------------------------------