function ENT:computeDescMarkup(description)
    if self.desc ~= description then
        self.desc = description
        self.markup = lia.markup.parse("<font=liaItemDescFont>" .. description .. "</font>", ScrW() * 0.5)
    end
    return self.markup
end

function ENT:onDrawEntityInfo(alpha)
    if IsValid(lia.gui.itemPanel) then return end
    local item = self:getItemTable()
    if not item then return end
    local oldE, oldD = item.entity, item.data
    item.entity, item.data = self, self:getNetVar("data") or oldD
    local name = L(item.getName and item:getName() or item.name)
    lia.util.drawEntText(self, name, 0, alpha)
    item.data, item.entity = oldD, oldE
end

function ENT:DrawTranslucent()
    local itemTable = self:getItemTable()
    if itemTable and itemTable.drawEntity then
        itemTable:drawEntity(self)
    else
        local paintMat = itemTable and hook.Run("PaintItem", itemTable)
        if isstring(paintMat) and paintMat ~= "" then self:SetMaterial(paintMat) end
        self:DrawModel()
    end
end
