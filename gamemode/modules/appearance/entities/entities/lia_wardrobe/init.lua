function ENT:Initialize()
    self:SetModel(lia.config.get("ModelTweakerModel"))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:DrawShadow(true)
    local physicsObject = self:GetPhysicsObject()
    if IsValid(physicsObject) then
        physicsObject:EnableMotion(false)
        physicsObject:Sleep()
    end
end

function ENT:Use(client)
    if not IsValid(client) or not client:IsPlayer() or not client:getChar() then return end
    self:AddUser(client)
    lia.appearance.openMenu(client, client, true)
end
