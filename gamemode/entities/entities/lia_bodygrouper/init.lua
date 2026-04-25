function ENT:Initialize()
    self:SetModel(lia.config.get("BodyGrouperModel"))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
end

function ENT:Use(activator)
    if activator:IsPlayer() then
        net.Start("BodygrouperMenu")
        net.Send(activator)
        self:AddUser(activator)
    end
end
