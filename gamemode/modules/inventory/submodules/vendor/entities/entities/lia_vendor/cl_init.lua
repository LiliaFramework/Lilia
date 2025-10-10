function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    if not self.hasSetupVars then self:setupVars() end
    local curTime = CurTime()
    if (self.nextAnimCheck or 0) < curTime then
        if self:isReadyForAnim() then self:setAnim() end
        self.nextAnimCheck = curTime + 60
    end

    self:SetNextClientThink(curTime + 1)
    return true
end

function ENT:onDrawEntityInfo(alpha)
    local name = self:getNetVar("name", L("vendorDefaultName"))
    lia.util.drawEntText(self, name, 0, alpha)
end
