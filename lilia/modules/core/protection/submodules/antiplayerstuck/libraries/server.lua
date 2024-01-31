---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CanCollide(ent1, ent2)
    local ShouldCollide = hook.Run("ShouldCollide", ent1, ent2)
    if ShouldCollide == nil then ShouldCollide = true end
    return ShouldCollide
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ShouldCheck(client)
    return IsValid(client) and client:IsPlayer() and client:Alive() and not client:InVehicle() and not client:IsNoClipping() and client:IsSolid()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CheckIfPlayerStuck()
    local function handleStuckPlayer(client)
        local offset = client.Stuck and Vector(2, 2, 2) or Vector(5, 5, 5)
        local stuck = false
        for _, entity in pairs(ents.FindInBox(client:GetPos() + client:OBBMins() + offset, client:GetPos() + client:OBBMaxs() - offset)) do
            if self:ShouldCheck(entity) and entity ~= client and self:CanCollide(client, entity) then
                client:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                local velocity = entity:GetForward() * 200
                client:SetVelocity(velocity)
                entity:SetVelocity(-velocity)
                stuck = true
            end
        end

        if not stuck then
            client.Stuck = false
            if client:GetCollisionGroup() ~= COLLISION_GROUP_PLAYER then
                client:SetCollisionGroup(COLLISION_GROUP_PLAYER)
                MsgC(Color(255, 155, 0), "[ANTI-STUCK] ", Color(255, 255, 255), "Changing collision group back to player for: " .. client:Nick() .. "\n")
            end
        end
    end

    timer.Create("CheckIfPlayerStuck", 5, 0, function()
        for _, client in ipairs(player.GetAll()) do
            if self:ShouldCheck(client) then handleStuckPlayer(client) end
        end
    end)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ShouldCollide(ent1, ent2)
    if table.HasValue(self.BlockedCollideEntities, ent1:GetClass()) and table.HasValue(self.BlockedCollideEntities, ent2:GetClass()) then return false end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
