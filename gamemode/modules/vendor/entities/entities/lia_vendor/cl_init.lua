function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    if not self.hasSetupVars then self:setupVars() end
    local curTime = CurTime()
    local currentAnim = self:getNetVar("animation", "")
    if (self.lastAnimationCheck or "") ~= currentAnim and currentAnim ~= "" then
        self.lastAnimationCheck = currentAnim
        if self:isReadyForAnim() then self:setAnim() end
    end

    if (self.nextAnimCheck or 0) < curTime then
        if self:isReadyForAnim() then self:setAnim() end
        self.nextAnimCheck = curTime + 5
    end

    self:SetNextClientThink(curTime + 0.5)
    return true
end

function ENT:onDrawEntityInfo(alpha)
    local name = self:getNetVar("name", L("vendorDefaultName"))
    lia.util.drawEntText(self, name, 0, alpha)
end
