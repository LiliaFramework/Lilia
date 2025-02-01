local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta.ToScreen
function ENT:createBubble()
    self.bubble = ClientsideModel("models/extras/info_speech.mdl", RENDERGROUP_OPAQUE)
    self.bubble:SetPos(self:GetPos() + Vector(0, 0, 84))
    self.bubble:SetModelScale(0.6, 0)
end

function ENT:Draw()
    local bubble = self.bubble
    if IsValid(bubble) then
        local realTime = RealTime()
        local bounce = Vector(0, 0, 84 + math.sin(realTime * 3) * 0.05)
        bubble:SetRenderOrigin(self:GetPos() + bounce)
        bubble:SetRenderAngles(Angle(0, realTime * 100, 0))
    end

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

function ENT:OnRemove()
    if IsValid(self.bubble) then self.bubble:Remove() end
end