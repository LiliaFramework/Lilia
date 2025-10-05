function ENT:Draw()
    self:DrawModel()
end

function ENT:onDrawEntityInfo(alpha)
    local amount = self:getAmount()
    if amount <= 0 then return end
    local text = lia.currency.get(amount)
    lia.util.drawEntText(self, text, 0, alpha)
end
