local TEXT_OFFSET = Vector(0, 0, 20)
local toScreen = FindMetaTable("Vector").ToScreen
local drawText = lia.util.drawText
local configGet = lia.config.get
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
    local pos = self:LocalToWorld(self:OBBCenter()) + TEXT_OFFSET
    local screenPos = toScreen(pos)
    drawText(self:getNetVar("name", L("vendorDefaultName")), screenPos.x, screenPos.y, ColorAlpha(configGet("Color"), alpha), 1, 1, nil, alpha * 0.65)
end
