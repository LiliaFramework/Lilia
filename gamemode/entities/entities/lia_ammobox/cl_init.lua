function ENT:Draw()
    self:DrawModel()
end

function ENT:onDrawEntityInfo(alpha)
    lia.util.drawEntText(self, "Ammo Box", 0, alpha)
    lia.util.drawEntText(self, "Refills your active weapon", 40, alpha)
end
