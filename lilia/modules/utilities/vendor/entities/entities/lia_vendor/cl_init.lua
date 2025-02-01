function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    if not self.hasSetupVars then self:setupVars() end
    if (self.nextAnimCheck or 0) < CurTime() then
        self:setAnim()
        self.nextAnimCheck = CurTime() + 60
    end

    self:SetNextClientThink(CurTime() + 1)
    return true
end