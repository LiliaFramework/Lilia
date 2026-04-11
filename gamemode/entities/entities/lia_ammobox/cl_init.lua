function ENT:Draw()
    self:DrawModel()
end

function ENT:onDrawEntityInfo(alpha)
    lia.util.drawEntText(self, L("liaAmmoBoxName"), 0, alpha)
    lia.util.drawEntText(self, L("liaAmmoBoxDesc"), 40, alpha)
end
