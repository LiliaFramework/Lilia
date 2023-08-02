function MODULE:InitPostEntity()
    if not lia.config.CentsCompatibility then return end
    local ENT = scripted_ents.GetStored("lia_money").t
    local toScreen = FindMetaTable("Vector").ToScreen
    local colorAlpha = ColorAlpha
    local drawText = lia.util.drawText

    function ENT:onDrawEntityInfo(alpha)
        local position = toScreen(self:LocalToWorld(self:OBBCenter()))
        local x, y = position.x, position.y
        drawText(lia.currency.get(self:getAmount() / 1), x, y, colorAlpha(lia.config.Color), 1, 1, nil, alpha * 0.65)
    end

    local charMT = lia.meta.character

    function charMT:getMoney()
        return self.vars.money / 1
    end
end